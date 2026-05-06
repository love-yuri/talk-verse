import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/message.dart';
import '../utils/date_utils.dart';

/// 聊天气泡组件
/// 支持用户消息和AI消息的显示
class ChatBubble extends StatelessWidget {
  final Message message;
  final String characterAvatar;
  final String characterName;

  const ChatBubble({
    super.key,
    required this.message,
    required this.characterAvatar,
    required this.characterName,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: AppDimensions.spacingSm),
          Flexible(child: _buildBubble(isUser)),
          if (isUser) const SizedBox(width: AppDimensions.spacingSm),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    final isUser = message.type == MessageType.user;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primaryLight.withOpacity(0.1)
            : AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Center(
        child: isUser
            ? const Icon(
                Icons.person,
                size: 20,
                color: AppColors.primary,
              )
            : Text(
                characterAvatar,
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  /// 构建气泡
  Widget _buildBubble(bool isUser) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: AppDimensions.bubbleMaxWidth,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.bubbleUser : AppColors.bubbleAI,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimensions.radiusMd),
          topRight: const Radius.circular(AppDimensions.radiusMd),
          bottomLeft: Radius.circular(isUser ? AppDimensions.radiusMd : AppDimensions.radiusXs),
          bottomRight: Radius.circular(isUser ? AppDimensions.radiusXs : AppDimensions.radiusMd),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimensions.radiusMd),
          topRight: const Radius.circular(AppDimensions.radiusMd),
          bottomLeft: Radius.circular(isUser ? AppDimensions.radiusMd : AppDimensions.radiusXs),
          bottomRight: Radius.circular(isUser ? AppDimensions.radiusXs : AppDimensions.radiusMd),
        ),
        child: _buildBubbleContent(isUser),
      ),
    );
  }

  /// 构建气泡内容
  Widget _buildBubbleContent(bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildSenderName(),
          _buildMessageText(isUser),
          const SizedBox(height: AppDimensions.spacingXs),
          _buildTimestamp(isUser),
        ],
      ),
    );
  }

  /// 构建发送者名称
  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
      child: Text(
        characterName,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// 构建消息文本
  Widget _buildMessageText(bool isUser) {
    return Text(
      message.content,
      style: AppTextStyles.chatMessage.copyWith(
        color: isUser ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  /// 构建时间戳
  Widget _buildTimestamp(bool isUser) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        AppDateUtils.formatTime(message.timestamp),
        style: AppTextStyles.chatTime.copyWith(
          color: isUser ? Colors.white70 : AppColors.textTertiary,
        ),
      ),
    );
  }
}
