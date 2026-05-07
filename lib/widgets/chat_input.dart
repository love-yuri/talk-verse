import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'warm_background.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onTextChanged;

  const ChatInput({super.key, required this.controller, required this.onSend, this.onTextChanged});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    widget.onTextChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _inputField()),
          const SizedBox(width: 8),
          _sendBtn(),
        ],
      ),
    );
  }

  Widget _inputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: AppTextStyles.input,
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 9, right: 4),
            child: GestureDetector(onTap: () {}, child: Icon(Icons.emoji_emotions_outlined, size: 20, color: AppColors.textTertiary)),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _sendBtn() {
    return TapScale(
      onTap: _hasText ? widget.onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _hasText ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.arrow_upward_rounded, size: 20, color: _hasText ? Colors.white : AppColors.textTertiary),
      ),
    );
  }
}
