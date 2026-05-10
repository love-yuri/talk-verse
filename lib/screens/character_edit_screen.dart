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
    _personalityCtrl.addListener(() => setState(() {}));
    _greetingCtrl.addListener(() => setState(() {}));
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
    final color = AppColors.avatarColors[widget.index % AppColors.avatarColors.length];

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
          colors: [color.withValues(alpha: 0.4), AppColors.chatAppBarMid, color.withValues(alpha: 0.3)],
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
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.24),
            ),
            const Spacer(),
            TapScale(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('保存', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard([
            _buildNameField(),
            _divider(),
            _buildPersonalityField(),
            _divider(),
            _buildGreetingField(),
          ], color),
          const SizedBox(height: 32),
        ],
      ),
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
          BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: Color(0xFFF0E6F6));
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
                Text('*', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.error)),
                Text('角色名称', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '请输入角色名称',
                hintStyle: TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textTertiary),
                border: InputBorder.none,
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

  Widget _buildPersonalityField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('*', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.error)),
              const Text('角色设定', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _personalityCtrl,
            maxLines: null,
            minLines: 6,
            style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textPrimary, height: 1.6),
            decoration: InputDecoration(
              hintText: '详细描述角色的性格、背景、说话风格等设定',
              hintStyle: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textTertiary),
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
                borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              contentPadding: const EdgeInsets.all(12),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_personalityCtrl.text.length} 字',
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('*', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.error)),
              Text('开场白', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _greetingCtrl,
            maxLines: null,
            minLines: 3,
            style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textPrimary, height: 1.6),
            decoration: InputDecoration(
              hintText: '开始对话时角色说的第一句话',
              hintStyle: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, color: AppColors.textTertiary),
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
                borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              contentPadding: const EdgeInsets.all(12),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_greetingCtrl.text.length} 字',
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final character = Character(
      id: widget.character?.id ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      avatar: widget.character?.avatar ?? 'assets/images/default_avatar.png',
      description: widget.character?.description ?? '',
      personality: _personalityCtrl.text.trim(),
      greeting: _greetingCtrl.text.trim(),
      tags: widget.character?.tags ?? [],
      myNickname: widget.character?.myNickname ?? '冒险者',
      aiNickname: widget.character?.aiNickname ?? '',
    );

    Navigator.pop(context, character);
  }
}
