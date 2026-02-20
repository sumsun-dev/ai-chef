import { create } from "zustand";
import type { AIChefConfig, ChefPreset } from "@/lib/gemini";
import { chefPresets } from "@/lib/gemini";

export interface RecipeIngredient {
  name: string;
  quantity: string;
  unit: string;
}

export interface RecipeInstruction {
  step: number;
  title: string;
  description: string;
  time?: number;
  tips?: string;
}

export interface NutritionInfo {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

export interface GeneratedRecipe {
  title: string;
  description: string;
  ingredients: RecipeIngredient[];
  instructions: RecipeInstruction[];
  nutrition?: NutritionInfo;
  chefNote?: string;
}

interface RecipeState {
  ingredients: string[];
  tools: string[];
  preferences: {
    cuisine?: string;
    difficulty?: "easy" | "medium" | "hard";
    cookingTime?: number;
    servings?: number;
  };
  selectedPresetId: string;
  recipe: GeneratedRecipe | null;
  isLoading: boolean;
  error: string | null;
}

interface RecipeActions {
  addIngredient: (ingredient: string) => void;
  removeIngredient: (ingredient: string) => void;
  addTool: (tool: string) => void;
  removeTool: (tool: string) => void;
  setPreferences: (prefs: Partial<RecipeState["preferences"]>) => void;
  setPreset: (presetId: string) => void;
  generateRecipe: () => Promise<void>;
  reset: () => void;
}

const DEFAULT_PRESET_ID = "korean_grandma";

function getPresetConfig(presetId: string): AIChefConfig {
  const preset = chefPresets.find((p: ChefPreset) => p.id === presetId);
  return preset?.config ?? chefPresets[0].config;
}

const initialState: RecipeState = {
  ingredients: [],
  tools: [],
  preferences: {},
  selectedPresetId: DEFAULT_PRESET_ID,
  recipe: null,
  isLoading: false,
  error: null,
};

export const useRecipeStore = create<RecipeState & RecipeActions>((set, get) => ({
  ...initialState,

  addIngredient: (ingredient: string) => {
    const trimmed = ingredient.trim();
    if (!trimmed) return;
    set((state) => ({
      ingredients: state.ingredients.includes(trimmed)
        ? state.ingredients
        : [...state.ingredients, trimmed],
    }));
  },

  removeIngredient: (ingredient: string) => {
    set((state) => ({
      ingredients: state.ingredients.filter((i) => i !== ingredient),
    }));
  },

  addTool: (tool: string) => {
    const trimmed = tool.trim();
    if (!trimmed) return;
    set((state) => ({
      tools: state.tools.includes(trimmed)
        ? state.tools
        : [...state.tools, trimmed],
    }));
  },

  removeTool: (tool: string) => {
    set((state) => ({
      tools: state.tools.filter((t) => t !== tool),
    }));
  },

  setPreferences: (prefs) => {
    set((state) => ({
      preferences: { ...state.preferences, ...prefs },
    }));
  },

  setPreset: (presetId: string) => {
    set({ selectedPresetId: presetId });
  },

  generateRecipe: async () => {
    const { ingredients, tools, preferences, selectedPresetId } = get();

    if (ingredients.length === 0) {
      set({ error: "재료를 최소 1개 이상 입력해주세요." });
      return;
    }

    set({ isLoading: true, error: null });

    try {
      const response = await fetch("/api/recipe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ingredients,
          tools,
          preferences,
          chefConfig: getPresetConfig(selectedPresetId),
        }),
      });

      if (!response.ok) {
        throw new Error(`API 오류: ${response.status}`);
      }

      const data = await response.json();
      set({
        recipe: data.data?.recipe ?? data.recipe ?? null,
        isLoading: false,
      });
    } catch (error) {
      set({
        isLoading: false,
        error: error instanceof Error ? error.message : "알 수 없는 오류",
      });
    }
  },

  reset: () => {
    set(initialState);
  },
}));
