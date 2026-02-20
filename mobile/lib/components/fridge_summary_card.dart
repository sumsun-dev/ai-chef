import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 홈 탭 냉장고 미니 요약 카드
class FridgeSummaryCard extends StatelessWidget {
  final List<Ingredient> ingredients;
  final int expiringCount;
  final VoidCallback? onTap;

  const FridgeSummaryCard({
    super.key,
    required this.ingredients,
    required this.expiringCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = ingredients.length;
    final fridgeCount = ingredients
        .where((i) => i.storageLocation == StorageLocation.fridge)
        .length;
    final freezerCount = ingredients
        .where((i) => i.storageLocation == StorageLocation.freezer)
        .length;
    final pantryCount = ingredients
        .where((i) => i.storageLocation == StorageLocation.pantry)
        .length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🧊', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '내 냉장고',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '총 $total개',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildLocationChip('냉장', fridgeCount, Icons.kitchen),
                const SizedBox(width: AppSpacing.md),
                _buildLocationChip('냉동', freezerCount, Icons.ac_unit),
                const SizedBox(width: AppSpacing.md),
                _buildLocationChip('실온', pantryCount, Icons.home),
                const Spacer(),
                if (expiringCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '임박 $expiringCount개',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(String label, int count, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          '$label $count',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
