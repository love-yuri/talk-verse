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
              child: Center(child: Text(widget.session.characterAvatar, style: const TextStyle(fontSize: 19))),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.session.characterName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Text(
                _isTyping ? '正在输入...' : '在线 ♡',
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
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
        child: Text(AppDateUtils.formatChatTime(t), style: AppTextStyles.chatTime.copyWith(color: const Color(0xFF9B7BB8))),
      ),
    );
  }

  Widget _buildInput() {
    return ChatInput(controller: _msgCtrl, onSend: _send, onTextChanged: (_) {});
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
