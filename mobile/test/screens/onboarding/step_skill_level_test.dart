import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/onboarding/step_skill_level.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('StepSkillLevel', () {
    late String? capturedLevel;

    Widget buildWidget({String selectedLevel = ''}) {
      return wrapWithMaterialApp(
        StepSkillLevel(
          selectedLevel: selectedLevel,
          onChanged: (level) => capturedLevel = level,
        ),
      );
    }

    setUp(() {
      capturedLevel = null;
    });

    testWidgets('4개 실력 카드가 렌더링된다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget());

      // Assert
      expect(find.text('요리 초보'), findsOneWidget);
      expect(find.text('기본 요리 가능'), findsOneWidget);
      expect(find.text('어느 정도'), findsOneWidget);
      expect(find.text('요리 고수'), findsOneWidget);
    });

    testWidgets('카드 탭 시 onChanged(key)가 호출된다', (tester) async {
      // Arrange
      await tester.pumpWidget(buildWidget());

      // Act
      await tester.tap(find.text('요리 초보'));
      await tester.pump();

      // Assert
      expect(capturedLevel, 'beginner');
    });

    testWidgets('선택된 레벨에 check_circle 아이콘이 표시된다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget(selectedLevel: 'beginner'));

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('미선택 레벨에 check_circle 아이콘이 없다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget(selectedLevel: ''));

      // Assert
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}
