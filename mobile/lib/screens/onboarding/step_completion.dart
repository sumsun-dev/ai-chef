import 'package:flutter/material.dart';

/// 온보딩 Step 5: 완료 화면
class StepCompletion extends StatefulWidget {
  final String chefName;
  final VoidCallback onComplete;
  final bool isLoading;

  const StepCompletion({
    super.key,
    required this.chefName,
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  State<StepCompletion> createState() => _StepCompletionState();
}

class _StepCompletionState extends State<StepCompletion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    _controller.forward();
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // 체크 아이콘 애니메이션
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

          // 축하 메시지
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

          // 홈으로 가기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: widget.isLoading ? null : widget.onComplete,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '홈으로 가기',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
