import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ingredient.dart';

/// 재료 관리 서비스
/// Supabase를 통한 재료 CRUD 처리
class IngredientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 현재 사용자 ID
  String? get _userId => _supabase.auth.currentUser?.id;

  /// 재료 목록 조회
  Future<List<Ingredient>> getIngredients() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 재료 단일 조회
  Future<Ingredient> getIngredient(String id) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('id', id)
        .eq('user_id', _userId!)
        .single();

    return Ingredient.fromJson(response);
  }

  /// 재료 추가
  Future<Ingredient> addIngredient(Ingredient ingredient) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = ingredient.toJson();
    data['user_id'] = _userId;

    final response = await _supabase
        .from('ingredients')
        .insert(data)
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// 여러 재료 일괄 추가 (OCR 결과 저장용)
  Future<List<Ingredient>> saveIngredients(List<Ingredient> ingredients) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final dataList = ingredients.map((ingredient) {
      final data = ingredient.toJson();
      data['user_id'] = _userId;
      return data;
    }).toList();

    final response = await _supabase
        .from('ingredients')
        .insert(dataList)
        .select();

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 재료 수정
  Future<Ingredient> updateIngredient(Ingredient ingredient) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');
    if (ingredient.id == null) throw Exception('재료 ID가 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .update(ingredient.toJson())
        .eq('id', ingredient.id!)
        .eq('user_id', _userId!)
        .select()
        .single();

    return Ingredient.fromJson(response);
  }

  /// 재료 삭제
  Future<void> deleteIngredient(String id) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('ingredients')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId!);
  }

  /// 유통기한 임박 재료 조회
  Future<List<Ingredient>> getExpiringIngredients({int days = 7}) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .gte('expiry_date', now.toIso8601String().split('T')[0])
        .lte('expiry_date', threshold.toIso8601String().split('T')[0])
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 만료된 재료 조회
  Future<List<Ingredient>> getExpiredIngredients() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final now = DateTime.now();

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .lt('expiry_date', now.toIso8601String().split('T')[0])
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 카테고리별 재료 조회
  Future<List<Ingredient>> getIngredientsByCategory(String category) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .eq('category', category)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 보관 위치별 재료 조회
  Future<List<Ingredient>> getIngredientsByStorageLocation(
    StorageLocation location,
  ) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .eq('storage_location', location.value)
        .order('expiry_date', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }

  /// 재료 검색
  Future<List<Ingredient>> searchIngredients(String query) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('ingredients')
        .select()
        .eq('user_id', _userId!)
        .ilike('name', '%$query%')
        .order('name', ascending: true);

    return (response as List)
        .map((item) => Ingredient.fromJson(item))
        .toList();
  }
}
