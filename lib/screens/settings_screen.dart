import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../models/ai_settings.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../services/settings_sync_service.dart';
import '../widgets/warm_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  final _settingsSync = SettingsSyncService();
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;
  late List<_ConfigEntry> _configs;
  late _ImageConfigEntry _imageConfig;
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
    _configs = settings.configs
        .map(
          (c) => _ConfigEntry(
            nameCtrl: TextEditingController(text: c.name),
            urlCtrl: TextEditingController(text: c.baseUrl),
            keyCtrl: TextEditingController(text: c.apiKey),
            modelCtrl: TextEditingController(text: c.model),
            maxTokensCtrl: TextEditingController(text: c.maxTokens.toString()),
            reasoningBudgetCtrl: TextEditingController(
              text: c.reasoningBudgetTokens.toString(),
            ),
            topKCtrl: TextEditingController(text: c.topK.toString()),
            obscureKey: true,
            reasoningEnabled: c.reasoningEnabled,
            temperature: c.temperature,
            topP: c.topP,
          ),
        )
        .toList();
    _imageConfig = _ImageConfigEntry(
      urlCtrl: TextEditingController(text: settings.imageApiConfig.baseUrl),
      keyCtrl: TextEditingController(text: settings.imageApiConfig.apiKey),
      modelCtrl: TextEditingController(text: settings.imageApiConfig.model),
      sizeCtrl: TextEditingController(text: settings.imageApiConfig.size),
      qualityCtrl: TextEditingController(text: settings.imageApiConfig.quality),
      outputFormatCtrl: TextEditingController(
        text: settings.imageApiConfig.outputFormat,
      ),
      obscureKey: true,
    );
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
      c.maxTokensCtrl.dispose();
      c.reasoningBudgetCtrl.dispose();
      c.topKCtrl.dispose();
    }
    _imageConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.spacingXl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'API 配置',
                          trailing: '${_configs.length} 套配置',
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        _buildConfigSelector(),
                        const SizedBox(height: 16),
                        _buildConfigFields(),
                        const SizedBox(height: 20),
                        _buildAddDeleteRow(),
                        const SizedBox(height: AppDimensions.spacing3Xl),
                        _buildSectionHeader('头像生成 API', trailing: 'GPT Image'),
                        const SizedBox(height: AppDimensions.spacingMd),
                        _buildImageConfigFields(),
                        const SizedBox(height: AppDimensions.spacing3Xl),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.chatAppBarStart,
            AppColors.chatAppBarMid,
            AppColors.chatAppBarEnd,
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
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '设置',
              style: TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.41,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _settingIcon(IconData icon, {double size = 32, bool active = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? null : AppColors.accentLight.withValues(alpha: 0.55),
        gradient: active ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(size <= 28 ? 7 : 8),
        border: active
            ? null
            : Border.all(
                color: AppColors.border.withValues(alpha: 0.65),
                width: 0.6,
              ),
      ),
      child: Icon(
        icon,
        size: size <= 28 ? 13 : 18,
        color: active ? Colors.white : AppColors.accent,
      ),
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
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: _selectorOpen
                ? AppColors.accent.withValues(alpha: 0.45)
                : AppColors.border.withValues(alpha: 0.75),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            _settingIcon(Icons.smart_toy_rounded, active: _selectorOpen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.nameCtrl.text.isEmpty ? '未命名' : entry.nameCtrl.text,
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    entry.modelCtrl.text,
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _editIndex == _activeIndex
                    ? AppColors.accent
                    : Colors.transparent,
                border: Border.all(
                  color: _editIndex == _activeIndex
                      ? AppColors.accent
                      : AppColors.border,
                  width: 1.4,
                ),
              ),
              child: _editIndex == _activeIndex
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Icon(
              _selectorOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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
    final renderBox =
        _selectorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = (screenHeight - pos.dy - size.height - 40).clamp(
      60.0,
      280.0,
    );

    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: pos.dy + size.height + 4,
              left: pos.dx,
              width: size.width,
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(14),
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.75),
                      width: 0.7,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    children: _configs.asMap().entries.map((e) {
                      final isActive = e.key == _editIndex;
                      final isGlobal = e.key == _activeIndex;
                      return _buildSelectorItem(
                        e.key,
                        e.value,
                        isActive,
                        isGlobal,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_overlay!);
    setState(() => _selectorOpen = true);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    setState(() => _selectorOpen = false);
  }

  Widget _buildSelectorItem(
    int index,
    _ConfigEntry entry,
    bool isActive,
    bool isGlobalActive,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _editIndex = index);
        _removeOverlay();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentLight.withValues(alpha: 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _settingIcon(Icons.smart_toy_rounded, size: 28, active: isActive),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.nameCtrl.text.isEmpty
                              ? '未命名'
                              : entry.nameCtrl.text,
                          style: TextStyle(
                            fontFamily: 'MapleMono',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isGlobalActive)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '当前',
                            style: TextStyle(
                              fontFamily: 'MapleMono',
                              fontSize: 9,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    entry.modelCtrl.text,
                    style: const TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (index == _activeIndex)
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.accent,
              ),
            if (_configs.length > 1)
              TapScale(
                onTap: () => _deleteConfig(index),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 配置字段 ───

  Widget _buildConfigFields() {
    final entry = _configs[_editIndex];
    return Column(
      children: [
        _buildField(entry.nameCtrl, '配置名称', 'My Config', Icons.label_rounded),
        const SizedBox(height: 12),
        _buildField(
          entry.urlCtrl,
          'Base API URL',
          'https://api.anthropic.com',
          Icons.link_rounded,
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.keyCtrl,
          'API Key',
          'sk-ant-...',
          Icons.key_rounded,
          obscure: entry.obscureKey,
          suffix: _fieldIconButton(
            entry.obscureKey ? Icons.visibility_off : Icons.visibility,
            () => setState(() => entry.obscureKey = !entry.obscureKey),
          ),
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.modelCtrl,
          'Model',
          'claude-sonnet-4-20250514',
          Icons.smart_toy_rounded,
        ),
        const SizedBox(height: 12),
        _buildReasoningToggle(entry),
        const SizedBox(height: 12),
        _buildTemperatureSlider(entry),
        const SizedBox(height: 12),
        _buildTopPSlider(entry),
        const SizedBox(height: 12),
        _buildField(entry.topKCtrl, 'Top K', '40', Icons.filter_list_rounded),
        const SizedBox(height: 12),
        _buildField(
          entry.maxTokensCtrl,
          '最大输出 Token',
          '1024',
          Icons.output_rounded,
        ),
        if (entry.reasoningEnabled) ...[
          const SizedBox(height: 12),
          _buildField(
            entry.reasoningBudgetCtrl,
            '推理 Token 预算',
            '4000',
            Icons.psychology_rounded,
          ),
        ],
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
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '设为当前配置',
                      style: TextStyle(
                        fontFamily: 'MapleMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageConfigFields() {
    final entry = _imageConfig;
    return Column(
      children: [
        _buildField(
          entry.urlCtrl,
          'Image API URL',
          'https://api.openai.com 或完整 /v1/images/generations',
          Icons.image_search_rounded,
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.keyCtrl,
          'Image API Key',
          'sk-...',
          Icons.key_rounded,
          obscure: entry.obscureKey,
          suffix: _fieldIconButton(
            entry.obscureKey ? Icons.visibility_off : Icons.visibility,
            () => setState(() => entry.obscureKey = !entry.obscureKey),
          ),
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.modelCtrl,
          'Image Model',
          'gpt-image-2',
          Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.sizeCtrl,
          'Image Size',
          '1024x1024',
          Icons.crop_square_rounded,
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.qualityCtrl,
          'Quality',
          'auto',
          Icons.high_quality_rounded,
        ),
        const SizedBox(height: 12),
        _buildField(
          entry.outputFormatCtrl,
          'Output Format',
          'png',
          Icons.file_download_rounded,
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.75),
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: AppTextStyles.input.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 14),
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (suffix != null) ...[const SizedBox(width: 8), suffix],
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldIconButton(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.75),
            width: 0.6,
          ),
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildReasoningToggle(_ConfigEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          _settingIcon(
            Icons.psychology_rounded,
            active: entry.reasoningEnabled,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '推理模式',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.reasoningEnabled ? '模型会先思考再回答，响应更深入' : '标准模式，响应更快',
                  style: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(
              () => entry.reasoningEnabled = !entry.reasoningEnabled,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: entry.reasoningEnabled
                    ? AppColors.accent
                    : AppColors.surfaceAlt,
                border: Border.all(
                  color: entry.reasoningEnabled
                      ? AppColors.accent
                      : AppColors.border,
                  width: 0.7,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: entry.reasoningEnabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureSlider(_ConfigEntry entry) {
    return _buildParameterSlider(
      icon: Icons.thermostat_rounded,
      title: 'Temperature',
      subtitle: '值越低回答越确定，值越高越有创意 (${entry.temperature.toStringAsFixed(2)})',
      value: entry.temperature,
      min: 0,
      max: 2,
      divisions: 40,
      onChanged: (v) => setState(() => entry.temperature = v),
    );
  }

  Widget _buildTopPSlider(_ConfigEntry entry) {
    final percent = (entry.topP * 100).round();
    return _buildParameterSlider(
      icon: Icons.tune_rounded,
      title: 'Top P',
      subtitle:
          '核采样：仅从累积概率前 $percent% 的词中采样 (${entry.topP.toStringAsFixed(2)})',
      value: entry.topP,
      min: 0,
      max: 1,
      divisions: 20,
      onChanged: (v) => setState(() => entry.topP = v),
    );
  }

  Widget _buildParameterSlider({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _settingIcon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'MapleMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'MapleMono',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCustomSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    double quantize(double raw) {
      final clamped = raw.clamp(min, max);
      final step = (max - min) / divisions;
      return min + ((clamped - min) / step).round() * step;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final percent = ((value - min) / (max - min)).clamp(0.0, 1.0);

        void updateFromDx(double dx) {
          final next = min + (dx / width).clamp(0.0, 1.0) * (max - min);
          onChanged(quantize(next));
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => updateFromDx(details.localPosition.dx),
          onHorizontalDragUpdate: (details) =>
              updateFromDx(details.localPosition.dx),
          child: SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Positioned(
                  left: (width - 18) * percent,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 添加 / 删除 ───

  Widget _buildAddDeleteRow() {
    return Row(
      children: [
        Expanded(
          child: TapScale(
            onTap: _addConfig,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.75),
                  width: 0.7,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text(
                    '添加配置',
                    style: TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
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
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.18),
                  width: 0.7,
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addConfig() {
    setState(() {
      _configs.add(
        _ConfigEntry(
          nameCtrl: TextEditingController(
            text: 'Config ${_configs.length + 1}',
          ),
          urlCtrl: TextEditingController(text: 'https://api.anthropic.com'),
          keyCtrl: TextEditingController(),
          modelCtrl: TextEditingController(text: 'claude-sonnet-4-20250514'),
          maxTokensCtrl: TextEditingController(text: '1024'),
          reasoningBudgetCtrl: TextEditingController(text: '4000'),
          topKCtrl: TextEditingController(text: '40'),
          obscureKey: true,
        ),
      );
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
      onTap: _isSaving ? null : _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  '保存设置',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.41,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final configs = _configs
        .map(
          (c) => ApiConfig(
            name: c.nameCtrl.text.trim().isEmpty
                ? 'Config'
                : c.nameCtrl.text.trim(),
            baseUrl: c.urlCtrl.text.trim().isEmpty
                ? 'https://api.anthropic.com'
                : c.urlCtrl.text.trim(),
            apiKey: c.keyCtrl.text.trim(),
            model: c.modelCtrl.text.trim().isEmpty
                ? 'claude-sonnet-4-20250514'
                : c.modelCtrl.text.trim(),
            reasoningEnabled: c.reasoningEnabled,
            reasoningBudgetTokens:
                int.tryParse(c.reasoningBudgetCtrl.text.trim()) ?? 4000,
            temperature: c.temperature,
            maxTokens: int.tryParse(c.maxTokensCtrl.text.trim()) ?? 1024,
            topP: c.topP,
            topK: int.tryParse(c.topKCtrl.text.trim()) ?? 40,
          ),
        )
        .toList();

    final settings = AiSettings(
      configs: configs,
      activeConfigIndex: _activeIndex,
      imageApiConfig: ImageApiConfig(
        baseUrl: _imageConfig.urlCtrl.text.trim().isEmpty
            ? 'https://api.openai.com'
            : _imageConfig.urlCtrl.text.trim(),
        apiKey: _imageConfig.keyCtrl.text.trim(),
        model: _imageConfig.modelCtrl.text.trim().isEmpty
            ? 'gpt-image-2'
            : _imageConfig.modelCtrl.text.trim(),
        size: _imageConfig.sizeCtrl.text.trim().isEmpty
            ? '1024x1024'
            : _imageConfig.sizeCtrl.text.trim(),
        quality: _imageConfig.qualityCtrl.text.trim().isEmpty
            ? 'auto'
            : _imageConfig.qualityCtrl.text.trim(),
        outputFormat: _imageConfig.outputFormatCtrl.text.trim().isEmpty
            ? 'png'
            : _imageConfig.outputFormatCtrl.text.trim(),
      ),
    );
    await _settingsService.save(settings);

    var message = '设置已保存';
    var color = AppColors.success;
    final session = _authService.session ?? await _authService.loadSession();
    if (session != null) {
      try {
        await _settingsSync.pushAiSettings(settings);
        message = '设置已保存并同步到云端';
      } catch (e) {
        message = '设置已保存，云端同步失败：$e';
        color = AppColors.error;
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    } else {
      _isSaving = false;
    }
  }
}

class _ConfigEntry {
  final TextEditingController nameCtrl;
  final TextEditingController urlCtrl;
  final TextEditingController keyCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController maxTokensCtrl;
  final TextEditingController reasoningBudgetCtrl;
  final TextEditingController topKCtrl;
  bool obscureKey;
  bool reasoningEnabled;
  double temperature;
  double topP;

  _ConfigEntry({
    required this.nameCtrl,
    required this.urlCtrl,
    required this.keyCtrl,
    required this.modelCtrl,
    required this.maxTokensCtrl,
    required this.reasoningBudgetCtrl,
    required this.topKCtrl,
    this.obscureKey = true,
    this.reasoningEnabled = false,
    this.temperature = 1.0,
    this.topP = 0.9,
  });

  void dispose() {
    nameCtrl.dispose();
    urlCtrl.dispose();
    keyCtrl.dispose();
    modelCtrl.dispose();
    maxTokensCtrl.dispose();
    reasoningBudgetCtrl.dispose();
    topKCtrl.dispose();
  }
}

class _ImageConfigEntry {
  final TextEditingController urlCtrl;
  final TextEditingController keyCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController sizeCtrl;
  final TextEditingController qualityCtrl;
  final TextEditingController outputFormatCtrl;
  bool obscureKey;

  _ImageConfigEntry({
    required this.urlCtrl,
    required this.keyCtrl,
    required this.modelCtrl,
    required this.sizeCtrl,
    required this.qualityCtrl,
    required this.outputFormatCtrl,
    this.obscureKey = true,
  });

  void dispose() {
    urlCtrl.dispose();
    keyCtrl.dispose();
    modelCtrl.dispose();
    sizeCtrl.dispose();
    qualityCtrl.dispose();
    outputFormatCtrl.dispose();
  }
}
