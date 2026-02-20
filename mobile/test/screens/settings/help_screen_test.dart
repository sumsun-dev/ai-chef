import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/settings/help_screen.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('HelpScreen', () {
    testWidgets('AppBar에 "도움말" 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const HelpScreen()),
      );

      expect(find.text('도움말'), findsOneWidget);
    });

    testWidgets('FAQ 질문 3개가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const HelpScreen()),
      );

      expect(find.text('재료는 어떻게 등록하나요?'), findsOneWidget);
      expect(find.text('AI 셰프를 변경할 수 있나요?'), findsOneWidget);
      expect(find.text('유통기한 알림은 어떻게 설정하나요?'), findsOneWidget);
    });

    testWidgets('ExpansionTile 탭 시 답변이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const HelpScreen()),
      );

      // 첫 번째 FAQ 열기
      await tester.tap(find.text('재료는 어떻게 등록하나요?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('영수증 스캔으로 자동 등록'),
        findsOneWidget,
      );
    });

    testWidgets('버전 정보가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const HelpScreen()),
      );

      expect(find.text('AI Chef v1.0.0'), findsOneWidget);
    });
  });
}
