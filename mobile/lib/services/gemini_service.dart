import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

/// Gemini API 서비스
///
/// 사용 모델:
/// - gemini-3.0-flash: 빠른 대화용
/// - gemini-3.0-pro: 복잡한 레시피 생성용
class GeminiService {
  late final GenerativeModel _flashModel;
  late final GenerativeModel _proModel;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }

    // Flash 모델 (빠른 대화용)
    _flashModel = GenerativeModel(
      model: 'gemini-3.0-flash',
      apiKey: apiKey,
      safetySettings: _safetySettings,
    );

    // Pro 모델 (복잡한 레시피 생성용)
    _proModel = GenerativeModel(
      model: 'gemini-3.0-pro',
      apiKey: apiKey,
      safetySettings: _safetySettings,
    );
  }

  /// 안전 설정
  static final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  /// 성격별 프롬프트 생성
  String _getPersonalityPrompt(ChefPersonality personality, String? customPersonality) {
    const personalities = {
      ChefPersonality.professional:
          '정확하고 전문적인 설명을 제공합니다. 요리 용어를 정확히 사용하고, 체계적으로 안내합니다.',
      ChefPersonality.friendly:
          '친근하고 편안한 친구처럼 대화합니다. 격의 없이 말하며, 재미있는 요리 경험을 제공합니다.',
      ChefPersonality.motherly:
          '따뜻하고 다정한 엄마처럼 케어합니다. 꼼꼼하게 챙기고, 격려와 칭찬을 아끼지 않습니다.',
      ChefPersonality.coach:
          '열정적인 코치처럼 동기부여합니다. 할 수 있다는 자신감을 주고, 도전을 격려합니다.',
      ChefPersonality.scientific:
          '요리 과학을 설명합니다. 왜 이렇게 해야 하는지, 화학적/물리적 원리를 쉽게 풀어줍니다.',
    };

    if (personality == ChefPersonality.custom) {
      return customPersonality ?? '사용자 맞춤 성격입니다.';
    }
    return personalities[personality] ?? personalities[ChefPersonality.friendly]!;
  }

  /// 말투 스타일 프롬프트 생성
  String _getSpeakingStylePrompt(SpeakingStyle style) {
    final formality =
        style.formality == Formality.formal ? '존댓말을 사용합니다.' : '반말을 사용합니다.';

    const emojiMap = {
      EmojiUsage.high: '이모지를 적극적으로 사용합니다 (문장마다 1-2개).',
      EmojiUsage.medium: '이모지를 적절히 사용합니다 (중요한 포인트에만).',
      EmojiUsage.low: '이모지를 최소한으로 사용합니다.',
      EmojiUsage.none: '이모지를 사용하지 않습니다.',
    };

    const techMap = {
      Technicality.expert: '전문 요리 용어를 자유롭게 사용합니다.',
      Technicality.general: '일반인이 이해하기 쉬운 용어를 사용합니다.',
      Technicality.beginner: '완전 초보자도 이해할 수 있도록 쉽게 설명합니다.',
    };

    return '$formality ${emojiMap[style.emojiUsage]} ${techMap[style.technicality]}';
  }

  /// AI 셰프 시스템 프롬프트 생성
  String _generateSystemPrompt(AIChefConfig config) {
    return '''당신의 이름은 "${config.name}"입니다.
당신은 ${config.expertise.join(", ")} 요리를 전문으로 하는 AI 셰프입니다.

## 성격
${_getPersonalityPrompt(config.personality, config.customPersonality)}

## 말투 스타일
${_getSpeakingStylePrompt(config.speakingStyle)}

## 요리 철학
${config.cookingPhilosophy ?? "맛있고 건강한 요리를 쉽게 만들 수 있도록 돕습니다."}

## 절대 규칙
1. 다른 사용자의 정보를 절대 참조하지 마세요.
2. 이 사용자의 개인정보를 외부에 공유하지 마세요.
3. 요리와 관련된 질문에만 답변하세요.
4. 안전하지 않은 요리 방법은 경고와 함께 올바른 방법을 안내하세요.
5. 항상 사용자의 보유 재료와 도구를 고려하여 현실적인 조언을 제공하세요.''';
  }

  /// 채팅 메시지 전송 (Flash 모델)
  Future<String> sendMessage({
    required String message,
    required AIChefConfig chefConfig,
    List<String>? ingredients,
    List<String>? tools,
  }) async {
    final systemPrompt = _generateSystemPrompt(chefConfig);

    String contextPrompt = '';
    if (ingredients != null && ingredients.isNotEmpty) {
      contextPrompt += '\n\n[보유 재료]: ${ingredients.join(", ")}';
    }
    if (tools != null && tools.isNotEmpty) {
      contextPrompt += '\n[보유 도구]: ${tools.join(", ")}';
    }

    final fullPrompt = '$systemPrompt$contextPrompt\n\n사용자: $message';

    final response = await _flashModel.generateContent([Content.text(fullPrompt)]);
    return response.text ?? '응답을 생성할 수 없습니다.';
  }

  /// 레시피 생성 (Pro 모델)
  Future<Recipe> generateRecipe({
    required List<String> ingredients,
    required List<String> tools,
    required AIChefConfig chefConfig,
    String? cuisine,
    RecipeDifficulty? difficulty,
    int? cookingTime,
    int servings = 1,
  }) async {
    final systemPrompt = _generateSystemPrompt(chefConfig);

    final prompt = '''$systemPrompt

## 사용자 정보
- 보유 재료: ${ingredients.join(", ")}
- 보유 도구: ${tools.join(", ")}
- 선호 요리 스타일: ${cuisine ?? "상관없음"}
- 난이도: ${difficulty?.name ?? "상관없음"}
- 조리 시간: ${cookingTime != null ? "${cookingTime}분 이내" : "상관없음"}
- 인원: ${servings}인분

## 요청
위 재료와 도구로 만들 수 있는 맞춤 레시피를 추천해주세요.

## 응답 형식 (JSON)
다음 형식으로 응답해주세요:
```json
{
  "title": "요리명",
  "description": "한 줄 설명",
  "cuisine": "요리 스타일",
  "difficulty": "easy|medium|hard",
  "cookingTime": 조리시간(분),
  "servings": 인원수,
  "ingredients": [
    {
      "name": "재료명",
      "quantity": "양",
      "unit": "단위",
      "isAvailable": true/false,
      "substitute": "대체 재료 (없으면 null)"
    }
  ],
  "tools": [
    {
      "name": "도구명",
      "isAvailable": true/false,
      "alternative": "대체 방법 (없으면 null)"
    }
  ],
  "instructions": [
    {
      "step": 1,
      "title": "단계 제목",
      "description": "상세 설명",
      "time": 소요시간(분),
      "tips": "팁 (없으면 null)"
    }
  ],
  "nutrition": {
    "calories": 칼로리,
    "protein": 단백질(g),
    "carbs": 탄수화물(g),
    "fat": 지방(g)
  },
  "chefNote": "셰프의 한마디"
}
```''';

    final response = await _proModel.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    // JSON 파싱
    try {
      final jsonMatch = RegExp(r'```json\n?([\s\S]*?)\n?```').firstMatch(text);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(1)!);
        return Recipe.fromJson(jsonData);
      }
      final jsonData = json.decode(text);
      return Recipe.fromJson(jsonData);
    } catch (e) {
      throw Exception('레시피 파싱 실패: $e');
    }
  }

  /// 요리 사진 분석 (Vision API)
  ///
  /// 사진을 분석하여 익힘 정도, 플레이팅 상태, 개선점 등을 피드백합니다.
  Future<CookingFeedback> analyzeCookingPhoto({
    required Uint8List imageBytes,
    required String mimeType,
    required AIChefConfig chefConfig,
    String? currentStep,
    String? recipeName,
  }) async {
    final systemPrompt = _generateSystemPrompt(chefConfig);

    String contextInfo = '';
    if (recipeName != null) {
      contextInfo += '\n현재 요리: $recipeName';
    }
    if (currentStep != null) {
      contextInfo += '\n현재 단계: $currentStep';
    }

    final prompt = '''$systemPrompt
$contextInfo

## 요청
사용자가 요리 중인 사진을 보내왔습니다. 다음을 분석해주세요:

1. **익힘 정도 (doneness)**: 재료가 적절히 익었는지, 더 익혀야 하는지, 과하게 익었는지
2. **플레이팅 (plating)**: 담음새, 배치, 시각적 매력도
3. **전반적인 상태 (overallAssessment)**: 현재 요리 진행 상황에 대한 종합 평가
4. **개선 제안 (suggestions)**: 구체적인 개선 방법 (최대 3개)
5. **격려 메시지 (encouragement)**: 사용자를 응원하는 한마디

## 응답 형식 (JSON)
```json
{
  "doneness": "undercooked|perfect|overcooked|not_applicable",
  "donenessDescription": "익힘 정도에 대한 상세 설명",
  "platingScore": 1-10,
  "platingFeedback": "플레이팅에 대한 피드백",
  "overallAssessment": "전반적인 평가",
  "suggestions": ["제안1", "제안2", "제안3"],
  "encouragement": "격려 메시지"
}
```''';

    final response = await _flashModel.generateContent([
      Content.multi([
        DataPart(mimeType, imageBytes),
        TextPart(prompt),
      ]),
    ]);

    final text = response.text ?? '';

    try {
      final jsonMatch = RegExp(r'```json\n?([\s\S]*?)\n?```').firstMatch(text);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(1)!);
        return CookingFeedback.fromJson(jsonData);
      }
      final jsonData = json.decode(text);
      return CookingFeedback.fromJson(jsonData);
    } catch (e) {
      // JSON 파싱 실패시 기본 피드백 생성
      return CookingFeedback(
        doneness: Doneness.notApplicable,
        donenessDescription: text,
        platingScore: 5,
        platingFeedback: '분석 중 오류가 발생했습니다.',
        overallAssessment: text,
        suggestions: [],
        encouragement: '다시 시도해 주세요!',
      );
    }
  }
}
