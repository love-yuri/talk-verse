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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: const Color(0xFFF0E6F6), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'avatar_${character.id}',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    character.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _) => Icon(Icons.person, size: 32, color: color.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              character.name,
              style: const TextStyle(fontFamily: 'MapleMono', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.24),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                character.description,
                style: const TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.07),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: character.tags.take(2).map((tag) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(tag, style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, fontWeight: FontWeight.w500, color: color.withValues(alpha: 0.85))),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
