import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/chef_presets.dart';
import '../models/chef_config.dart';
import '../services/auth_service.dart';

/// 온보딩 화면 - AI 셰프 설정
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'AI 셰프');

  String? _selectedPresetId;
  bool _showCustomization = false;

  String _personality = 'friendly';
  List<String> _expertise = ['한식'];
  String _formality = 'formal';
  String _emojiUsage = 'medium';
  String _technicality = 'general';

  bool _isLoading = false;

  void _applyPreset(ChefPreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _nameController.text = preset.config.name;
      _personality = preset.config.personality.name;
      _expertise = List.from(preset.config.expertise);
      _formality = preset.config.speakingStyle.formality.name;
      _emojiUsage = preset.config.speakingStyle.emojiUsage.name;
      _technicality = preset.config.speakingStyle.technicality.name;
    });
  }

  final Map<String, String> _personalityOptions = {
    'professional': '프로페셔널',
    'friendly': '친근한 친구',
    'motherly': '다정한 엄마',
    'coach': '열정적인 코치',
    'scientific': '과학적 분석가',
  };

  final List<String> _expertiseOptions = [
    '한식',
    '일식',
    '중식',
    '이탈리아식',
    '프랑스식',
    '멕시칸',
    '인도식',
    '태국식',
    '베이킹',
    '채식/비건',
  ];

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.updateAIChefSettings(
        name: _nameController.text,
        personality: _personality,
        expertise: _expertise,
        formality: _formality,
        emojiUsage: _emojiUsage,
        technicality: _technicality,
      );

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 셰프 설정'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '나만의 AI 셰프를 만들어보세요!\n취향에 맞는 요리 파트너가 될 거예요.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 캐릭터 프리셋 선택
            const Text(
              '추천 AI 셰프',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '원하는 캐릭터를 선택하거나, 아래에서 직접 설정하세요',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ChefPresets.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final preset = ChefPresets.all[index];
                  final isSelected = _selectedPresetId == preset.id;
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
                          Text(
                            preset.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
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
                                      .withOpacity(0.8)
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
            const SizedBox(height: 24),

            // 상세 설정 토글
            InkWell(
              onTap: () => setState(() => _showCustomization = !_showCustomization),
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

            // 상세 설정 섹션 (접기/펼치기)
            if (_showCustomization) ...[
              const SizedBox(height: 16),

              // AI 셰프 이름
            const Text(
              'AI 셰프 이름',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '예: 요리왕 김셰프, 마스터 킴',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 성격
            const Text(
              'AI 셰프 성격',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 전문 분야
            const Text(
              '전문 분야 (복수 선택 가능)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 말투 설정
            const Text(
              '말투 설정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'formal', label: Text('존댓말')),
                      ButtonSegment(value: 'casual', label: Text('반말')),
                    ],
                    selected: {_formality},
                    onSelectionChanged: (value) {
                      setState(() => _formality = value.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이모지 사용
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
              },
            ),
            const SizedBox(height: 16),

            // 전문 용어 수준
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
              },
            ),
            ],  // end if (_showCustomization)

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveSettings,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '시작하기',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
