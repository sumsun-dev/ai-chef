import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/onboarding/step_completion.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('StepCompletion', () {
    testWidgets('저장 중: CircularProgressIndicator와 메시지가 표시된다',
        (tester) async {
      // Arrange - Completer로 저장을 pending 상태로 유지
      final completer = Completer<bool>();

      await tester.pumpWidget(
        wrapWithMaterialApp(
          StepCompletion(
            chefName: '테스트 셰프',
            onSave: () => completer.future,
            onGoHome: () {},
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('설정을 저장하고 있어요...'), findsOneWidget);
    });

    testWidgets('저장 성공: "준비 완료!"와 시작하기 버튼이 표시된다',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          StepCompletion(
            chefName: '테스트 셰프',
            onSave: () async => true,
            onGoHome: () {},
          ),
        ),
      );

      // Act - 저장 완료 대기
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('준비 완료!'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('저장 실패: "저장에 실패했어요"와 다시 시도 버튼이 표시된다',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          StepCompletion(
            chefName: '테스트 셰프',
            onSave: () async => false,
            onGoHome: () {},
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('저장에 실패했어요'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('다시 시도 탭 시 onSave가 재호출된다', (tester) async {
      // Arrange
      int saveCallCount = 0;
      await tester.pumpWidget(
        wrapWithMaterialApp(
          StepCompletion(
            chefName: '테스트 셰프',
            onSave: () async {
              saveCallCount++;
              return false;
            },
            onGoHome: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(saveCallCount, 1);

      // Act
      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      // Assert
      expect(saveCallCount, 2);
    });
  });
}
