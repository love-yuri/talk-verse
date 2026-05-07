import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B8FF5);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primarySurface = Color(0xFFF0EDFD);

  // 强调色
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFFA8A8);

  // 背景色
  static const Color background = Color(0xFFF7F5F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F0ED);

  // 文本颜色
  static const Color textPrimary = Color(0xFF2D2B2E);
  static const Color textSecondary = Color(0xFF787479);
  static const Color textTertiary = Color(0xFFAEAAB2);

  // 聊天气泡颜色
  static const Color bubbleUser = Color(0xFF6C5CE7);
  static const Color bubbleAI = Color(0xFFFFFFFF);

  // 状态颜色
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFA502);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF70A1FF);

  // 边框颜色
  static const Color border = Color(0xFFE8E5E0);
  static const Color borderLight = Color(0xFFF0EDE8);

  // 阴影颜色
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);

  // 毛玻璃效果颜色
  static const Color glass = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B78F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFF7F5F2), Color(0xFFEFECF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 角色头像渐变
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF6C5CE7), Color(0xFF8B78F7)],
    [Color(0xFFFF6B6B), Color(0xFFFFA8A8)],
    [Color(0xFF1DD1A1), Color(0xFF7FE5D4)],
    [Color(0xFFFFA502), Color(0xFFFFD93D)],
    [Color(0xFF70A1FF), Color(0xFFA8D8FF)],
  ];
}
