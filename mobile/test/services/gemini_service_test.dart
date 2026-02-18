import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/services/gemini_service.dart';
import 'package:ai_chef/models/chef_config.dart';

void main() {
  late GeminiService service;

  setUp(() {
    service = GeminiService(apiKey: 'test-api-key');
  });

  group('GeminiService constructor', () {
    test('empty apiKey throws Exception', () {
      expect(
        () => GeminiService(apiKey: ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('GEMINI_API_KEY'),
        )),
      );
    });
  });

  group('getPersonalityPrompt', () {
    test('professional returns 전문적 description', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.professional, null);
      expect(result, contains('전문적'));
    });

    test('friendly returns 친근 description', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.friendly, null);
      expect(result, contains('친근'));
    });

    test('motherly returns 엄마 description', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.motherly, null);
      expect(result, contains('엄마'));
    });

    test('coach returns 코치 description', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.coach, null);
      expect(result, contains('코치'));
    });

    test('scientific returns 과학 description', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.scientific, null);
      expect(result, contains('과학'));
    });

    test('custom returns customPersonality string', () {
      final result = service.getPersonalityPrompt(
          ChefPersonality.custom, '나만의 성격입니다');
      expect(result, '나만의 성격입니다');
    });

    test('custom with null returns default message', () {
      final result =
          service.getPersonalityPrompt(ChefPersonality.custom, null);
      expect(result, contains('사용자 맞춤'));
    });
  });

  group('getSpeakingStylePrompt', () {
    test('formal + high emoji + expert', () {
      const style = SpeakingStyle(
        formality: Formality.formal,
        emojiUsage: EmojiUsage.high,
        technicality: Technicality.expert,
      );
      final result = service.getSpeakingStylePrompt(style);
      expect(result, contains('존댓말'));
      expect(result, contains('적극적'));
      expect(result, contains('전문'));
    });

    test('casual + none emoji + beginner', () {
      const style = SpeakingStyle(
        formality: Formality.casual,
        emojiUsage: EmojiUsage.none,
        technicality: Technicality.beginner,
      );
      final result = service.getSpeakingStylePrompt(style);
      expect(result, contains('반말'));
      expect(result, contains('사용하지 않습니다'));
      expect(result, contains('초보자'));
    });

    test('medium emoji', () {
      const style = SpeakingStyle(emojiUsage: EmojiUsage.medium);
      final result = service.getSpeakingStylePrompt(style);
      expect(result, contains('적절히'));
    });

    test('low emoji', () {
      const style = SpeakingStyle(emojiUsage: EmojiUsage.low);
      final result = service.getSpeakingStylePrompt(style);
      expect(result, contains('최소한'));
    });
  });

  group('generateSystemPrompt', () {
    test('includes chef name', () {
      const config = AIChefConfig(name: '백종원');
      final result = service.generateSystemPrompt(config);
      expect(result, contains('백종원'));
    });

    test('includes expertise', () {
      const config = AIChefConfig(expertise: ['한식', '일식']);
      final result = service.generateSystemPrompt(config);
      expect(result, contains('한식'));
      expect(result, contains('일식'));
    });

    test('includes cooking philosophy', () {
      const config = AIChefConfig(cookingPhilosophy: '건강이 최고');
      final result = service.generateSystemPrompt(config);
      expect(result, contains('건강이 최고'));
    });

    test('uses default philosophy when null', () {
      const config = AIChefConfig(cookingPhilosophy: null);
      final result = service.generateSystemPrompt(config);
      expect(result, contains('맛있고 건강한'));
    });

    test('includes safety rules', () {
      const config = AIChefConfig();
      final result = service.generateSystemPrompt(config);
      expect(result, contains('한국어로 응답'));
      expect(result, contains('개인정보'));
      expect(result, contains('요리와 관련된'));
    });
  });
}
