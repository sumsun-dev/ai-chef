import 'package:flutter/material.dart';

import '../../models/chef_presets.dart';

/// 온보딩 Step 3: AI 셰프 선택 (기존 onboarding_screen에서 추출)
class StepChefSelection extends StatefulWidget {
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

  @override
  State<StepChefSelection> createState() => _StepChefSelectionState();
}

class _StepChefSelectionState extends State<StepChefSelection> {
  late final TextEditingController _nameController;
  bool _showCustomization = false;

  late String _personality;
  late List<String> _expertise;
  late String _formality;
  late String _emojiUsage;
  late String _technicality;

  final Map<String, String> _personalityOptions = const {
    'professional': '프로페셔널',
    'friendly': '친근한 친구',
    'motherly': '다정한 엄마',
    'coach': '열정적인 코치',
    'scientific': '과학적 분석가',
  };

  final List<String> _expertiseOptions = const [
    '한식', '일식', '중식', '이탈리아식', '프랑스식',
    '멕시칸', '인도식', '태국식', '베이킹', '채식/비건',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chefName);
    _personality = widget.personality;
    _expertise = List.from(widget.expertise);
    _formality = widget.formality;
    _emojiUsage = widget.emojiUsage;
    _technicality = widget.technicality;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _applyPreset(ChefPreset preset) {
    setState(() {
      _nameController.text = preset.config.name;
      _personality = preset.config.personality.name;
      _expertise = List.from(preset.config.expertise);
      _formality = preset.config.speakingStyle.formality.name;
      _emojiUsage = preset.config.speakingStyle.emojiUsage.name;
      _technicality = preset.config.speakingStyle.technicality.name;
    });
    _notifyParent(presetId: preset.id);
  }

  void _notifyParent({String? presetId}) {
    widget.onChanged(
      presetId: presetId ?? widget.selectedPresetId,
      name: _nameController.text,
      personality: _personality,
      expertise: _expertise,
      formality: _formality,
      emojiUsage: _emojiUsage,
      technicality: _technicality,
    );
  }

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
            'AI 셰프를\n선택하세요',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '원하는 캐릭터를 선택하거나 직접 설정하세요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // 프리셋 가로 스크롤
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ChefPresets.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final preset = ChefPresets.all[index];
                final isSelected = widget.selectedPresetId == preset.id;
                return GestureDetector(
                  onTap: () => _applyPreset(preset),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(preset.emoji,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          preset.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 상세 설정 토글
          InkWell(
            onTap: () =>
                setState(() => _showCustomization = !_showCustomization),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _showCustomization
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showCustomization ? '상세 설정 접기' : '상세 설정 펼치기',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_showCustomization) ...[
            const SizedBox(height: 16),

            // AI 셰프 이름
            const Text('AI 셰프 이름',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '예: 요리왕 김셰프, 마스터 킴',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 24),

            // 성격
            const Text('AI 셰프 성격',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _personalityOptions.entries.map((entry) {
                final isSelected = _personality == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _personality = entry.key);
                      _notifyParent();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 전문 분야
            const Text('전문 분야 (복수 선택 가능)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _expertiseOptions.map((option) {
                final isSelected = _expertise.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _expertise.add(option);
                      } else {
                        _expertise.remove(option);
                      }
                    });
                    _notifyParent();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 말투
            const Text('말투 설정',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'formal', label: Text('존댓말')),
                ButtonSegment(value: 'casual', label: Text('반말')),
              ],
              selected: {_formality},
              onSelectionChanged: (value) {
                setState(() => _formality = value.first);
                _notifyParent();
              },
            ),
            const SizedBox(height: 16),

            // 이모지
            const Text('이모지 사용'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'high', label: Text('많이')),
                ButtonSegment(value: 'medium', label: Text('보통')),
                ButtonSegment(value: 'low', label: Text('적게')),
                ButtonSegment(value: 'none', label: Text('없음')),
              ],
              selected: {_emojiUsage},
              onSelectionChanged: (value) {
                setState(() => _emojiUsage = value.first);
                _notifyParent();
              },
            ),
            const SizedBox(height: 16),

            // 전문 용어
            const Text('설명 수준'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expert', label: Text('전문가')),
                ButtonSegment(value: 'general', label: Text('일반')),
                ButtonSegment(value: 'beginner', label: Text('초보자')),
              ],
              selected: {_technicality},
              onSelectionChanged: (value) {
                setState(() => _technicality = value.first);
                _notifyParent();
              },
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
