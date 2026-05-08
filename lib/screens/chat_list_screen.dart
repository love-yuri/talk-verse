import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../utils/date_utils.dart';
import '../widgets/warm_background.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatSession> _sessions = [
    ChatSession(id: '1', characterId: 'ai_1', characterName: '小助手', characterAvatar: '🤖', messages: [], createdAt: DateTime.now().subtract(const Duration(hours: 2)), updatedAt: DateTime.now().subtract(const Duration(minutes: 5))),
    ChatSession(id: '2', characterId: 'ai_2', characterName: '诗人', characterAvatar: '📝', messages: [], createdAt: DateTime.now().subtract(const Duration(days: 1)), updatedAt: DateTime.now().subtract(const Duration(hours: 3))),
    ChatSession(id: '3', characterId: 'ai_3', characterName: '朋友', characterAvatar: '😊', messages: [], createdAt: DateTime.now().subtract(const Duration(days: 3)), updatedAt: DateTime.now().subtract(const Duration(days: 1))),
  ];

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
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8B4F8), Color(0xFFB4D0F8), Color(0xFFF8C8E8)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_getGreeting()} ✨', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70, letterSpacing: -0.08)),
                const SizedBox(height: 2),
                const Text('💬 对话', style: TextStyle(fontFamily: 'MapleMono', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.35)),
              ],
            ),
            const Spacer(),
            _headerIconBtn(Icons.search_rounded),
            const SizedBox(width: 8),
            _headerIconBtn(Icons.edit_square),
          ],
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon) {
    return TapScale(
      onTap: () {},
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
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
                tag: 'avatar_${session.characterId}',
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(session.characterAvatar, style: const TextStyle(fontSize: 24))),
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
                    Row(children: [
                      Expanded(child: Text(session.lastMessage?.content ?? '点击开始对话 ♡', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (session.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFB6D9), Color(0xFFD4BBFF)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(session.unreadCount > 99 ? '99+' : '${session.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ]),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('已删除与${session.characterName}的对话'),
      action: SnackBarAction(label: '撤销', onPressed: () => setState(() => _sessions.add(session))),
    ));
  }

  void _openChat(ChatSession session) {
    Navigator.push(context, _chatRoute(session));
  }
}

Route _chatRoute(ChatSession session) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(session: session),
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
