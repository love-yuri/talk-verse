import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/message.dart';
import '../utils/date_utils.dart';

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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(characterAvatar, AppColors.avatarColors[0]),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: _bubble(isUser)),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar('👤', AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _avatar(String emoji, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15))),
    );
  }

  Widget _bubble(bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: isUser ? AppColors.bubbleUser : AppColors.bubbleAI,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isUser ? 14 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 14),
        ),
        border: isUser ? null : Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(characterName, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
              ),
            Text(message.content, style: isUser ? AppTextStyles.chatMessageWhite : AppTextStyles.chatMessage),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(AppDateUtils.formatTime(message.timestamp), style: AppTextStyles.chatTime.copyWith(color: isUser ? Colors.white70 : AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}
