"use client";

import { useState, type KeyboardEvent } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useRecipeStore } from "@/lib/stores/recipe-store";
import { chefPresets } from "@/lib/gemini";

function TagInput({
  label,
  placeholder,
  tags,
  onAdd,
  onRemove,
}: {
  label: string;
  placeholder: string;
  tags: string[];
  onAdd: (tag: string) => void;
  onRemove: (tag: string) => void;
}) {
  const [value, setValue] = useState("");

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (value.trim()) {
        onAdd(value.trim());
        setValue("");
      }
    }
  };

  return (
    <div>
      <label className="text-sm font-medium mb-1 block">{label}</label>
      <Input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
      />
      {tags.length > 0 && (
        <div className="flex flex-wrap gap-1 mt-2">
          {tags.map((tag) => (
            <Badge key={tag} variant="secondary" className="gap-1">
              {tag}
              <button
                onClick={() => onRemove(tag)}
                className="ml-1 hover:text-destructive"
              >
                x
              </button>
            </Badge>
          ))}
        </div>
      )}
    </div>
  );
}

export default function RecipePage() {
  const {
    ingredients,
    tools,
    preferences,
    selectedPresetId,
    recipe,
    isLoading,
    error,
    addIngredient,
    removeIngredient,
    addTool,
    removeTool,
    setPreferences,
    setPreset,
    generateRecipe,
    reset,
  } = useRecipeStore();

  const selectedPreset = chefPresets.find((p) => p.id === selectedPresetId);

  return (
    <div className="container mx-auto p-4">
      <Tabs defaultValue="input" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="input">재료 입력</TabsTrigger>
          <TabsTrigger value="result" disabled={!recipe}>
            레시피 결과
          </TabsTrigger>
        </TabsList>

        <TabsContent value="input" className="space-y-6 mt-4">
          {/* Ingredients & Tools */}
          <div className="grid md:grid-cols-2 gap-4">
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">재료</CardTitle>
              </CardHeader>
              <CardContent>
                <TagInput
                  label=""
                  placeholder="재료 입력 후 Enter (예: 양파)"
                  tags={ingredients}
                  onAdd={addIngredient}
                  onRemove={removeIngredient}
                />
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-base">조리 도구</CardTitle>
              </CardHeader>
              <CardContent>
                <TagInput
                  label=""
                  placeholder="도구 입력 후 Enter (예: 프라이팬)"
                  tags={tools}
                  onAdd={addTool}
                  onRemove={removeTool}
                />
              </CardContent>
            </Card>
          </div>

          {/* Preferences */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-base">선호 설정</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div>
                  <label className="text-sm font-medium mb-1 block">
                    요리 종류
                  </label>
                  <Input
                    placeholder="예: 한식"
                    value={preferences.cuisine ?? ""}
                    onChange={(e) =>
                      setPreferences({ cuisine: e.target.value || undefined })
                    }
                  />
                </div>
                <div>
                  <label className="text-sm font-medium mb-1 block">
                    난이도
                  </label>
                  <select
                    className="w-full h-9 rounded-md border border-input bg-background px-3 text-sm"
                    value={preferences.difficulty ?? ""}
                    onChange={(e) =>
                      setPreferences({
                        difficulty:
                          (e.target.value as "easy" | "medium" | "hard") ||
                          undefined,
                      })
                    }
                  >
                    <option value="">선택 안함</option>
                    <option value="easy">쉬움</option>
                    <option value="medium">보통</option>
                    <option value="hard">어려움</option>
                  </select>
                </div>
                <div>
                  <label className="text-sm font-medium mb-1 block">
                    조리 시간 (분)
                  </label>
                  <Input
                    type="number"
                    placeholder="예: 30"
                    value={preferences.cookingTime ?? ""}
                    onChange={(e) =>
                      setPreferences({
                        cookingTime: e.target.value
                          ? Number(e.target.value)
                          : undefined,
                      })
                    }
                  />
                </div>
                <div>
                  <label className="text-sm font-medium mb-1 block">
                    인분
                  </label>
                  <Input
                    type="number"
                    placeholder="예: 2"
                    value={preferences.servings ?? ""}
                    onChange={(e) =>
                      setPreferences({
                        servings: e.target.value
                          ? Number(e.target.value)
                          : undefined,
                      })
                    }
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Chef Selection */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-base">AI 셰프 선택</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-4 md:grid-cols-8 gap-2">
                {chefPresets.map((preset) => (
                  <button
                    key={preset.id}
                    onClick={() => setPreset(preset.id)}
                    className={`flex flex-col items-center p-2 rounded-lg text-xs transition-colors ${
                      selectedPresetId === preset.id
                        ? "bg-primary text-primary-foreground"
                        : "hover:bg-muted"
                    }`}
                  >
                    <span className="text-2xl mb-1">{preset.emoji}</span>
                    <span className="truncate w-full text-center">
                      {preset.name}
                    </span>
                  </button>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Actions */}
          {error && (
            <p className="text-destructive text-sm text-center">{error}</p>
          )}

          <div className="flex gap-3 justify-center">
            <Button variant="outline" onClick={reset}>
              초기화
            </Button>
            <Button
              onClick={generateRecipe}
              disabled={ingredients.length === 0 || isLoading}
              className="min-w-32"
            >
              {isLoading ? "생성 중..." : "레시피 생성"}
            </Button>
          </div>
        </TabsContent>

        <TabsContent value="result" className="mt-4">
          {recipe && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <span>{selectedPreset?.emoji}</span>
                  {recipe.title}
                </CardTitle>
                <p className="text-muted-foreground text-sm">
                  {recipe.description}
                </p>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Ingredients */}
                <section>
                  <h3 className="font-semibold mb-2">재료</h3>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                    {recipe.ingredients.map((ing, i) => (
                      <div
                        key={i}
                        className="flex items-center gap-2 text-sm p-2 bg-muted rounded"
                      >
                        <span className="font-medium">{ing.name}</span>
                        <span className="text-muted-foreground">
                          {ing.quantity} {ing.unit}
                        </span>
                      </div>
                    ))}
                  </div>
                </section>

                {/* Instructions */}
                <section>
                  <h3 className="font-semibold mb-2">조리 순서</h3>
                  <ol className="space-y-3">
                    {recipe.instructions.map((step) => (
                      <li key={step.step} className="flex gap-3">
                        <span className="flex-shrink-0 w-7 h-7 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm font-bold">
                          {step.step}
                        </span>
                        <div>
                          <p className="font-medium">{step.title}</p>
                          <p className="text-sm text-muted-foreground">
                            {step.description}
                          </p>
                          {step.tips && (
                            <p className="text-xs text-primary mt-1">
                              Tip: {step.tips}
                            </p>
                          )}
                        </div>
                      </li>
                    ))}
                  </ol>
                </section>

                {/* Nutrition */}
                {recipe.nutrition && (
                  <section>
                    <h3 className="font-semibold mb-2">영양 정보</h3>
                    <div className="grid grid-cols-4 gap-2">
                      {[
                        {
                          label: "칼로리",
                          value: `${recipe.nutrition.calories}kcal`,
                        },
                        {
                          label: "단백질",
                          value: `${recipe.nutrition.protein}g`,
                        },
                        {
                          label: "탄수화물",
                          value: `${recipe.nutrition.carbs}g`,
                        },
                        { label: "지방", value: `${recipe.nutrition.fat}g` },
                      ].map((item) => (
                        <div
                          key={item.label}
                          className="text-center p-2 bg-muted rounded"
                        >
                          <p className="text-xs text-muted-foreground">
                            {item.label}
                          </p>
                          <p className="font-semibold text-sm">{item.value}</p>
                        </div>
                      ))}
                    </div>
                  </section>
                )}

                {/* Chef Note */}
                {recipe.chefNote && (
                  <section className="bg-primary/5 p-4 rounded-lg border border-primary/20">
                    <p className="text-sm font-medium mb-1">
                      {selectedPreset?.emoji} 셰프의 한마디
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {recipe.chefNote}
                    </p>
                  </section>
                )}
              </CardContent>
            </Card>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
