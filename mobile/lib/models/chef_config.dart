/// AI 셰프 성격 타입
enum ChefPersonality {
  professional,
  friendly,
  motherly,
  coach,
  scientific,
  custom,
}

/// 말투 격식
enum Formality { formal, casual }

/// 이모지 사용량
enum EmojiUsage { high, medium, low, none }

/// 기술 용어 수준
enum Technicality { expert, general, beginner }

/// 말투 스타일
class SpeakingStyle {
  final Formality formality;
  final EmojiUsage emojiUsage;
  final Technicality technicality;

  const SpeakingStyle({
    this.formality = Formality.casual,
    this.emojiUsage = EmojiUsage.medium,
    this.technicality = Technicality.general,
  });

  Map<String, dynamic> toJson() => {
        'formality': formality.name,
        'emojiUsage': emojiUsage.name,
        'technicality': technicality.name,
      };
}

/// AI 셰프 설정
class AIChefConfig {
  final String name;
  final ChefPersonality personality;
  final String? customPersonality;
  final List<String> expertise;
  final String? cookingPhilosophy;
  final SpeakingStyle speakingStyle;

  const AIChefConfig({
    this.name = 'AI 셰프',
    this.personality = ChefPersonality.friendly,
    this.customPersonality,
    this.expertise = const ['한식', '일식', '양식'],
    this.cookingPhilosophy,
    this.speakingStyle = const SpeakingStyle(),
  });

  /// 기본 AI 셰프 설정
  static const defaultConfig = AIChefConfig(
    name: 'AI 셰프',
    personality: ChefPersonality.friendly,
    expertise: ['한식', '일식', '양식'],
    cookingPhilosophy: '간편하고 맛있는 요리를 함께 만들어요!',
    speakingStyle: SpeakingStyle(
      formality: Formality.casual,
      emojiUsage: EmojiUsage.medium,
      technicality: Technicality.general,
    ),
  );

  Map<String, dynamic> toJson() => {
        'name': name,
        'personality': personality.name,
        'customPersonality': customPersonality,
        'expertise': expertise,
        'cookingPhilosophy': cookingPhilosophy,
        'speakingStyle': speakingStyle.toJson(),
      };
}
