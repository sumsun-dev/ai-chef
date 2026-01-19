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
    this.storageLocation = StorageLocation.refrigerated,
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
        json['storage_location'] as String? ?? 'refrigerated',
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
      'storage_location': storageLocation.value,
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
    return ExpiryStatus.ok;
  }
}

/// 보관 위치
enum StorageLocation {
  refrigerated('refrigerated', '냉장'),
  frozen('frozen', '냉동'),
  roomTemp('room_temp', '실온');

  final String value;
  final String displayName;

  const StorageLocation(this.value, this.displayName);

  static StorageLocation fromString(String value) {
    return StorageLocation.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StorageLocation.refrigerated,
    );
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
  ok('양호');

  final String displayName;

  const ExpiryStatus(this.displayName);
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

  /// 카테고리별 기본 유통기한 (일)
  static int _getDefaultExpiryDays(String category) {
    const expiryMap = {
      'produce': 7, // 채소/과일
      'dairy': 14, // 유제품
      'meat': 5, // 육류
      'seafood': 3, // 해산물
      'pantry': 180, // 건조식품
      'frozen': 90, // 냉동식품
      'beverages': 30, // 음료
      'bakery': 5, // 빵/베이커리
      'condiments': 90, // 소스/양념
      'other': 14, // 기타
    };
    return expiryMap[category] ?? 14;
  }

  /// 카테고리별 기본 보관 위치
  static StorageLocation _getStorageLocation(String category) {
    const locationMap = {
      'produce': StorageLocation.refrigerated,
      'dairy': StorageLocation.refrigerated,
      'meat': StorageLocation.refrigerated,
      'seafood': StorageLocation.refrigerated,
      'pantry': StorageLocation.roomTemp,
      'frozen': StorageLocation.frozen,
      'beverages': StorageLocation.roomTemp,
      'bakery': StorageLocation.roomTemp,
      'condiments': StorageLocation.refrigerated,
      'other': StorageLocation.refrigerated,
    };
    return locationMap[category] ?? StorageLocation.refrigerated;
  }
}
