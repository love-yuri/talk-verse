import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../utils/date_utils.dart';
import 'chat_screen.dart';

/// 聊天列表屏幕
/// 显示所有聊天会话列表
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // 临时数据，后续会从状态管理获取
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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        '聊天',
        style: AppTextStyles.h3,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          onPressed: () {
            // TODO: 实现搜索功能
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.textSecondary),
          onPressed: () {
            // TODO: 实现新建聊天功能
          },
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    if (_sessions.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSessionList();
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            '还没有聊天记录',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            '点击右上角开始新对话',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 构建会话列表
  Widget _buildSessionList() {
    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionItem(session);
      },
    );
  }

  /// 构建会话项
  Widget _buildSessionItem(ChatSession session) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.paddingLg),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteSession(session);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight,
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLg,
            vertical: AppDimensions.paddingSm,
          ),
          leading: _buildAvatar(session),
          title: _buildTitle(session),
          subtitle: _buildSubtitle(session),
          trailing: _buildTrailing(session),
          onTap: () => _openChat(session),
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(ChatSession session) {
    return Container(
      width: AppDimensions.avatarLg,
      height: AppDimensions.avatarLg,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Center(
        child: Text(
          session.characterAvatar,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle(ChatSession session) {
    return Row(
      children: [
        Expanded(
          child: Text(
            session.characterName,
            style: AppTextStyles.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (session.unreadCount > 0) ...[
          const SizedBox(width: AppDimensions.spacingSm),
          _buildUnreadBadge(session.unreadCount),
        ],
      ],
    );
  }

  /// 构建未读消息徽章
  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建副标题
  Widget _buildSubtitle(ChatSession session) {
    final lastMessage = session.lastMessage;
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
      child: Text(
        lastMessage?.content ?? '开始对话...',
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 构建尾部
  Widget _buildTrailing(ChatSession session) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppDateUtils.formatChatTime(session.updatedAt),
          style: AppTextStyles.chatTime,
        ),
      ],
    );
  }

  /// 删除会话
  void _deleteSession(ChatSession session) {
    setState(() {
      _sessions.remove(session);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除与${session.characterName}的对话'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() {
              _sessions.add(session);
            });
          },
        ),
      ),
    );
  }

  /// 打开聊天
  void _openChat(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(session: session),
      ),
    );
  }
}
