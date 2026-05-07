import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3);
  static const TextStyle h3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static const TextStyle body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.45);
  static const TextStyle bodySmall = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.3);

  static const TextStyle label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  static const TextStyle greeting = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  static const TextStyle chatMessage = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.45);
  static const TextStyle chatMessageWhite = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white, height: 1.45);
  static const TextStyle chatTime = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  static const TextStyle input = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const TextStyle inputHint = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
}
