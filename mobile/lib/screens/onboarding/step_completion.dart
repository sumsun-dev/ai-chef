import 'package:flutter/material.dart';

enum _SaveStatus { saving, success, error }

/// 온보딩 완료 화면: 자동 저장 → 성공/실패 분기
class StepCompletion extends StatefulWidget {
  final String chefName;
  final Future<bool> Function() onSave;
  final VoidCallback onGoHome;

  const StepCompletion({
    super.key,
    required this.chefName,
    required this.onSave,
    required this.onGoHome,
  });

  @override
  State<StepCompletion> createState() => _StepCompletionState();
}

class _StepCompletionState extends State<StepCompletion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  _SaveStatus _status = _SaveStatus.saving;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _doSave();
  }

  Future<void> _doSave() async {
    setState(() => _status = _SaveStatus.saving);
    final ok = await widget.onSave();
    if (!mounted) return;
    setState(() => _status = ok ? _SaveStatus.success : _SaveStatus.error);
    if (ok) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: switch (_status) {
        _SaveStatus.saving => _buildSaving(colorScheme),
        _SaveStatus.success => _buildSuccess(colorScheme),
        _SaveStatus.error => _buildError(colorScheme),
      },
    );
  }

  Widget _buildSaving(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 24),
        Text(
          '설정을 저장하고 있어요...',
          style: TextStyle(
            fontSize: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '준비 완료!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.chefName}이(가)\n준비되었어요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '이제 맞춤 레시피를 받아보세요',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(flex: 3),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: widget.onGoHome,
            child: const Text('시작하기', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildError(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          '저장에 실패했어요',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '네트워크를 확인하고 다시 시도해 주세요',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _doSave,
            child: const Text('다시 시도', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
