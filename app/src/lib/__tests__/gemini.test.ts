import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  chefPresets,
  findPresetById,
  generateChefSystemPrompt,
  AIChefConfig,
} from "@/lib/gemini";

// Mock @google/generative-ai
const mockGenerateContent = vi.fn();
const mockStartChat = vi.fn();
const mockSendMessage = vi.fn();
const mockGetGenerativeModel = vi.fn(() => ({
  generateContent: mockGenerateContent,
  startChat: mockStartChat,
}));

vi.mock("@google/generative-ai", () => ({
  GoogleGenerativeAI: vi.fn(function (this: Record<string, unknown>) {
    this.getGenerativeModel = mockGetGenerativeModel;
  }),
  HarmCategory: {
    HARM_CATEGORY_HARASSMENT: "HARM_CATEGORY_HARASSMENT",
    HARM_CATEGORY_HATE_SPEECH: "HARM_CATEGORY_HATE_SPEECH",
    HARM_CATEGORY_SEXUALLY_EXPLICIT: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
    HARM_CATEGORY_DANGEROUS_CONTENT: "HARM_CATEGORY_DANGEROUS_CONTENT",
  },
  HarmBlockThreshold: {
    BLOCK_MEDIUM_AND_ABOVE: "BLOCK_MEDIUM_AND_ABOVE",
  },
}));

