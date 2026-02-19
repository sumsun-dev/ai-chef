import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/profile/profile_edit_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ProfileEditScreen', () {
    testWidgets('로딩 후 설정 항목들 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileEditScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('요리 설정'), findsOneWidget);
      expect(find.text('요리 실력'), findsOneWidget);
      expect(find.text('요리 시나리오 (복수 선택)'), findsOneWidget);
      expect(find.text('가구원 수'), findsOneWidget);
      expect(find.text('선호 조리시간'), findsOneWidget);
      expect(find.text('1인분 예산'), findsOneWidget);
    });

    testWidgets('저장 버튼 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileEditScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('요리 실력 칩 선택 가능', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileEditScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      // '중급' 칩을 찾아서 탭
      await tester.tap(find.text('중급'));
      await tester.pump();

      // ChoiceChip이 선택되었는지 확인
      final chip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('중급'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip.selected, isTrue);
    });
  });
}
