/// 재료 모델
class Ingredient {
  final String? id;
  final String? userId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? purchaseDate;
  final DateTime expiryDate;
  final double? price;
  final StorageLocation storageLocation;
  final String? memo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// OCR 추출 시 신뢰도 (high, medium, low)
  final OcrConfidence? ocrConfidence;

  Ingredient({
    this.id,
    this.userId,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.unit = '개',
    this.purchaseDate,
    required this.expiryDate,
    this.price,
    this.storageLocation = StorageLocation.fridge,
    this.memo,
    this.createdAt,
    this.updatedAt,
    this.ocrConfidence,
  });

  /// JSON에서 Ingredient 생성
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? '개',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      price: (json['price'] as num?)?.toDouble(),
      storageLocation: StorageLocation.fromString(
        (json['location'] ?? json['storage_location']) as String? ?? 'fridge',
      ),
      memo: json['memo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      ocrConfidence: json['confidence'] != null
          ? OcrConfidence.fromString(json['confidence'] as String)
          : null,
    );
  }

  /// Ingredient를 JSON으로 변환 (Supabase 저장용)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      if (price != null) 'price': price,
      'location': storageLocation.value,
      if (memo != null) 'memo': memo,
    };
  }

  /// 복사본 생성
  Ingredient copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? price,
    StorageLocation? storageLocation,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
    OcrConfidence? ocrConfidence,
  }) {
    return Ingredient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      price: price ?? this.price,
      storageLocation: storageLocation ?? this.storageLocation,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
    );
  }

  /// 유통기한까지 남은 일수 계산
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// 만료 상태 확인
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryStatus.expired;
    if (days <= 3) return ExpiryStatus.critical;
    if (days <= 7) return ExpiryStatus.warning;
    return ExpiryStatus.safe;
  }

  /// D-Day 문자열 (예: "D-3", "D-Day", "D+2")
  String get dDayString {
    final days = daysUntilExpiry;
    if (days == 0) return 'D-Day';
    if (days > 0) return 'D-$days';
    return 'D+${-days}';
  }
}

/// 보관 위치
enum StorageLocation {
  fridge('fridge', '냉장'),
  freezer('freezer', '냉동'),
  pantry('pantry', '실온');

  final String value;
  final String displayName;

  const StorageLocation(this.value, this.displayName);

  static StorageLocation fromString(String value) {
    // 이전 값들과 호환성 유지
    final mapping = {
      'fridge': StorageLocation.fridge,
      'freezer': StorageLocation.freezer,
      'pantry': StorageLocation.pantry,
      // 레거시 값 호환
      'refrigerated': StorageLocation.fridge,
      'refrigerator': StorageLocation.fridge,
      'frozen': StorageLocation.freezer,
      'room_temp': StorageLocation.pantry,
    };
    return mapping[value] ?? StorageLocation.fridge;
  }
}

/// OCR 신뢰도
enum OcrConfidence {
  high('high', '높음'),
  medium('medium', '보통'),
  low('low', '낮음');

  final String value;
  final String displayName;

  const OcrConfidence(this.value, this.displayName);

  static OcrConfidence fromString(String value) {
    return OcrConfidence.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OcrConfidence.medium,
    );
  }
}

/// 만료 상태
enum ExpiryStatus {
  expired('만료됨'),
  critical('3일 이내'),
  warning('7일 이내'),
  safe('양호');

  final String displayName;

  const ExpiryStatus(this.displayName);
}

/// 유통기한 그룹
class ExpiryIngredientGroup {
  final List<Ingredient> expiredItems;
  final List<Ingredient> criticalItems;
  final List<Ingredient> warningItems;
  final List<Ingredient> safeItems;

  ExpiryIngredientGroup({
    required this.expiredItems,
    required this.criticalItems,
    required this.warningItems,
    required this.safeItems,
  });

  int get expiredCount => expiredItems.length;
  int get criticalCount => criticalItems.length;
  int get warningCount => warningItems.length;
  int get safeCount => safeItems.length;
  int get totalCount => expiredCount + criticalCount + warningCount + safeCount;
}

/// OCR 결과 모델
class ReceiptOcrResult {
  final List<Ingredient> ingredients;
  final DateTime? purchaseDate;
  final String? storeName;

  ReceiptOcrResult({
    required this.ingredients,
    this.purchaseDate,
    this.storeName,
  });

  factory ReceiptOcrResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?) ?? [];
    final purchaseDate = json['date'] != null
        ? DateTime.tryParse(json['date'] as String)
        : DateTime.now();

    return ReceiptOcrResult(
      ingredients: items.map((item) {
        final itemMap = item as Map<String, dynamic>;
        final category = itemMap['category'] as String? ?? 'other';
        final confidence = itemMap['confidence'] as String? ?? 'medium';

        // 카테고리별 기본 유통기한 설정
        final expiryDays = _getDefaultExpiryDays(category);
        final expiryDate =
            (purchaseDate ?? DateTime.now()).add(Duration(days: expiryDays));

        return Ingredient(
          name: itemMap['name'] as String,
          category: category,
          quantity: (itemMap['quantity'] as num?)?.toDouble() ?? 1,
          unit: itemMap['unit'] as String? ?? '개',
          purchaseDate: purchaseDate,
          expiryDate: expiryDate,
          price: (itemMap['price'] as num?)?.toDouble(),
          storageLocation: _getStorageLocation(category),
          ocrConfidence: OcrConfidence.fromString(confidence),
        );
      }).toList(),
      purchaseDate: purchaseDate,
      storeName: json['store'] as String?,
    );
  }

  /// 카테고리별 기본 유통기한 (일) - DB CHECK 제약조건 기준
  static int _getDefaultExpiryDays(String category) {
    const expiryMap = {
      'vegetable': 7, // 채소
      'fruit': 7, // 과일
      'meat': 5, // 육류
      'seafood': 3, // 해산물
      'dairy': 14, // 유제품
      'egg': 14, // 달걀
      'grain': 180, // 곡류/건조식품
      'seasoning': 90, // 양념/소스
      'other': 14, // 기타
    };
    return expiryMap[category] ?? 14;
  }

  /// 카테고리별 기본 보관 위치 - DB CHECK 제약조건 기준
  static StorageLocation _getStorageLocation(String category) {
    const locationMap = {
      'vegetable': StorageLocation.fridge,
      'fruit': StorageLocation.fridge,
      'meat': StorageLocation.fridge,
      'seafood': StorageLocation.fridge,
      'dairy': StorageLocation.fridge,
      'egg': StorageLocation.fridge,
      'grain': StorageLocation.pantry,
      'seasoning': StorageLocation.pantry,
      'other': StorageLocation.fridge,
    };
    return locationMap[category] ?? StorageLocation.fridge;
  }
}
