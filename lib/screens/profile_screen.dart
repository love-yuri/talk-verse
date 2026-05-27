import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/settings_sync_service.dart';
import '../models/user_session.dart';
import '../constants/app_colors.dart';
import '../widgets/glass_header.dart';
import '../widgets/warm_background.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'token_usage_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _settingsSync = SettingsSyncService();
  UserSession? _session;
  bool _syncingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _authService.loadSession();
    if (!mounted) return;
    setState(() => _session = session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildMenuSection('我的旅程', [
              _MenuItem(Icons.auto_stories_rounded, '聊天记录', '回顾与AI的对话', AppColors.gradPink),
              _MenuItem(Icons.favorite_rounded, '我的收藏', '珍藏的精彩瞬间', AppColors.error),
              _MenuItem(Icons.workspace_premium_rounded, '成就徽章', '收集所有成就', AppColors.warning),
              _MenuItem(Icons.photo_library_rounded, '相册壁纸', '二次元美图集', AppColors.success),
            ]),
            const SizedBox(height: 14),
            _buildMenuSection('更多功能', [
              _MenuItem(Icons.login_rounded, _session == null ? '登录' : '退出登录', _session == null ? '登录后同步云端数据' : '当前：${_session!.username}', AppColors.success, onTap: _session == null ? _openLogin : _confirmLogout),
              _MenuItem(Icons.cloud_sync_rounded, '拉取云端设置', _syncingSettings ? '正在同步...' : '同步当前账号的模型配置', AppColors.gradBlue, onTap: _syncingSettings ? null : _pullCloudSettings),
              _MenuItem(Icons.data_usage_rounded, 'Token 用量', '查看API请求消耗明细', AppColors.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TokenUsageScreen()))),
              _MenuItem(Icons.palette_rounded, '主题装扮', '个性化你的空间', AppColors.gradMint),
              _MenuItem(Icons.settings_rounded, '设置', '偏好与账号管理', AppColors.textSecondary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            ]),
            const SizedBox(height: 14),
            _buildVersionBadge(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 毛玻璃头部区域
  Widget _buildHeader() {
    return GlassHeader(
      subtitle: '个人中心',
      title: '我的',
      actions: [
        GlassHeader.iconBtn(Icons.settings_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ],
    );
  }

  /// 个人资料卡片
  Widget _buildProfileCard() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75), width: 0.6),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 22, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            // 头像
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withValues(alpha: 0.24), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text('🎀', style: TextStyle(fontFamily: 'MapleMono', fontSize: 36)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 用户名
            Text(_session?.username ?? '未登录', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.35)),
            const SizedBox(height: 4),
            // 等级标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Lv.5 星见者', style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.07)),
            ),
            const SizedBox(height: 8),
            // 个性签名
            Text(
              _session == null ? '登录后同步模型配置与角色卡' : '与AI相遇的每一天都充满惊喜 ✨',
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: -0.08),
            ),
          ],
        ),
      );
  }

  /// 数据统计行
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _statItem('💬', '对话', '128')),
          _statDivider(),
          Expanded(child: _statItem('🌸', '角色', '12')),
          _statDivider(),
          Expanded(child: _statItem('⭐', '收藏', '36')),
          _statDivider(),
          Expanded(child: _statItem('📅', '天数', '7')),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.accent, letterSpacing: 0.35)),
        const SizedBox(height: 2),
        Text('$emoji $label', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.07)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.divider,
    );
  }

  /// 菜单区块
  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75), width: 0.6),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(title, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.accent, letterSpacing: -0.24)),
          ),
          ...items.asMap().entries.map((e) => Column(children: [
            _buildMenuItem(e.value),
            if (e.key < items.length - 1)
              Divider(height: 0.5, indent: 56, color: AppColors.divider),
          ])),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return TapScale(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.24)),
                Text(item.subtitle, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary, letterSpacing: 0.07)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
        ]),
      ),
    );
  }

  /// 版本徽章
  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('TalkVerse v1.0.0 ♡', style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.07)),
    );
  }
  Future<void> _openLogin() async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (changed == true) _loadSession();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录'),
        content: const Text('退出后本地聊天、角色和设置不会被删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _loadSession();
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _pullCloudSettings() async {
    if (_session == null) {
      await _openLogin();
      if (_session == null) return;
    }
    setState(() => _syncingSettings = true);
    try {
      final settings = await _settingsSync.pullAiSettingsForCurrentUser();
      if (!mounted) return;
      _showSnack(settings == null ? '云端暂无模型配置' : '已拉取云端模型配置', backgroundColor: AppColors.success);
    } catch (e) {
      if (mounted) _showSnack(e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _syncingSettings = false);
    }
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor));
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  const _MenuItem(this.icon, this.label, this.subtitle, this.color, {this.onTap});
}
