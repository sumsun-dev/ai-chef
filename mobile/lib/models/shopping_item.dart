/// 쇼핑 아이템 소스
enum ShoppingItemSource {
  manual('manual'),
  recipe('recipe');

  final String value;

  const ShoppingItemSource(this.value);

  static ShoppingItemSource fromString(String value) {
    return ShoppingItemSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShoppingItemSource.manual,
    );
  }
}

/// 쇼핑 아이템 모델
class ShoppingItem {
  final String? id;
  final String? userId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool isChecked;
  final ShoppingItemSource source;
  final String? recipeTitle;
  final String? memo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShoppingItem({
    this.id,
    this.userId,
    required this.name,
    this.category = 'other',
    this.quantity = 1,
    this.unit = '개',
    this.isChecked = false,
    this.source = ShoppingItemSource.manual,
    this.recipeTitle,
    this.memo,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'other',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? '개',
      isChecked: json['is_checked'] as bool? ?? false,
      source: ShoppingItemSource.fromString(
        json['source'] as String? ?? 'manual',
      ),
      recipeTitle: json['recipe_title'] as String?,
      memo: json['memo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'is_checked': isChecked,
      'source': source.value,
      if (recipeTitle != null) 'recipe_title': recipeTitle,
      if (memo != null) 'memo': memo,
    };
  }

  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    bool? isChecked,
    ShoppingItemSource? source,
    String? recipeTitle,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      source: source ?? this.source,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 카테고리 한글 표시명
  String get categoryDisplayName {
    const categoryNames = {
      'vegetable': '채소',
      'fruit': '과일',
      'meat': '육류',
      'seafood': '해산물',
      'dairy': '유제품',
      'egg': '달걀',
      'grain': '곡류',
      'seasoning': '양념',
      'other': '기타',
    };
    return categoryNames[category] ?? '기타';
  }
}
