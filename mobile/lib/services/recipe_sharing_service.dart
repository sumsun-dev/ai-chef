import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';

/// 레시피 공유 서비스
class RecipeSharingService {
  /// 레시피를 텍스트로 포맷
  String formatRecipeAsText(Recipe recipe) {
    final buffer = StringBuffer();

    buffer.writeln('🍳 ${recipe.title}');
    buffer.writeln();
    buffer.writeln(recipe.description);
    buffer.writeln();

    // 기본 정보
    buffer.writeln('⏱️ ${recipe.cookingTime}분 | 👥 ${recipe.servings}인분 | ${_difficultyEmoji(recipe.difficulty)} ${_difficultyLabel(recipe.difficulty)}');
    if (recipe.cuisine.isNotEmpty) {
      buffer.writeln('🍽️ ${recipe.cuisine}');
    }
    buffer.writeln();

    // 재료
    buffer.writeln('📝 재료');
    for (final ingredient in recipe.ingredients) {
      buffer.writeln('  • ${ingredient.name} ${ingredient.quantity} ${ingredient.unit}');
    }
    buffer.writeln();

    // 조리 순서
    buffer.writeln('👨‍🍳 조리 순서');
    for (final step in recipe.instructions) {
      buffer.writeln('${step.step}. ${step.title}');
      buffer.writeln('   ${step.description}');
      if (step.tips != null && step.tips!.isNotEmpty) {
        buffer.writeln('   💡 ${step.tips}');
      }
    }

    // 영양 정보
    if (recipe.nutrition != null) {
      buffer.writeln();
      buffer.writeln('📊 영양 정보');
      buffer.writeln('  칼로리: ${recipe.nutrition!.calories}kcal | 단백질: ${recipe.nutrition!.protein}g | 탄수화물: ${recipe.nutrition!.carbs}g | 지방: ${recipe.nutrition!.fat}g');
    }

    // 셰프 노트
    if (recipe.chefNote != null && recipe.chefNote!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('💬 셰프 노트');
      buffer.writeln(recipe.chefNote);
    }

    buffer.writeln();
    buffer.writeln('— AI Chef에서 공유됨');

    return buffer.toString();
  }

  /// 레시피 공유
  Future<void> shareRecipe(Recipe recipe) async {
    final text = formatRecipeAsText(recipe);
    await Share.share(text, subject: recipe.title);
  }

  String _difficultyEmoji(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return '🟢';
      case RecipeDifficulty.medium:
        return '🟡';
      case RecipeDifficulty.hard:
        return '🔴';
    }
  }

  String _difficultyLabel(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return '쉬움';
      case RecipeDifficulty.medium:
        return '보통';
      case RecipeDifficulty.hard:
        return '어려움';
    }
  }
}
