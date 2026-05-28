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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.7), width: 0.6)),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, -6)),
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: MediaQuery.of(context).padding.bottom + 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _inputField()),
          const SizedBox(width: 8),
          Opacity(
            opacity: _hasText ? 1.0 : 0.4,
            child: _sendBtn(),
          ),
        ],
      ),
    );
  }

  void _insertParen() {
    final ctrl = widget.controller;
    final text = ctrl.text;
    final selection = ctrl.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    ctrl.text = '${text.substring(0, start)}()${text.substring(end)}';
    ctrl.selection = TextSelection.collapsed(offset: start + 1);
  }

  Widget _inputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 0.6),
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        textInputAction: TextInputAction.send,
        style: AppTextStyles.input,
        decoration: InputDecoration(
          hintText: '输入消息... ♡',
          hintStyle: AppTextStyles.inputHint.copyWith(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          suffix: TapScale(
            onTap: _insertParen,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Text('()', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 18, color: AppColors.textMuted)),
            ),
          ),
        ),
        onSubmitted: (_) => widget.onSend(),
      ),
    );
  }

  Widget _sendBtn() {
    return TapScale(
      onTap: _hasText ? widget.onSend : null,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}
