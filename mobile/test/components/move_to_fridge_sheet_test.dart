import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/components/move_to_fridge_sheet.dart';
import 'package:ai_chef/models/ingredient.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;
  late FakeShoppingService fakeShoppingService;

  setUp(() {
    fakeIngredientService = FakeIngredientService();
    fakeShoppingService = FakeShoppingService();
  });

  group('MoveToFridgeSheet', () {
    testWidgets('체크된 아이템 목록을 표시한다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '양파', category: 'vegetable'),
        createTestShoppingItem(id: '2', name: '소고기', category: 'meat'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('양파'), findsOneWidget);
      expect(find.textContaining('소고기'), findsOneWidget);
      expect(find.text('냉장고에 추가'), findsOneWidget);
    });

    testWidgets('아이템 수가 표시된다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '양파'),
        createTestShoppingItem(id: '2', name: '당근'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('2개'), findsWidgets);
    });

    testWidgets('보관위치 SegmentedButton이 표시된다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '양파', category: 'vegetable'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('냉장'), findsOneWidget);
      expect(find.text('냉동'), findsOneWidget);
      expect(find.text('실온'), findsOneWidget);
    });

    testWidgets('카테고리별 기본 보관위치가 설정된다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '쌀', category: 'grain'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // grain은 기본 pantry(실온) - SegmentedButton에서 실온이 선택된 상태
      final segmented = tester.widget<SegmentedButton<StorageLocation>>(
        find.byType(SegmentedButton<StorageLocation>),
      );
      expect(segmented.selected, {StorageLocation.pantry});
    });

    testWidgets('유통기한이 표시된다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '양파', category: 'vegetable'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('유통기한'), findsWidgets);
    });

    testWidgets('추가 버튼 클릭 시 saveIngredients가 호출된다', (tester) async {
      final items = [
        createTestShoppingItem(id: '1', name: '양파', category: 'vegetable'),
      ];

      await tester.pumpWidget(wrapWithMaterialApp(
        Scaffold(
          body: MoveToFridgeSheet(
            items: items,
            ingredientService: fakeIngredientService,
            shoppingService: fakeShoppingService,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, '1개 냉장고에 추가'));
      await tester.pumpAndSettle();

      expect(fakeShoppingService.deleteCheckedCalled, isTrue);
    });
  });
}
