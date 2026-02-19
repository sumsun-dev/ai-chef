import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

import 'package:ai_chef/screens/login_screen.dart';
import '../helpers/widget_test_helpers.dart';

class _ThrowingAuthService extends FakeAuthService {
  @override
  Future<AuthResponse> signInWithGoogle() async {
    throw Exception('테스트 에러');
  }
}

void main() {
  group('LoginScreen', () {
    testWidgets('앱 이름과 슬로건이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(LoginScreen(authService: FakeAuthService())),
      );

      expect(find.text('AI Chef'), findsOneWidget);
      expect(find.text('나만의 AI 셰프와 함께하는\n맞춤 요리 여정'), findsOneWidget);
    });

    testWidgets('Google 로그인 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(LoginScreen(authService: FakeAuthService())),
      );

      expect(find.text('Google로 시작하기'), findsOneWidget);
    });

    testWidgets('로그인 실패 시 일반 에러 메시지 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(LoginScreen(authService: _ThrowingAuthService())),
      );

      await tester.tap(find.text('Google로 시작하기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('로그인에 실패했습니다. 다시 시도해주세요.'), findsOneWidget);
      // 내부 에러 메시지가 노출되지 않아야 함
      expect(find.textContaining('테스트 에러'), findsNothing);
    });

    testWidgets('이용약관 안내 텍스트 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(LoginScreen(authService: FakeAuthService())),
      );

      expect(
        find.text('시작하면 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.'),
        findsOneWidget,
      );
    });
  });
}
