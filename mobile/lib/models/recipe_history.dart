/// 요리 기록 모델
class RecipeHistory {
  final String id;
  final String? userId;
  final String? recipeId;
  final String? chefId;
  final String recipeTitle;
  final DateTime cookedAt;
  final int? rating;
  final String? memo;

  RecipeHistory({
    required this.id,
    this.userId,
    this.recipeId,
    this.chefId,
    required this.recipeTitle,
    required this.cookedAt,
    this.rating,
    this.memo,
  });

  factory RecipeHistory.fromJson(Map<String, dynamic> json) {
    return RecipeHistory(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String?,
      recipeId: json['recipe_id'] as String?,
      chefId: json['chef_id'] as String?,
      recipeTitle: json['recipe_title'] as String? ?? '',
      cookedAt: json['cooked_at'] != null
          ? DateTime.parse(json['cooked_at'] as String)
          : DateTime.now(),
      rating: json['rating'] as int?,
      memo: json['memo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (chefId != null) 'chef_id': chefId,
      'recipe_title': recipeTitle,
      'cooked_at': cookedAt.toIso8601String(),
      if (rating != null) 'rating': rating,
      if (memo != null) 'memo': memo,
    };
  }

  RecipeHistory copyWith({
    String? id,
    String? userId,
    String? recipeId,
    String? chefId,
    String? recipeTitle,
    DateTime? cookedAt,
    int? rating,
    String? memo,
  }) {
    return RecipeHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      chefId: chefId ?? this.chefId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      cookedAt: cookedAt ?? this.cookedAt,
      rating: rating ?? this.rating,
      memo: memo ?? this.memo,
    );
  }
}
