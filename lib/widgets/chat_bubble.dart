import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/message.dart';
import '../utils/date_utils.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final String characterAvatar;
  final String characterName;
  final bool isLast;
  final bool isMenuActive;
  final VoidCallback? onLongPress;
  final ValueChanged<String>? onEditConfirm;
  final VoidCallback? onResend;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.characterAvatar,
    required this.characterName,
    this.isLast = false,
    this.isMenuActive = false,
    this.onLongPress,
    this.onEditConfirm,
    this.onResend,
    this.onDelete,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isEditing = false;
  late TextEditingController _editCtrl;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == MessageType.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(widget.characterAvatar),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _bubbleWithStatus(isUser),
                  const SizedBox(height: 3),
                  Text(
                    AppDateUtils.formatTime(widget.message.timestamp),
                    style: AppTextStyles.chatTime,
                  ),
                  if (widget.isMenuActive && !_isEditing) _buildInlineMenu(isUser),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar('assets/images/default_avatar.png'),
        ],
      ),
    );
  }

  /// 内联操作菜单
  Widget _buildInlineMenu(bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuBtn(Icons.edit, '编辑', () {
            setState(() => _isEditing = true);
          }),
          if (widget.isLast)
            _menuBtn(Icons.refresh, '重发', () {
              widget.onResend?.call();
            }),
          _menuBtn(Icons.copy, '复制', () {
            Clipboard.setData(ClipboardData(text: widget.message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制'), duration: Duration(seconds: 1)),
            );
          }),
          _menuBtn(Icons.delete_outline, '删除', () {
            widget.onDelete?.call();
          }),
        ],
      ),
    );
  }

  Widget _menuBtn(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF9B7BB8)),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9B7BB8))),
            ],
          ),
        ),
      ),
    );
  }

  /// 带状态指示器的气泡
  Widget _bubbleWithStatus(bool isUser) {
    if (widget.message.type == MessageType.typing) {
      return widget.message.content.isEmpty ? _typingBubble() : _bubble(isUser);
    }

    // 编辑模式
    if (_isEditing) return _editingBubble(isUser);

    final bubble = _bubble(isUser);

    if (!isUser) return bubble;

    // 用户消息：在气泡左侧显示状态
    Widget statusIcon;
    switch (widget.message.status) {
      case MessageStatus.sending:
        statusIcon = const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textTertiary),
        );
        break;
      case MessageStatus.failed:
        // 显示重试图标，点击直接重试
        statusIcon = GestureDetector(
          onTap: widget.onResend,
          child: const Icon(Icons.refresh, size: 18, color: AppColors.error),
        );
        break;
      case MessageStatus.sent:
        return bubble;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [statusIcon, const SizedBox(width: 4), bubble],
    );
  }

  /// 编辑中的气泡
  Widget _editingBubble(bool isUser) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 2 / 3),
      margin: EdgeInsets.only(left: isUser ? 0 : 4, right: isUser ? 4 : 0),
      decoration: BoxDecoration(
        color: isUser ? AppColors.bubbleUser : AppColors.bubbleAI,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9B7BB8), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _editCtrl,
            maxLines: null,
            style: isUser ? AppTextStyles.chatMessageUser : AppTextStyles.chatMessage,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            autofocus: true,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _editActionBtn('取消', () {
                  setState(() {
                    _isEditing = false;
                    _editCtrl.text = widget.message.content;
                  });
                }),
                _editActionBtn('确认', () {
                  final newContent = _editCtrl.text.trim();
                  if (newContent.isNotEmpty && newContent != widget.message.content) {
                    widget.onEditConfirm?.call(newContent);
                  }
                  setState(() => _isEditing = false);
                }, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editActionBtn(String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
            color: isPrimary ? const Color(0xFF9B7BB8) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _avatar(String avatarPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8B4F8), Color(0xFFB4D0F8)],
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.asset(
            avatarPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _bubble(bool isUser) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 2 / 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: isUser
          ? Text(widget.message.content, style: AppTextStyles.chatMessageUser)
          : _buildRichContent(widget.message.content),
    );
  }

  /// 解析AI消息中的""引号内容并高亮显示
  Widget _buildRichContent(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp('“(.*?)”');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: '“${match.group(1)!}”',
        style: const TextStyle(
          color: Color(0xFF9C27B0),
          fontWeight: FontWeight.w600,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.chatMessage,
        children: spans,
      ),
    );
  }

  /// 正在输入的动画气泡
  Widget _typingBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: AppColors.bubbleAI,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _TypingDot(delay: Duration(milliseconds: i * 200)),
          ),
        ),
      ),
    );
  }
}

/// 跳动圆点动画组件
class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
