import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'warm_background.dart';

/// 统一渐变顶栏，与聊天页 AppBar 风格一致
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.chatAppBarStart, AppColors.chatAppBarMid, AppColors.chatAppBarEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.8), letterSpacing: -0.08)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.35)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(badge!, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}
