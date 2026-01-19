import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

/// Gemini API 서비스
///
/// 사용 모델:
/// - gemini-3.0-flash: 빠른 대화용
/// - gemini-3.0-pro: 복잡한 레시피 생성용
///
/// 프롬프트 엔지니어링 전략:
/// 1. 구조화된 시스템 프롬프트 (역할, 맥락, 규칙, 출력 형식)
/// 2. 대화 히스토리 관리 (최근 N개 메시지 유지)
/// 3. Few-shot 예시로 일관된 출력 유도
/// 4. 토큰 최적화 (컨텍스트 요약, 슬라이딩 윈도우)
class GeminiService {
  late final GenerativeModel _flashModel;
  late final GenerativeModel _proModel;

  /// 대화 히스토리 저장 (최대 10개 턴 유지)
  final List<ChatMessage> _conversationHistory = [];
  static const int _maxHistoryTurns = 10;

  /// 토큰 추정 (한글 기준 대략적 계산)
  static const int _maxContextTokens = 8000;
  static const double _tokensPerChar = 0.5; // 한글 기준

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }

    // Flash 모델 (빠른 대화용) - 온도 낮춤 for 일관성
    _flashModel = GenerativeModel(
      model: 'gemini-3.0-flash',
      apiKey: apiKey,
      safetySettings: _safetySettings,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );

    // Pro 모델 (복잡한 레시피 생성용) - 더 낮은 온도
    _proModel = GenerativeModel(
      model: 'gemini-3.0-pro',
      apiKey: apiKey,
      safetySettings: _safetySettings,
      generationConfig: GenerationConfig(
        temperature: 0.5,
        topP: 0.85,
        topK: 30,
        maxOutputTokens: 4096,
      ),
    );
  }

  /// 대화 히스토리 초기화
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// 대화 히스토리에 메시지 추가
  void _addToHistory(ChatMessage message) {
    _conversationHistory.add(message);
    // 최대 턴 수 초과 시 오래된 메시지 제거
    while (_conversationHistory.length > _maxHistoryTurns * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  /// 대화 히스토리를 프롬프트 문자열로 변환
  String _buildConversationContext() {
    if (_conversationHistory.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('\n## 이전 대화');

    for (final msg in _conversationHistory) {
      final role = msg.role == MessageRole.user ? '사용자' : '셰프';
      buffer.writeln('$role: ${msg.content}');
    }

    return buffer.toString();
  }

  /// 토큰 수 추정
  int _estimateTokens(String text) {
    return (text.length * _tokensPerChar).round();
  }

  /// 컨텍스트가 너무 길 경우 요약
  String _optimizeContext(String context, int maxTokens) {
    final estimated = _estimateTokens(context);
    if (estimated <= maxTokens) return context;

    // 대화 히스토리 축소 (최근 절반만 유지)
    final halfLength = _conversationHistory.length ~/ 2;
    _conversationHistory.removeRange(0, halfLength);

    return _buildConversationContext();
  }

  /// 안전 설정
  static final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  /// 성격별 프롬프트 생성 (확장된 페르소나 정의)
  String _getPersonalityPrompt(ChefPersonality personality, String? customPersonality) {
    const personalities = {
      ChefPersonality.professional: '''
당신은 미슐랭 스타 레스토랑에서 수년간 경력을 쌓은 전문 셰프입니다.
- 요리 용어를 정확하게 사용하고, 체계적인 순서로 안내합니다
- 재료의 품질과 신선도를 중시하며, 대체재 사용 시에도 최적의 결과를 추구합니다
- 사용자의 실력 수준에 맞춰 기술적 팁을 제공합니다
- 플레이팅과 마무리에 대한 조언도 아끼지 않습니다''',
      ChefPersonality.friendly: '''
당신은 동네 인기 쿡방 유튜버처럼 친근한 친구 같은 셰프입니다.
- 어려운 용어 대신 쉽고 재미있는 표현을 사용합니다
- "이거 진짜 맛있어요!", "걱정 마세요~" 같은 격의 없는 말투를 씁니다
- 실패해도 괜찮다는 분위기로 요리를 즐겁게 만들어줍니다
- 작은 성공에도 함께 기뻐하며 응원합니다''',
      ChefPersonality.motherly: '''
당신은 40년 경력의 따뜻한 어머니 같은 셰프입니다.
- "우리 ○○이가", "얼마나 고생이야" 같이 다정하게 말합니다
- 영양 균형과 건강을 항상 챙기며, 정성을 강조합니다
- 실수해도 "괜찮아, 다음엔 더 잘할 수 있어"라며 격려합니다
- 요리 외에도 식사 예절이나 보관법 등 살림 지혜를 나눕니다''',
      ChefPersonality.coach: '''
당신은 요리 경연대회 출신의 열정 넘치는 코치 셰프입니다.
- "할 수 있어요!", "도전해보세요!" 같이 동기부여하는 말투를 씁니다
- 단계별 목표를 제시하고, 달성 시 칭찬과 다음 도전을 제안합니다
- 실력 향상을 위한 구체적인 연습 방법을 알려줍니다
- 때로는 약간의 압박으로 성장을 유도하지만 항상 응원합니다''',
      ChefPersonality.scientific: '''
당신은 푸드 사이언스 박사 학위를 가진 과학자 셰프입니다.
- 마이야르 반응, 유화 작용 등 요리 과학 원리를 쉽게 설명합니다
- "왜 이렇게 해야 하는지" 이유를 항상 함께 설명합니다
- 온도, 시간, 비율 등 정확한 수치를 제공합니다
- 실험적 시도를 장려하고, 결과에 대한 과학적 분석을 제공합니다''',
    };

    if (personality == ChefPersonality.custom) {
      return customPersonality ?? '사용자가 정의한 맞춤 성격으로 대화합니다.';
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

  /// AI 셰프 시스템 프롬프트 생성 (구조화된 RISEN 프레임워크)
  /// R: Role (역할), I: Instructions (지시), S: Steps (단계), E: Examples (예시), N: Narrowing (제약)
  String _generateSystemPrompt(AIChefConfig config) {
    return '''# 역할 (Role)
당신의 이름은 "${config.name}"입니다.
당신은 ${config.expertise.join(", ")} 요리를 전문으로 하는 AI 셰프입니다.

${_getPersonalityPrompt(config.personality, config.customPersonality)}

# 말투 스타일
${_getSpeakingStylePrompt(config.speakingStyle)}

# 요리 철학
${config.cookingPhilosophy ?? "맛있고 건강한 요리를 쉽게 만들 수 있도록 돕습니다."}

# 응답 지침 (Instructions)
1. **맥락 파악**: 사용자의 질문 의도와 현재 상황(보유 재료, 도구, 시간)을 먼저 파악하세요
2. **단계적 사고**: 복잡한 요리 질문은 단계별로 나눠서 설명하세요
3. **실용적 조언**: 이론보다 실제로 적용 가능한 팁을 우선하세요
4. **대안 제시**: 재료나 도구가 부족할 때는 항상 대체 방법을 제안하세요

# 응답 형식 가이드
- 레시피 설명 시: [재료] → [준비] → [조리 단계] → [팁] 순서로 구조화
- 질문 답변 시: 핵심 답변을 먼저, 부연 설명은 뒤에
- 여러 옵션 제시 시: 번호를 매겨 명확하게 구분

# 안전 및 제약 규칙 (Narrowing)
1. 다른 사용자의 정보를 절대 참조하거나 언급하지 마세요
2. 이 사용자의 개인정보를 외부에 공유하지 마세요
3. 요리와 관련된 질문에만 답변하세요. 요리 외 주제는 정중히 거절하세요
4. 안전하지 않은 요리 방법(날것 섭취 위험, 알레르기 등)은 경고와 함께 올바른 방법을 안내하세요
5. 항상 사용자의 보유 재료와 도구를 고려하여 현실적인 조언을 제공하세요
6. 확실하지 않은 영양 정보나 건강 효능은 단정적으로 말하지 마세요''';
  }

  /// 채팅용 확장 시스템 프롬프트 (대화 맥락 포함)
  String _generateChatSystemPrompt(AIChefConfig config, {
    List<String>? ingredients,
    List<String>? tools,
  }) {
    final basePrompt = _generateSystemPrompt(config);

    final contextBuffer = StringBuffer();
    contextBuffer.writeln('\n# 현재 사용자 컨텍스트');

    if (ingredients != null && ingredients.isNotEmpty) {
      contextBuffer.writeln('- 보유 재료: ${ingredients.join(", ")}');
    } else {
      contextBuffer.writeln('- 보유 재료: 정보 없음');
    }

    if (tools != null && tools.isNotEmpty) {
      contextBuffer.writeln('- 보유 도구: ${tools.join(", ")}');
    } else {
      contextBuffer.writeln('- 보유 도구: 정보 없음');
    }

    return '$basePrompt${contextBuffer.toString()}';
  }

  /// 채팅 메시지 전송 (Flash 모델) - 대화 히스토리 지원
  Future<String> sendMessage({
    required String message,
    required AIChefConfig chefConfig,
    List<String>? ingredients,
    List<String>? tools,
    bool preserveHistory = true,
  }) async {
    // 1. 시스템 프롬프트 생성
    final systemPrompt = _generateChatSystemPrompt(
      chefConfig,
      ingredients: ingredients,
      tools: tools,
    );

    // 2. 대화 히스토리 컨텍스트 구성
    String conversationContext = _buildConversationContext();
    conversationContext = _optimizeContext(
      conversationContext,
      _maxContextTokens - _estimateTokens(systemPrompt) - _estimateTokens(message) - 500,
    );

    // 3. 전체 프롬프트 구성
    final fullPrompt = '''$systemPrompt
$conversationContext

# 현재 대화
사용자: $message

응답:''';

    // 4. API 호출
    final response = await _flashModel.generateContent([Content.text(fullPrompt)]);
    final responseText = response.text ?? '응답을 생성할 수 없습니다.';

    // 5. 대화 히스토리 업데이트
    if (preserveHistory) {
      _addToHistory(ChatMessage(role: MessageRole.user, content: message));
      _addToHistory(ChatMessage(role: MessageRole.assistant, content: responseText));
    }

    return responseText;
  }

  /// 스트리밍 채팅 메시지 전송 (Flash 모델)
  Stream<String> sendMessageStream({
    required String message,
    required AIChefConfig chefConfig,
    List<String>? ingredients,
    List<String>? tools,
    bool preserveHistory = true,
  }) async* {
    // 1. 시스템 프롬프트 생성
    final systemPrompt = _generateChatSystemPrompt(
      chefConfig,
      ingredients: ingredients,
      tools: tools,
    );

    // 2. 대화 히스토리 컨텍스트 구성
    String conversationContext = _buildConversationContext();
    conversationContext = _optimizeContext(
      conversationContext,
      _maxContextTokens - _estimateTokens(systemPrompt) - _estimateTokens(message) - 500,
    );

    // 3. 전체 프롬프트 구성
    final fullPrompt = '''$systemPrompt
$conversationContext

# 현재 대화
사용자: $message

응답:''';

    // 4. 스트리밍 API 호출
    final responseBuffer = StringBuffer();
    final stream = _flashModel.generateContentStream([Content.text(fullPrompt)]);

    await for (final chunk in stream) {
      final text = chunk.text ?? '';
      responseBuffer.write(text);
      yield text;
    }

    // 5. 대화 히스토리 업데이트
    if (preserveHistory) {
      _addToHistory(ChatMessage(role: MessageRole.user, content: message));
      _addToHistory(ChatMessage(role: MessageRole.assistant, content: responseBuffer.toString()));
    }
  }

  /// 레시피 JSON 스키마 (Few-shot 예시 포함)
  static const String _recipeJsonSchema = '''
## JSON 스키마
{
  "title": "string (요리명, 구체적으로)",
  "description": "string (한 줄 설명, 20-40자)",
  "cuisine": "string (한식/양식/일식/중식/퓨전 등)",
  "difficulty": "easy|medium|hard",
  "cookingTime": number (총 조리시간, 분 단위),
  "servings": number (인원수),
  "ingredients": [
    {
      "name": "string (재료명)",
      "quantity": "string (숫자+단위, 예: '2')",
      "unit": "string (단위, 예: '개', '큰술', 'g')",
      "isAvailable": boolean (사용자 보유 여부),
      "substitute": "string|null (대체 재료, 없으면 null)"
    }
  ],
  "tools": [
    {
      "name": "string (도구명)",
      "isAvailable": boolean (사용자 보유 여부),
      "alternative": "string|null (대체 방법)"
    }
  ],
  "instructions": [
    {
      "step": number (1부터 시작),
      "title": "string (단계 제목, 5-15자)",
      "description": "string (상세 설명, 구체적 동작 포함)",
      "time": number (해당 단계 소요시간, 분),
      "tips": "string|null (초보자 팁)"
    }
  ],
  "nutrition": {
    "calories": number (추정 칼로리),
    "protein": number (단백질 g),
    "carbs": number (탄수화물 g),
    "fat": number (지방 g)
  },
  "chefNote": "string (셰프의 한마디, 격려/팁/변형 아이디어)"
}''';

  /// Few-shot 레시피 예시
  static const String _recipeExample = '''
## 예시 출력
```json
{
  "title": "간장 계란밥",
  "description": "5분 완성! 간단하지만 감칠맛 나는 한끼",
  "cuisine": "한식",
  "difficulty": "easy",
  "cookingTime": 5,
  "servings": 1,
  "ingredients": [
    {"name": "밥", "quantity": "1", "unit": "공기", "isAvailable": true, "substitute": null},
    {"name": "계란", "quantity": "2", "unit": "개", "isAvailable": true, "substitute": null},
    {"name": "진간장", "quantity": "1", "unit": "큰술", "isAvailable": true, "substitute": "양조간장"},
    {"name": "참기름", "quantity": "1", "unit": "작은술", "isAvailable": true, "substitute": "들기름"},
    {"name": "김", "quantity": "약간", "unit": "", "isAvailable": false, "substitute": "김가루나 깨"}
  ],
  "tools": [
    {"name": "프라이팬", "isAvailable": true, "alternative": null},
    {"name": "뒤집개", "isAvailable": true, "alternative": "젓가락"}
  ],
  "instructions": [
    {"step": 1, "title": "계란 프라이", "description": "프라이팬에 기름을 두르고 중불에서 계란 2개를 프라이합니다. 노른자는 반숙으로!", "time": 2, "tips": "뚜껑을 덮으면 윗면도 익어요"},
    {"step": 2, "title": "밥 준비", "description": "그릇에 따뜻한 밥을 담습니다.", "time": 1, "tips": "찬밥이면 전자레인지로 1분"},
    {"step": 3, "title": "양념 & 완성", "description": "밥 위에 계란 프라이를 올리고, 간장과 참기름을 뿌립니다. 김을 부숴 올리면 완성!", "time": 2, "tips": "비벼 먹으면 더 맛있어요"}
  ],
  "nutrition": {"calories": 450, "protein": 15, "carbs": 55, "fat": 18},
  "chefNote": "노른자를 터뜨려 밥과 비비면 고소함이 배가 됩니다! 취향에 따라 고춧가루나 후추를 추가해보세요."
}
```''';

  /// 레시피 생성 (Pro 모델) - 구조화된 프롬프트와 Few-shot
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

    // 난이도 한글 변환
    String difficultyKr = '상관없음';
    if (difficulty != null) {
      difficultyKr = {
        RecipeDifficulty.easy: '쉬움 (초보자 가능)',
        RecipeDifficulty.medium: '보통 (약간의 요리 경험 필요)',
        RecipeDifficulty.hard: '어려움 (숙련된 요리사 수준)',
      }[difficulty] ?? '상관없음';
    }

    final prompt = '''$systemPrompt

# 레시피 생성 태스크

## 사용자 컨텍스트
- **보유 재료**: ${ingredients.join(", ")}
- **보유 도구**: ${tools.join(", ")}
- **선호 요리 스타일**: ${cuisine ?? "상관없음 (보유 재료에 맞게 추천)"}
- **난이도**: $difficultyKr
- **조리 시간**: ${cookingTime != null ? "최대 ${cookingTime}분" : "상관없음"}
- **인원**: ${servings}인분

## 지시사항
1. 위 재료와 도구만으로 실제로 만들 수 있는 레시피를 추천하세요
2. 보유하지 않은 재료가 필요하면 isAvailable: false로 표시하고 substitute에 대체재를 제안하세요
3. 각 조리 단계는 초보자도 따라할 수 있도록 구체적으로 작성하세요
4. 영양 정보는 1인분 기준 추정치입니다

$_recipeJsonSchema

$_recipeExample

## 요청
위 사용자 정보에 맞는 맞춤 레시피를 JSON 형식으로만 응답해주세요.
JSON 외의 텍스트는 포함하지 마세요.

```json''';

    final response = await _proModel.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    // JSON 파싱 (다양한 형식 지원)
    return _parseRecipeJson(text);
  }

  /// JSON 응답 파싱 (여러 형식 처리)
  Recipe _parseRecipeJson(String text) {
    try {
      // 1. ```json ... ``` 형식
      final jsonBlockMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(text);
      if (jsonBlockMatch != null) {
        final jsonStr = jsonBlockMatch.group(1)!.trim();
        final jsonData = json.decode(jsonStr);
        return Recipe.fromJson(jsonData);
      }

      // 2. ``` ... ``` 형식 (언어 표시 없음)
      final codeBlockMatch = RegExp(r'```\s*([\s\S]*?)\s*```').firstMatch(text);
      if (codeBlockMatch != null) {
        final jsonStr = codeBlockMatch.group(1)!.trim();
        if (jsonStr.startsWith('{')) {
          final jsonData = json.decode(jsonStr);
          return Recipe.fromJson(jsonData);
        }
      }

      // 3. 직접 JSON 형식
      final trimmed = text.trim();
      if (trimmed.startsWith('{')) {
        final jsonData = json.decode(trimmed);
        return Recipe.fromJson(jsonData);
      }

      // 4. JSON 객체 추출 시도
      final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonObjMatch != null) {
        final jsonData = json.decode(jsonObjMatch.group(0)!);
        return Recipe.fromJson(jsonData);
      }

      throw FormatException('JSON 형식을 찾을 수 없습니다');
    } on FormatException catch (e) {
      throw Exception('레시피 파싱 실패 (형식 오류): $e\n응답: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');
    } on TypeError catch (e) {
      throw Exception('레시피 파싱 실패 (타입 오류): $e');
    } catch (e) {
      throw Exception('레시피 파싱 실패: $e');
    }
  }

  /// 빠른 요리 팁 조회 (간단한 질문용, Flash 모델)
  Future<String> getQuickTip({
    required String question,
    required AIChefConfig chefConfig,
  }) async {
    final systemPrompt = _generateSystemPrompt(chefConfig);

    final prompt = '''$systemPrompt

# 빠른 요리 팁 요청

질문: $question

짧고 명확하게 답변해주세요 (2-3문장 이내).''';

    final response = await _flashModel.generateContent([Content.text(prompt)]);
    return response.text ?? '팁을 생성할 수 없습니다.';
  }

  /// 재료 대체 추천 (특정 재료 없을 때)
  Future<String> suggestSubstitute({
    required String originalIngredient,
    required String recipeContext,
    required AIChefConfig chefConfig,
  }) async {
    final systemPrompt = _generateSystemPrompt(chefConfig);

    final prompt = '''$systemPrompt

# 재료 대체 추천

원래 재료: $originalIngredient
요리 맥락: $recipeContext

이 재료를 대체할 수 있는 옵션을 추천해주세요.
각 대체재의 특징과 결과물의 차이점도 설명해주세요.''';

    final response = await _flashModel.generateContent([Content.text(prompt)]);
    return response.text ?? '대체재 추천을 생성할 수 없습니다.';
  }
}
