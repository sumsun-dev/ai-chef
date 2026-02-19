import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 온보딩 Step 2a: 요리 실력 선택
class StepSkillLevel extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onChanged;

  const StepSkillLevel({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  static const _levels = [
    _SkillOption('beginner', '🌱', '요리 초보', '라면은 끓일 수 있어요'),
    _SkillOption('novice', '🍳', '기본 요리 가능', '간단한 볶음, 찌개 정도'),
    _SkillOption('intermediate', '👨‍🍳', '어느 정도', '웬만한 요리는 해요'),
    _SkillOption('advanced', '⭐', '요리 고수', '새로운 도전이 즐거워요'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            '요리 실력이\n어느 정도인가요?',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '맞춤 레시피를 위해 알려주세요',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...List.generate(_levels.length, (index) {
            final level = _levels[index];
            final isSelected = selectedLevel == level.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildSkillCard(context, level, isSelected),
            );
          }),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '나머지 설정은 언제든 프로필에서 변경할 수 있어요',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    _SkillOption level,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onChanged(level.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(level.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SkillOption {
  final String key;
  final String emoji;
  final String title;
  final String subtitle;

  const _SkillOption(this.key, this.emoji, this.title, this.subtitle);
}
