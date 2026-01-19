/// 재료 보관 위치
enum StorageLocation {
  refrigerated, // 냉장
  frozen, // 냉동
  roomTemp; // 실온

  String get displayName {
    switch (this) {
      case StorageLocation.refrigerated:
        return '냉장';
      case StorageLocation.frozen:
        return '냉동';
      case StorageLocation.roomTemp:
        return '실온';
    }
  }

  static StorageLocation fromString(String? value) {
    switch (value) {
      case 'refrigerated':
        return StorageLocation.refrigerated;
      case 'frozen':
        return StorageLocation.frozen;
      case 'room_temp':
        return StorageLocation.roomTemp;
      default:
        return StorageLocation.refrigerated;
    }
  }
}

/// 유통기한 상태
enum ExpiryStatus {
  expired, // 유통기한 지남
  critical, // 3일 이내 만료
  warning, // 7일 이내 만료
  safe; // 안전

  String get displayName {
    switch (this) {
      case ExpiryStatus.expired:
        return '유통기한 지남';
      case ExpiryStatus.critical:
        return '3일 이내 만료';
      case ExpiryStatus.warning:
        return '7일 이내 만료';
      case ExpiryStatus.safe:
        return '안전';
    }
  }
}

/// 재료 모델
class Ingredient {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? purchaseDate;
  final DateTime expiryDate;
  final double? price;
  final StorageLocation storageLocation;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ingredient({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.purchaseDate,
    required this.expiryDate,
    this.price,
    required this.storageLocation,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] ?? '개',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      expiryDate: DateTime.parse(json['expiry_date']),
      price: (json['price'] as num?)?.toDouble(),
      storageLocation: StorageLocation.fromString(json['storage_location']),
      memo: json['memo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate?.toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'price': price,
      'storage_location': storageLocation.name == 'roomTemp'
          ? 'room_temp'
          : storageLocation.name,
      'memo': memo,
    };
  }

  /// 남은 일수 계산
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// 유통기한 상태
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) {
      return ExpiryStatus.expired;
    } else if (days <= 3) {
      return ExpiryStatus.critical;
    } else if (days <= 7) {
      return ExpiryStatus.warning;
    } else {
      return ExpiryStatus.safe;
    }
  }

  /// D-day 문자열
  String get dDayString {
    final days = daysUntilExpiry;
    if (days < 0) {
      return 'D+${-days}';
    } else if (days == 0) {
      return 'D-Day';
    } else {
      return 'D-$days';
    }
  }
}

/// 유통기한별 재료 그룹
class ExpiryIngredientGroup {
  final int expiredCount;
  final int criticalCount;
  final int warningCount;
  final List<Ingredient> expiredItems;
  final List<Ingredient> criticalItems;
  final List<Ingredient> warningItems;

  ExpiryIngredientGroup({
    required this.expiredCount,
    required this.criticalCount,
    required this.warningCount,
    required this.expiredItems,
    required this.criticalItems,
    required this.warningItems,
  });

  factory ExpiryIngredientGroup.fromIngredients(List<Ingredient> ingredients) {
    final expiredItems = <Ingredient>[];
    final criticalItems = <Ingredient>[];
    final warningItems = <Ingredient>[];

    for (final ingredient in ingredients) {
      switch (ingredient.expiryStatus) {
        case ExpiryStatus.expired:
          expiredItems.add(ingredient);
          break;
        case ExpiryStatus.critical:
          criticalItems.add(ingredient);
          break;
        case ExpiryStatus.warning:
          warningItems.add(ingredient);
          break;
        case ExpiryStatus.safe:
          break;
      }
    }

    // 유통기한 가까운 순으로 정렬
    expiredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    criticalItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    warningItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return ExpiryIngredientGroup(
      expiredCount: expiredItems.length,
      criticalCount: criticalItems.length,
      warningCount: warningItems.length,
      expiredItems: expiredItems,
      criticalItems: criticalItems,
      warningItems: warningItems,
    );
  }

  /// 총 알림 개수
  int get totalAlertCount => expiredCount + criticalCount + warningCount;

  /// 알림이 있는지 여부
  bool get hasAlerts => totalAlertCount > 0;
}
