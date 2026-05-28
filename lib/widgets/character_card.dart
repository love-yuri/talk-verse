import 'dart:io';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/character.dart';
import 'warm_background.dart';

/// 角色卡片组件
class CharacterCard extends StatelessWidget {
  final Character character;
  final int index;
  final VoidCallback? onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.avatarColors[index % AppColors.avatarColors.length];

    return TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 0.6),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'avatar_${character.id}',
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.45), AppColors.surface.withValues(alpha: 0.75)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatar(character.avatar, 36, color),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              character.name,
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String path, double fallbackIconSize, Color color) {
    final fallback = Icon(Icons.person, size: fallbackIconSize, color: color.withValues(alpha: 0.6));
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
