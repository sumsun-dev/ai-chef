import 'package:supabase_flutter/supabase_flutter.dart';

/// 조리 도구 서비스
/// DB에서 사용자 보유 도구를 조회합니다.
class ToolService {
  final SupabaseClient _supabase;

  ToolService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  static const defaultTools = ['프라이팬', '냄비', '전자레인지', '오븐'];

  /// 사용자 보유 도구 이름 목록 조회
  ///
  /// DB에 도구가 없으면 [defaultTools]를 반환합니다.
  Future<List<String>> getAvailableToolNames() async {
    final userId = _userId;
    if (userId == null) return List.from(defaultTools);

    final response = await _supabase
        .from('cooking_tools')
        .select('tool_name')
        .eq('user_id', userId)
        .eq('is_available', true);

    final names = (response as List)
        .map((row) => row['tool_name'] as String)
        .toList();

    return names.isEmpty ? List.from(defaultTools) : names;
  }
}
