import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingredient.dart';

/// 재료 관리 서비스
/// Supabase를 통한 재료 CRUD 및 유통기한 조회
class IngredientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 현재 사용자 ID
  String? get _userId => _supabase.auth.currentUser?.id;

  /// 모든 재료 조회
  Future<List<Ingredient>> getAllIngredients() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((json) => Ingredient.fromJson(json))
        .toList();
  }

  /// 유통기한 알림이 필요한 재료 조회 (7일 이내 만료 또는 만료됨)
  Future<List<Ingredient>> getExpiringIngredients() async {
    if (_userId == null) return [];

    final sevenDaysFromNow =
        DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .lte('expiry_date', sevenDaysFromNow)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((json) => Ingredient.fromJson(json))
        .toList();
  }

  /// 유통기한별 재료 그룹 조회
  Future<ExpiryIngredientGroup> getExpiryIngredientGroup() async {
    final ingredients = await getExpiringIngredients();
    return ExpiryIngredientGroup.fromIngredients(ingredients);
  }

  /// 특정 상태의 재료만 조회
  Future<List<Ingredient>> getIngredientsByExpiryStatus(
      ExpiryStatus status) async {
    final ingredients = await getAllIngredients();
    return ingredients.where((i) => i.expiryStatus == status).toList();
  }

  /// 재료 추가
  Future<Ingredient> addIngredient({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    DateTime? purchaseDate,
    required DateTime expiryDate,
    double? price,
    StorageLocation storageLocation = StorageLocation.refrigerated,
    String? memo,
  }) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = {
      'user_id': _userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate?.toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'price': price,
      'storage_location':
          storageLocation.name == 'roomTemp' ? 'room_temp' : storageLocation.name,
      'memo': memo,
    };

    final response = await _supabase
        .from('ingredients')
        .insert(data)
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// 재료 수정
  Future<Ingredient> updateIngredient(
    String ingredientId, {
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? price,
    StorageLocation? storageLocation,
    String? memo,
  }) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (category != null) data['category'] = category;
    if (quantity != null) data['quantity'] = quantity;
    if (unit != null) data['unit'] = unit;
    if (purchaseDate != null) {
      data['purchase_date'] = purchaseDate.toIso8601String().split('T')[0];
    }
    if (expiryDate != null) {
      data['expiry_date'] = expiryDate.toIso8601String().split('T')[0];
    }
    if (price != null) data['price'] = price;
    if (storageLocation != null) {
      data['storage_location'] =
          storageLocation.name == 'roomTemp' ? 'room_temp' : storageLocation.name;
    }
    if (memo != null) data['memo'] = memo;

    final response = await _supabase
        .from('ingredients')
        .update(data)
        .eq('id', ingredientId)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// 재료 삭제
  Future<void> deleteIngredient(String ingredientId) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('ingredients')
        .delete()
        .eq('id', ingredientId)
        .eq('user_id', _userId!);
  }

  /// 재료 수량 차감 (조리 시 사용)
  Future<void> consumeIngredient(String ingredientId, double amount) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    // 현재 수량 조회
    final current = await _supabase
        .from('ingredients')
        .select('quantity')
        .eq('id', ingredientId)
        .eq('user_id', _userId!)
        .single();

    final currentQuantity = (current['quantity'] as num).toDouble();
    final newQuantity = currentQuantity - amount;

    if (newQuantity <= 0) {
      // 수량이 0 이하면 삭제
      await deleteIngredient(ingredientId);
    } else {
      // 수량 업데이트
      await _supabase
          .from('ingredients')
          .update({'quantity': newQuantity})
          .eq('id', ingredientId)
          .eq('user_id', _userId!);
    }
  }

  /// 카테고리별 재료 조회
  Future<List<Ingredient>> getIngredientsByCategory(String category) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .eq('category', category)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((json) => Ingredient.fromJson(json))
        .toList();
  }

  /// 보관 위치별 재료 조회
  Future<List<Ingredient>> getIngredientsByStorageLocation(
      StorageLocation location) async {
    if (_userId == null) return [];

    final locationStr =
        location.name == 'roomTemp' ? 'room_temp' : location.name;

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .eq('storage_location', locationStr)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((json) => Ingredient.fromJson(json))
        .toList();
  }
}
