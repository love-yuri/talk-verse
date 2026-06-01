import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import '../services/avatar_generation_service.dart';
import '../services/character_import_service.dart';
import '../widgets/warm_background.dart';
import 'settings_screen.dart';

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
  final _avatarGenerationStatus = ValueNotifier<String>('');
  late String _avatarPath;
  bool _pickingAvatar = false;
  bool _generatingAvatar = false;

  bool get _isEditing => !widget.isCreating;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _personalityCtrl = TextEditingController(text: c?.personality ?? '');
    _greetingCtrl = TextEditingController(text: c?.greeting ?? '');
    _avatarPath = c?.avatar ?? CharacterImportService.defaultAvatarPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _personalityCtrl.dispose();
    _greetingCtrl.dispose();
    _avatarGenerationStatus.dispose();
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
        final textAreaPool = (usableHeight - 246).clamp(320.0, 760.0);
        final personalityHeight = (textAreaPool * 0.64).clamp(220.0, 520.0);
        final greetingHeight = (textAreaPool * 0.36).clamp(140.0, 320.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard([
                _buildAvatarField(color),
                _divider(),
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

  Widget _buildAvatarField(Color color) {
    final isDefaultAvatar =
        _avatarPath == CharacterImportService.defaultAvatarPath;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              '头像',
              style: TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TapScale(
            onTap: _avatarBusy ? null : _pickAvatar,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.45),
                        AppColors.surface.withValues(alpha: 0.75),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildAvatarImage(color)),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _avatarBusy
                        ? const Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _avatarActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI生成',
                  onTap: _avatarBusy ? null : _generateAvatar,
                ),
                _avatarActionButton(
                  icon: Icons.image_outlined,
                  label: '更换头像',
                  onTap: _avatarBusy ? null : _pickAvatar,
                ),
                if (!isDefaultAvatar)
                  _avatarActionButton(
                    icon: Icons.restart_alt_rounded,
                    label: '恢复默认',
                    onTap: _avatarBusy
                        ? null
                        : () => setState(
                            () => _avatarPath =
                                CharacterImportService.defaultAvatarPath,
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _avatarBusy => _pickingAvatar || _generatingAvatar;

  Widget _avatarActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentLight.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(Color color) {
    final fallback = Icon(
      Icons.person,
      size: 34,
      color: color.withValues(alpha: 0.6),
    );
    if (_avatarPath.startsWith('/')) {
      return Image.file(
        File(_avatarPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.asset(
      _avatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
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

  Future<void> _pickAvatar() async {
    if (_pickingAvatar) return;

    setState(() => _pickingAvatar = true);
    try {
      final path = await CharacterImportService.pickAvatarImage(
        name: _nameCtrl.text.trim(),
      );
      if (path == null || !mounted) return;
      setState(() => _avatarPath = path);
    } catch (e) {
      debugPrint('选择角色头像失败: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('头像选择失败：$e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  Future<void> _generateAvatar() async {
    if (_avatarBusy) return;

    final promptCtrl = TextEditingController(text: _buildAvatarPrompt());
    final prompt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('AI 生成头像'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: promptCtrl,
            maxLines: 8,
            minLines: 5,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 13,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '描述头像画面、风格、服装、表情等',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, promptCtrl.text.trim()),
            child: const Text('生成', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    promptCtrl.dispose();

    if (prompt == null || prompt.trim().isEmpty || !mounted) return;

    setState(() => _generatingAvatar = true);
    _avatarGenerationStatus.value = '准备生成头像...';
    final cancelToken = AvatarGenerationCancelToken();
    var progressDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AvatarGenerationProgressDialog(
        statusListenable: _avatarGenerationStatus,
        onCancel: () {
          _avatarGenerationStatus.value = '正在取消头像生成...';
          cancelToken.cancel();
        },
      ),
    ).then((_) => progressDialogOpen = false);

    String? generatedPath;
    String? errorMessage;
    var cancelled = false;
    try {
      generatedPath = await AvatarGenerationService().generateAvatar(
        prompt: prompt,
        characterName: _nameCtrl.text.trim(),
        onProgress: (message) => _avatarGenerationStatus.value = message,
        cancelToken: cancelToken,
      );
    } on AvatarGenerationCancelled {
      cancelled = true;
    } catch (e) {
      debugPrint('AI 生成角色头像失败: $e');
      errorMessage = e.toString();
    } finally {
      if (mounted) {
        if (progressDialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        setState(() => _generatingAvatar = false);
      }
    }

    if (!mounted) return;

    if (cancelled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已取消头像生成')));
      return;
    }

    if (generatedPath != null) {
      setState(() => _avatarPath = generatedPath!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('头像已生成'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    if (errorMessage != null) _showAvatarGenerationError(errorMessage);
  }

  Future<void> _showAvatarGenerationError(String message) async {
    final lastStep = _avatarGenerationStatus.value;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('头像生成失败'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lastStep.isNotEmpty) ...[
                const Text(
                  '失败前进度',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lastStep,
                  style: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const Text(
                '错误详情',
                style: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.6),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    message,
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (message.contains('API Key'))
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              child: const Text(
                '去设置',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _buildAvatarPrompt() {
    final name = _nameCtrl.text.trim().isEmpty ? '这个角色' : _nameCtrl.text.trim();
    final setting = _extractAvatarRelevantSetting(_personalityCtrl.text);
    return [
      '请阅读下面的【AI角色设定摘要】，只根据其中属于 AI 角色本人的身份、外貌、服装、气质和性格来生成角色「$name」的正方形头像。',
      '不要根据完整剧情自由发挥；不要画用户、旁人、剧情事件、开场场景、世界观背景或关系设定。',
      '如果摘要里没有明确外貌，只根据角色身份与气质做克制补全，保持人物清晰居中。',
      '画面要求：单人半身或肩颈肖像，表情符合角色性格，背景简洁，无文字、标志、水印。',
      '风格：精致数字插画，柔和光线，适合作为聊天应用头像。',
      if (setting.isNotEmpty) '【AI角色设定摘要】\n$setting',
    ].join('\n');
  }

  String _extractAvatarRelevantSetting(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';

    final sections = _extractBracketSections(text);
    final includeKeywords = [
      'ai设定',
      'ai角色',
      '角色设定',
      '角色身份',
      '身份',
      '外貌',
      '外貌气质',
      '形象',
      '容貌',
      '衣着',
      '服装',
      '发型',
      '年龄',
      '性别',
      '种族',
      '性格',
      '气质',
    ];
    final excludeKeywords = [
      '剧情',
      '开局',
      '场景',
      '世界观',
      '背景故事',
      '关系',
      '用户',
      '互动',
      '边界',
      '规则',
      '示例',
    ];

    final selected = <String>[];
    for (final section in sections) {
      final title = section.title.toLowerCase();
      final shouldInclude = includeKeywords.any(title.contains);
      final shouldExclude = excludeKeywords.any(title.contains);
      if (shouldInclude && !shouldExclude) {
        selected.add(section.content);
      }
    }

    final source = selected.isEmpty ? text : selected.join('\n\n');
    final filteredLines = source.split('\n').map((line) => line.trim()).where((
      line,
    ) {
      if (line.isEmpty) return false;
      final lower = line.toLowerCase();
      return !excludeKeywords.any(lower.contains);
    }).toList();
    final summary = filteredLines.join('\n').trim();
    if (summary.length <= 900) return summary;
    return '${summary.substring(0, 900).trimRight()}...';
  }

  List<_SettingSection> _extractBracketSections(String text) {
    final regex = RegExp(r'【([^】]+)】');
    final matches = regex.allMatches(text).toList();
    if (matches.isEmpty) return const [];

    final sections = <_SettingSection>[];
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final nextStart = i + 1 < matches.length
          ? matches[i + 1].start
          : text.length;
      final title = match.group(1)?.trim() ?? '';
      final content = text.substring(match.end, nextStart).trim();
      if (title.isNotEmpty && content.isNotEmpty) {
        sections.add(_SettingSection(title, content));
      }
    }
    return sections;
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
      avatar: _avatarPath,
      personality: _personalityCtrl.text.trim(),
      greeting: _greetingCtrl.text.trim(),
      myNickname: widget.character?.myNickname ?? '冒险者',
      aiNickname: widget.character?.aiNickname ?? '',
    );

    Navigator.pop(context, character);
  }
}

class _AvatarGenerationProgressDialog extends StatelessWidget {
  final ValueListenable<String> statusListenable;
  final VoidCallback onCancel;

  const _AvatarGenerationProgressDialog({
    required this.statusListenable,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('正在生成头像'),
        content: SizedBox(
          width: 360,
          child: ValueListenableBuilder<String>(
            valueListenable: statusListenable,
            builder: (context, status, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.accentLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status.isEmpty ? '准备生成头像...' : status,
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '图片生成通常需要几十秒，请保持当前页面打开。',
                    style: TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: const Text('取消生成', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingSection {
  final String title;
  final String content;

  const _SettingSection(this.title, this.content);
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
