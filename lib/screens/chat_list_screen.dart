import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';
import '../utils/date_utils.dart';
import '../widgets/glass_header.dart';
import '../widgets/warm_background.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _storage = ChatStorageService();
  List<ChatSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _storage.load();
    if (mounted) setState(() => _sessions = sessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _sessions.isEmpty ? _buildEmpty() : _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassHeader(
      subtitle: _getGreeting(),
      title: '对话',
      badge: '${_sessions.length}',
      actions: [
        GlassHeader.iconBtn(Icons.search_rounded, onTap: () {}),
        const SizedBox(width: 8),
        GlassHeader.iconBtn(Icons.edit_square, onTap: () {}),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌸', style: TextStyle(fontFamily: 'MapleMono', fontSize: 48)),
          const SizedBox(height: 16),
          const Text('还没有对话', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B), letterSpacing: -0.41)),
          const SizedBox(height: 6),
          Text('去发现页面，找到你的第一个聊天伙伴', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey[400], letterSpacing: -0.08)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      itemCount: _sessions.length,
      itemBuilder: (context, i) => _buildItem(_sessions[i]),
    );
  }

  Widget _buildItem(ChatSession session) {
    final colorIdx = session.characterId.hashCode.abs() % AppColors.avatarColors.length;
    final color = AppColors.avatarColors[colorIdx];

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => _deleteSession(session),
      child: TapScale(
        onTap: () => _openChat(session),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${session.id}',
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                      ),
                    ),
                    child: Image.asset(
                      session.characterAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 26, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(session.characterName, style: AppTextStyles.label)),
                      Text(AppDateUtils.formatChatTime(session.updatedAt), style: AppTextStyles.labelSmall),
                    ]),
                    const SizedBox(height: 4),
                    Text('点击继续对话 ♡', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了';
    if (h < 12) return '早上好';
    if (h < 14) return '中午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  void _deleteSession(ChatSession session) {
    setState(() => _sessions.remove(session));
    _storage.deleteSession(session.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已删除与${session.characterName}的对话'),
      action: SnackBarAction(label: '撤销', onPressed: () {
        setState(() => _sessions.add(session));
        _storage.saveSession(session);
      }),
    ));
  }

  Future<void> _openChat(ChatSession session) async {
    await Navigator.push(context, _chatRoute(session));
    _loadSessions();
  }
}

Route _chatRoute(ChatSession session) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(session: session, heroTag: 'avatar_${session.id}'),
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
