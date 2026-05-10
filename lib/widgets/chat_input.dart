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
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
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
        color: const Color(0xFFF5EFF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        style: AppTextStyles.input,
        decoration: InputDecoration(
          hintText: '输入消息... ♡',
          hintStyle: AppTextStyles.inputHint.copyWith(color: const Color(0xFFC4B0D9)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          suffix: Transform.translate(
            offset: const Offset(0, 0),
            child: TapScale(
              onTap: _insertParen,
              child: Text('()', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: const Color(0xFFC4B0D9).withValues(alpha: 0.7))),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}
