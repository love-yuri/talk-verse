import 'package:flutter/material.dart';
import '../widgets/warm_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _sparkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0E6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildMenuSection('我的旅程', [
              _MenuItem(Icons.auto_stories_rounded, '聊天记录', '回顾与AI的对话', const Color(0xFFFF7EB3)),
              _MenuItem(Icons.favorite_rounded, '我的收藏', '珍藏的精彩瞬间', const Color(0xFFFF6B9D)),
              _MenuItem(Icons.workspace_premium_rounded, '成就徽章', '收集所有成就', const Color(0xFFFFD93D)),
              _MenuItem(Icons.photo_library_rounded, '相册壁纸', '二次元美图集', const Color(0xFF6BCB77)),
            ]),
            const SizedBox(height: 14),
            _buildMenuSection('更多功能', [
              _MenuItem(Icons.palette_rounded, '主题装扮', '个性化你的空间', const Color(0xFF4D96FF)),
              _MenuItem(Icons.diamond_rounded, '会员中心', '解锁专属特权', const Color(0xFF9B59B6)),
              _MenuItem(Icons.settings_rounded, '设置', '偏好与账号管理', const Color(0xFF95A5A6)),
            ]),
            const SizedBox(height: 14),
            _buildVersionBadge(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 渐变头部区域
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8B4F8), Color(0xFFB4D0F8), Color(0xFFF8C8E8)],
        ),
      ),
      child: Stack(
        children: [
          // 装饰性闪烁星星
          ..._buildSparkles(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                const Text('✨ 我的空间', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const Spacer(),
                _headerIconBtn(Icons.settings_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    final positions = [
      const Offset(30, 20),
      const Offset(120, 35),
      const Offset(250, 15),
      const Offset(320, 40),
      const Offset(80, 50),
    ];
    return positions.map((pos) => Positioned(
      left: pos.dx,
      top: pos.dy,
      child: AnimatedBuilder(
        animation: _sparkleCtrl,
        builder: (_, anim) {
          final v = (_sparkleCtrl.value + pos.dx / 400) % 1.0;
          final opacity = (v < 0.5 ? v * 2 : (1 - v) * 2).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity * 0.7,
            child: const Text('✦', style: TextStyle(fontSize: 12, color: Colors.white)),
          );
        },
      ),
    )).toList();
  }

  Widget _headerIconBtn(IconData icon) {
    return TapScale(
      onTap: () {},
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  /// 个人资料卡片
  Widget _buildProfileCard() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFFE8B4F8).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9EC6), Color(0xFFB4D0F8)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE8B4F8).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text('🎀', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 用户名
            const Text('冒险者', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 4),
            // 等级标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFB6D9), Color(0xFFD4BBFF)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Lv.5 星见者', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            // 个性签名
            Text(
              '与AI相遇的每一天都充满惊喜 ✨',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
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
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF6B4E9B))),
        const SizedBox(height: 2),
        Text('$emoji $label', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFE8D8F0),
    );
  }

  /// 菜单区块
  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE8B4F8).withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B4E9B))),
          ),
          ...items.asMap().entries.map((e) => Column(children: [
            _buildMenuItem(e.value),
            if (e.key < items.length - 1)
              Divider(height: 0.5, indent: 56, color: const Color(0xFFF0E6F6)),
          ])),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return TapScale(
      onTap: () {},
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
                Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                Text(item.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[300]),
        ]),
      ),
    );
  }

  /// 版本徽章
  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF8C8E8), Color(0xFFD4BBFF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('TalkVerse v1.0.0 ♡', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _MenuItem(this.icon, this.label, this.subtitle, this.color);
}
