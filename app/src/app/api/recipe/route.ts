import { NextRequest, NextResponse } from "next/server";
import { generateRecipe } from "@/lib/gemini";
import { recipeRequestSchema } from "@/lib/validation";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const result = recipeRequestSchema.safeParse(body);

    if (!result.success) {
      return NextResponse.json(
        { error: "잘못된 요청입니다.", details: result.error.issues },
        { status: 400 }
      );
    }

    const { ingredients, tools, preferences, chefConfig } = result.data;
    const recipe = await generateRecipe(
      { ingredients, tools, preferences },
      chefConfig
    );

    return NextResponse.json({ recipe });
  } catch {
    return NextResponse.json(
      { error: "레시피 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
