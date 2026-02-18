import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_chef/models/chat_message.dart';
import 'package:ai_chef/services/chat_service.dart';
import '../helpers/mock_supabase.dart';

void main() {
  final testMessageJson = {
    'id': '1',
    'user_id': 'test-user-id',
    'chef_id': 'baek',
    'role': 'user',
    'content': '안녕하세요',
    'created_at': '2026-02-18T12:00:00.000Z',
  };

  group('not logged in', () {
    late ChatService service;

    setUp(() {
      service = ChatService(supabase: createLoggedOutClient());
    });

    test('getChatHistory throws', () {
      expect(() => service.getChatHistory(chefId: 'baek'),
          throwsA(isA<Exception>()));
    });

    test('saveMessage throws', () {
      final message = ChatMessage(role: MessageRole.user, content: '테스트');
      expect(() => service.saveMessage(message), throwsA(isA<Exception>()));
    });

    test('saveMessages throws when not empty', () {
      final messages = [
        ChatMessage(role: MessageRole.user, content: '테스트'),
      ];
      expect(() => service.saveMessages(messages), throwsA(isA<Exception>()));
    });

    test('clearChatHistory throws', () {
      expect(() => service.clearChatHistory('baek'),
          throwsA(isA<Exception>()));
    });
  });

  group('logged in', () {
    late MockSupabaseClient mockClient;
    late ChatService service;

    setUp(() {
      mockClient = createLoggedInClient();
      service = ChatService(supabase: mockClient);
    });

    test('getChatHistory returns messages', () async {
      when(mockClient.from('chat_messages'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testMessageJson]));

      final result = await service.getChatHistory(chefId: 'baek');
      expect(result.length, 1);
      expect(result.first.content, '안녕하세요');
      expect(result.first.role, MessageRole.user);
    });

    test('saveMessage completes without error', () async {
      when(mockClient.from('chat_messages'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      final message = ChatMessage(
        role: MessageRole.user,
        content: '테스트 메시지',
        chefId: 'baek',
      );
      await service.saveMessage(message);
    });

    test('saveMessages with empty list returns early', () async {
      // from() 호출 없이 early return
      await service.saveMessages([]);
    });

    test('saveMessages saves multiple messages', () async {
      when(mockClient.from('chat_messages'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      final messages = [
        ChatMessage(role: MessageRole.user, content: '질문'),
        ChatMessage(role: MessageRole.assistant, content: '답변'),
      ];
      await service.saveMessages(messages);
    });

    test('clearChatHistory completes without error', () async {
      when(mockClient.from('chat_messages'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.clearChatHistory('baek');
    });
  });
}
