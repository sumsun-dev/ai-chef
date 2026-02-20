import 'recipe_history.dart';

/// 요리 통계 모델
class CookingStatistics {
  final int totalCooked;
  final int thisMonthCooked;
  final int thisWeekCooked;
  final int streak;
  final String? mostCookedRecipe;
  final int mostCookedCount;
  final Map<String, int> recipeFrequency;
  final Map<int, int> weekdayFrequency;
  final List<RecipeHistory> recentHistory;

  CookingStatistics({
    required this.totalCooked,
    required this.thisMonthCooked,
    required this.thisWeekCooked,
    required this.streak,
    this.mostCookedRecipe,
    required this.mostCookedCount,
    required this.recipeFrequency,
    required this.weekdayFrequency,
    required this.recentHistory,
  });

  factory CookingStatistics.empty() {
    return CookingStatistics(
      totalCooked: 0,
      thisMonthCooked: 0,
      thisWeekCooked: 0,
      streak: 0,
      mostCookedRecipe: null,
      mostCookedCount: 0,
      recipeFrequency: {},
      weekdayFrequency: {},
      recentHistory: [],
    );
  }

  factory CookingStatistics.fromHistory(List<RecipeHistory> history) {
    if (history.isEmpty) return CookingStatistics.empty();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final thisMonthCooked = history
        .where((h) => h.cookedAt.isAfter(startOfMonth))
        .length;

    final thisWeekCooked = history
        .where((h) => h.cookedAt.isAfter(startOfWeekDate))
        .length;

    // Recipe frequency
    final recipeFrequency = <String, int>{};
    for (final h in history) {
      recipeFrequency[h.recipeTitle] =
          (recipeFrequency[h.recipeTitle] ?? 0) + 1;
    }

    // Most cooked recipe
    String? mostCookedRecipe;
    int mostCookedCount = 0;
    for (final entry in recipeFrequency.entries) {
      if (entry.value > mostCookedCount) {
        mostCookedCount = entry.value;
        mostCookedRecipe = entry.key;
      }
    }

    // Weekday frequency (1=Monday, 7=Sunday)
    final weekdayFrequency = <int, int>{};
    for (final h in history) {
      final weekday = h.cookedAt.weekday;
      weekdayFrequency[weekday] = (weekdayFrequency[weekday] ?? 0) + 1;
    }

    // Streak calculation
    final streak = _calculateStreak(history, now);

    return CookingStatistics(
      totalCooked: history.length,
      thisMonthCooked: thisMonthCooked,
      thisWeekCooked: thisWeekCooked,
      streak: streak,
      mostCookedRecipe: mostCookedRecipe,
      mostCookedCount: mostCookedCount,
      recipeFrequency: recipeFrequency,
      weekdayFrequency: weekdayFrequency,
      recentHistory: history.take(10).toList(),
    );
  }

  static int _calculateStreak(List<RecipeHistory> history, DateTime now) {
    final dates = history
        .map((h) => DateTime(h.cookedAt.year, h.cookedAt.month, h.cookedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Streak must start from today or yesterday
    if (dates.first != today && dates.first != yesterday) return 0;

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
