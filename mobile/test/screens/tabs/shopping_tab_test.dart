import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/shopping_item.dart';
import 'package:ai_chef/screens/tabs/shopping_tab.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;

  setUp(() {
    fakeIngredientService = FakeIngredientService();
  });

  group('ShoppingTab', () {
    testWidgets('빈 상태에서 EmptyState를 표시한다', (tester) async {
      final fakeService = FakeShoppingService(items: []);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('쇼핑 리스트가 비어있어요'), findsOneWidget);
      expect(find.text('쇼핑 리스트'), findsOneWidget);
    });

    testWidgets('아이템을 카테고리별로 그룹핑하여 표시한다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(id: '1', name: '양파', category: 'vegetable'),
        createTestShoppingItem(id: '2', name: '당근', category: 'vegetable'),
        createTestShoppingItem(id: '3', name: '소고기', category: 'meat'),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('양파'), findsOneWidget);
      expect(find.text('당근'), findsOneWidget);
      expect(find.text('소고기'), findsOneWidget);
      // 카테고리 섹션 헤더
      expect(find.text('채소'), findsOneWidget);
      expect(find.text('고기'), findsOneWidget);
    });

    testWidgets('체크된 아이템에 취소선이 표시된다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(id: '1', name: '양파', isChecked: true),
        createTestShoppingItem(id: '2', name: '당근', isChecked: false),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      final checkedText = tester.widget<Text>(find.text('양파'));
      expect(checkedText.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('체크박스 탭 시 toggleCheck가 호출된다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(id: '1', name: '양파', isChecked: false),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(fakeService.toggleCheckCalled, isTrue);
    });

    testWidgets('FAB이 표시된다', (tester) async {
      final fakeService = FakeShoppingService(items: []);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('추가'), findsOneWidget);
    });

    testWidgets('완료 정리 버튼이 체크된 아이템 있을 때 동작한다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(id: '1', name: '양파', isChecked: true),
        createTestShoppingItem(id: '2', name: '당근', isChecked: false),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.cleaning_services));
      await tester.pumpAndSettle();

      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(fakeService.deleteCheckedCalled, isTrue);
    });

    testWidgets('냉장고에 추가 버튼이 표시된다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(id: '1', name: '양파', isChecked: true),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.kitchen), findsOneWidget);
    });

    testWidgets('레시피 소스 아이템에 레시피 제목이 표시된다', (tester) async {
      final fakeService = FakeShoppingService(items: [
        createTestShoppingItem(
          id: '1',
          name: '소고기',
          source: ShoppingItemSource.recipe,
          recipeTitle: '소고기 불고기',
        ),
      ]);

      await tester.pumpWidget(wrapWithMaterialApp(
        ShoppingTab(
          shoppingService: fakeService,
          ingredientService: fakeIngredientService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('소고기'), findsOneWidget);
      expect(find.textContaining('소고기 불고기'), findsOneWidget);
    });
  });
}
