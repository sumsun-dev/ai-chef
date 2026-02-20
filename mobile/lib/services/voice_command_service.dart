import 'package:speech_to_text/speech_to_text.dart';

/// 음성 명령 sealed class
sealed class VoiceCommand {}

class NextStepCommand extends VoiceCommand {}

class PreviousStepCommand extends VoiceCommand {}

class StartTimerCommand extends VoiceCommand {}

class PauseTimerCommand extends VoiceCommand {}

class RepeatCommand extends VoiceCommand {}

class UnknownCommand extends VoiceCommand {
  final String rawText;
  UnknownCommand(this.rawText);
}

/// 음성 명령 인식 서비스
///
/// speech_to_text를 사용하여 한국어 음성을 인식하고
/// [VoiceCommand]로 파싱합니다.
class VoiceCommandService {
  final SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  VoiceCommandService({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  bool get isListening => _isListening;

  /// 음성 인식 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final available = await _speech.initialize();
    _isInitialized = available;
    return available;
  }

  /// 음성 인식 시작
  Future<void> startListening({
    required void Function(VoiceCommand command) onCommand,
    void Function(String partialText)? onPartial,
  }) async {
    if (!_isInitialized) {
      final available = await initialize();
      if (!available) return;
    }

    _isListening = true;
    await _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          final command = parseCommand(result.recognizedWords);
          onCommand(command);
        } else {
          onPartial?.call(result.recognizedWords);
        }
      },
    );
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// 한국어 텍스트를 VoiceCommand로 파싱
  VoiceCommand parseCommand(String text) {
    final normalized = text.trim().toLowerCase();

    // 다음 단계
    if (_matchesAny(normalized, ['다음', '넘어가', '다음 단계', '넥스트'])) {
      return NextStepCommand();
    }

    // 이전 단계
    if (_matchesAny(normalized, ['이전', '뒤로', '이전 단계', '돌아가'])) {
      return PreviousStepCommand();
    }

    // 타이머 시작
    if (_matchesAny(normalized, ['타이머 시작', '시작', '타이머 켜', '타이머 걸어'])) {
      return StartTimerCommand();
    }

    // 타이머 일시정지
    if (_matchesAny(normalized, ['일시정지', '멈춰', '타이머 멈춰', '정지', '타이머 정지', '스톱'])) {
      return PauseTimerCommand();
    }

    // 다시 읽기
    if (_matchesAny(normalized, ['다시', '반복', '한번 더', '다시 읽어', '다시 말해'])) {
      return RepeatCommand();
    }

    return UnknownCommand(text);
  }

  bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((pattern) => text.contains(pattern));
  }
}
