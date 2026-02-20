import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/components/shopping_item_add_sheet.dart';
import 'package:ai_chef/models/shopping_item.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('ShoppingItemAddSheet', () {
    testWidgets('빈 이름으로 추가 시 validation 에러를 표시한다', (tester) async {
      ShoppingItem? addedItem;

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: ShoppingItemAddSheet(onAdd: (item) => addedItem = item),
        ),
      ));

      await tester.tap(find.text('추가하기'));
      await tester.pumpAndSettle();

      expect(find.text('이름을 입력해주세요'), findsOneWidget);
      expect(addedItem, isNull);
    });

    testWidgets('이름 입력 후 추가하면 onAdd 콜백이 호출된다', (tester) async {
      ShoppingItem? addedItem;

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: ShoppingItemAddSheet(onAdd: (item) => addedItem = item),
        ),
      ));

      await tester.enterText(find.byType(TextFormField).first, '양파');
      await tester.tap(find.text('추가하기'));
      await tester.pumpAndSettle();

      expect(addedItem, isNotNull);
      expect(addedItem!.name, '양파');
      expect(addedItem!.quantity, 1);
      expect(addedItem!.unit, '개');
      expect(addedItem!.category, 'other');
    });

    testWidgets('카테고리 드롭다운에 9개 옵션이 있다', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: ShoppingItemAddSheet(onAdd: (_) {}),
        ),
      ));

      // 카테고리 드롭다운 탭
      await tester.tap(find.text('기타').last);
      await tester.pumpAndSettle();

      // 9개 카테고리가 표시되어야 함
      expect(find.text('채소'), findsWidgets);
      expect(find.text('과일'), findsWidgets);
      expect(find.text('육류'), findsWidgets);
      expect(find.text('해산물'), findsWidgets);
      expect(find.text('유제품'), findsWidgets);
      expect(find.text('달걀'), findsWidgets);
      expect(find.text('곡류'), findsWidgets);
      expect(find.text('양념'), findsWidgets);
      expect(find.text('기타'), findsWidgets);
    });

    testWidgets('기본 단위가 "개"로 설정되어 있다', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: ShoppingItemAddSheet(onAdd: (_) {}),
        ),
      ));

      // 단위 드롭다운에 '개'가 선택되어 있어야 함
      expect(find.text('개'), findsOneWidget);
    });
  });
}
