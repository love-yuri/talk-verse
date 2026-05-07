import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/warm_background.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildMenuSection('常用', [
              _MenuItem(Icons.history_rounded, '聊天记录', AppColors.accent),
              _MenuItem(Icons.favorite_border_rounded, '我的收藏', const Color(0xFFFF9500)),
              _MenuItem(Icons.star_border_rounded, '我的评分', const Color(0xFFFFCC00)),
              _MenuItem(Icons.download_outlined, '下载管理', AppColors.success),
            ]),
            const SizedBox(height: 12),
            _buildMenuSection('其他', [
              _MenuItem(Icons.info_outline_rounded, '关于我们', AppColors.textSecondary),
              _MenuItem(Icons.feedback_outlined, '意见反馈', AppColors.textSecondary),
              _MenuItem(Icons.share_outlined, '分享给朋友', AppColors.textSecondary),
            ]),
            const SizedBox(height: 12),
            Text('TalkVerse v1.0.0', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            const Text('我的', style: AppTextStyles.h1),
            const Spacer(),
            _iconBtn(Icons.settings_outlined, () {}),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.person_rounded, size: 28, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('用户', style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text('探索AI对话的无限可能', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title, style: AppTextStyles.labelSmall),
          ),
          ...items.asMap().entries.map((e) => Column(children: [
            _buildMenuItem(e.value),
            if (e.key < items.length - 1) Divider(height: 0.5, indent: 52, color: AppColors.divider),
          ])),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return TapScale(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(item.icon, size: 16, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: AppTextStyles.body.copyWith(fontSize: 14))),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textTertiary),
        ]),
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
