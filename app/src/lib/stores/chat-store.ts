import { create } from "zustand";
import type { AIChefConfig, ChefPreset } from "@/lib/gemini";
import { chefPresets } from "@/lib/gemini";

export interface ChatMessage {
  id: string;
  role: "user" | "assistant";
  content: string;
  timestamp: number;
}

interface ChatState {
  messages: ChatMessage[];
  selectedPresetId: string;
  isLoading: boolean;
  error: string | null;
}

interface ChatActions {
  sendMessage: (message: string) => Promise<void>;
  setPreset: (presetId: string) => void;
  clearMessages: () => void;
}

const DEFAULT_PRESET_ID = "korean_grandma";

function getPresetConfig(presetId: string): AIChefConfig {
  const preset = chefPresets.find((p: ChefPreset) => p.id === presetId);
  return preset?.config ?? chefPresets[0].config;
}

export const useChatStore = create<ChatState & ChatActions>((set, get) => ({
  messages: [],
  selectedPresetId: DEFAULT_PRESET_ID,
  isLoading: false,
  error: null,

  sendMessage: async (message: string) => {
    const { selectedPresetId, messages } = get();

    const userMessage: ChatMessage = {
      id: `user-${Date.now()}`,
      role: "user",
      content: message,
      timestamp: Date.now(),
    };

    set({
      messages: [...messages, userMessage],
      isLoading: true,
      error: null,
    });

    try {
      const response = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message,
          chefConfig: getPresetConfig(selectedPresetId),
        }),
      });

      if (!response.ok) {
        throw new Error(`API 오류: ${response.status}`);
      }

      const data = await response.json();

      const assistantMessage: ChatMessage = {
        id: `assistant-${Date.now()}`,
        role: "assistant",
        content: data.data?.reply ?? data.reply ?? "응답을 받지 못했습니다.",
        timestamp: Date.now(),
      };

      set((state) => ({
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      }));
    } catch (error) {
      set({
        isLoading: false,
        error: error instanceof Error ? error.message : "알 수 없는 오류",
      });
    }
  },

  setPreset: (presetId: string) => {
    set({ selectedPresetId: presetId });
  },

  clearMessages: () => {
    set({ messages: [], error: null });
  },
}));
