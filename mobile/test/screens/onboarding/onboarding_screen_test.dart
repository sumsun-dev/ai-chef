import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chef_presets.dart';
import 'package:ai_chef/screens/onboarding/onboarding_screen.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('OnboardingScreen', () {
    late FakeAuthService fakeAuth;

    setUp(() {
      fakeAuth = FakeAuthService();
    });

    Widget buildScreen() {
      return wrapWithMaterialApp(
        OnboardingScreen(authService: fakeAuth),
      );
    }

    /// 셰프 선택 후 page 1(SkillLevel)로 이동하는 헬퍼
    Future<void> navigateToSkillLevel(WidgetTester tester) async {
      await tester.tap(find.text(ChefPresets.all.first.name));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
    }

    testWidgets('초기 화면에 StepChefSelection이 표시된다', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.text('나만의 AI 셰프를\n골라주세요'), findsOneWidget);
    });

    testWidgets('프리셋 선택 후 다음 버튼으로 SkillLevel로 이동한다',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await navigateToSkillLevel(tester);
      expect(find.text('요리 실력이\n어느 정도인가요?'), findsOneWidget);
    });

    testWidgets('SkillLevel에서 완료 버튼으로 Completion으로 이동한다',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await navigateToSkillLevel(tester);

      await tester.tap(find.text('요리 초보'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '완료'));
      await tester.pumpAndSettle();

      // Assert - Completion 화면 (저장 성공)
      expect(find.text('준비 완료!'), findsOneWidget);
    });

    testWidgets('뒤로 버튼으로 이전 페이지로 이동한다', (tester) async {
      await tester.pumpWidget(buildScreen());
      await navigateToSkillLevel(tester);
      expect(find.text('요리 실력이\n어느 정도인가요?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('나만의 AI 셰프를\n골라주세요'), findsOneWidget);
    });

    testWidgets('FakeAuthService 주입으로 저장 동작을 검증한다',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await navigateToSkillLevel(tester);

      await tester.tap(find.text('요리 초보'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, '완료'));
      await tester.pumpAndSettle();

      // Assert - 저장 성공
      expect(find.text('준비 완료!'), findsOneWidget);
    });
  });
}
