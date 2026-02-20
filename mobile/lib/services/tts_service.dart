import 'package:flutter_tts/flutter_tts.dart';

/// TTS(Text-to-Speech) 서비스
///
/// FlutterTts 래퍼. 조리 모드에서 단계 읽기에 사용.
/// DI를 위해 [FlutterTts] 인스턴스를 주입 가능.
class TtsService {
  final FlutterTts _tts;
  bool _isInitialized = false;

  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  /// TTS 초기화 (한국어 설정)
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _isInitialized = true;
  }

  /// 텍스트 읽기
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _tts.speak(text);
  }

  /// 읽기 중지
  Future<void> stop() async {
    await _tts.stop();
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await _tts.stop();
  }
}
