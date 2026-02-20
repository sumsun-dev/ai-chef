import 'recipe.dart';

/// 빠른 액션에서 레시피 탭으로 전달하는 필터 설정
class RecipeQuickFilter {
  final int? servings;
  final int? maxCookingTime;
  final RecipeDifficulty? difficulty;
  final bool useExpiringFirst;
  final String label;

  const RecipeQuickFilter({
    this.servings,
    this.maxCookingTime,
    this.difficulty,
    this.useExpiringFirst = false,
    required this.label,
  });

  /// 혼밥: 1인분, 30분 이내
  static const solo = RecipeQuickFilter(
    servings: 1,
    maxCookingTime: 30,
    label: '혼밥',
  );

  /// 급해요: 15분 이내, 쉬운 난이도
  static const quick = RecipeQuickFilter(
    maxCookingTime: 15,
    difficulty: RecipeDifficulty.easy,
    label: '급해요',
  );

  /// 재료정리: 유통기한 임박 재료 우선
  static const clearFridge = RecipeQuickFilter(
    useExpiringFirst: true,
    label: '재료정리',
  );
}
