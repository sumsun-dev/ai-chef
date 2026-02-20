import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../components/cooking_timer.dart';
import '../models/recipe.dart';
import '../services/cooking_audio_service.dart';
import '../services/recipe_service.dart';
import '../services/tts_service.dart';
import '../services/voice_command_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 요리 시작 모드 화면
///
/// PageView로 한 번에 한 단계 집중 표시,
/// 단계별 카운트다운 타이머, 완료 시 기록 자동 저장.
/// TTS로 단계 자동 읽기, 음성 명령으로 핸즈프리 조작.
class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  final RecipeService? recipeService;
  final TtsService? ttsService;
  final VoiceCommandService? voiceCommandService;
  final CookingAudioService? audioService;

  const CookingModeScreen({
    super.key,
    required this.recipe,
    this.recipeService,
    this.ttsService,
    this.voiceCommandService,
    this.audioService,
  });

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  late final PageController _pageController;
  late final RecipeService _recipeService;
  late final TtsService _ttsService;
  late final VoiceCommandService _voiceCommandService;
  late final CookingAudioService _audioService;
  late final List<RecipeInstruction> _steps;
  final Set<int> _completedSteps = {};
  int _currentPage = 0;
  bool _isSavingHistory = false;
  bool _isTtsEnabled = false;
  bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _recipeService = widget.recipeService ?? RecipeService();
    _ttsService = widget.ttsService ?? TtsService();
    _voiceCommandService = widget.voiceCommandService ?? VoiceCommandService();
    _audioService = widget.audioService ?? CookingAudioService();
    _steps = widget.recipe.instructions;
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ttsService.dispose();
    _voiceCommandService.stopListening();
    _audioService.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  /// TTS로 현재 단계 읽기
  Future<void> _speakCurrentStep() async {
    if (!_isTtsEnabled || _steps.isEmpty) return;
    final step = _steps[_currentPage];
    final text = '${step.step}단계. ${step.title}. ${step.description}';
    await _ttsService.speak(text);
  }

  /// TTS 토글
  void _toggleTts() {
    setState(() => _isTtsEnabled = !_isTtsEnabled);
    if (_isTtsEnabled) {
      _speakCurrentStep();
    } else {
      _ttsService.stop();
    }
  }

  /// 음성 명령 리스닝 토글
  Future<void> _toggleVoiceListening() async {
    if (_isVoiceListening) {
      await _voiceCommandService.stopListening();
      setState(() => _isVoiceListening = false);
      return;
    }

    setState(() => _isVoiceListening = true);
    await _voiceCommandService.startListening(
      onCommand: _handleVoiceCommand,
    );
  }

  /// 음성 명령 처리
  void _handleVoiceCommand(VoiceCommand command) {
    setState(() => _isVoiceListening = false);

    switch (command) {
      case NextStepCommand():
        if (_currentPage < _steps.length - 1) {
          _goToPage(_currentPage + 1);
        }
      case PreviousStepCommand():
        if (_currentPage > 0) {
          _goToPage(_currentPage - 1);
        }
      case StartTimerCommand():
        // 타이머 시작은 위젯 내부에서 처리
        break;
      case PauseTimerCommand():
        // 타이머 일시정지는 위젯 내부에서 처리
        break;
      case RepeatCommand():
        _speakCurrentStep();
      case UnknownCommand():
        break;
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeStep(int stepIndex) {
    setState(() => _completedSteps.add(stepIndex));
    if (stepIndex < _steps.length - 1) {
      _goToPage(stepIndex + 1);
    } else {
      _onAllComplete();
    }
  }

  Future<void> _onAllComplete() async {
    setState(() => _isSavingHistory = true);

    try {
      await _recipeService.saveRecipeHistory(
        recipeId: widget.recipe.id,
        recipeTitle: widget.recipe.title,
      );
    } catch (_) {
      // 기록 저장 실패 시 무시
    }

    if (!mounted) return;
    setState(() => _isSavingHistory = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('요리 완료!'),
        content: Text('${widget.recipe.title}을(를) 완성했습니다!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_completedSteps.isEmpty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('요리 중단'),
        content: const Text('진행 중인 요리를 중단하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('중단'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _steps.isEmpty
        ? 0.0
        : _completedSteps.length / _steps.length;

    return PopScope(
      canPop: _completedSteps.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe.title),
          centerTitle: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Text(
                  '${_currentPage + 1} / ${_steps.length}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isSavingHistory
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.lg),
                    Text('요리 기록 저장 중...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // 진행률 표시
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    minHeight: 4,
                  ),

                  // 단계별 페이지
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _steps.length,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                        _speakCurrentStep();
                      },
                      itemBuilder: (context, index) {
                        return _buildStepPage(_steps[index], index);
                      },
                    ),
                  ),

                  // 하단 네비게이션
                  _buildBottomNav(),
                ],
              ),
      ),
    );
  }

  Widget _buildStepPage(RecipeInstruction step, int index) {
    final isCompleted = _completedSteps.contains(index);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // 단계 번호
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : Text(
                      '${step.step}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 단계 제목
          Text(
            step.title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 상세 설명
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              step.description,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 타이머 (시간이 있을 때만)
          if (step.time > 0) ...[
            CookingTimer(
              key: ValueKey('timer_$index'),
              minutes: step.time,
              audioService: _audioService,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // 팁
          if (step.tips != null && step.tips!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      step.tips!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _steps.length - 1;
    final isCurrentCompleted = _completedSteps.contains(_currentPage);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이전 버튼
            if (!isFirst)
              OutlinedButton.icon(
                onPressed: () => _goToPage(_currentPage - 1),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('이전'),
              )
            else
              const SizedBox(width: 100),

            const Spacer(),

            // TTS 토글
            IconButton(
              onPressed: _toggleTts,
              icon: Icon(
                _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                color: _isTtsEnabled ? AppColors.primary : AppColors.textTertiary,
              ),
              tooltip: 'TTS 읽기',
            ),

            // 음성 명령
            IconButton(
              onPressed: _toggleVoiceListening,
              icon: Icon(
                _isVoiceListening ? Icons.mic : Icons.mic_none,
                color: _isVoiceListening ? AppColors.error : AppColors.textTertiary,
              ),
              tooltip: '음성 명령',
            ),

            const SizedBox(width: AppSpacing.sm),

            // 완료/다음 버튼
            FilledButton.icon(
              onPressed: isCurrentCompleted && !isLast
                  ? () => _goToPage(_currentPage + 1)
                  : () => _completeStep(_currentPage),
              icon: Icon(
                isCurrentCompleted
                    ? (isLast ? Icons.celebration : Icons.arrow_forward)
                    : Icons.check,
                size: 18,
              ),
              label: Text(
                isCurrentCompleted
                    ? (isLast ? '요리 완료!' : '다음')
                    : '완료',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isLast && isCurrentCompleted
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
