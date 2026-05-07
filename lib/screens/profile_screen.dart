import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildMenuSection('常用', [
                _MenuItem(Icons.history_rounded, '聊天记录', AppColors.info),
                _MenuItem(Icons.favorite_border_rounded, '我的收藏', AppColors.accent),
                _MenuItem(Icons.star_border_rounded, '我的评分', AppColors.warning),
                _MenuItem(Icons.download_outlined, '下载管理', AppColors.success),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('其他', [
                _MenuItem(Icons.info_outline_rounded, '关于我们', AppColors.textSecondary),
                _MenuItem(Icons.feedback_outlined, '意见反馈', AppColors.textSecondary),
                _MenuItem(Icons.share_outlined, '分享给朋友', AppColors.textSecondary),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '我的',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Icon(Icons.settings_outlined, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '探索AI对话的无限可能',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                _buildMenuItem(entry.value),
                if (!isLast)
                  Divider(height: 1, indent: 56, color: AppColors.borderLight),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuItem(this.icon, this.label, this.color);
}
