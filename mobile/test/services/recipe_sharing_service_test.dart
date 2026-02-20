import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/services/recipe_sharing_service.dart';

void main() {
  late RecipeSharingService service;

  setUp(() {
    service = RecipeSharingService();
  });

  Recipe createRecipeForShare({
    String title = '김치찌개',
    String description = '맛있는 김치찌개',
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    NutritionInfo? nutrition,
    String? chefNote,
  }) {
    return Recipe(
      title: title,
      description: description,
      cuisine: '한식',
      difficulty: RecipeDifficulty.easy,
      cookingTime: 30,
      servings: 2,
      ingredients: ingredients ?? [],
      tools: [],
      instructions: instructions ?? [],
      nutrition: nutrition,
      chefNote: chefNote,
    );
  }

  group('RecipeSharingService', () {
    test('formatRecipeAsText 제목 포함', () {
      final recipe = createRecipeForShare(title: '된장찌개');
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('🍳 된장찌개'));
    });

    test('formatRecipeAsText 설명 포함', () {
      final recipe = createRecipeForShare(description: '구수한 된장찌개');
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('구수한 된장찌개'));
    });

    test('formatRecipeAsText 재료 포함', () {
      final recipe = createRecipeForShare(
        ingredients: [
          RecipeIngredient(name: '두부', quantity: '1', unit: '모'),
          RecipeIngredient(name: '된장', quantity: '2', unit: '큰술'),
        ],
      );
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('📝 재료'));
      expect(text, contains('두부 1 모'));
      expect(text, contains('된장 2 큰술'));
    });

    test('formatRecipeAsText 조리 순서 포함', () {
      final recipe = createRecipeForShare(
        instructions: [
          RecipeInstruction(
            step: 1,
            title: '재료 준비',
            description: '두부를 깍둑썰기합니다',
            time: 5,
            tips: '물기를 빼세요',
          ),
        ],
      );
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('👨‍🍳 조리 순서'));
      expect(text, contains('1. 재료 준비'));
      expect(text, contains('두부를 깍둑썰기합니다'));
      expect(text, contains('💡 물기를 빼세요'));
    });

    test('formatRecipeAsText 영양 정보 포함', () {
      final recipe = createRecipeForShare(
        nutrition: NutritionInfo(
          calories: 350,
          protein: 15,
          carbs: 40,
          fat: 10,
        ),
      );
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('📊 영양 정보'));
      expect(text, contains('350kcal'));
    });

    test('formatRecipeAsText 셰프 노트 포함', () {
      final recipe = createRecipeForShare(chefNote: '맛있게 드세요!');
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('💬 셰프 노트'));
      expect(text, contains('맛있게 드세요!'));
    });

    test('formatRecipeAsText AI Chef 서명 포함', () {
      final recipe = createRecipeForShare(title: 'AI Chef 테스트');
      final text = service.formatRecipeAsText(recipe);
      expect(text, contains('AI Chef에서 공유됨'));
    });
  });
}
