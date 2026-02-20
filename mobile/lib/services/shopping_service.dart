import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shopping_item.dart';

/// 쇼핑 리스트 관리 서비스
/// Supabase를 통한 쇼핑 아이템 CRUD 처리
class ShoppingService {
  final SupabaseClient _supabase;

  ShoppingService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 쇼핑 아이템 목록 조회 (미완료 먼저, 카테고리순)
  Future<List<ShoppingItem>> getShoppingItems() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('shopping_items')
        .select()
        .eq('user_id', _userId!)
        .order('is_checked', ascending: true)
        .order('category', ascending: true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ShoppingItem.fromJson(item))
        .toList();
  }

  /// 쇼핑 아이템 단건 추가
  Future<ShoppingItem> addShoppingItem(ShoppingItem item) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = item.toJson();
    data['user_id'] = _userId;

    final response = await _supabase
        .from('shopping_items')
        .insert(data)
        .select()
        .single();

    return ShoppingItem.fromJson(response);
  }

  /// 레시피에서 일괄 추가
  Future<List<ShoppingItem>> addShoppingItems(List<ShoppingItem> items) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final dataList = items.map((item) {
      final data = item.toJson();
      data['user_id'] = _userId;
      return data;
    }).toList();

    final response = await _supabase
        .from('shopping_items')
        .insert(dataList)
        .select();

    return (response as List)
        .map((item) => ShoppingItem.fromJson(item))
        .toList();
  }

  /// 체크 토글
  Future<void> toggleCheck(String id, bool isChecked) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('shopping_items')
        .update({'is_checked': isChecked})
        .eq('id', id)
        .eq('user_id', _userId!);
  }

  /// 쇼핑 아이템 단건 삭제
  Future<void> deleteShoppingItem(String id) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('shopping_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId!);
  }

  /// 완료 아이템 일괄 삭제
  Future<void> deleteCheckedItems() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('shopping_items')
        .delete()
        .eq('user_id', _userId!)
        .eq('is_checked', true);
  }

  /// 체크된 아이템만 조회
  Future<List<ShoppingItem>> getCheckedItems() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('shopping_items')
        .select()
        .eq('user_id', _userId!)
        .eq('is_checked', true)
        .order('category', ascending: true);

    return (response as List)
        .map((item) => ShoppingItem.fromJson(item))
        .toList();
  }
}
