import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/ai_response_card.dart';
import 'package:ai_chef/models/ai_response.dart';
import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/models/recipe.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('AIResponseCard', () {
    testWidgets('TextResponse는 텍스트를 표시한다', (tester) async {
      final response = TextResponse(text: '안녕하세요, 무엇을 도와드릴까요?');

      await tester.pumpWidget(
        wrapWithMaterialApp(
          AIResponseCard(response: response),
        ),
      );

      expect(find.text('안녕하세요, 무엇을 도와드릴까요?'), findsOneWidget);
    });

    testWidgets('RecipeResponse는 레시피 카드를 표시한다', (tester) async {
      final recipe = Recipe(
        title: '김치찌개',
        description: '매콤한 김치찌개',
        cuisine: '한식',
        difficulty: RecipeDifficulty.easy,
        cookingTime: 30,
        servings: 2,
        ingredients: [],
        tools: [],
        instructions: [],
      );

      final response = RecipeResponse(
        recipe: recipe,
        summary: '김치찌개를 추천합니다!',
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          Scaffold(
            body: AIResponseCard(response: response),
          ),
        ),
      );

      expect(find.text('김치찌개를 추천합니다!'), findsOneWidget);
      expect(find.text('김치찌개'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('IngredientListResponse는 재료 칩을 표시한다', (tester) async {
      final ingredients = [
        Ingredient(
          name: '양파',
          category: 'vegetable',
          quantity: 3,
          unit: '개',
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          storageLocation: StorageLocation.fridge,
          purchaseDate: DateTime.now(),
        ),
        Ingredient(
          name: '당근',
          category: 'vegetable',
          quantity: 2,
          unit: '개',
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          storageLocation: StorageLocation.fridge,
          purchaseDate: DateTime.now(),
        ),
      ];

      final response = IngredientListResponse(
        ingredients: ingredients,
        commentary: '냉장고에 2개 재료가 있습니다.',
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          Scaffold(
            body: SingleChildScrollView(
              child: AIResponseCard(response: response),
            ),
          ),
        ),
      );

      expect(find.text('냉장고에 2개 재료가 있습니다.'), findsOneWidget);
      expect(find.text('재료 2개'), findsOneWidget);
      expect(find.byIcon(Icons.kitchen), findsOneWidget);
    });

    testWidgets('ActionResponse 성공은 성공 카드를 표시한다', (tester) async {
      final response = ActionResponse(
        actionType: 'bookmark',
        success: true,
        message: '북마크에 추가했습니다.',
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          AIResponseCard(response: response),
        ),
      );

      expect(find.text('북마크에 추가했습니다.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('ActionResponse 실패는 에러 카드를 표시한다', (tester) async {
      final response = ActionResponse(
        actionType: 'bookmark',
        success: false,
        message: '실패했습니다.',
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          AIResponseCard(response: response),
        ),
      );

      expect(find.text('실패했습니다.'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('RecipeResponse의 onRecipeTap 콜백이 동작한다', (tester) async {
      bool tapped = false;
      final recipe = Recipe(
        title: '김치찌개',
        description: '매콤한 김치찌개',
        cuisine: '한식',
        difficulty: RecipeDifficulty.easy,
        cookingTime: 30,
        servings: 2,
        ingredients: [],
        tools: [],
        instructions: [],
      );

      final response = RecipeResponse(
        recipe: recipe,
        summary: '추천합니다!',
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          Scaffold(
            body: AIResponseCard(
              response: response,
              onRecipeTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('김치찌개'));
      expect(tapped, true);
    });
  });
}
