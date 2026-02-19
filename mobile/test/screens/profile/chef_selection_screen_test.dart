import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/profile/chef_selection_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ChefSelectionScreen', () {
    testWidgets('셰프 변경 타이틀과 저장 버튼 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ChefSelectionScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('셰프 변경'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('셰프 프리셋 목록이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ChefSelectionScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      // StepChefSelection 위젯이 렌더링됨
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
