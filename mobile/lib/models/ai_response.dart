import 'ingredient.dart';
import 'recipe.dart';

/// AI 응답 sealed class
///
/// Function Calling 결과를 타입별로 분류하여
/// UI에서 적절한 카드를 렌더링할 수 있도록 합니다.
sealed class AIResponse {}

/// 텍스트 응답
class TextResponse extends AIResponse {
  final String text;

  TextResponse({required this.text});
}

/// 레시피 응답
class RecipeResponse extends AIResponse {
  final Recipe recipe;
  final String summary;

  RecipeResponse({required this.recipe, required this.summary});
}

/// 재료 목록 응답
class IngredientListResponse extends AIResponse {
  final List<Ingredient> ingredients;
  final String commentary;

  IngredientListResponse({
    required this.ingredients,
    required this.commentary,
  });
}

/// 액션 결과 응답
class ActionResponse extends AIResponse {
  final String actionType;
  final bool success;
  final String message;

  ActionResponse({
    required this.actionType,
    required this.success,
    required this.message,
  });
}
