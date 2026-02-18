import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '요리 실력이\n어느 정도인가요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '맞춤 레시피를 위해 알려주세요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(_levels.length, (index) {
            final level = _levels[index];
            final isSelected = selectedLevel == level.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSkillCard(context, level, isSelected),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    _SkillOption level,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged(level.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(level.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
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
