import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_sharing_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 레시피 공유 바텀 시트
class RecipeShareSheet extends StatelessWidget {
  final Recipe recipe;
  final RecipeSharingService? sharingService;

  const RecipeShareSheet({
    super.key,
    required this.recipe,
    this.sharingService,
  });

  @override
  Widget build(BuildContext context) {
    final service = sharingService ?? RecipeSharingService();
    final previewText = service.formatRecipeAsText(recipe);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '레시피 공유',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  previewText,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await service.shareRecipe(recipe);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('공유하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
