import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../services/webdav_config_service.dart';
import '../widgets/warm_background.dart';

class WebDavConfigScreen extends StatefulWidget {
  const WebDavConfigScreen({super.key});

  @override
  State<WebDavConfigScreen> createState() => _WebDavConfigScreenState();
}

class _WebDavConfigScreenState extends State<WebDavConfigScreen> {
  static const _jianguoyunWebDavUrl = 'https://dav.jianguoyun.com/dav/';

  final _configService = WebDavConfigService();
  final _baseUrlCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    '配置 WebDAV',
                    style: TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '默认使用坚果云 WebDAV，用于下载登录数据库、同步模型配置和共享角色卡',
                    style: TextStyle(
                      fontFamily: 'MapleMono',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  else ...[
                    _buildField(
                      _baseUrlCtrl,
                      'WebDAV 地址',
                      _jianguoyunWebDavUrl,
                      Icons.link_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      _usernameCtrl,
                      '坚果云账号',
                      '请输入坚果云账号',
                      Icons.person_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      _passwordCtrl,
                      '坚果云应用密码',
                      '请输入坚果云应用密码',
                      Icons.lock_rounded,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                  ],
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
              'WebDAV 设置',
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
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            fontFamily: 'MapleMono',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(icon, size: 18, color: AppColors.accent),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surfaceAlt,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '保存配置',
                style: TextStyle(
                  fontFamily: 'MapleMono',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _loadConfig() async {
    final config = await _configService.load();
    if (!mounted) return;
    setState(() {
      _baseUrlCtrl.text = config.baseUrl.isEmpty
          ? _jianguoyunWebDavUrl
          : config.baseUrl;
      _usernameCtrl.text = config.username;
      _passwordCtrl.text = config.password;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final config = WebDavConnectionConfig(
      baseUrl: _baseUrlCtrl.text,
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    ).normalized();

    if (!config.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请填写完整 WebDAV 配置'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _configService.save(config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WebDAV 配置已保存'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
