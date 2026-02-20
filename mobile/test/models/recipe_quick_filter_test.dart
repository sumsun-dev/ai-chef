import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/models/recipe_quick_filter.dart';

void main() {
  group('RecipeQuickFilter', () {
    test('solo 필터: servings=1, maxCookingTime=30', () {
      const filter = RecipeQuickFilter.solo;
      expect(filter.servings, 1);
      expect(filter.maxCookingTime, 30);
      expect(filter.difficulty, isNull);
      expect(filter.useExpiringFirst, isFalse);
      expect(filter.label, '혼밥');
    });

    test('quick 필터: maxCookingTime=15, difficulty=easy', () {
      const filter = RecipeQuickFilter.quick;
      expect(filter.servings, isNull);
      expect(filter.maxCookingTime, 15);
      expect(filter.difficulty, RecipeDifficulty.easy);
      expect(filter.useExpiringFirst, isFalse);
      expect(filter.label, '급해요');
    });

    test('clearFridge 필터: useExpiringFirst=true', () {
      const filter = RecipeQuickFilter.clearFridge;
      expect(filter.servings, isNull);
      expect(filter.maxCookingTime, isNull);
      expect(filter.difficulty, isNull);
      expect(filter.useExpiringFirst, isTrue);
      expect(filter.label, '재료정리');
    });
  });
}
