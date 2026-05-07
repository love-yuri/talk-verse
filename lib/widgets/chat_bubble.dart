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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(characterAvatar),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _bubble(isUser),
                const SizedBox(height: 3),
                Text(AppDateUtils.formatTime(message.timestamp), style: AppTextStyles.chatTime),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar('🎀'),
        ],
      ),
    );
  }

  Widget _avatar(String emoji) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8B4F8), Color(0xFFB4D0F8)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _bubble(bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: EdgeInsets.only(left: isUser ? 0 : 4, right: isUser ? 4 : 0),
      decoration: BoxDecoration(
        color: isUser ? AppColors.bubbleUser : AppColors.bubbleAI,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? const Color(0xFFD4BBFF).withValues(alpha: 0.3)
                : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: isUser ? AppTextStyles.chatMessageUser : AppTextStyles.chatMessage,
      ),
    );
  }
}
