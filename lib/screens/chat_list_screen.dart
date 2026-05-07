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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _sessions.isEmpty ? _buildEmpty() : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: AppTextStyles.greeting),
              const SizedBox(height: 2),
              const Text('对话', style: AppTextStyles.h1),
            ],
          ),
          const Spacer(),
          _iconBtn(Icons.search_rounded, () {}),
          const SizedBox(width: 8),
          _iconBtn(Icons.edit_square, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 28, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          const Text('还没有对话', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text('去发现页面，找到你的第一个聊天伙伴', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => _deleteSession(session),
      child: TapScale(
        onTap: () => _openChat(session),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                child: Center(child: Text(session.characterAvatar, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(session.characterName, style: AppTextStyles.label, overflow: TextOverflow.ellipsis)),
                      Text(AppDateUtils.formatChatTime(session.updatedAt), style: AppTextStyles.labelSmall),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(child: Text(session.lastMessage?.content ?? '点击开始对话...', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (session.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(session: session)));
  }
}
