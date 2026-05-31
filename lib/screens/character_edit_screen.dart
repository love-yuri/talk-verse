import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import '../widgets/warm_background.dart';

class CharacterEditScreen extends StatefulWidget {
  final Character? character;
  final int index;
  final bool isCreating;

  const CharacterEditScreen({
    super.key,
    this.character,
    required this.index,
    this.isCreating = false,
  });

  @override
  State<CharacterEditScreen> createState() => _CharacterEditScreenState();
}

class _CharacterEditScreenState extends State<CharacterEditScreen> {
  static const int _inlinePersonalityLimit = 1500;
  static const int _personalityPreviewLimit = 700;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _personalityCtrl;
  late final TextEditingController _greetingCtrl;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => !widget.isCreating;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _personalityCtrl = TextEditingController(text: c?.personality ?? '');
    _greetingCtrl = TextEditingController(text: c?.greeting ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _personalityCtrl.dispose();
    _greetingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.avatarColors[widget.index % AppColors.avatarColors.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(context, color),
            Expanded(child: _buildForm(context, color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.4),
            AppColors.chatAppBarMid,
            color.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            TapScale(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _isEditing ? '编辑角色' : '新建角色',
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.24,
              ),
            ),
            const Spacer(),
            TapScale(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final usableHeight = constraints.maxHeight - 40 - 32;
        final textAreaPool = (usableHeight - 158).clamp(320.0, 760.0);
        final personalityHeight = (textAreaPool * 0.64).clamp(220.0, 520.0);
        final greetingHeight = (textAreaPool * 0.36).clamp(140.0, 320.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard([
                _buildNameField(),
                _divider(),
                _buildPersonalityField(personalityHeight),
                _divider(),
                _buildGreetingField(greetingHeight),
              ], color),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(List<Widget> items, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFFF0E6F6), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFF0E6F6),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            child: Row(
              children: [
                Text(
                  '*',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '角色名称',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '请输入角色名称',
                hintStyle: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityField(double fieldHeight) {
    final isLongPersonality =
        _personalityCtrl.text.length > _inlinePersonalityLimit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '*',
                style: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
              const Text(
                '角色设定',
                style: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLongPersonality)
            _buildLongPersonalityPreview(fieldHeight)
          else
            SizedBox(
              height: fieldHeight,
              child: TextFormField(
                controller: _personalityCtrl,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                scrollPhysics: const ClampingScrollPhysics(),
                style: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: '详细描述角色的性格、背景、说话风格等设定',
                  hintStyle: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFF0E6F6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFF0E6F6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
              ),
            ),
          if (isLongPersonality)
            const SizedBox.shrink()
          else ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _personalityCtrl,
                builder: (context, value, child) {
                  return Text(
                    '${value.text.length} 字',
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLongPersonalityPreview(double fieldHeight) {
    final text = _personalityCtrl.text;
    final preview = text.length > _personalityPreviewLimit
        ? '${text.substring(0, _personalityPreviewLimit).trimRight()}...'
        : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: (fieldHeight - 44).clamp(140.0, 360.0),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF0E6F6)),
          ),
          child: Text(
            preview,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${text.length} 字',
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openPersonalityEditor,
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: const Text('编辑完整人设'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openPersonalityEditor() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _LongTextEditScreen(
          title: '编辑角色设定',
          initialText: _personalityCtrl.text,
          hintText: '详细描述角色的性格、背景、说话风格等设定',
        ),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _personalityCtrl.text = updated);
  }

  Widget _buildGreetingField(double fieldHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '开场白',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              controller: _greetingCtrl,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              scrollPhysics: const ClampingScrollPhysics(),
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: '开始对话时角色说的第一句话（可选）',
                hintStyle: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF0E6F6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF0E6F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.4),
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _greetingCtrl,
              builder: (context, value, child) {
                return Text(
                  '${value.text.length} 字',
                  style: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_personalityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('角色设定必填'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final character = Character(
      id: widget.character?.id ?? 0,
      name: _nameCtrl.text.trim(),
      avatar: widget.character?.avatar ?? 'assets/images/default_avatar.png',
      personality: _personalityCtrl.text.trim(),
      greeting: _greetingCtrl.text.trim(),
      myNickname: widget.character?.myNickname ?? '冒险者',
      aiNickname: widget.character?.aiNickname ?? '',
    );

    Navigator.pop(context, character);
  }
}

class _LongTextEditScreen extends StatefulWidget {
  final String title;
  final String initialText;
  final String hintText;

  const _LongTextEditScreen({
    required this.title,
    required this.initialText,
    required this.hintText,
  });

  @override
  State<_LongTextEditScreen> createState() => _LongTextEditScreenState();
}

class _LongTextEditScreenState extends State<_LongTextEditScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.75),
                    width: 0.7,
                  ),
                ),
                child: TextField(
                  controller: _ctrl,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 22),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.7),
                  width: 0.6,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.7),
                      width: 0.6,
                    ),
                  ),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _ctrl,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.length} 字',
                        style: const TextStyle(
                          fontFamily: 'MapleMono',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                TapScale(
                  onTap: () => Navigator.pop(context, _ctrl.text.trim()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '完成',
                      style: TextStyle(
                        fontFamily: 'MapleMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            TapScale(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
