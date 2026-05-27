import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'warm_background.dart';

/// 统一渐变顶栏，与聊天页 AppBar 高度一致
class GlassHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final String? badge;
  final List<Widget>? actions;

  const GlassHeader({
    super.key,
    required this.subtitle,
    required this.title,
    this.badge,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(
              subtitle,
              style: TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.78)),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.24),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
            const Spacer(),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  /// 统一操作按钮样式（白色半透明底，白色图标）
  static Widget iconBtn(IconData icon, {VoidCallback? onTap}) {
    return TapScale(
      onTap: onTap ?? () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
