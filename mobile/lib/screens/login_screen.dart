import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginScreen({super.key, this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AuthService _authService;
  late final AnimationController _floatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();

      if (!mounted) return;
      final profile = await _authService.getUserProfile();

      if (!mounted) return;
      if (profile != null && profile['ai_chef_name'] != null) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    } catch (e, stackTrace) {
      assert(() {
        debugPrint('로그인 에러: $e');
        debugPrint('스택트레이스: $stackTrace');
        return true;
      }());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppColors.error,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 부유 이모지 일러스트
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final offset = Tween<double>(begin: -8, end: 8)
                          .animate(CurvedAnimation(
                        parent: _floatController,
                        curve: Curves.easeInOut,
                      ));
                      return Transform.translate(
                        offset: Offset(0, offset.value),
                        child: child,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('👨‍🍳', style: TextStyle(fontSize: 52)),
                        SizedBox(width: 8),
                        Text('🍳', style: TextStyle(fontSize: 44)),
                        SizedBox(width: 8),
                        Text('🥘', style: TextStyle(fontSize: 44)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // 앱 이름
                  const Text(
                    'AI Chef',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 슬로건
                  const Text(
                    '나만의 AI 셰프와 함께하는\n맞춤 요리 여정',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 56),

                  // Google 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Google로 시작하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // 이용약관
                  Text(
                    '시작하면 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
