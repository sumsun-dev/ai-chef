import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/cooking_statistics.dart';
import 'package:ai_chef/models/recipe_history.dart';

void main() {
  group('CookingStatistics', () {
    test('empty() 팩토리 기본값', () {
      final stats = CookingStatistics.empty();

      expect(stats.totalCooked, 0);
      expect(stats.thisMonthCooked, 0);
      expect(stats.thisWeekCooked, 0);
      expect(stats.streak, 0);
      expect(stats.mostCookedRecipe, isNull);
      expect(stats.mostCookedCount, 0);
      expect(stats.recipeFrequency, isEmpty);
      expect(stats.weekdayFrequency, isEmpty);
      expect(stats.recentHistory, isEmpty);
    });

    test('fromHistory 빈 리스트 처리', () {
      final stats = CookingStatistics.fromHistory([]);

      expect(stats.totalCooked, 0);
      expect(stats.mostCookedRecipe, isNull);
    });

    test('fromHistory totalCooked 계산', () {
      final history = List.generate(5, (i) => RecipeHistory(
        id: '$i',
        recipeTitle: '레시피 $i',
        cookedAt: DateTime.now().subtract(Duration(days: i)),
      ));

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.totalCooked, 5);
    });

    test('fromHistory recipeFrequency 계산', () {
      final history = [
        RecipeHistory(id: '1', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        RecipeHistory(id: '2', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        RecipeHistory(id: '3', recipeTitle: '된장찌개', cookedAt: DateTime.now()),
      ];

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.recipeFrequency['김치찌개'], 2);
      expect(stats.recipeFrequency['된장찌개'], 1);
    });

    test('fromHistory mostCookedRecipe 계산', () {
      final history = [
        RecipeHistory(id: '1', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        RecipeHistory(id: '2', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        RecipeHistory(id: '3', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        RecipeHistory(id: '4', recipeTitle: '된장찌개', cookedAt: DateTime.now()),
      ];

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.mostCookedRecipe, '김치찌개');
      expect(stats.mostCookedCount, 3);
    });

    test('fromHistory weekdayFrequency 계산', () {
      // Monday = 1
      final monday = _findNextWeekday(DateTime.now(), DateTime.monday);
      final history = [
        RecipeHistory(id: '1', recipeTitle: '레시피', cookedAt: monday),
        RecipeHistory(id: '2', recipeTitle: '레시피', cookedAt: monday),
      ];

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.weekdayFrequency[DateTime.monday], 2);
    });

    test('fromHistory thisMonthCooked 계산', () {
      final now = DateTime.now();
      final history = [
        RecipeHistory(id: '1', recipeTitle: '이번달', cookedAt: now),
        RecipeHistory(id: '2', recipeTitle: '저번달', cookedAt: DateTime(now.year, now.month - 1, 15)),
      ];

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.thisMonthCooked, 1);
    });

    test('fromHistory recentHistory 최대 10개', () {
      final history = List.generate(15, (i) => RecipeHistory(
        id: '$i',
        recipeTitle: '레시피 $i',
        cookedAt: DateTime.now().subtract(Duration(days: i)),
      ));

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.recentHistory.length, 10);
    });

    test('fromHistory streak 계산 (연속 요리)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final history = [
        RecipeHistory(id: '1', recipeTitle: '레시피', cookedAt: today),
        RecipeHistory(id: '2', recipeTitle: '레시피', cookedAt: today.subtract(const Duration(days: 1))),
        RecipeHistory(id: '3', recipeTitle: '레시피', cookedAt: today.subtract(const Duration(days: 2))),
      ];

      final stats = CookingStatistics.fromHistory(history);

      expect(stats.streak, 3);
    });
  });
}

DateTime _findNextWeekday(DateTime from, int weekday) {
  var date = from;
  while (date.weekday != weekday) {
    date = date.subtract(const Duration(days: 1));
  }
  return date;
}
