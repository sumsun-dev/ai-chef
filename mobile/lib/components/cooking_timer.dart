import 'dart:async';

import 'package:flutter/material.dart';

import '../services/cooking_audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 조리 모드 카운트다운 타이머 위젯
class CookingTimer extends StatefulWidget {
  /// 타이머 시간 (분)
  final int minutes;

  /// 타이머 완료 콜백
  final VoidCallback? onComplete;

  /// 자동 시작 여부
  final bool autoStart;

  /// 오디오/진동 서비스 (optional DI)
  final CookingAudioService? audioService;

  const CookingTimer({
    super.key,
    required this.minutes,
    this.onComplete,
    this.autoStart = false,
    this.audioService,
  });

  @override
  State<CookingTimer> createState() => CookingTimerState();
}

class CookingTimerState extends State<CookingTimer> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _remainingSeconds = _totalSeconds;
    if (widget.autoStart) {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _isRunning = false);
        _onTimerComplete();
      }
    });
  }

  Future<void> _onTimerComplete() async {
    await widget.audioService?.notifyTimerComplete();
    widget.onComplete?.call();
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    if (_totalSeconds == 0) return 1.0;
    return _remainingSeconds / _totalSeconds;
  }

  bool get _isComplete => _remainingSeconds <= 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.border,
                  color: _isComplete
                      ? AppColors.success
                      : _remainingSeconds < 30
                          ? AppColors.warning
                          : AppColors.primary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isComplete
                        ? Icons.check_circle
                        : Icons.timer_outlined,
                    size: 24,
                    color: _isComplete ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formattedTime,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isComplete) ...[
              if (_isRunning)
                FilledButton.icon(
                  onPressed: _pause,
                  icon: const Icon(Icons.pause, size: 18),
                  label: const Text('일시정지'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('시작'),
                ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('초기화'),
              ),
            ],
            if (_isComplete)
              FilledButton.icon(
                onPressed: () => widget.onComplete?.call(),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('완료!'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