describe("chefPresets", () => {
  it("8개 프리셋이 존재한다", () => {
    expect(chefPresets).toHaveLength(8);
  });

  it("모든 프리셋이 고유한 id를 가진다", () => {
    const ids = chefPresets.map((p) => p.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it("모든 프리셋이 필수 필드를 포함한다", () => {
    for (const preset of chefPresets) {
      expect(preset.id).toBeTruthy();
      expect(preset.name).toBeTruthy();
      expect(preset.description).toBeTruthy();
      expect(preset.emoji).toBeTruthy();
      expect(preset.config).toBeDefined();
      expect(preset.config.name).toBeTruthy();
      expect(preset.config.personality).toBeTruthy();
      expect(preset.config.expertise.length).toBeGreaterThan(0);
      expect(preset.config.speakingStyle).toBeDefined();
    }
  });
});

describe("findPresetById", () => {
  it("존재하는 id로 프리셋을 조회한다", () => {
    const preset = findPresetById("korean_grandma");
    expect(preset).toBeDefined();
    expect(preset!.name).toBe("할머니 손맛");
  });

  it("존재하지 않는 id에 대해 undefined를 반환한다", () => {
    expect(findPresetById("nonexistent")).toBeUndefined();
  });

  it("모든 프리셋을 id로 조회할 수 있다", () => {
    for (const preset of chefPresets) {
      expect(findPresetById(preset.id)).toBe(preset);
    }
  });
});

describe("generateChefSystemPrompt", () => {
  const config: AIChefConfig = {
    name: "테스트 셰프",
    personality: "friendly",
    expertise: ["한식", "일식"],
    cookingPhilosophy: "맛있게 요리합시다",
    speakingStyle: {
      formality: "casual",
      emojiUsage: "medium",
      technicality: "general",
    },
  };

  it("셰프 이름을 포함한다", () => {
    const prompt = generateChefSystemPrompt(config);
    expect(prompt).toContain("테스트 셰프");
  });

  it("전문 분야를 포함한다", () => {
    const prompt = generateChefSystemPrompt(config);
    expect(prompt).toContain("한식");
    expect(prompt).toContain("일식");
  });

  it("요리 철학을 포함한다", () => {
    const prompt = generateChefSystemPrompt(config);
    expect(prompt).toContain("맛있게 요리합시다");
  });

  it("성격 설명을 포함한다", () => {
    const prompt = generateChefSystemPrompt(config);
    expect(prompt).toContain("친근하고");
  });

  it("말투 스타일을 포함한다", () => {
    const prompt = generateChefSystemPrompt(config);
    expect(prompt).toContain("반말을 사용합니다");
  });
});

// ---- Mock 기반 테스트 (API 호출 함수) ----

const testConfig: AIChefConfig = {
  name: "테스트 셰프",
  personality: "friendly",
  expertise: ["한식", "일식"],
  cookingPhilosophy: "맛있게 요리합시다",
  speakingStyle: {
    formality: "casual",
    emojiUsage: "medium",
    technicality: "general",
  },
};

describe("getGeminiFlash / getGeminiPro", () => {
  beforeEach(() => {
    vi.resetModules();
    vi.stubEnv("GEMINI_API_KEY", "test-api-key");
    mockGetGenerativeModel.mockClear();
  });

  it("Flash 모델명으로 모델을 요청한다", async () => {
    const { getGeminiFlash } = await import("@/lib/gemini");
    getGeminiFlash();
    expect(mockGetGenerativeModel).toHaveBeenCalledWith(
      expect.objectContaining({ model: "gemini-2.5-flash" })
    );
  });

  it("Pro 모델명으로 모델을 요청한다", async () => {
    const { getGeminiPro } = await import("@/lib/gemini");
    getGeminiPro();
    expect(mockGetGenerativeModel).toHaveBeenCalledWith(
      expect.objectContaining({ model: "gemini-2.5-pro" })
    );
  });

  it("API 키가 없으면 에러를 던진다", async () => {
    vi.stubEnv("GEMINI_API_KEY", "");
    vi.resetModules();
    const { getGeminiFlash: getFlash } = await import("@/lib/gemini");
    expect(() => getFlash()).toThrow("GEMINI_API_KEY 환경 변수가 설정되지 않았습니다.");
  });
});

describe("createChatSession", () => {
  beforeEach(() => {
    vi.resetModules();
    vi.stubEnv("GEMINI_API_KEY", "test-api-key");
    mockStartChat.mockClear();
    mockStartChat.mockReturnValue({ sendMessage: mockSendMessage });
  });

  it("채팅 세션 생성 시 history에 셰프 설정을 포함한다", async () => {
    const { createChatSession } = await import("@/lib/gemini");
    createChatSession(testConfig);

    expect(mockStartChat).toHaveBeenCalledWith(
      expect.objectContaining({
        history: expect.arrayContaining([
          expect.objectContaining({
            role: "user",
            parts: expect.arrayContaining([
              expect.objectContaining({
                text: expect.stringContaining("테스트 셰프"),
              }),
            ]),
          }),
        ]),
      })
    );
  });
});

describe("sendMessage", () => {
  beforeEach(() => {
    vi.resetModules();
    vi.stubEnv("GEMINI_API_KEY", "test-api-key");
    mockGenerateContent.mockClear();
  });

  it("정상 응답을 반환한다", async () => {
    mockGenerateContent.mockResolvedValue({
      response: { text: () => "맛있는 김치찌개 레시피입니다." },
    });

    const { sendMessage } = await import("@/lib/gemini");
    const result = await sendMessage("김치찌개 만들어줘", testConfig);
    expect(result).toBe("맛있는 김치찌개 레시피입니다.");
  });

  it("context(ingredients, tools) 포함 시 프롬프트에 반영한다", async () => {
    mockGenerateContent.mockResolvedValue({
      response: { text: () => "응답" },
    });

    const { sendMessage } = await import("@/lib/gemini");
    await sendMessage("뭐 만들까?", testConfig, {
      ingredients: ["김치", "두부"],
      tools: ["냄비", "가스레인지"],
    });

    const calledPrompt = mockGenerateContent.mock.calls[0][0] as string;
    expect(calledPrompt).toContain("김치");
    expect(calledPrompt).toContain("두부");
    expect(calledPrompt).toContain("냄비");
    expect(calledPrompt).toContain("가스레인지");
  });

  it("context 없이 호출 시 정상 동작한다", async () => {
    mockGenerateContent.mockResolvedValue({
      response: { text: () => "안녕하세요!" },
    });

    const { sendMessage } = await import("@/lib/gemini");
    const result = await sendMessage("안녕", testConfig);
    expect(result).toBe("안녕하세요!");
  });

  it("API 에러 시 의미 있는 에러를 던진다", async () => {
    mockGenerateContent.mockRejectedValue(new Error("API rate limit"));

    const { sendMessage } = await import("@/lib/gemini");
    await expect(sendMessage("테스트", testConfig)).rejects.toThrow("AI 응답 생성 실패: API rate limit");
  });
});

describe("generateRecipe", () => {
  const recipeRequest = {
    ingredients: ["김치", "두부", "돼지고기"],
    tools: ["냄비", "가스레인지"],
    preferences: {
      cuisine: "한식",
      difficulty: "easy" as const,
      cookingTime: 30,
      servings: 2,
    },
  };

  beforeEach(() => {
    vi.resetModules();
    vi.stubEnv("GEMINI_API_KEY", "test-api-key");
    mockGenerateContent.mockClear();
  });

  it("JSON 코드블록 응답을 파싱한다", async () => {
    const jsonRecipe = { title: "김치찌개", description: "매콤한 김치찌개" };
    mockGenerateContent.mockResolvedValue({
      response: { text: () => "```json\n" + JSON.stringify(jsonRecipe) + "\n```" },
    });

    const { generateRecipe } = await import("@/lib/gemini");
    const result = await generateRecipe(recipeRequest, testConfig);
    expect(result).toEqual(jsonRecipe);
  });

  it("순수 JSON 응답을 파싱한다", async () => {
    const jsonRecipe = { title: "된장찌개", description: "구수한 된장찌개" };
    mockGenerateContent.mockResolvedValue({
      response: { text: () => JSON.stringify(jsonRecipe) },
    });

    const { generateRecipe } = await import("@/lib/gemini");
    const result = await generateRecipe(recipeRequest, testConfig);
    expect(result).toEqual(jsonRecipe);
  });

  it("JSON 파싱 실패 시 rawText를 반환한다", async () => {
    mockGenerateContent.mockResolvedValue({
      response: { text: () => "이것은 JSON이 아닌 텍스트입니다" },
    });

    const { generateRecipe } = await import("@/lib/gemini");
    const result = await generateRecipe(recipeRequest, testConfig);
    expect(result).toEqual({ rawText: "이것은 JSON이 아닌 텍스트입니다" });
  });

  it("요청 파라미터가 프롬프트에 반영된다", async () => {
    mockGenerateContent.mockResolvedValue({
      response: { text: () => JSON.stringify({ title: "test" }) },
    });

    const { generateRecipe } = await import("@/lib/gemini");
    await generateRecipe(recipeRequest, testConfig);

    const calledPrompt = mockGenerateContent.mock.calls[0][0] as string;
    expect(calledPrompt).toContain("김치");
    expect(calledPrompt).toContain("두부");
    expect(calledPrompt).toContain("돼지고기");
    expect(calledPrompt).toContain("냄비");
    expect(calledPrompt).toContain("한식");
    expect(calledPrompt).toContain("30분 이내");
    expect(calledPrompt).toContain("2인분");
  });

  it("API 에러 시 의미 있는 에러를 던진다", async () => {
    mockGenerateContent.mockRejectedValue(new Error("quota exceeded"));

    const { generateRecipe } = await import("@/lib/gemini");
    await expect(generateRecipe(recipeRequest, testConfig)).rejects.toThrow("레시피 생성 실패: quota exceeded");
  });
});
