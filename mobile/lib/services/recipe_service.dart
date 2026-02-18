import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recipe.dart';

/// 레시피 저장/북마크/기록 DB 서비스
class RecipeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 저장된 레시피 전체 조회
  Future<List<Recipe>> getSavedRecipes() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('recipes')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Recipe.fromJson(item))
        .toList();
  }

  /// 북마크된 레시피만 조회
  Future<List<Recipe>> getBookmarkedRecipes() async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('recipes')
        .select()
        .eq('user_id', _userId!)
        .eq('is_bookmarked', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Recipe.fromJson(item))
        .toList();
  }

  /// 레시피 저장
  Future<Recipe> saveRecipe(Recipe recipe) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = recipe.toJson();
    data['user_id'] = _userId;

    final response = await _supabase
        .from('recipes')
        .insert(data)
        .select()
        .single();

    return Recipe.fromJson(response);
  }

  /// 북마크 토글
  Future<void> toggleBookmark(String recipeId, bool isBookmarked) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('recipes')
        .update({'is_bookmarked': isBookmarked})
        .eq('id', recipeId)
        .eq('user_id', _userId!);
  }

  /// 레시피 삭제
  Future<void> deleteRecipe(String recipeId) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('recipes')
        .delete()
        .eq('id', recipeId)
        .eq('user_id', _userId!);
  }

  /// 요리 기록 저장
  Future<void> saveRecipeHistory({
    required String recipeTitle,
    String? recipeId,
    String? chefId,
  }) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase.from('recipe_history').insert({
      'user_id': _userId,
      'recipe_title': recipeTitle,
      if (recipeId != null) 'recipe_id': recipeId,
      if (chefId != null) 'chef_id': chefId,
    });
  }

  /// 요리 기록 조회
  Future<List<Map<String, dynamic>>> getRecipeHistory({
    int limit = 50,
  }) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('recipe_history')
        .select()
        .eq('user_id', _userId!)
        .order('cooked_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }
}
