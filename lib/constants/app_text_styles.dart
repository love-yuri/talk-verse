/*
 * @Author: love-yuri yuri2078170658@gmail.com
 * @Date: 2026-05-21 10:00:56
 * @LastEditTime: 2026-05-28 10:32:20
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 苹果 SF Pro 设计规范的文本样式
/// 使用 MapleMono 字体，统一粗细层次
class AppTextStyles {
  static const String _fontFamily = 'MapleMono';

  // ── 标题 ──
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.35,
    height: 1.27,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.41,
    height: 1.29,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.24,
    height: 1.33,
  );

  // ── 正文 ──
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.24,
    height: 1.33,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.08,
    height: 1.38,
  );

  // ── 标签 ──
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.08,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.07,
  );

  // ── 问候语 ──
  static const TextStyle greeting = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.08,
  );

  // ── 聊天消息 ──
  static const TextStyle chatMessage = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.bubbleAIText,
    letterSpacing: -0.24,
    height: 1.33,
  );
  static const TextStyle chatMessageUser = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.bubbleUserText,
    letterSpacing: -0.24,
    height: 1.33,
  );
  static const TextStyle chatTime = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.07,
  );

  // ── 输入框 ──
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.24,
    height: 1.53,
  );
  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: -0.24,
    height: 1.33,
  );
}
