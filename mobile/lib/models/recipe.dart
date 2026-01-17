/// 재료 정보
class RecipeIngredient {
  final String name;
  final String quantity;
  final String unit;
  final bool isAvailable;
  final String? substitute;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.isAvailable = false,
    this.substitute,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      substitute: json['substitute'],
    );
  }
}

/// 도구 정보
class RecipeTool {
  final String name;
  final bool isAvailable;
  final String? alternative;

  RecipeTool({
    required this.name,
    this.isAvailable = false,
    this.alternative,
  });

  factory RecipeTool.fromJson(Map<String, dynamic> json) {
    return RecipeTool(
      name: json['name'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      alternative: json['alternative'],
    );
  }
}

/// 조리 단계
class RecipeInstruction {
  final int step;
  final String title;
  final String description;
  final int time;
  final String? tips;

  RecipeInstruction({
    required this.step,
    required this.title,
    required this.description,
    required this.time,
    this.tips,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) {
    return RecipeInstruction(
      step: json['step'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? 0,
      tips: json['tips'],
    );
  }
}

/// 영양 정보
class NutritionInfo {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
    );
  }
}

/// 레시피 난이도
enum RecipeDifficulty { easy, medium, hard }

/// 레시피 모델
class Recipe {
  final String title;
  final String description;
  final String cuisine;
  final RecipeDifficulty difficulty;
  final int cookingTime;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<RecipeTool> tools;
  final List<RecipeInstruction> instructions;
  final NutritionInfo? nutrition;
  final String? chefNote;

  Recipe({
    required this.title,
    required this.description,
    required this.cuisine,
    required this.difficulty,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.tools,
    required this.instructions,
    this.nutrition,
    this.chefNote,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cuisine: json['cuisine'] ?? '',
      difficulty: _parseDifficulty(json['difficulty']),
      cookingTime: json['cookingTime'] ?? 0,
      servings: json['servings'] ?? 1,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromJson(e))
              .toList() ??
          [],
      tools: (json['tools'] as List<dynamic>?)
              ?.map((e) => RecipeTool.fromJson(e))
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => RecipeInstruction.fromJson(e))
              .toList() ??
          [],
      nutrition: json['nutrition'] != null
          ? NutritionInfo.fromJson(json['nutrition'])
          : null,
      chefNote: json['chefNote'],
    );
  }

  static RecipeDifficulty _parseDifficulty(String? value) {
    switch (value) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'medium':
        return RecipeDifficulty.medium;
      case 'hard':
        return RecipeDifficulty.hard;
      default:
        return RecipeDifficulty.easy;
    }
  }
}
