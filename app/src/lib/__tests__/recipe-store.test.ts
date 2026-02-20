import { describe, it, expect, vi, beforeEach } from "vitest";
import { useRecipeStore } from "@/lib/stores/recipe-store";

describe("useRecipeStore", () => {
  beforeEach(() => {
    useRecipeStore.getState().reset();
  });

  it("초기 상태가 올바르다", () => {
    const state = useRecipeStore.getState();
    expect(state.ingredients).toEqual([]);
    expect(state.tools).toEqual([]);
    expect(state.recipe).toBeNull();
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();
  });

  it("addIngredient가 재료를 추가한다", () => {
    useRecipeStore.getState().addIngredient("양파");
    useRecipeStore.getState().addIngredient("당근");
    expect(useRecipeStore.getState().ingredients).toEqual(["양파", "당근"]);
  });

  it("addIngredient가 중복 재료를 무시한다", () => {
    useRecipeStore.getState().addIngredient("양파");
    useRecipeStore.getState().addIngredient("양파");
    expect(useRecipeStore.getState().ingredients).toEqual(["양파"]);
  });

  it("addIngredient가 빈 문자열을 무시한다", () => {
    useRecipeStore.getState().addIngredient("  ");
    expect(useRecipeStore.getState().ingredients).toEqual([]);
  });

  it("removeIngredient가 재료를 제거한다", () => {
    useRecipeStore.getState().addIngredient("양파");
    useRecipeStore.getState().addIngredient("당근");
    useRecipeStore.getState().removeIngredient("양파");
    expect(useRecipeStore.getState().ingredients).toEqual(["당근"]);
  });

  it("addTool / removeTool이 올바르게 동작한다", () => {
    useRecipeStore.getState().addTool("프라이팬");
    useRecipeStore.getState().addTool("냄비");
    expect(useRecipeStore.getState().tools).toEqual(["프라이팬", "냄비"]);

    useRecipeStore.getState().removeTool("프라이팬");
    expect(useRecipeStore.getState().tools).toEqual(["냄비"]);
  });

  it("generateRecipe가 재료 없으면 에러를 설정한다", async () => {
    await useRecipeStore.getState().generateRecipe();
    expect(useRecipeStore.getState().error).toBe(
      "재료를 최소 1개 이상 입력해주세요.",
    );
  });

  it("generateRecipe가 API를 호출하고 결과를 설정한다", async () => {
    const mockRecipe = {
      title: "양파볶음",
      description: "간단한 양파볶음",
      ingredients: [{ name: "양파", quantity: "2", unit: "개" }],
      instructions: [
        { step: 1, title: "준비", description: "양파를 썬다" },
      ],
      nutrition: { calories: 100, protein: 5, carbs: 15, fat: 3 },
      chefNote: "맛있게 드세요!",
    };

    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ data: { recipe: mockRecipe } }),
      }),
    );

    useRecipeStore.getState().addIngredient("양파");
    await useRecipeStore.getState().generateRecipe();

    const state = useRecipeStore.getState();
    expect(state.recipe).toEqual(mockRecipe);
    expect(state.isLoading).toBe(false);
    expect(state.error).toBeNull();

    vi.unstubAllGlobals();
  });

  it("generateRecipe API 에러 시 error를 설정한다", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: false, status: 500 }),
    );

    useRecipeStore.getState().addIngredient("양파");
    await useRecipeStore.getState().generateRecipe();

    expect(useRecipeStore.getState().error).toContain("500");

    vi.unstubAllGlobals();
  });

  it("reset이 상태를 초기화한다", () => {
    useRecipeStore.getState().addIngredient("양파");
    useRecipeStore.getState().addTool("프라이팬");
    useRecipeStore.getState().reset();

    const state = useRecipeStore.getState();
    expect(state.ingredients).toEqual([]);
    expect(state.tools).toEqual([]);
    expect(state.recipe).toBeNull();
  });
});
