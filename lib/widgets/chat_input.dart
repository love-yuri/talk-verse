import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// 聊天输入组件
/// 包含文本输入框和发送按钮
class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onTextChanged;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onTextChanged,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  /// 文本变化监听
  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onTextChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingLg,
        right: AppDimensions.paddingLg,
        top: AppDimensions.paddingMd,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.paddingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildInputField(),
          const SizedBox(width: AppDimensions.spacingMd),
          _buildSendButton(),
        ],
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputField() {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.inputHeight,
          maxHeight: 120,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildEmojiButton(),
            Expanded(child: _buildTextField()),
            _buildAttachButton(),
          ],
        ),
      ),
    );
  }

  /// 构建表情按钮
  Widget _buildEmojiButton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingSm,
        bottom: AppDimensions.paddingSm,
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: 打开表情选择器
        },
        child: const Icon(
          Icons.emoji_emotions_outlined,
          size: 24,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// 构建文本输入框
  Widget _buildTextField() {
    return TextField(
      controller: widget.controller,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        hintText: '输入消息...',
        hintStyle: AppTextStyles.inputHint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSm,
          vertical: AppDimensions.paddingMd,
        ),
      ),
      onSubmitted: (_) => widget.onSend(),
    );
  }

  /// 构建附件按钮
  Widget _buildAttachButton() {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppDimensions.paddingSm,
        bottom: AppDimensions.paddingSm,
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: 打开附件选择器
        },
        child: const Icon(
          Icons.attach_file,
          size: 24,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  /// 构建发送按钮
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _hasText ? widget.onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _hasText ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: _hasText
              ? null
              : Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
        ),
        child: Icon(
          Icons.send,
          size: 22,
          color: _hasText ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}
