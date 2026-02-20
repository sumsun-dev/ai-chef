import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ai_response.dart';
import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/models/recipe.dart';

void main() {
  group('AIResponse sealed class', () {
    test('TextResponse는 텍스트를 포함한다', () {
      final response = TextResponse(text: '안녕하세요!');

      expect(response, isA<AIResponse>());
      expect(response, isA<TextResponse>());
      expect(response.text, '안녕하세요!');
    });

    test('RecipeResponse는 레시피와 요약을 포함한다', () {
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

      expect(response, isA<AIResponse>());
      expect(response, isA<RecipeResponse>());
      expect(response.recipe.title, '김치찌개');
      expect(response.summary, '김치찌개를 추천합니다!');
    });

    test('IngredientListResponse는 재료 목록과 코멘트를 포함한다', () {
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
      ];

      final response = IngredientListResponse(
        ingredients: ingredients,
        commentary: '양파 3개가 있습니다.',
      );

      expect(response, isA<AIResponse>());
      expect(response, isA<IngredientListResponse>());
      expect(response.ingredients.length, 1);
      expect(response.commentary, '양파 3개가 있습니다.');
    });

    test('ActionResponse는 액션 결과를 포함한다', () {
      final response = ActionResponse(
        actionType: 'bookmark',
        success: true,
        message: '북마크에 추가했습니다.',
      );

      expect(response, isA<AIResponse>());
      expect(response, isA<ActionResponse>());
      expect(response.actionType, 'bookmark');
      expect(response.success, true);
      expect(response.message, '북마크에 추가했습니다.');
    });

    test('switch 패턴 매칭이 동작한다', () {
      final AIResponse response = TextResponse(text: '테스트');

      final result = switch (response) {
        TextResponse(text: final t) => 'text: $t',
        RecipeResponse() => 'recipe',
        IngredientListResponse() => 'ingredients',
        ActionResponse() => 'action',
      };

      expect(result, 'text: 테스트');
    });
  });
}
