import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// 조리 모드 오디오/진동 서비스
///
/// 타이머 완료 시 효과음 재생 + 진동 피드백 제공.
/// DI를 위해 [AudioPlayer]와 [VibrationWrapper]를 주입 가능.
class CookingAudioService {
  static const String _timerDoneSoundPath = 'sounds/timer_done.mp3';

  final AudioPlayer _player;
  final VibrationWrapper _vibration;

  CookingAudioService({
    AudioPlayer? player,
    VibrationWrapper? vibration,
  })  : _player = player ?? AudioPlayer(),
        _vibration = vibration ?? VibrationWrapper();

  /// 타이머 완료 사운드 재생
  Future<void> playTimerDone() async {
    await _player.play(AssetSource(_timerDoneSoundPath));
  }

  /// 진동 피드백 (짧은 패턴)
  Future<void> vibrate() async {
    final hasVibrator = await _vibration.hasVibrator();
    if (hasVibrator) {
      await _vibration.vibrate(duration: 500);
    }
  }

  /// 타이머 완료 알림 (사운드 + 진동)
  Future<void> notifyTimerComplete() async {
    await playTimerDone();
    await vibrate();
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Vibration 패키지 래퍼 (테스트용 DI)
class VibrationWrapper {
  Future<bool> hasVibrator() async {
    final result = await Vibration.hasVibrator();
    return result;
  }

  Future<void> vibrate({int duration = 500}) async {
    await Vibration.vibrate(duration: duration);
  }
}
