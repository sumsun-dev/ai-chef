import 'package:flutter/material.dart';

/// 온보딩 Step 2d: 시간/예산 선호도
class StepPreferences extends StatelessWidget {
  final String timePreference;
  final String budgetPreference;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onBudgetChanged;

  const StepPreferences({
    super.key,
    required this.timePreference,
    required this.budgetPreference,
    required this.onTimeChanged,
    required this.onBudgetChanged,
  });

  static const _timeOptions = [
    _PrefOption('10min', '⚡', '10분 이내'),
    _PrefOption('20min', '⏱️', '20분 이내'),
    _PrefOption('40min', '🕐', '40분 이내'),
    _PrefOption('unlimited', '🍽️', '시간 여유'),
  ];

  static const _budgetOptions = [
    _PrefOption('low', '💰', '절약형'),
    _PrefOption('medium', '💵', '보통'),
    _PrefOption('high', '💎', '프리미엄'),
    _PrefOption('unlimited', '🌟', '제한 없음'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '요리 시간과\n예산은?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선호하는 스타일을 알려주세요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // 시간 선호도
          Text(
            '선호 요리 시간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeOptions.map((opt) {
              final isSelected = timePreference == opt.key;
              return ChoiceChip(
                label: Text('${opt.emoji} ${opt.label}'),
                selected: isSelected,
                onSelected: (_) => onTimeChanged(opt.key),
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 예산 선호도
          Text(
            '예산 선호도',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _budgetOptions.map((opt) {
              final isSelected = budgetPreference == opt.key;
              return ChoiceChip(
                label: Text('${opt.emoji} ${opt.label}'),
                selected: isSelected,
                onSelected: (_) => onBudgetChanged(opt.key),
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PrefOption {
  final String key;
  final String emoji;
  final String label;

  const _PrefOption(this.key, this.emoji, this.label);
}
