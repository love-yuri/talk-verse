import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// 个人中心屏幕
/// 显示用户信息和设置选项
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
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: const Text(
        '个人中心',
        style: AppTextStyles.h3,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.textSecondary),
          onPressed: () {
            // TODO: 打开设置页面
          },
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildMenuSection(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildAboutSection(),
        ],
      ),
    );
  }

  /// 构建个人资料头部
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding2Xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildUserName(),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildUserBio(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildStats(),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// 构建用户名
  Widget _buildUserName() {
    return const Text(
      '用户',
      style: AppTextStyles.h3,
    );
  }

  /// 构建用户简介
  Widget _buildUserBio() {
    return Text(
      '这个人很懒，什么都没写~',
      style: AppTextStyles.bodySmall,
    );
  }

  /// 构建统计数据
  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('对话', '12'),
        _buildStatDivider(),
        _buildStatItem('角色', '5'),
        _buildStatDivider(),
        _buildStatItem('消息', '156'),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  /// 构建统计分隔线
  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border,
    );
  }

  /// 构建菜单部分
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.history, '聊天记录'),
          _buildDivider(),
          _buildMenuItem(Icons.favorite_border, '我的收藏'),
          _buildDivider(),
          _buildMenuItem(Icons.star_border, '我的评分'),
          _buildDivider(),
          _buildMenuItem(Icons.download_outlined, '下载管理'),
        ],
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
      ),
      onTap: () {
        // TODO: 处理菜单项点击
      },
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.borderLight,
    );
  }

  /// 构建关于部分
  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.info_outline, '关于我们'),
          _buildDivider(),
          _buildMenuItem(Icons.feedback_outlined, '意见反馈'),
          _buildDivider(),
          _buildMenuItem(Icons.share_outlined, '分享给朋友'),
        ],
      ),
    );
  }
}
