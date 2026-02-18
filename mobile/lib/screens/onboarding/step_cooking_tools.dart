import 'package:flutter/material.dart';

import '../../models/onboarding_state.dart';

/// 온보딩 Step 2c: 조리 도구 확인
class StepCookingTools extends StatelessWidget {
  final Map<String, bool> tools;
  final ValueChanged<Map<String, bool>> onChanged;

  const StepCookingTools({
    super.key,
    required this.tools,
    required this.onChanged,
  });

  static const _toolEmojis = {
    'frying_pan': '🍳',
    'pot': '🫕',
    'stove': '🔥',
    'microwave': '📡',
    'rice_cooker': '🍚',
    'air_fryer': '🌪️',
    'oven': '♨️',
    'blender': '🥤',
  };

  void _toggleTool(String key, bool value) {
    final updated = Map<String, bool>.from(tools);
    updated[key] = value;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orderedKeys = tools.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '어떤 조리 도구가\n있나요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '있는 도구를 켜주세요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: orderedKeys.length,
              itemBuilder: (context, index) {
                final key = orderedKeys[index];
                final isAvailable = tools[key] ?? false;
                final name = OnboardingState.toolKeyToName[key] ?? key;
                final emoji = _toolEmojis[key] ?? '🔧';

                return SwitchListTile(
                  title: Text('$emoji  $name'),
                  value: isAvailable,
                  onChanged: (value) => _toggleTool(key, value),
                  activeTrackColor: colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
