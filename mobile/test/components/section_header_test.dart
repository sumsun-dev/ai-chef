import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/section_header.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('emoji와 title을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const SectionHeader(emoji: '🍳', title: '오늘의 추천'),
        ),
      );

      expect(find.text('🍳'), findsOneWidget);
      expect(find.text('오늘의 추천'), findsOneWidget);
    });

    testWidgets('actionText가 없으면 TextButton이 없다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const SectionHeader(emoji: '🍳', title: '제목'),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('actionText가 있으면 TextButton을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          SectionHeader(
            emoji: '🍳',
            title: '제목',
            actionText: '더보기',
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('더보기'), findsOneWidget);
    });

    testWidgets('onAction 콜백이 호출된다', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          SectionHeader(
            emoji: '🍳',
            title: '제목',
            actionText: '더보기',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      expect(tapped, isTrue);
    });
  });
}
