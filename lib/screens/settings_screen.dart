import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/ai_settings.dart';
import '../services/settings_service.dart';
import '../widgets/warm_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  bool _isLoading = true;
  late List<_ConfigEntry> _configs;
  late int _activeIndex;
  int _editIndex = 0;
  bool _selectorOpen = false;
  final _selectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.load();
    _configs = settings.configs.map((c) => _ConfigEntry(
      nameCtrl: TextEditingController(text: c.name),
      urlCtrl: TextEditingController(text: c.baseUrl),
      keyCtrl: TextEditingController(text: c.apiKey),
      modelCtrl: TextEditingController(text: c.model),
      obscureKey: true,
      reasoningEnabled: c.reasoningEnabled,
    )).toList();
    _activeIndex = settings.activeConfigIndex.clamp(0, _configs.length - 1);
    _editIndex = _activeIndex;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    for (final c in _configs) {
      c.nameCtrl.dispose();
      c.urlCtrl.dispose();
      c.keyCtrl.dispose();
      c.modelCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildAppBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('API 配置'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildConfigSelector(),
                      const SizedBox(height: 16),
                      _buildConfigFields(),
                      const SizedBox(height: 20),
                      _buildAddDeleteRow(),
                      const SizedBox(height: AppDimensions.spacing3Xl),
                      _buildSaveButton(),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.chatAppBarStart, AppColors.chatAppBarMid, AppColors.chatAppBarEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          TapScale(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          const Text('设置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.41)),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B))),
        const Spacer(),
        Text('${_configs.length} 套配置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  // ─── 配置选择器 ───

  Widget _buildConfigSelector() {
    final entry = _configs[_editIndex];
    return TapScale(
      key: _selectorKey,
      onTap: _toggleSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(
            color: _selectorOpen ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.nameCtrl.text.isEmpty ? '未命名' : entry.nameCtrl.text,
                  style: const TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                Text(entry.modelCtrl.text,
                  style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _editIndex == _activeIndex ? AppColors.accent : Colors.transparent,
              border: Border.all(color: _editIndex == _activeIndex ? AppColors.accent : AppColors.border, width: 2),
            ),
            child: _editIndex == _activeIndex ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Icon(_selectorOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20, color: Colors.grey[400]),
        ]),
      ),
    );
  }

  void _toggleSelector() {
    if (_selectorOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  OverlayEntry? _overlay;

  void _showOverlay() {
    final renderBox = _selectorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = (screenHeight - pos.dy - size.height - 40).clamp(60.0, 280.0);

    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(builder: (ctx) {
      return Stack(children: [
        Positioned.fill(
          child: GestureDetector(onTap: _removeOverlay, child: Container(color: Colors.transparent)),
        ),
        Positioned(
          top: pos.dy + size.height + 4,
          left: pos.dx,
          width: size.width,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                children: _configs.asMap().entries.map((e) {
                  final isActive = e.key == _editIndex;
                  final isGlobal = e.key == _activeIndex;
                  return _buildSelectorItem(e.key, e.value, isActive, isGlobal);
                }).toList(),
              ),
            ),
          ),
        ),
      ]);
    });
    overlay.insert(_overlay!);
    setState(() => _selectorOpen = true);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    setState(() => _selectorOpen = false);
  }

  Widget _buildSelectorItem(int index, _ConfigEntry entry, bool isActive, bool isGlobalActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _editIndex = index);
        _removeOverlay();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isActive ? const LinearGradient(colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)]) : null,
              color: isActive ? null : const Color(0xFFF5EFF8),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(Icons.smart_toy_rounded, size: 13, color: isActive ? Colors.white : AppColors.textTertiary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(entry.nameCtrl.text.isEmpty ? '未命名' : entry.nameCtrl.text,
                      style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.accent : const Color(0xFF2D2D2D)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isGlobalActive)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('当前', style: TextStyle(fontFamily: 'MapleMono', fontSize: 9, color: AppColors.accent)),
                    ),
                ]),
                Text(entry.modelCtrl.text, style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
          if (index == _activeIndex)
            const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accent),
          if (_configs.length > 1)
            GestureDetector(
              onTap: () => _deleteConfig(index),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.close, size: 12, color: AppColors.error),
              ),
            ),
        ]),
      ),
    );
  }

  // ─── 配置字段 ───

  Widget _buildConfigFields() {
    final entry = _configs[_editIndex];
    return Column(children: [
      _buildField(entry.nameCtrl, '配置名称', 'My Config', Icons.label_rounded),
      const SizedBox(height: 12),
      _buildField(entry.urlCtrl, 'Base API URL', 'https://api.anthropic.com', Icons.link_rounded),
      const SizedBox(height: 12),
      _buildField(entry.keyCtrl, 'API Key', 'sk-ant-...', Icons.key_rounded,
        obscure: entry.obscureKey,
        suffix: IconButton(
          icon: Icon(entry.obscureKey ? Icons.visibility_off : Icons.visibility, size: 16, color: AppColors.textTertiary),
          onPressed: () => setState(() => entry.obscureKey = !entry.obscureKey),
        ),
      ),
      const SizedBox(height: 12),
      _buildField(entry.modelCtrl, 'Model', 'claude-sonnet-4-20250514', Icons.smart_toy_rounded),
      const SizedBox(height: 12),
      _buildReasoningToggle(entry),
      const SizedBox(height: 6),
      // 设为当前使用
      if (_editIndex != _activeIndex)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TapScale(
            onTap: () => setState(() => _activeIndex = _editIndex),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text('设为当前配置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accent)),
                ],
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _buildField(TextEditingController controller, String label, String hint, IconData icon, {bool obscure = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.accent),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasoningToggle(_ConfigEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: entry.reasoningEnabled ? AppColors.accent.withValues(alpha: 0.12) : const Color(0xFFF0E6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.psychology_rounded, size: 18, color: entry.reasoningEnabled ? AppColors.accent : AppColors.textTertiary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('推理模式', style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2D))),
              Text(
                entry.reasoningEnabled ? '模型会先思考再回答，响应更深入' : '标准模式，响应更快',
                style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => entry.reasoningEnabled = !entry.reasoningEnabled),
          child: Container(
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: entry.reasoningEnabled ? AppColors.accent : Colors.grey[300],
            ),
            alignment: entry.reasoningEnabled ? Alignment.centerRight : Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── 添加 / 删除 ───

  Widget _buildAddDeleteRow() {
    return Row(children: [
      Expanded(
        child: TapScale(
          onTap: _addConfig,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                SizedBox(width: 6),
                Text('添加配置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accent)),
              ],
            ),
          ),
        ),
      ),
      if (_configs.length > 1) ...[
        const SizedBox(width: 10),
        TapScale(
          onTap: () => _deleteConfig(_editIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
          ),
        ),
      ],
    ]);
  }

  void _addConfig() {
    setState(() {
      _configs.add(_ConfigEntry(
        nameCtrl: TextEditingController(text: 'Config ${_configs.length + 1}'),
        urlCtrl: TextEditingController(text: 'https://api.anthropic.com'),
        keyCtrl: TextEditingController(),
        modelCtrl: TextEditingController(text: 'claude-sonnet-4-20250514'),
        obscureKey: true,
      ));
      _editIndex = _configs.length - 1;
    });
  }

  void _deleteConfig(int index) {
    setState(() {
      _configs[index].dispose();
      _configs.removeAt(index);
      if (_activeIndex >= _configs.length) _activeIndex = _configs.length - 1;
      if (_editIndex >= _configs.length) _editIndex = _configs.length - 1;
      if (_configs.isEmpty) {
        _addConfig();
        _activeIndex = 0;
        _editIndex = 0;
      }
    });
  }

  // ─── 保存 ───

  Widget _buildSaveButton() {
    return TapScale(
      onTap: _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.gradPurple, AppColors.accent]),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Center(
          child: Text('保存设置', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.41)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final configs = _configs.map((c) => ApiConfig(
      name: c.nameCtrl.text.trim().isEmpty ? 'Config' : c.nameCtrl.text.trim(),
      baseUrl: c.urlCtrl.text.trim().isEmpty ? 'https://api.anthropic.com' : c.urlCtrl.text.trim(),
      apiKey: c.keyCtrl.text.trim(),
      model: c.modelCtrl.text.trim().isEmpty ? 'claude-sonnet-4-20250514' : c.modelCtrl.text.trim(),
      reasoningEnabled: c.reasoningEnabled,
    )).toList();

    final settings = AiSettings(configs: configs, activeConfigIndex: _activeIndex);
    await _settingsService.save(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存'), backgroundColor: AppColors.success),
      );
    }
  }
}

class _ConfigEntry {
  final TextEditingController nameCtrl;
  final TextEditingController urlCtrl;
  final TextEditingController keyCtrl;
  final TextEditingController modelCtrl;
  bool obscureKey;
  bool reasoningEnabled;

  _ConfigEntry({
    required this.nameCtrl,
    required this.urlCtrl,
    required this.keyCtrl,
    required this.modelCtrl,
    this.obscureKey = true,
    this.reasoningEnabled = false,
  });

  void dispose() {
    nameCtrl.dispose();
    urlCtrl.dispose();
    keyCtrl.dispose();
    modelCtrl.dispose();
  }
}
