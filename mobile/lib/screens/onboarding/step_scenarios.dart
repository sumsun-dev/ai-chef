import 'package:flutter/material.dart';

/// 온보딩 Step 2b: 주요 상황 선택
class StepScenarios extends StatelessWidget {
  final List<String> selectedScenarios;
  final ValueChanged<List<String>> onChanged;

  const StepScenarios({
    super.key,
    required this.selectedScenarios,
    required this.onChanged,
  });

  static const _scenarios = [
    _ScenarioOption('solo', '🍚', '혼밥/자취'),
    _ScenarioOption('couple', '💑', '둘이서'),
    _ScenarioOption('family', '👨‍👩‍👧‍👦', '가족 식사'),
    _ScenarioOption('kids', '🧒', '아이 간식'),
    _ScenarioOption('lunchbox', '🍱', '도시락'),
    _ScenarioOption('party', '🎉', '손님 접대'),
    _ScenarioOption('diet', '🥗', '다이어트'),
    _ScenarioOption('midnight', '🌙', '야식'),
    _ScenarioOption('quick', '⚡', '초스피드 요리'),
  ];

  void _toggleScenario(String key) {
    final updated = List<String>.from(selectedScenarios);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '주로 어떤 상황에서\n요리하나요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '복수 선택 가능 (최소 1개)',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _scenarios.map((scenario) {
              final isSelected = selectedScenarios.contains(scenario.key);
              return FilterChip(
                label: Text('${scenario.emoji} ${scenario.label}'),
                selected: isSelected,
                onSelected: (_) => _toggleScenario(scenario.key),
                showCheckmark: false,
                selectedColor: colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ScenarioOption {
  final String key;
  final String emoji;
  final String label;

  const _ScenarioOption(this.key, this.emoji, this.label);
}
