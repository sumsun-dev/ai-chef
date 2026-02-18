import { describe, it, expect } from "vitest";
import {
  chefPresets,
  findPresetById,
  generateChefSystemPrompt,
  AIChefConfig,
} from "@/lib/gemini";

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
