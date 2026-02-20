import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/services/voice_command_service.dart';

void main() {
  late VoiceCommandService service;

  setUp(() {
    service = VoiceCommandService();
  });

  group('VoiceCommandService.parseCommand', () {
    test('"다음"은 NextStepCommand를 반환한다', () {
      final result = service.parseCommand('다음');
      expect(result, isA<NextStepCommand>());
    });

    test('"다음 단계"은 NextStepCommand를 반환한다', () {
      final result = service.parseCommand('다음 단계');
      expect(result, isA<NextStepCommand>());
    });

    test('"넘어가"은 NextStepCommand를 반환한다', () {
      final result = service.parseCommand('넘어가');
      expect(result, isA<NextStepCommand>());
    });

    test('"이전"은 PreviousStepCommand를 반환한다', () {
      final result = service.parseCommand('이전');
      expect(result, isA<PreviousStepCommand>());
    });

    test('"뒤로"은 PreviousStepCommand를 반환한다', () {
      final result = service.parseCommand('뒤로');
      expect(result, isA<PreviousStepCommand>());
    });

    test('"이전 단계"은 PreviousStepCommand를 반환한다', () {
      final result = service.parseCommand('이전 단계');
      expect(result, isA<PreviousStepCommand>());
    });

    test('"타이머 시작"은 StartTimerCommand를 반환한다', () {
      final result = service.parseCommand('타이머 시작');
      expect(result, isA<StartTimerCommand>());
    });

    test('"시작"은 StartTimerCommand를 반환한다', () {
      final result = service.parseCommand('시작');
      expect(result, isA<StartTimerCommand>());
    });

    test('"타이머 걸어"은 StartTimerCommand를 반환한다', () {
      final result = service.parseCommand('타이머 걸어');
      expect(result, isA<StartTimerCommand>());
    });

    test('"일시정지"은 PauseTimerCommand를 반환한다', () {
      final result = service.parseCommand('일시정지');
      expect(result, isA<PauseTimerCommand>());
    });

    test('"멈춰"은 PauseTimerCommand를 반환한다', () {
      final result = service.parseCommand('멈춰');
      expect(result, isA<PauseTimerCommand>());
    });

    test('"정지"은 PauseTimerCommand를 반환한다', () {
      final result = service.parseCommand('정지');
      expect(result, isA<PauseTimerCommand>());
    });

    test('"다시"은 RepeatCommand를 반환한다', () {
      final result = service.parseCommand('다시');
      expect(result, isA<RepeatCommand>());
    });

    test('"반복"은 RepeatCommand를 반환한다', () {
      final result = service.parseCommand('반복');
      expect(result, isA<RepeatCommand>());
    });

    test('"다시 읽어"은 RepeatCommand를 반환한다', () {
      final result = service.parseCommand('다시 읽어');
      expect(result, isA<RepeatCommand>());
    });

    test('인식 불가 텍스트는 UnknownCommand를 반환한다', () {
      final result = service.parseCommand('안녕하세요');
      expect(result, isA<UnknownCommand>());
      expect((result as UnknownCommand).rawText, '안녕하세요');
    });

    test('앞뒤 공백은 무시한다', () {
      final result = service.parseCommand('  다음  ');
      expect(result, isA<NextStepCommand>());
    });

    test('대소문자를 무시한다', () {
      final result = service.parseCommand('넥스트');
      expect(result, isA<NextStepCommand>());
    });
  });
}
