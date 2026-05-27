import 'package:flutter/material.dart';

/// 淡雅低饱和色系
class AppColors {
  static const Color background = Color(0xFFF7F3EE);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceAlt = Color(0xFFF1F5F2);
  static const Color surfaceGlass = Color(0xDFFFFCF8);
  static const Color surfaceOverlay = Color(0xBFFFFFFF);

  static const Color textPrimary = Color(0xFF34383A);
  static const Color textSecondary = Color(0xFF7A8584);
  static const Color textTertiary = Color(0xFFA8B2B0);
  static const Color textMuted = Color(0xFFB8B8AD);

  static const Color accent = Color(0xFF7EA6A1);
  static const Color accentLight = Color(0xFFE3EFEC);
  static const Color accentSoft = Color(0xFFC9DDD8);

  static const Color border = Color(0xFFE5E1D8);
  static const Color divider = Color(0xFFEEE9E1);

  static const Color gradPink = Color(0xFFEFC9C5);
  static const Color gradPurple = Color(0xFFD8D2E8);
  static const Color gradBlue = Color(0xFFC9DCE8);
  static const Color gradMint = Color(0xFFC9DDD8);
  static const Color gradCream = Color(0xFFF1DEC2);

  static const Color bubbleUser = Color(0xFFDDEBE8);
  static const Color bubbleUserText = Color(0xFFFFFFFF);
  static const Color bubbleAI = Color(0xFFFFFCF8);
  static const Color bubbleAIText = Color(0xFF34383A);

  static const Color chatAppBarStart = Color(0xFFC9DDD8);
  static const Color chatAppBarMid = Color(0xFFC9DCE8);
  static const Color chatAppBarEnd = Color(0xFFEADBD0);

  static const Color navActive = Color(0xFF6F9691);
  static const Color navInactive = Color(0xFFA8B2B0);
  static const Color navBackground = Color(0xEFFFFCF8);

  static const Color shadow = Color(0x1A7EA6A1);
  static const Color cardShadow = Color(0x147EA6A1);

  static const Color success = Color(0xFF8BAF9A);
  static const Color warning = Color(0xFFD8B56A);
  static const Color error = Color(0xFFD77872);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF9FB8C9)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [chatAppBarStart, chatAppBarMid, chatAppBarEnd],
  );

  static const LinearGradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F5EF), Color(0xFFF1F6F3), Color(0xFFF7F3EE)],
  );

  static const List<Color> avatarColors = [
    Color(0xFFEFC9C5),
    Color(0xFFD8D2E8),
    Color(0xFFC9DCE8),
    Color(0xFFC9DDD8),
    Color(0xFFF1DEC2),
  ];
}
