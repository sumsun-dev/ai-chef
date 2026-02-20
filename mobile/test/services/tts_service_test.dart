import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:ai_chef/services/tts_service.dart';

/// Fake FlutterTts for testing
class FakeFlutterTts extends Fake implements FlutterTts {
  String? lastSpokenText;
  String? language;
  double? speechRate;
  double? volume;
  double? pitch;
  bool stopCalled = false;
  int speakCallCount = 0;

  @override
  Future<dynamic> setLanguage(String lang) async {
    language = lang;
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    speechRate = rate;
    return 1;
  }

  @override
  Future<dynamic> setVolume(double vol) async {
    volume = vol;
    return 1;
  }

  @override
  Future<dynamic> setPitch(double p) async {
    pitch = p;
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
    speakCallCount++;
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    stopCalled = true;
    return 1;
  }
}

void main() {
  late FakeFlutterTts fakeTts;
  late TtsService service;

  setUp(() {
    fakeTts = FakeFlutterTts();
    service = TtsService(tts: fakeTts);
  });

  group('TtsService', () {
    test('initialize는 한국어로 설정한다', () async {
      // Act
      await service.initialize();

      // Assert
      expect(fakeTts.language, 'ko-KR');
      expect(fakeTts.speechRate, 0.5);
      expect(fakeTts.volume, 1.0);
      expect(fakeTts.pitch, 1.0);
    });

    test('initialize는 중복 호출 시 한 번만 실행된다', () async {
      // Act
      await service.initialize();
      fakeTts.language = null;
      await service.initialize();

      // Assert - 두 번째 호출에서 language가 다시 설정되지 않음
      expect(fakeTts.language, isNull);
    });

    test('speak는 텍스트를 읽는다', () async {
      // Arrange
      await service.initialize();

      // Act
      await service.speak('양파를 썰어주세요');

      // Assert
      expect(fakeTts.lastSpokenText, '양파를 썰어주세요');
      expect(fakeTts.speakCallCount, 1);
    });

    test('speak는 초기화되지 않았으면 자동 초기화한다', () async {
      // Act
      await service.speak('테스트');

      // Assert
      expect(fakeTts.language, 'ko-KR');
      expect(fakeTts.lastSpokenText, '테스트');
    });

    test('stop은 읽기를 중지한다', () async {
      // Act
      await service.stop();

      // Assert
      expect(fakeTts.stopCalled, true);
    });

    test('dispose는 TTS를 정리한다', () async {
      // Act
      await service.dispose();

      // Assert
      expect(fakeTts.stopCalled, true);
    });
  });
}
