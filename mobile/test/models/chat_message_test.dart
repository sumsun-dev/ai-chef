import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    group('constructor', () {
      test('id가 자동 생성된다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '안녕하세요',
        );

        expect(msg.id, isNotEmpty);
      });

      test('isLoading 기본값은 false이다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '테스트',
        );

        expect(msg.isLoading, isFalse);
      });

      test('timestamp 기본값은 현재 시간이다', () {
        final before = DateTime.now();
        final msg = ChatMessage(
          role: MessageRole.assistant,
          content: '응답',
        );
        final after = DateTime.now();

        expect(msg.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(msg.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('명시적 id가 유지된다', () {
        final msg = ChatMessage(
          id: 'custom-id',
          role: MessageRole.user,
          content: '테스트',
        );

        expect(msg.id, 'custom-id');
      });

      test('user role이 올바르게 설정된다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '사용자 메시지',
        );

        expect(msg.role, MessageRole.user);
      });

      test('assistant role이 올바르게 설정된다', () {
        final msg = ChatMessage(
          role: MessageRole.assistant,
          content: 'AI 응답',
        );

        expect(msg.role, MessageRole.assistant);
      });

      test('userId와 chefId가 올바르게 설정된다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '테스트',
          userId: 'user-123',
          chefId: 'baek',
        );

        expect(msg.userId, 'user-123');
        expect(msg.chefId, 'baek');
      });

      test('userId와 chefId 기본값은 null이다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '테스트',
        );

        expect(msg.userId, isNull);
        expect(msg.chefId, isNull);
      });
    });

    group('fromJson', () {
      test('DB 응답을 올바르게 파싱한다', () {
        final json = {
          'id': 42,
          'role': 'user',
          'content': '김치찌개 만들어줘',
          'created_at': '2026-02-18T12:00:00.000Z',
          'user_id': 'user-abc',
          'chef_id': 'baek',
        };

        final msg = ChatMessage.fromJson(json);

        expect(msg.id, '42');
        expect(msg.role, MessageRole.user);
        expect(msg.content, '김치찌개 만들어줘');
        expect(msg.userId, 'user-abc');
        expect(msg.chefId, 'baek');
        expect(msg.timestamp.year, 2026);
      });

      test('assistant role을 올바르게 파싱한다', () {
        final json = {
          'id': '1',
          'role': 'assistant',
          'content': '네, 김치찌개를 만들어 볼게요!',
          'created_at': '2026-02-18T12:01:00.000Z',
        };

        final msg = ChatMessage.fromJson(json);

        expect(msg.role, MessageRole.assistant);
        expect(msg.content, '네, 김치찌개를 만들어 볼게요!');
      });

      test('누락된 필드에 기본값을 사용한다', () {
        final json = <String, dynamic>{
          'role': 'user',
        };

        final msg = ChatMessage.fromJson(json);

        expect(msg.id, '');
        expect(msg.content, '');
        expect(msg.userId, isNull);
        expect(msg.chefId, isNull);
      });
    });

    group('toJson', () {
      test('올바르게 직렬화한다', () {
        final timestamp = DateTime(2026, 2, 18, 12, 0);
        final msg = ChatMessage(
          id: '1',
          role: MessageRole.user,
          content: '안녕하세요',
          timestamp: timestamp,
          userId: 'user-123',
          chefId: 'baek',
        );

        final json = msg.toJson();

        expect(json['role'], 'user');
        expect(json['content'], '안녕하세요');
        expect(json['user_id'], 'user-123');
        expect(json['chef_id'], 'baek');
        expect(json['created_at'], contains('2026-02-18'));
      });

      test('isLoading은 toJson에 포함되지 않는다', () {
        final msg = ChatMessage(
          role: MessageRole.assistant,
          content: '',
          isLoading: true,
        );

        final json = msg.toJson();

        expect(json.containsKey('isLoading'), isFalse);
        expect(json.containsKey('is_loading'), isFalse);
      });

      test('null 필드는 toJson에 포함되지 않는다', () {
        final msg = ChatMessage(
          role: MessageRole.user,
          content: '테스트',
        );

        final json = msg.toJson();

        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('chef_id'), isFalse);
      });
    });

    group('round-trip', () {
      test('toJson → fromJson round-trip이 동작한다', () {
        final original = ChatMessage(
          id: '99',
          role: MessageRole.assistant,
          content: '맛있는 파스타 레시피를 알려드릴게요!',
          timestamp: DateTime(2026, 2, 18),
          userId: 'user-xyz',
          chefId: 'gordon',
        );

        final json = original.toJson();
        json['id'] = original.id;
        final restored = ChatMessage.fromJson(json);

        expect(restored.role, original.role);
        expect(restored.content, original.content);
        expect(restored.userId, original.userId);
        expect(restored.chefId, original.chefId);
      });
    });

    group('copyWith', () {
      test('isLoading을 변경할 수 있다', () {
        final original = ChatMessage(
          role: MessageRole.assistant,
          content: '',
          isLoading: true,
        );

        final updated = original.copyWith(isLoading: false);

        expect(updated.isLoading, isFalse);
        expect(updated.id, original.id);
        expect(updated.role, original.role);
      });

      test('content를 변경할 수 있다', () {
        final original = ChatMessage(
          role: MessageRole.assistant,
          content: '로딩 중...',
          isLoading: true,
        );

        final updated = original.copyWith(
          content: '실제 응답입니다',
          isLoading: false,
        );

        expect(updated.content, '실제 응답입니다');
        expect(updated.isLoading, isFalse);
        expect(updated.id, original.id);
        expect(updated.timestamp, original.timestamp);
      });

      test('변경하지 않은 필드는 유지된다', () {
        final timestamp = DateTime(2026, 1, 1);
        final original = ChatMessage(
          id: 'keep-id',
          role: MessageRole.user,
          content: '원래 내용',
          timestamp: timestamp,
        );

        final updated = original.copyWith(content: '새 내용');

        expect(updated.id, 'keep-id');
        expect(updated.role, MessageRole.user);
        expect(updated.timestamp, timestamp);
        expect(updated.content, '새 내용');
      });

      test('userId와 chefId를 변경할 수 있다', () {
        final original = ChatMessage(
          role: MessageRole.user,
          content: '테스트',
        );

        final updated = original.copyWith(
          userId: 'new-user',
          chefId: 'new-chef',
        );

        expect(updated.userId, 'new-user');
        expect(updated.chefId, 'new-chef');
        expect(updated.content, original.content);
      });
    });
  });

  group('MessageRole', () {
    test('user와 assistant 두 값이 존재한다', () {
      expect(MessageRole.values.length, 2);
      expect(MessageRole.values, contains(MessageRole.user));
      expect(MessageRole.values, contains(MessageRole.assistant));
    });
  });
}
