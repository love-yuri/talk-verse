import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/chat_session.dart';
import '../utils/date_utils.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatSession> _sessions = [
    ChatSession(
      id: '1',
      characterId: 'ai_1',
      characterName: '小助手',
      characterAvatar: '🤖',
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatSession(
      id: '2',
      characterId: 'ai_2',
      characterName: '诗人',
      characterAvatar: '📝',
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ChatSession(
      id: '3',
      characterId: 'ai_3',
      characterName: '朋友',
      characterAvatar: '😊',
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _sessions.isEmpty ? _buildEmptyState() : _buildSessionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '对话',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderAction(Icons.search_rounded, () {}),
              const SizedBox(width: 8),
              _buildHeaderAction(Icons.edit_square, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '还没有对话',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去角色页面，开始你的第一次对话吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        return _buildSessionItem(_sessions[index]);
      },
    );
  }

  Widget _buildSessionItem(ChatSession session) {
    final gradientIndex = session.characterId.hashCode.abs() % AppColors.avatarGradients.length;
    final gradient = AppColors.avatarGradients[gradientIndex];

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => _deleteSession(session),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(session),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient.map((c) => c.withValues(alpha: 0.15)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(session.characterAvatar, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.characterName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            AppDateUtils.formatChatTime(session.updatedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.lastMessage?.content ?? '点击开始对话...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (session.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                session.unreadCount > 99 ? '99+' : '${session.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  void _deleteSession(ChatSession session) {
    setState(() => _sessions.remove(session));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除与${session.characterName}的对话'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () => setState(() => _sessions.add(session)),
        ),
      ),
    );
  }

  void _openChat(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(session: session)),
    );
  }
}
