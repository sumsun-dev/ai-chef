import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/onboarding_state.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'step_skill_level.dart';
import 'step_chef_selection.dart';
import 'step_completion.dart';

/// 온보딩 멀티스텝 화면 (3 페이지)
/// ChefSelection -> SkillLevel -> Completion
class OnboardingScreen extends StatefulWidget {
  final AuthService? authService;
  const OnboardingScreen({super.key, this.authService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingState _state = OnboardingState();
  late final AuthService _authService;

  int _currentPage = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  static const _totalPages = 3;

  Future<void> _nextPage() async {
    if (_isAnimating || _currentPage >= _totalPages - 1) return;
    setState(() => _isAnimating = true);
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) setState(() => _isAnimating = false);
  }

  Future<void> _previousPage() async {
    if (_isAnimating || _currentPage <= 0) return;
    setState(() => _isAnimating = true);
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) setState(() => _isAnimating = false);
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _state.chefName.isNotEmpty;
      case 1:
        return _state.skillLevel.isNotEmpty;
      case 2:
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
    final isCompletionPage = _currentPage == _totalPages - 1;
    final stepsCount = _totalPages - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Progress indicator (Completion 제외)
            if (!isCompletionPage)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 0 && !_isAnimating
                                ? _previousPage
                                : null,
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (_currentPage + 1) / stepsCount,
                              backgroundColor: AppColors.surfaceDim,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${_currentPage + 1} / $stepsCount',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // PageView
            Expanded(
              key: const ValueKey('onboarding-pageview'),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
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
                  StepSkillLevel(
                    selectedLevel: _state.skillLevel,
                    onChanged: (level) =>
                        setState(() => _state.skillLevel = level),
                  ),
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    0,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed:
                          _canProceed && !_isAnimating ? _nextPage : null,
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
      ),
    );
  }
}
