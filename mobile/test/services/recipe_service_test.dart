import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/services/recipe_service.dart';
import '../helpers/mock_supabase.dart';

void main() {
  final testRecipeJson = {
    'id': '1',
    'user_id': 'test-user-id',
    'title': '김치찌개',
    'description': '맛있는 김치찌개',
    'cuisine': '한식',
    'difficulty': 'easy',
    'cooking_time': 30,
    'servings': 2,
    'ingredients': <Map<String, dynamic>>[],
    'tools': <Map<String, dynamic>>[],
    'instructions': <Map<String, dynamic>>[],
    'is_bookmarked': false,
    'created_at': '2026-02-18T12:00:00.000Z',
  };

  group('not logged in', () {
    late RecipeService service;

    setUp(() {
      service = RecipeService(supabase: createLoggedOutClient());
    });

    test('getSavedRecipes throws', () {
      expect(() => service.getSavedRecipes(), throwsA(isA<Exception>()));
    });

    test('getBookmarkedRecipes throws', () {
      expect(() => service.getBookmarkedRecipes(), throwsA(isA<Exception>()));
    });

    test('saveRecipe throws', () {
      final recipe = Recipe(
        title: '테스트',
        description: '설명',
        cuisine: '한식',
        difficulty: RecipeDifficulty.easy,
        cookingTime: 30,
        servings: 2,
        ingredients: [],
        tools: [],
        instructions: [],
      );
      expect(() => service.saveRecipe(recipe), throwsA(isA<Exception>()));
    });

    test('toggleBookmark throws', () {
      expect(() => service.toggleBookmark('1', true),
          throwsA(isA<Exception>()));
    });

    test('deleteRecipe throws', () {
      expect(() => service.deleteRecipe('1'), throwsA(isA<Exception>()));
    });
  });

  group('logged in', () {
    late MockSupabaseClient mockClient;
    late RecipeService service;

    setUp(() {
      mockClient = createLoggedInClient();
      service = RecipeService(supabase: mockClient);
    });

    test('getSavedRecipes returns list', () async {
      when(mockClient.from('recipes'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testRecipeJson]));

      final result = await service.getSavedRecipes();
      expect(result.length, 1);
      expect(result.first.title, '김치찌개');
    });

    test('getBookmarkedRecipes returns bookmarked', () async {
      final bookmarked = Map<String, dynamic>.from(testRecipeJson)
        ..['is_bookmarked'] = true;
      when(mockClient.from('recipes'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([bookmarked]));

      final result = await service.getBookmarkedRecipes();
      expect(result.length, 1);
      expect(result.first.isBookmarked, true);
    });

    test('saveRecipe returns saved recipe', () async {
      when(mockClient.from('recipes'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testRecipeJson]));

      final recipe = Recipe(
        title: '김치찌개',
        description: '맛있는 김치찌개',
        cuisine: '한식',
        difficulty: RecipeDifficulty.easy,
        cookingTime: 30,
        servings: 2,
        ingredients: [],
        tools: [],
        instructions: [],
      );
      final result = await service.saveRecipe(recipe);
      expect(result.title, '김치찌개');
      expect(result.id, '1');
    });

    test('toggleBookmark completes', () async {
      when(mockClient.from('recipes'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.toggleBookmark('1', true);
    });

    test('deleteRecipe completes', () async {
      when(mockClient.from('recipes'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.deleteRecipe('1');
    });

    test('saveRecipeHistory completes', () async {
      when(mockClient.from('recipe_history'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.saveRecipeHistory(recipeTitle: '김치찌개');
    });

    test('getRecipeHistory returns list', () async {
      when(mockClient.from('recipe_history')).thenAnswer(
          (_) => FakeSupabaseQueryBuilder([
                {'id': '1', 'recipe_title': '김치찌개', 'cooked_at': '2026-02-18'},
              ]));

      final result = await service.getRecipeHistory();
      expect(result.length, 1);
      expect(result.first['recipe_title'], '김치찌개');
    });
  });
}
