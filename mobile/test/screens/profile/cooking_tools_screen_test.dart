import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/profile/cooking_tools_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('CookingToolsScreen', () {
    testWidgets('타이틀과 저장 버튼 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingToolsScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      expect(find.text('조리 도구 관리'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('로딩 중 인디케이터 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingToolsScreen(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      // initState에서 Supabase를 호출하므로 로딩 상태
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
