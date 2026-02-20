import 'package:flutter/material.dart';

import '../../models/chef_presets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 온보딩 Step 0: AI 셰프 선택 (프리셋 그리드)
class StepChefSelection extends StatelessWidget {
  final String? selectedPresetId;
  final String chefName;
  final String personality;
  final List<String> expertise;
  final String formality;
  final String emojiUsage;
  final String technicality;
  final void Function({
    String? presetId,
    required String name,
    required String personality,
    required List<String> expertise,
    required String formality,
    required String emojiUsage,
    required String technicality,
  }) onChanged;

  const StepChefSelection({
    super.key,
    required this.selectedPresetId,
    required this.chefName,
    required this.personality,
    required this.expertise,
    required this.formality,
    required this.emojiUsage,
    required this.technicality,
    required this.onChanged,
  });

  void _applyPreset(ChefPreset preset) {
    onChanged(
      presetId: preset.id,
      name: preset.config.name,
      personality: preset.config.personality.name,
      expertise: List.from(preset.config.expertise),
      formality: preset.config.speakingStyle.formality.name,
      emojiUsage: preset.config.speakingStyle.emojiUsage.name,
      technicality: preset.config.speakingStyle.technicality.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            '나만의 AI 셰프를\n골라주세요',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '어떤 스타일의 셰프와 함께할까요?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 프리셋 2열 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.1,
            ),
            itemCount: ChefPresets.all.length,
            itemBuilder: (context, index) {
              final preset = ChefPresets.all[index];
              final isSelected = selectedPresetId == preset.id;
              return _buildPresetCard(context, preset, isSelected);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          Center(
            child: Text(
              '나중에 프로필에서 자세히 설정할 수 있어요',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    ChefPreset preset,
    bool isSelected,
  ) {
    final hintColor = Color(preset.primaryColor);

    return GestureDetector(
      onTap: () => _applyPreset(preset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? hintColor.withValues(alpha: 0.12)
              : hintColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? Border.all(color: hintColor, width: 2)
              : Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(preset.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              preset.name,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 13,
                color: isSelected ? hintColor : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              preset.description,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
