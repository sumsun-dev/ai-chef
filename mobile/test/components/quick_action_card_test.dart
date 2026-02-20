import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/quick_action_card.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('QuickActionCard', () {
    testWidgets('icon과 label을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          QuickActionCard(
            icon: '📸',
            label: '사진 촬영',
            onTap: () {},
          ),
        ),
      );

      expect(find.text('📸'), findsOneWidget);
      expect(find.text('사진 촬영'), findsOneWidget);
    });

    testWidgets('InkWell이 존재한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          QuickActionCard(
            icon: '📸',
            label: '사진 촬영',
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('onTap 콜백이 호출된다', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          QuickActionCard(
            icon: '📸',
            label: '사진 촬영',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
