import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/onboarding_state.dart';
import '../../services/auth_service.dart';
import 'step_skill_level.dart';
import 'step_scenarios.dart';
import 'step_cooking_tools.dart';
import 'step_preferences.dart';
import 'step_chef_selection.dart';
import 'step_first_fridge.dart';
import 'step_completion.dart';

/// 온보딩 멀티스텝 화면 (7 페이지)
/// SkillLevel → Scenarios → CookingTools → Preferences → ChefSelection → FirstFridge → Completion
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingState _state = OnboardingState();
  final AuthService _authService = AuthService();

  int _currentPage = 0;

  static const _totalPages = 7;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0: // SkillLevel
        return _state.skillLevel.isNotEmpty;
      case 1: // Scenarios
        return _state.scenarios.isNotEmpty;
      case 2: // CookingTools - 항상 가능
        return true;
      case 3: // Preferences
        return _state.timePreference.isNotEmpty &&
            _state.budgetPreference.isNotEmpty;
      case 4: // ChefSelection
        return _state.chefName.isNotEmpty;
      case 5: // FirstFridge - 항상 가능 (스킵 가능)
        return true;
      case 6: // Completion
        return true;
      default:
        return false;
    }
  }

  Future<bool> _saveOnboardingData() async {
    try {
      await _authService.saveOnboardingData(_state);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompletionPage = _currentPage == _totalPages - 1;
    final stepsCount = _totalPages - 1; // Completion 제외한 스텝 수

    return Scaffold(
      body: Column(
        children: [
          // Progress indicator (Completion 제외)
          if (!isCompletionPage)
            SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // 뒤로가기
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 0 ? _previousPage : null,
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / stepsCount,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 48), // 대칭 여백
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentPage + 1} / $stepsCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                // 0: SkillLevel
                StepSkillLevel(
                  selectedLevel: _state.skillLevel,
                  onChanged: (level) =>
                      setState(() => _state.skillLevel = level),
                ),

                // 1: Scenarios
                StepScenarios(
                  selectedScenarios: _state.scenarios,
                  onChanged: (scenarios) =>
                      setState(() => _state.scenarios = scenarios),
                ),

                // 2: CookingTools
                StepCookingTools(
                  tools: _state.tools,
                  onChanged: (tools) => setState(() => _state.tools = tools),
                ),

                // 3: Preferences
                StepPreferences(
                  timePreference: _state.timePreference,
                  budgetPreference: _state.budgetPreference,
                  onTimeChanged: (t) =>
                      setState(() => _state.timePreference = t),
                  onBudgetChanged: (b) =>
                      setState(() => _state.budgetPreference = b),
                ),

                // 4: ChefSelection
                StepChefSelection(
                  selectedPresetId: _state.selectedPresetId,
                  chefName: _state.chefName,
                  personality: _state.personality,
                  expertise: _state.expertise,
                  formality: _state.formality,
                  emojiUsage: _state.emojiUsage,
                  technicality: _state.technicality,
                  onChanged: ({
                    String? presetId,
                    required String name,
                    required String personality,
                    required List<String> expertise,
                    required String formality,
                    required String emojiUsage,
                    required String technicality,
                  }) {
                    setState(() {
                      _state.selectedPresetId = presetId;
                      _state.chefName = name;
                      _state.personality = personality;
                      _state.expertise = expertise;
                      _state.formality = formality;
                      _state.emojiUsage = emojiUsage;
                      _state.technicality = technicality;
                    });
                  },
                ),

                // 5: FirstFridge
                StepFirstFridge(
                  ingredients: _state.firstIngredients,
                  onChanged: (ingredients) =>
                      setState(() => _state.firstIngredients = ingredients),
                ),

                // 6: Completion
                StepCompletion(
                  chefName: _state.chefName,
                  onSave: _saveOnboardingData,
                  onGoHome: () {
                    if (mounted) context.go('/');
                  },
                ),
              ],
            ),
          ),

          // 하단 버튼 (Completion 제외)
          if (!isCompletionPage)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _canProceed ? _nextPage : null,
                    child: Text(
                      _currentPage == _totalPages - 2 ? '완료' : '다음',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
