import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/services/cooking_audio_service.dart';

class FakeAudioPlayer extends Fake implements AudioPlayer {
  Source? lastSource;
  int playCallCount = 0;
  bool disposeCalled = false;

  @override
  Future<void> play(Source source, {double? volume, double? balance, AudioContext? ctx, Duration? position, PlayerMode? mode}) async {
    lastSource = source;
    playCallCount++;
  }

  @override
  Future<void> dispose() async {
    disposeCalled = true;
  }
}

class FakeVibrationWrapper extends Fake implements VibrationWrapper {
  bool hasVibratorResult;
  int vibrateCallCount = 0;
  int? lastDuration;

  FakeVibrationWrapper({this.hasVibratorResult = true});

  @override
  Future<bool> hasVibrator() async => hasVibratorResult;

  @override
  Future<void> vibrate({int duration = 500}) async {
    vibrateCallCount++;
    lastDuration = duration;
  }
}

void main() {
  late FakeAudioPlayer fakePlayer;
  late FakeVibrationWrapper fakeVibration;
  late CookingAudioService service;

  setUp(() {
    fakePlayer = FakeAudioPlayer();
    fakeVibration = FakeVibrationWrapper();
    service = CookingAudioService(
      player: fakePlayer,
      vibration: fakeVibration,
    );
  });

  group('CookingAudioService', () {
    test('playTimerDone은 타이머 완료 사운드를 재생한다', () async {
      // Act
      await service.playTimerDone();

      // Assert
      expect(fakePlayer.playCallCount, 1);
      expect(fakePlayer.lastSource, isA<AssetSource>());
    });

    test('vibrate는 진동 피드백을 제공한다', () async {
      // Act
      await service.vibrate();

      // Assert
      expect(fakeVibration.vibrateCallCount, 1);
      expect(fakeVibration.lastDuration, 500);
    });

    test('vibrate는 진동 미지원 기기에서 무시한다', () async {
      // Arrange
      fakeVibration.hasVibratorResult = false;

      // Act
      await service.vibrate();

      // Assert
      expect(fakeVibration.vibrateCallCount, 0);
    });

    test('notifyTimerComplete는 사운드와 진동을 동시에 실행한다', () async {
      // Act
      await service.notifyTimerComplete();

      // Assert
      expect(fakePlayer.playCallCount, 1);
      expect(fakeVibration.vibrateCallCount, 1);
    });

    test('dispose는 오디오 플레이어를 정리한다', () async {
      // Act
      await service.dispose();

      // Assert
      expect(fakePlayer.disposeCalled, true);
    });
  });
}
