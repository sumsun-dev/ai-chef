import { describe, it, expect, vi, beforeEach } from "vitest";
import { NextRequest } from "next/server";

const mockSendMessage = vi.fn();
vi.mock("@/lib/gemini", () => ({
  sendMessage: mockSendMessage,
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
  return new NextRequest("http://localhost:3000/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

describe("POST /api/chat", () => {
  beforeEach(() => {
    mockSendMessage.mockReset();
  });

  it("유효한 요청 시 200과 응답을 반환한다", async () => {
    // Arrange
    mockSendMessage.mockResolvedValue("맛있는 김치찌개 레시피입니다.");
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        message: "김치찌개 만들어줘",
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.response).toBe("맛있는 김치찌개 레시피입니다.");
  });

  it("빈 message 시 400을 반환한다", async () => {
    // Arrange
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        message: "",
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(400);
    const data = await res.json();
    expect(data.error).toBeDefined();
  });

  it("chefConfig 누락 시 400을 반환한다", async () => {
    // Arrange
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        message: "안녕",
      })
    );

    // Assert
    expect(res.status).toBe(400);
  });

  it("context 포함 요청이 정상 처리된다", async () => {
    // Arrange
    mockSendMessage.mockResolvedValue("김치로 만들 수 있어요!");
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        message: "뭐 만들까?",
        chefConfig: validChefConfig,
        context: {
          ingredients: ["김치", "두부"],
          tools: ["냄비"],
        },
      })
    );

    // Assert
    expect(res.status).toBe(200);
    expect(mockSendMessage).toHaveBeenCalledWith(
      "뭐 만들까?",
      validChefConfig,
      expect.objectContaining({
        ingredients: ["김치", "두부"],
        tools: ["냄비"],
      })
    );
  });

  it("sendMessage 에러 시 500을 반환한다", async () => {
    // Arrange
    mockSendMessage.mockRejectedValue(new Error("API rate limit"));
    const { POST } = await import("../route");

    // Act
    const res = await POST(
      createRequest({
        message: "테스트",
        chefConfig: validChefConfig,
      })
    );

    // Assert
    expect(res.status).toBe(500);
    const data = await res.json();
    expect(data.error).toContain("오류");
  });
});
