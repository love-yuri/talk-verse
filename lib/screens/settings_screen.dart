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
  final _baseUrlCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _settingsService = SettingsService();
  bool _isLoading = true;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.load();
    _baseUrlCtrl.text = settings.baseUrl;
    _apiKeyCtrl.text = settings.apiKey;
    _modelCtrl.text = settings.model;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
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
                      _buildSectionTitle('AI 服务配置'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildInputCard(),
                      const SizedBox(height: AppDimensions.spacing2Xl),
                      _buildSectionTitle('模型列表'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildModelHints(),
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

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.accent));
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        _buildTextField(
          controller: _baseUrlCtrl,
          label: 'Base API URL',
          hint: 'https://api.anthropic.com',
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildTextField(
          controller: _apiKeyCtrl,
          label: 'API Key',
          hint: 'sk-ant-...',
          icon: Icons.key_rounded,
          obscure: _obscureKey,
          suffix: IconButton(
            icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 20, color: AppColors.textTertiary),
            onPressed: () => setState(() => _obscureKey = !_obscureKey),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildTextField(
          controller: _modelCtrl,
          label: 'Model',
          hint: 'claude-sonnet-4-20250514',
          icon: Icons.smart_toy_rounded,
        ),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.spacingSm),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildModelHints() {
    const models = [
      'claude-sonnet-4-20250514',
      'claude-opus-4-20250514',
      'claude-haiku-4-20250514',
    ];
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: models.map((m) => TapScale(
        onTap: () => _modelCtrl.text = m,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(m, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
        ),
      )).toList(),
    );
  }

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
    final settings = AiSettings(
      baseUrl: _baseUrlCtrl.text.trim().isEmpty
          ? 'https://api.anthropic.com'
          : _baseUrlCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty
          ? 'claude-sonnet-4-20250514'
          : _modelCtrl.text.trim(),
    );
    await _settingsService.save(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存'), backgroundColor: AppColors.success),
      );
    }
  }
}
