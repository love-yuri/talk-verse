import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../utils/date_utils.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/warm_background.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession session;
  const ChatScreen({super.key, required this.session});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      Message(id: '1', content: widget.session.characterName == '小助手' ? '你好！我是你的智能助手，有什么可以帮你的吗？' : '你好！很高兴认识你！', type: MessageType.ai, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      Message(id: '2', content: '你好！', type: MessageType.user, timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
      Message(id: '3', content: '很高兴见到你！今天想聊些什么呢？', type: MessageType.ai, timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
    ]);
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
    final colorIdx = widget.session.characterId.hashCode.abs() % AppColors.avatarColors.length;
    final color = AppColors.avatarColors[colorIdx];

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(children: [
          TapScale(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(widget.session.characterAvatar, style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.session.characterName, style: AppTextStyles.label.copyWith(fontSize: 14)),
              Text(_isTyping ? '正在输入...' : '在线', style: AppTextStyles.labelSmall.copyWith(color: _isTyping ? AppColors.accent : AppColors.success, fontSize: 10)),
            ],
          ),
          const Spacer(),
          TapScale(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.more_vert, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      child: Text(AppDateUtils.formatChatTime(t), style: AppTextStyles.chatTime),
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ChatInput(controller: _msgCtrl, onSend: _send, onTextChanged: (_) {}),
    );
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(id: DateTime.now().millisecondsSinceEpoch.toString(), content: text, type: MessageType.user, timestamp: DateTime.now()));
      _msgCtrl.clear();
    });
    _scrollToBottom();
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(id: DateTime.now().millisecondsSinceEpoch.toString(), content: _aiReply(), type: MessageType.ai, timestamp: DateTime.now()));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _aiReply() {
    const r = ['我明白了，让我想想...', '这是个好问题！', '我理解你的意思。', '让我来帮你分析一下。', '你说得对。', '这是一个有趣的角度。'];
    return r[DateTime.now().millisecond % r.length];
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
