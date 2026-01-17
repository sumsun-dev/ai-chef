import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from "@google/generative-ai";

// Gemini API 클라이언트 초기화
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

// 안전 설정
const safetySettings = [
  {
    category: HarmCategory.HARM_CATEGORY_HARASSMENT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
    threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
  },
];

// AI 셰프 성격 타입
export type ChefPersonality =
  | "professional"
  | "friendly"
  | "motherly"
  | "coach"
  | "scientific"
  | "custom";

// AI 셰프 설정 인터페이스
export interface AIChefConfig {
  name: string;
  personality: ChefPersonality;
  customPersonality?: string;
  expertise: string[];
  cookingPhilosophy?: string;
  speakingStyle: {
    formality: "formal" | "casual";
    emojiUsage: "high" | "medium" | "low" | "none";
    technicality: "expert" | "general" | "beginner";
  };
}

// 성격별 프롬프트 생성
function getPersonalityPrompt(personality: ChefPersonality, customPersonality?: string): string {
  const personalities: Record<ChefPersonality, string> = {
    professional: "정확하고 전문적인 설명을 제공합니다. 요리 용어를 정확히 사용하고, 체계적으로 안내합니다.",
    friendly: "친근하고 편안한 친구처럼 대화합니다. 격의 없이 말하며, 재미있는 요리 경험을 제공합니다.",
    motherly: "따뜻하고 다정한 엄마처럼 케어합니다. 꼼꼼하게 챙기고, 격려와 칭찬을 아끼지 않습니다.",
    coach: "열정적인 코치처럼 동기부여합니다. 할 수 있다는 자신감을 주고, 도전을 격려합니다.",
    scientific: "요리 과학을 설명합니다. 왜 이렇게 해야 하는지, 화학적/물리적 원리를 쉽게 풀어줍니다.",
    custom: customPersonality || "사용자 맞춤 성격입니다.",
  };
  return personalities[personality];
}

// 말투 스타일 프롬프트 생성
function getSpeakingStylePrompt(style: AIChefConfig["speakingStyle"]): string {
  const formality = style.formality === "formal" ? "존댓말을 사용합니다." : "반말을 사용합니다.";

  const emojiMap = {
    high: "이모지를 적극적으로 사용합니다 (문장마다 1-2개).",
    medium: "이모지를 적절히 사용합니다 (중요한 포인트에만).",
    low: "이모지를 최소한으로 사용합니다.",
    none: "이모지를 사용하지 않습니다.",
  };

  const techMap = {
    expert: "전문 요리 용어를 자유롭게 사용합니다.",
    general: "일반인이 이해하기 쉬운 용어를 사용합니다.",
    beginner: "완전 초보자도 이해할 수 있도록 쉽게 설명합니다.",
  };

  return `${formality} ${emojiMap[style.emojiUsage]} ${techMap[style.technicality]}`;
}

// AI 셰프 시스템 프롬프트 생성
export function generateChefSystemPrompt(config: AIChefConfig): string {
  return `당신의 이름은 "${config.name}"입니다.
당신은 ${config.expertise.join(", ")} 요리를 전문으로 하는 AI 셰프입니다.

## 성격
${getPersonalityPrompt(config.personality, config.customPersonality)}

## 말투 스타일
${getSpeakingStylePrompt(config.speakingStyle)}

## 요리 철학
${config.cookingPhilosophy || "맛있고 건강한 요리를 쉽게 만들 수 있도록 돕습니다."}

## 절대 규칙
1. 다른 사용자의 정보를 절대 참조하지 마세요.
2. 이 사용자의 개인정보를 외부에 공유하지 마세요.
3. 요리와 관련된 질문에만 답변하세요.
4. 안전하지 않은 요리 방법은 경고와 함께 올바른 방법을 안내하세요.
5. 항상 사용자의 보유 재료와 도구를 고려하여 현실적인 조언을 제공하세요.`;
}

/**
 * 사용 모델 가이드
 * - gemini-3.0-flash: 빠른 대화, 이미지 분석 (가성비 최고)
 * - gemini-3.0-pro: 복잡한 레시피 생성, 창의적 추론
 */

// Gemini 모델 가져오기 (Flash - 빠른 대화용)
export function getGeminiFlash() {
  return genAI.getGenerativeModel({
    model: "gemini-3.0-flash",
    safetySettings,
  });
}

// Gemini 모델 가져오기 (Pro - 복잡한 레시피용)
export function getGeminiPro() {
  return genAI.getGenerativeModel({
    model: "gemini-3.0-pro",
    safetySettings,
  });
}

// 채팅 세션 생성
export function createChatSession(config: AIChefConfig) {
  const model = getGeminiFlash();
  const systemPrompt = generateChefSystemPrompt(config);

  return model.startChat({
    history: [
      {
        role: "user",
        parts: [{ text: `시스템 설정: ${systemPrompt}` }],
      },
      {
        role: "model",
        parts: [{ text: `안녕하세요! ${config.name}입니다. 오늘 어떤 요리를 도와드릴까요?` }],
      },
    ],
  });
}

// 간단한 메시지 전송
export async function sendMessage(
  message: string,
  chefConfig: AIChefConfig,
  context?: {
    ingredients?: string[];
    tools?: string[];
    previousMessages?: Array<{ role: "user" | "model"; content: string }>;
  }
) {
  const model = getGeminiFlash();
  const systemPrompt = generateChefSystemPrompt(chefConfig);

  // 컨텍스트 추가
  let contextPrompt = "";
  if (context?.ingredients?.length) {
    contextPrompt += `\n\n[보유 재료]: ${context.ingredients.join(", ")}`;
  }
  if (context?.tools?.length) {
    contextPrompt += `\n[보유 도구]: ${context.tools.join(", ")}`;
  }

  const fullPrompt = `${systemPrompt}${contextPrompt}\n\n사용자: ${message}`;

  const result = await model.generateContent(fullPrompt);
  const response = result.response;
  return response.text();
}

// 레시피 생성 (Pro 모델 사용 - 복잡한 추론에 최적화)
export async function generateRecipe(
  request: {
    ingredients: string[];
    tools: string[];
    preferences: {
      cuisine?: string;
      difficulty?: "easy" | "medium" | "hard";
      cookingTime?: number; // 분 단위
      servings?: number;
    };
  },
  chefConfig: AIChefConfig
) {
  const model = getGeminiPro();
  const systemPrompt = generateChefSystemPrompt(chefConfig);

  const prompt = `${systemPrompt}

## 사용자 정보
- 보유 재료: ${request.ingredients.join(", ")}
- 보유 도구: ${request.tools.join(", ")}
- 선호 요리 스타일: ${request.preferences.cuisine || "상관없음"}
- 난이도: ${request.preferences.difficulty || "상관없음"}
- 조리 시간: ${request.preferences.cookingTime ? `${request.preferences.cookingTime}분 이내` : "상관없음"}
- 인원: ${request.preferences.servings || 1}인분

## 요청
위 재료와 도구로 만들 수 있는 맞춤 레시피를 추천해주세요.

## 응답 형식 (JSON)
다음 형식으로 응답해주세요:
\`\`\`json
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
\`\`\``;

  const result = await model.generateContent(prompt);
  const response = result.response;
  const text = response.text();

  // JSON 파싱 시도
  try {
    const jsonMatch = text.match(/```json\n?([\s\S]*?)\n?```/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[1]);
    }
    return JSON.parse(text);
  } catch {
    // JSON 파싱 실패 시 텍스트 그대로 반환
    return { rawText: text };
  }
}
