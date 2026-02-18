import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';

/// 채팅 메시지 DB 서비스
class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 특정 셰프와의 대화 기록 조회
  Future<List<ChatMessage>> getChatHistory({
    required String chefId,
    int limit = 50,
  }) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('user_id', _userId!)
        .eq('chef_id', chefId)
        .order('created_at', ascending: true)
        .limit(limit);

    return (response as List)
        .map((item) => ChatMessage.fromJson(item))
        .toList();
  }

  /// 단일 메시지 저장
  Future<void> saveMessage(ChatMessage message) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    final data = message.toJson();
    data['user_id'] = _userId;

    await _supabase.from('chat_messages').insert(data);
  }

  /// 여러 메시지 일괄 저장
  Future<void> saveMessages(List<ChatMessage> messages) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');
    if (messages.isEmpty) return;

    final dataList = messages.map((msg) {
      final data = msg.toJson();
      data['user_id'] = _userId;
      return data;
    }).toList();

    await _supabase.from('chat_messages').insert(dataList);
  }

  /// 특정 셰프 대화 기록 삭제
  Future<void> clearChatHistory(String chefId) async {
    if (_userId == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('chat_messages')
        .delete()
        .eq('user_id', _userId!)
        .eq('chef_id', chefId);
  }
}
