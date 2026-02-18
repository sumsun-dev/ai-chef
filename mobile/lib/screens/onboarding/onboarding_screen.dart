import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/onboarding_state.dart';
import '../../services/auth_service.dart';
import 'step_welcome.dart';
import 'step_skill_level.dart';
import 'step_scenarios.dart';
import 'step_cooking_tools.dart';
import 'step_preferences.dart';
import 'step_chef_selection.dart';
import 'step_first_fridge.dart';
import 'step_completion.dart';

/// 온보딩 멀티스텝 화면 (7 페이지)
/// Welcome → SkillLevel → Scenarios → CookingTools → Preferences → ChefSelection → FirstFridge+Completion
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
  bool _isLoading = false;

  static const _totalPages = 8;

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
      case 0: // Welcome - 항상 가능 (버튼에서 직접 호출)
        return true;
      case 1: // SkillLevel
        return _state.skillLevel.isNotEmpty;
      case 2: // Scenarios
        return _state.scenarios.isNotEmpty;
      case 3: // CookingTools - 항상 가능
        return true;
      case 4: // Preferences
        return _state.timePreference.isNotEmpty &&
            _state.budgetPreference.isNotEmpty;
      case 5: // ChefSelection
        return _state.chefName.isNotEmpty;
      case 6: // FirstFridge - 항상 가능 (스킵 가능)
        return true;
      case 7: // Completion
        return true;
      default:
        return false;
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      await _authService.saveOnboardingData(_state);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWelcomePage = _currentPage == 0;
    final isCompletionPage = _currentPage == _totalPages - 1;

    return Scaffold(
      body: Column(
        children: [
          // Progress indicator (Welcome, Completion 제외)
          if (!isWelcomePage && !isCompletionPage)
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
                          onPressed: _previousPage,
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (_currentPage) / (_totalPages - 2),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 48), // 대칭 여백
                      ],
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
                // 0: Welcome
                StepWelcome(onNext: _nextPage),

                // 1: SkillLevel
                StepSkillLevel(
                  selectedLevel: _state.skillLevel,
                  onChanged: (level) =>
                      setState(() => _state.skillLevel = level),
                ),

                // 2: Scenarios
                StepScenarios(
                  selectedScenarios: _state.scenarios,
                  onChanged: (scenarios) =>
                      setState(() => _state.scenarios = scenarios),
                ),

                // 3: CookingTools
                StepCookingTools(
                  tools: _state.tools,
                  onChanged: (tools) => setState(() => _state.tools = tools),
                ),

                // 4: Preferences
                StepPreferences(
                  timePreference: _state.timePreference,
                  budgetPreference: _state.budgetPreference,
                  onTimeChanged: (t) =>
                      setState(() => _state.timePreference = t),
                  onBudgetChanged: (b) =>
                      setState(() => _state.budgetPreference = b),
                ),

                // 5: ChefSelection
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

                // 6: FirstFridge
                StepFirstFridge(
                  ingredients: _state.firstIngredients,
                  onChanged: (ingredients) =>
                      setState(() => _state.firstIngredients = ingredients),
                ),

                // 7: Completion
                StepCompletion(
                  chefName: _state.chefName,
                  isLoading: _isLoading,
                  onComplete: _completeOnboarding,
                ),
              ],
            ),
          ),

          // 하단 버튼 (Welcome, Completion 제외)
          if (!isWelcomePage && !isCompletionPage)
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
