import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/cooking_statistics.dart';
import 'package:ai_chef/models/recipe_history.dart';
import 'package:ai_chef/screens/profile/statistics_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  late FakeRecipeService fakeRecipeService;

  setUp(() {
    fakeRecipeService = FakeRecipeService();
  });

  Widget buildSubject({CookingStatistics? statistics}) {
    fakeRecipeService = FakeRecipeService(statistics: statistics);
    return wrapWithMaterialApp(
      StatisticsScreen(recipeService: fakeRecipeService),
    );
  }

  group('StatisticsScreen', () {
    testWidgets('AppBar 제목 표시', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('요리 통계'), findsOneWidget);
    });

    testWidgets('빈 상태 표시 (기록 없음)', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('아직 요리 기록이 없어요'), findsOneWidget);
    });

    testWidgets('요약 카드 표시', (tester) async {
      final stats = CookingStatistics(
        totalCooked: 10,
        thisMonthCooked: 5,
        thisWeekCooked: 3,
        streak: 2,
        mostCookedRecipe: '김치찌개',
        mostCookedCount: 4,
        recipeFrequency: {'김치찌개': 4, '된장찌개': 3},
        weekdayFrequency: {1: 2, 3: 3},
        recentHistory: [
          RecipeHistory(id: '1', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
        ],
      );
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      expect(find.text('요약'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsAtLeast(1));
      expect(find.text('2'), findsAtLeast(1));
    });

    testWidgets('총 요리/이번 달/이번 주/연속 라벨 표시', (tester) async {
      final stats = _createFullStats();
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      expect(find.text('총 요리'), findsOneWidget);
      expect(find.text('이번 달'), findsOneWidget);
      expect(find.text('이번 주'), findsOneWidget);
      expect(find.text('연속 요리'), findsOneWidget);
    });

    testWidgets('자주 만든 레시피 섹션 표시', (tester) async {
      final stats = _createFullStats();
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      expect(find.text('자주 만든 레시피'), findsOneWidget);
      expect(find.text('김치찌개'), findsAtLeast(1));
      expect(find.text('4회'), findsOneWidget);
    });

    testWidgets('요일별 패턴 섹션 표시', (tester) async {
      final stats = _createFullStats();
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      expect(find.text('요일별 요리 패턴'), findsOneWidget);
      expect(find.text('월'), findsOneWidget);
      // '일' appears both in stat card unit and weekday label
      expect(find.text('일'), findsAtLeast(1));
    });

    testWidgets('최근 요리 기록 섹션 표시', (tester) async {
      final stats = _createFullStats();
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      // Scroll to see recent history
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('최근 요리 기록'), findsOneWidget);
    });

    testWidgets('기록 항목에 레시피 제목 표시', (tester) async {
      final stats = CookingStatistics(
        totalCooked: 1,
        thisMonthCooked: 1,
        thisWeekCooked: 1,
        streak: 1,
        mostCookedRecipe: '비빔밥',
        mostCookedCount: 1,
        recipeFrequency: {'비빔밥': 1},
        weekdayFrequency: {3: 1},
        recentHistory: [
          RecipeHistory(id: '1', recipeTitle: '비빔밥', cookedAt: DateTime.now()),
        ],
      );
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      // Scroll down to see history
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('비빔밥'), findsAtLeast(1));
    });

    testWidgets('LinearProgressIndicator 표시', (tester) async {
      final stats = _createFullStats();
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsAtLeast(1));
    });

    testWidgets('별점 표시 (rating이 있을 때)', (tester) async {
      final stats = CookingStatistics(
        totalCooked: 1,
        thisMonthCooked: 1,
        thisWeekCooked: 1,
        streak: 1,
        mostCookedRecipe: '김치찌개',
        mostCookedCount: 1,
        recipeFrequency: {'김치찌개': 1},
        weekdayFrequency: {1: 1},
        recentHistory: [
          RecipeHistory(
            id: '1',
            recipeTitle: '김치찌개',
            cookedAt: DateTime.now(),
            rating: 5,
          ),
        ],
      );
      await tester.pumpWidget(buildSubject(statistics: stats));
      await tester.pumpAndSettle();

      // Scroll down to see history with rating
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsAtLeast(1));
    });
  });
}

CookingStatistics _createFullStats() {
  return CookingStatistics(
    totalCooked: 20,
    thisMonthCooked: 8,
    thisWeekCooked: 3,
    streak: 2,
    mostCookedRecipe: '김치찌개',
    mostCookedCount: 4,
    recipeFrequency: {
      '김치찌개': 4,
      '된장찌개': 3,
      '비빔밥': 2,
    },
    weekdayFrequency: {1: 3, 2: 2, 3: 4, 5: 3, 6: 5, 7: 3},
    recentHistory: [
      RecipeHistory(id: '1', recipeTitle: '김치찌개', cookedAt: DateTime.now()),
      RecipeHistory(
        id: '2',
        recipeTitle: '된장찌개',
        cookedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  );
}
