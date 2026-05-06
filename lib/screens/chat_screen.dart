import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../utils/date_utils.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

/// 聊天屏幕
/// 实现完整的聊天界面，包含消息列表和输入框
class ChatScreen extends StatefulWidget {
  final ChatSession session;

  const ChatScreen({super.key, required this.session});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载消息
  void _loadMessages() {
    // 临时添加一些示例消息
    _messages.addAll([
      Message(
        id: '1',
        content: widget.session.characterName == '小助手'
            ? '你好！我是你的智能助手，有什么可以帮你的吗？'
            : '你好！很高兴认识你！',
        type: MessageType.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        id: '2',
        content: '你好！',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      Message(
        id: '3',
        content: '很高兴见到你！今天想聊些什么呢？',
        type: MessageType.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 构建应用栏（带毛玻璃效果）
  Widget _buildAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          decoration: BoxDecoration(
            color: AppColors.glass,
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
          ),
          child: _buildAppBarContent(),
        ),
      ),
    );
  }

  /// 构建应用栏内容
  Widget _buildAppBarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: AppDimensions.spacingMd),
          _buildCharacterInfo(),
          const Spacer(),
          _buildMoreButton(),
        ],
      ),
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 构建角色信息
  Widget _buildCharacterInfo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Center(
            child: Text(
              widget.session.characterAvatar,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.characterName,
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 2),
            Text(
              _isTyping ? '正在输入...' : '在线',
              style: AppTextStyles.bodySmall.copyWith(
                color: _isTyping ? AppColors.primary : AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建更多按钮
  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () {
        // TODO: 显示更多选项
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLg,
        vertical: AppDimensions.paddingMd,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageItem(message, index);
      },
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(Message message, int index) {
    // 检查是否需要显示时间
    final showTime = _shouldShowTime(index);
    return Column(
      children: [
        if (showTime) _buildTimeDivider(message.timestamp),
        ChatBubble(
          message: message,
          characterAvatar: widget.session.characterAvatar,
          characterName: widget.session.characterName,
        ),
      ],
    );
  }

  /// 检查是否需要显示时间
  bool _shouldShowTime(int index) {
    if (index == 0) return true;
    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    final difference = currentMessage.timestamp.difference(previousMessage.timestamp);
    return difference.inMinutes > 5;
  }

  /// 构建时间分隔线
  Widget _buildTimeDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMd),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.borderLight)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
            child: Text(
              AppDateUtils.formatChatTime(timestamp),
              style: AppTextStyles.chatTime,
            ),
          ),
          const Expanded(child: Divider(color: AppColors.borderLight)),
        ],
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glass,
            border: Border(
              top: BorderSide(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
          ),
          child: ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onTextChanged: (text) {
              // TODO: 处理文本变化
            },
          ),
        ),
      ),
    );
  }

  /// 发送消息
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();
    _simulateAIResponse();
  }

  /// 模拟AI响应
  void _simulateAIResponse() {
    setState(() {
      _isTyping = true;
    });

    // 模拟延迟
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final response = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _generateAIResponse(),
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(response);
        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  /// 生成AI响应（临时实现）
  String _generateAIResponse() {
    final responses = [
      '我明白了，让我想想...',
      '这是个好问题！',
      '我理解你的意思。',
      '让我来帮你分析一下。',
      '你说得对，我们可以继续探讨这个话题。',
      '我同意你的观点。',
      '这是一个有趣的角度。',
      '让我为你提供更多信息。',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
