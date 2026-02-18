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
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? false,
      substitute: json['substitute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isAvailable': isAvailable,
      if (substitute != null) 'substitute': substitute,
    };
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
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? false,
      alternative: json['alternative'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isAvailable': isAvailable,
      if (alternative != null) 'alternative': alternative,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'title': title,
      'description': description,
      'time': time,
      if (tips != null) 'tips': tips,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

/// 레시피 난이도
enum RecipeDifficulty { easy, medium, hard }

/// 레시피 모델
class Recipe {
  final String? id;
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
  final String? userId;
  final String? chefId;
  final bool isBookmarked;
  final DateTime? createdAt;

  Recipe({
    this.id,
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
    this.userId,
    this.chefId,
    this.isBookmarked = false,
    this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cuisine: json['cuisine'] ?? '',
      difficulty: _parseDifficulty(json['difficulty']),
      cookingTime: json['cookingTime'] ?? json['cooking_time'] ?? 0,
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
      chefNote: json['chefNote'] ?? json['chef_note'],
      userId: json['user_id'],
      chefId: json['chef_id'] ?? json['chefId'],
      isBookmarked: json['is_bookmarked'] ?? json['isBookmarked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'cuisine': cuisine,
      'difficulty': difficulty.name,
      'cooking_time': cookingTime,
      'servings': servings,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'tools': tools.map((e) => e.toJson()).toList(),
      'instructions': instructions.map((e) => e.toJson()).toList(),
      if (nutrition != null) 'nutrition': nutrition!.toJson(),
      if (chefNote != null) 'chef_note': chefNote,
      if (userId != null) 'user_id': userId,
      if (chefId != null) 'chef_id': chefId,
      'is_bookmarked': isBookmarked,
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? cuisine,
    RecipeDifficulty? difficulty,
    int? cookingTime,
    int? servings,
    List<RecipeIngredient>? ingredients,
    List<RecipeTool>? tools,
    List<RecipeInstruction>? instructions,
    NutritionInfo? nutrition,
    String? chefNote,
    String? userId,
    String? chefId,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      tools: tools ?? this.tools,
      instructions: instructions ?? this.instructions,
      nutrition: nutrition ?? this.nutrition,
      chefNote: chefNote ?? this.chefNote,
      userId: userId ?? this.userId,
      chefId: chefId ?? this.chefId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
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
