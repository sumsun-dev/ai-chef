import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 재사용 레시피 카드 위젯
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final Widget? trailing;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                recipe.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildBadge(Icons.timer_outlined, '${recipe.cookingTime}분'),
                  const SizedBox(width: AppSpacing.sm),
                  _buildBadge(
                    Icons.signal_cellular_alt,
                    _difficultyLabel(recipe.difficulty),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildBadge(Icons.people_outline, '${recipe.servings}인분'),
                  const Spacer(),
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _difficultyLabel(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return '쉬움';
      case RecipeDifficulty.medium:
        return '보통';
      case RecipeDifficulty.hard:
        return '어려움';
    }
  }
}
