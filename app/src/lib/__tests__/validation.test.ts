import { describe, it, expect } from "vitest";
import {
  aiChefConfigSchema,
  chatRequestSchema,
  recipeRequestSchema,
} from "@/lib/validation";

const validChefConfig = {
  name: "테스트 셰프",
  personality: "friendly",
  expertise: ["한식"],
  speakingStyle: {
    formality: "casual",
    emojiUsage: "medium",
    technicality: "general",
  },
};

describe("aiChefConfigSchema", () => {
  it("유효한 설정을 통과시킨다", () => {
    const result = aiChefConfigSchema.safeParse(validChefConfig);
    expect(result.success).toBe(true);
  });

  it("name이 빈 문자열이면 실패한다", () => {
    const result = aiChefConfigSchema.safeParse({
      ...validChefConfig,
      name: "",
    });
    expect(result.success).toBe(false);
  });

  it("잘못된 personality를 거부한다", () => {
    const result = aiChefConfigSchema.safeParse({
      ...validChefConfig,
      personality: "invalid",
    });
    expect(result.success).toBe(false);
  });

  it("빈 expertise 배열을 거부한다", () => {
    const result = aiChefConfigSchema.safeParse({
      ...validChefConfig,
      expertise: [],
    });
    expect(result.success).toBe(false);
  });

  it("선택 필드 없이도 통과한다", () => {
    const result = aiChefConfigSchema.safeParse(validChefConfig);
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.cookingPhilosophy).toBeUndefined();
      expect(result.data.customPersonality).toBeUndefined();
    }
  });
});

describe("chatRequestSchema", () => {
  it("유효한 요청을 통과시킨다", () => {
    const result = chatRequestSchema.safeParse({
      message: "김치찌개 만드는 법",
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(true);
  });

  it("빈 message를 거부한다", () => {
    const result = chatRequestSchema.safeParse({
      message: "",
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(false);
  });

  it("message가 없으면 거부한다", () => {
    const result = chatRequestSchema.safeParse({
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(false);
  });

  it("선택적 context를 통과시킨다", () => {
    const result = chatRequestSchema.safeParse({
      message: "추천해줘",
      chefConfig: validChefConfig,
      context: {
        ingredients: ["김치", "두부"],
        tools: ["냄비"],
      },
    });
    expect(result.success).toBe(true);
  });
});

describe("recipeRequestSchema", () => {
  it("유효한 요청을 통과시킨다", () => {
    const result = recipeRequestSchema.safeParse({
      ingredients: ["김치", "두부"],
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(true);
  });

  it("빈 ingredients 배열을 거부한다", () => {
    const result = recipeRequestSchema.safeParse({
      ingredients: [],
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(false);
  });

  it("tools 미지정 시 빈 배열을 기본값으로 설정한다", () => {
    const result = recipeRequestSchema.safeParse({
      ingredients: ["계란"],
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.tools).toEqual([]);
    }
  });

  it("preferences 미지정 시 빈 객체를 기본값으로 설정한다", () => {
    const result = recipeRequestSchema.safeParse({
      ingredients: ["계란"],
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.preferences).toEqual({});
    }
  });

  it("잘못된 difficulty를 거부한다", () => {
    const result = recipeRequestSchema.safeParse({
      ingredients: ["계란"],
      preferences: { difficulty: "extreme" },
      chefConfig: validChefConfig,
    });
    expect(result.success).toBe(false);
  });
});
