import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

/// 프로필 > 요리 설정 편집 화면
class ProfileEditScreen extends StatefulWidget {
  final AuthService? authService;

  const ProfileEditScreen({super.key, this.authService});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final AuthService _authService;

  String _skillLevel = 'beginner';
  List<String> _scenarios = [];
  String _timePreference = '20min';
  String _budgetPreference = 'medium';
  int _householdSize = 1;
  bool _isLoading = true;
  bool _isSaving = false;

  static const _skillOptions = {
    'beginner': '왕초보',
    'novice': '초보',
    'intermediate': '중급',
    'advanced': '고급',
  };

  static const _scenarioOptions = [
    '혼밥', '가족 식사', '손님 접대', '도시락', '야식',
    '다이어트', '건강식', '간식',
  ];

  static const _timeOptions = {
    '10min': '10분 이내',
    '20min': '20분 이내',
    '40min': '40분 이내',
    'unlimited': '상관없음',
  };

  static const _budgetOptions = {
    'low': '3천원 이하',
    'medium': '3-5천원',
    'high': '5천원 이상',
    'unlimited': '상관없음',
  };

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _skillLevel = profile['skill_level'] ?? 'beginner';
          _scenarios = List<String>.from(profile['scenarios'] ?? []);
          _timePreference = profile['time_preference'] ?? '20min';
          _budgetPreference = profile['budget_preference'] ?? 'medium';
          _householdSize = profile['household_size'] ?? 1;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _authService.updateUserProfile({
        'skill_level': _skillLevel,
        'scenarios': _scenarios,
        'time_preference': _timePreference,
        'budget_preference': _budgetPreference,
        'household_size': _householdSize,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('요리 설정'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 요리 실력
                  _buildSectionTitle('요리 실력'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillOptions.entries.map((entry) {
                      final isSelected = _skillLevel == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _skillLevel = entry.key);
                          }
                        },
                        selectedColor: colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 요리 시나리오
                  _buildSectionTitle('요리 시나리오 (복수 선택)'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _scenarioOptions.map((option) {
                      final isSelected = _scenarios.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _scenarios.add(option);
                            } else {
                              _scenarios.remove(option);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 가구원 수
                  _buildSectionTitle('가구원 수'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(5, (i) {
                      final count = i + 1;
                      final isSelected = _householdSize == count;
                      return ChoiceChip(
                        label: Text('$count명${count == 5 ? '+' : ''}'),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _householdSize = count),
                        selectedColor: colorScheme.primaryContainer,
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 선호 조리시간
                  _buildSectionTitle('선호 조리시간'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeOptions.entries.map((entry) {
                      final isSelected = _timePreference == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _timePreference = entry.key);
                          }
                        },
                        selectedColor: colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 1인분 예산
                  _buildSectionTitle('1인분 예산'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _budgetOptions.entries.map((entry) {
                      final isSelected = _budgetPreference == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _budgetPreference = entry.key);
                          }
                        },
                        selectedColor: colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
