import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chef_config.dart';

void main() {
  group('ChefPersonality enum', () {
    test('모든 값이 존재한다', () {
      expect(ChefPersonality.values, containsAll([
        ChefPersonality.professional,
        ChefPersonality.friendly,
        ChefPersonality.motherly,
        ChefPersonality.coach,
        ChefPersonality.scientific,
        ChefPersonality.custom,
      ]));
      expect(ChefPersonality.values.length, 6);
    });
  });

  group('Formality enum', () {
    test('formal과 casual이 존재한다', () {
      expect(Formality.values, containsAll([
        Formality.formal,
        Formality.casual,
      ]));
      expect(Formality.values.length, 2);
    });
  });

  group('EmojiUsage enum', () {
    test('4가지 값이 존재한다', () {
      expect(EmojiUsage.values, containsAll([
        EmojiUsage.high,
        EmojiUsage.medium,
        EmojiUsage.low,
        EmojiUsage.none,
      ]));
      expect(EmojiUsage.values.length, 4);
    });
  });

  group('Technicality enum', () {
    test('3가지 값이 존재한다', () {
      expect(Technicality.values, containsAll([
        Technicality.expert,
        Technicality.general,
        Technicality.beginner,
      ]));
      expect(Technicality.values.length, 3);
    });
  });

  group('SpeakingStyle', () {
    test('기본값이 올바르다', () {
      const style = SpeakingStyle();
      expect(style.formality, Formality.casual);
      expect(style.emojiUsage, EmojiUsage.medium);
      expect(style.technicality, Technicality.general);
    });

    test('toJson이 올바른 맵을 반환한다', () {
      const style = SpeakingStyle(
        formality: Formality.formal,
        emojiUsage: EmojiUsage.high,
        technicality: Technicality.expert,
      );

      final json = style.toJson();
      expect(json['formality'], 'formal');
      expect(json['emojiUsage'], 'high');
      expect(json['technicality'], 'expert');
    });
  });

  group('AIChefConfig', () {
    test('기본 생성자 값이 올바르다', () {
      const config = AIChefConfig();
      expect(config.name, 'AI 셰프');
      expect(config.personality, ChefPersonality.friendly);
      expect(config.customPersonality, isNull);
      expect(config.expertise, ['한식', '일식', '양식']);
      expect(config.cookingPhilosophy, isNull);
    });

    test('defaultConfig의 필드가 올바르다', () {
      const config = AIChefConfig.defaultConfig;
      expect(config.name, 'AI 셰프');
      expect(config.personality, ChefPersonality.friendly);
      expect(config.expertise, ['한식', '일식', '양식']);
      expect(config.cookingPhilosophy, isNotNull);
      expect(config.speakingStyle.formality, Formality.casual);
      expect(config.speakingStyle.emojiUsage, EmojiUsage.medium);
      expect(config.speakingStyle.technicality, Technicality.general);
    });

    test('toJson이 올바른 맵을 반환한다', () {
      const config = AIChefConfig(
        name: '테스트 셰프',
        personality: ChefPersonality.professional,
        customPersonality: '커스텀',
        expertise: ['한식'],
        cookingPhilosophy: '맛있게!',
        speakingStyle: SpeakingStyle(
          formality: Formality.formal,
          emojiUsage: EmojiUsage.none,
          technicality: Technicality.expert,
        ),
      );

      final json = config.toJson();
      expect(json['name'], '테스트 셰프');
      expect(json['personality'], 'professional');
      expect(json['customPersonality'], '커스텀');
      expect(json['expertise'], ['한식']);
      expect(json['cookingPhilosophy'], '맛있게!');
      expect(json['speakingStyle'], isA<Map<String, dynamic>>());
      expect(json['speakingStyle']['formality'], 'formal');
    });
  });
}
