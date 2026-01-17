import { NextRequest, NextResponse } from "next/server";
import { generateRecipe, AIChefConfig } from "@/lib/gemini";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { ingredients, tools, preferences, chefConfig } = body as {
      ingredients: string[];
      tools: string[];
      preferences: {
        cuisine?: string;
        difficulty?: "easy" | "medium" | "hard";
        cookingTime?: number;
        servings?: number;
      };
      chefConfig: AIChefConfig;
    };

    if (!ingredients?.length) {
      return NextResponse.json(
        { error: "재료를 입력해주세요." },
        { status: 400 }
      );
    }

    if (!chefConfig) {
      return NextResponse.json(
        { error: "AI 셰프 설정이 필요합니다." },
        { status: 400 }
      );
    }

    const recipe = await generateRecipe(
      { ingredients, tools: tools || [], preferences: preferences || {} },
      chefConfig
    );

    return NextResponse.json({ recipe });
  } catch (error) {
    console.error("Recipe API Error:", error);
    return NextResponse.json(
      { error: "레시피 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
