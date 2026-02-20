import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/fridge_summary_card.dart';
import 'package:ai_chef/models/ingredient.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('FridgeSummaryCard', () {
    Ingredient makeIngredient(String name, StorageLocation location) {
      return Ingredient(
        id: name,
        name: name,
        category: 'vegetable',
        quantity: 1,
        unit: '개',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        storageLocation: location,
      );
    }

    testWidgets('총 재료 수를 표시한다', (tester) async {
      final ingredients = [
        makeIngredient('양파', StorageLocation.fridge),
        makeIngredient('고기', StorageLocation.freezer),
        makeIngredient('라면', StorageLocation.pantry),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(FridgeSummaryCard(
          ingredients: ingredients,
          expiringCount: 0,
        )),
      );

      expect(find.text('총 3개'), findsOneWidget);
      expect(find.text('내 냉장고'), findsOneWidget);
    });

    testWidgets('보관 위치별 개수를 표시한다', (tester) async {
      final ingredients = [
        makeIngredient('양파', StorageLocation.fridge),
        makeIngredient('당근', StorageLocation.fridge),
        makeIngredient('고기', StorageLocation.freezer),
        makeIngredient('라면', StorageLocation.pantry),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(FridgeSummaryCard(
          ingredients: ingredients,
          expiringCount: 0,
        )),
      );

      expect(find.text('냉장 2'), findsOneWidget);
      expect(find.text('냉동 1'), findsOneWidget);
      expect(find.text('실온 1'), findsOneWidget);
    });

    testWidgets('임박 재료가 있으면 경고를 표시한다', (tester) async {
      final ingredients = [
        makeIngredient('양파', StorageLocation.fridge),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(FridgeSummaryCard(
          ingredients: ingredients,
          expiringCount: 3,
        )),
      );

      expect(find.text('임박 3개'), findsOneWidget);
    });

    testWidgets('임박 재료가 없으면 경고를 숨긴다', (tester) async {
      final ingredients = [
        makeIngredient('양파', StorageLocation.fridge),
      ];

      await tester.pumpWidget(
        wrapWithMaterialApp(FridgeSummaryCard(
          ingredients: ingredients,
          expiringCount: 0,
        )),
      );

      expect(find.textContaining('임박'), findsNothing);
    });
  });
}
