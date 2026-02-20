import { describe, it, expect, vi, beforeEach } from "vitest";
import { useChatStore } from "@/lib/stores/chat-store";

describe("useChatStore", () => {
  beforeEach(() => {
    useChatStore.setState({
      messages: [],
      selectedPresetId: "korean_grandma",
      isLoading: false,
      error: null,
    });
  });

  it("초기 상태가 올바르다", () => {
    const state = useChatStore.getState();
    expect(state.messages).toEqual([]);
    expect(state.selectedPresetId).toBe("korean_grandma");
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();
  });

  it("setPreset이 프리셋을 변경한다", () => {
    useChatStore.getState().setPreset("michelin_chef");
    expect(useChatStore.getState().selectedPresetId).toBe("michelin_chef");
  });

  it("clearMessages가 메시지를 초기화한다", () => {
    useChatStore.setState({
      messages: [
        { id: "1", role: "user", content: "안녕", timestamp: Date.now() },
      ],
      error: "에러",
    });

    useChatStore.getState().clearMessages();

    const state = useChatStore.getState();
    expect(state.messages).toEqual([]);
    expect(state.error).toBeNull();
  });

  it("sendMessage가 사용자 메시지를 추가하고 API를 호출한다", async () => {
    const mockResponse = {
      ok: true,
      json: async () => ({ data: { reply: "안녕하세요!" } }),
    };

    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue(mockResponse),
    );

    await useChatStore.getState().sendMessage("안녕");

    const state = useChatStore.getState();
    expect(state.messages).toHaveLength(2);
    expect(state.messages[0].role).toBe("user");
    expect(state.messages[0].content).toBe("안녕");
    expect(state.messages[1].role).toBe("assistant");
    expect(state.messages[1].content).toBe("안녕하세요!");
    expect(state.isLoading).toBe(false);

    vi.unstubAllGlobals();
  });

  it("sendMessage API 에러 시 error를 설정한다", async () => {
    const mockResponse = {
      ok: false,
      status: 500,
    };

    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue(mockResponse),
    );

    await useChatStore.getState().sendMessage("안녕");

    const state = useChatStore.getState();
    expect(state.messages).toHaveLength(1); // user message only
    expect(state.error).toContain("500");
    expect(state.isLoading).toBe(false);

    vi.unstubAllGlobals();
  });

  it("sendMessage 네트워크 에러 시 error를 설정한다", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockRejectedValue(new Error("네트워크 오류")),
    );

    await useChatStore.getState().sendMessage("안녕");

    const state = useChatStore.getState();
    expect(state.error).toBe("네트워크 오류");
    expect(state.isLoading).toBe(false);

    vi.unstubAllGlobals();
  });
});
