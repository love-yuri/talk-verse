import 'package:flutter/material.dart';

/// 应用颜色常量
/// 定义应用中使用的颜色，保持一致性
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF6366F1); // 靛蓝色
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // 背景色
  static const Color background = Color(0xFFF8FAFC); // 浅灰色背景
  static const Color surface = Color(0xFFFFFFFF); // 白色表面
  static const Color surfaceVariant = Color(0xFFF1F5F9); // 浅灰色表面

  // 文本颜色
  static const Color textPrimary = Color(0xFF1E293B); // 深灰色
  static const Color textSecondary = Color(0xFF64748B); // 中灰色
  static const Color textTertiary = Color(0xFF94A3B8); // 浅灰色

  // 聊天气泡颜色
  static const Color bubbleUser = Color(0xFF6366F1); // 用户消息气泡
  static const Color bubbleAI = Color(0xFFFFFFFF); // AI消息气泡

  // 状态颜色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 边框颜色
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // 阴影颜色
  static const Color shadow = Color(0x1A000000);

  // 毛玻璃效果颜色
  static const Color glass = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
