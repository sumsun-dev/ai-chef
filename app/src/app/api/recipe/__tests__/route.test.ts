import { describe, it, expect, vi, beforeEach } from "vitest";
import { NextRequest } from "next/server";

const mockGenerateRecipe = vi.fn();
vi.mock("@/lib/gemini", () => ({
  generateRecipe: mockGenerateRecipe,
  generateChefSystemPrompt: vi.fn(() => "test prompt"),
}));

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

function createRequest(body: unknown): NextRequest {
  return new NextRequest("http://localhost:3000/api/recipe", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

describe("POST /api/recipe", () => {
  beforeEach(() => {
    mockGenerateRecipe.mockReset();
  });

  it("유효한 요청 시 200과 레시피를 반환한다", async () => {
    // Arrange
    const mockRecipe = { title: "김치찌개", description: "매콤한 김치찌개" };
    mockGenerateRecipe.mockResolvedValue(mockRecipe);
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        ingredients: ["김치", "두부"],
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.recipe).toEqual(mockRecipe);
  });

  it("빈 ingredients 시 400을 반환한다", async () => {
    // Arrange
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        ingredients: [],
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(400);
    const data = await res.json();
    expect(data.error).toBeDefined();
  });

  it("ingredients 누락 시 400을 반환한다", async () => {
    // Arrange
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(400);
  });

  it("tools/preferences 포함 요청이 정상 처리된다", async () => {
    // Arrange
    const mockRecipe = { title: "된장찌개" };
    mockGenerateRecipe.mockResolvedValue(mockRecipe);
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        ingredients: ["된장", "두부"],
        tools: ["냄비", "가스레인지"],
        preferences: { cuisine: "한식", cookingTime: 30 },
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(200);
    expect(mockGenerateRecipe).toHaveBeenCalledWith(
      expect.objectContaining({
        ingredients: ["된장", "두부"],
        tools: ["냄비", "가스레인지"],
        preferences: expect.objectContaining({ cuisine: "한식" }),
      }),
      validChefConfig
    );
  });

  it("generateRecipe 에러 시 500을 반환한다", async () => {
    // Arrange
    mockGenerateRecipe.mockRejectedValue(new Error("quota exceeded"));
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        ingredients: ["김치"],
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(500);
    const data = await res.json();
    expect(data.error).toContain("오류");
  });
});
