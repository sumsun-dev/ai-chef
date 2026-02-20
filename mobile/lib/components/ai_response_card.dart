import 'package:flutter/material.dart';

import '../models/ai_response.dart';
import '../models/ingredient.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// AI 응답 타입별 UI 카드 위젯
class AIResponseCard extends StatelessWidget {
  final AIResponse response;
  final VoidCallback? onRecipeTap;

  const AIResponseCard({
    super.key,
    required this.response,
    this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (response) {
      TextResponse(text: final text) => _buildTextCard(text),
      RecipeResponse(recipe: final recipe, summary: final summary) =>
        _buildRecipeCard(recipe.title, summary),
      IngredientListResponse(
        ingredients: final ingredients,
        commentary: final commentary
      ) =>
        _buildIngredientCard(ingredients, commentary),
      ActionResponse(
        actionType: final type,
        success: final success,
        message: final message
      ) =>
        _buildActionCard(type, success, message),
    };
  }

  Widget _buildTextCard(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
    );
  }

  Widget _buildRecipeCard(String title, String summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty)
          Text(
            summary,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onRecipeTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(
      List<Ingredient> ingredients, String commentary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (commentary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              commentary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.kitchen,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '재료 ${ingredients.length}개',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: ingredients.map((ingredient) {
                  return Chip(
                    label: Text(
                      '${ingredient.name} ${ingredient.quantity}${ingredient.unit}',
                      style: AppTypography.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String type, bool success, String message) {
    final color = success ? AppColors.success : AppColors.error;
    final icon = success ? Icons.check_circle : Icons.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
