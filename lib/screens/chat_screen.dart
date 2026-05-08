import 'package:flutter/material.dart';
import '../ai_modules/ai_provider.dart';
import '../ai_modules/anthropic/anthropic_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/character.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../services/settings_service.dart';
import '../utils/date_utils.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/warm_background.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession session;
  final Character? character;
  const ChatScreen({super.key, required this.session, this.character});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _settingsService = SettingsService();
  final List<Message> _messages = [];
  AiProvider? _aiProvider;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initProvider();
    // 使用角色的问候语作为首条消息
    final greeting = widget.character?.greeting ?? '你好！很高兴认识你！';
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: greeting,
      type: MessageType.ai,
      timestamp: DateTime.now(),
    ));
  }

  /// 加载 AI 设置并初始化 Provider
  Future<void> _initProvider() async {
    final settings = await _settingsService.load();
    if (!mounted) return;
    if (settings.isConfigured) {
      setState(() => _aiProvider = AnthropicProvider(settings));
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildAppBar(),
        Expanded(child: _buildMessages()),
        _buildInput(),
      ]),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.chatAppBarStart, AppColors.chatAppBarMid, AppColors.chatAppBarEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          TapScale(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Hero(
            tag: 'avatar_${widget.session.characterId}',
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(widget.session.characterAvatar, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 19))),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.session.characterName,
                style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.24),
              ),
              Text(
                _isTyping ? '正在输入...' : '在线 ♡',
                style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.07),
              ),
            ],
          ),
          const Spacer(),
          TapScale(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final showTime = i == 0 || _messages[i].timestamp.difference(_messages[i - 1].timestamp).inMinutes > 5;
        return Column(children: [
          if (showTime) _timeDivider(_messages[i].timestamp),
          ChatBubble(message: _messages[i], characterAvatar: widget.session.characterAvatar, characterName: widget.session.characterName),
        ]);
      },
    );
  }

  Widget _timeDivider(DateTime t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE8D8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppDateUtils.formatChatTime(t),
          style: AppTextStyles.chatTime.copyWith(color: const Color(0xFF9B7BB8)),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return ChatInput(controller: _msgCtrl, onSend: _send, onTextChanged: (_) {});
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isTyping) return;

    // 添加用户消息
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        type: MessageType.user,
        timestamp: DateTime.now(),
      ));
      _msgCtrl.clear();
    });
    _scrollToBottom();

    // 检查 API 是否已配置
    if (_aiProvider == null) {
      _showConfigDialog();
      return;
    }

    setState(() => _isTyping = true);

    // 先显示打字动画，等第一个片段到达后转为 AI 消息
    final aiMsgId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.add(Message(
        id: aiMsgId,
        content: '',
        type: MessageType.typing,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    try {
      final systemPrompt = _buildSystemPrompt();
      final history = _messages
          .where((m) => m.type == MessageType.user || m.type == MessageType.ai)
          .toList();

      bool isFirstChunk = true;
      final buffer = StringBuffer();
      await for (final chunk in _aiProvider!.sendMessageStream(
        history,
        systemPrompt: systemPrompt,
      )) {
        if (!mounted) return;
        buffer.write(chunk);
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == aiMsgId);
          if (idx != -1) {
            _messages[idx] = Message(
              id: aiMsgId,
              content: buffer.toString(),
              type: MessageType.ai,
              timestamp: _messages[idx].timestamp,
            );
          }
        });
        if (isFirstChunk) {
          isFirstChunk = false;
          _scrollToBottom();
        }
      }

      if (!mounted) return;
      setState(() => _isTyping = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == aiMsgId);
        _isTyping = false;
      });
      _showError('发送失败: $e');
      _scrollToBottom();
    }
  }

  /// 构建系统提示词
  String? _buildSystemPrompt() {
    final character = widget.character;
    if (character == null) return null;
    return '你是${character.name}。'
        '性格特点: ${character.personality}。'
        '角色描述: ${character.description}。'
        '请始终保持这个角色的身份和说话风格与用户对话。';
  }

  /// 显示 API 未配置的对话框
  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('未配置 API Key'),
        content: const Text('请先在设置中配置 API Key 才能使用 AI 对话功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示错误提示
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
