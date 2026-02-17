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
