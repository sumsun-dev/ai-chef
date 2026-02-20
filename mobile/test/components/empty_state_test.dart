import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/empty_state.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('emoji, title, subtitle을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const EmptyState(
            emoji: '🍳',
            title: '레시피가 없습니다',
            subtitle: '새로운 레시피를 추가해보세요',
          ),
        ),
      );

      expect(find.text('🍳'), findsOneWidget);
      expect(find.text('레시피가 없습니다'), findsOneWidget);
      expect(find.text('새로운 레시피를 추가해보세요'), findsOneWidget);
    });

    testWidgets('actionText가 없으면 FilledButton이 없다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const EmptyState(
            emoji: '🍳',
            title: '제목',
            subtitle: '설명',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('actionText가 있으면 FilledButton을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EmptyState(
            emoji: '🍳',
            title: '제목',
            subtitle: '설명',
            actionText: '추가하기',
            onAction: () {},
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('추가하기'), findsOneWidget);
    });

    testWidgets('onAction 콜백이 호출된다', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          EmptyState(
            emoji: '🍳',
            title: '제목',
            subtitle: '설명',
            actionText: '추가하기',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });
  });
}
