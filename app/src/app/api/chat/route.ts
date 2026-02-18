import { NextRequest, NextResponse } from "next/server";
import { sendMessage } from "@/lib/gemini";
import { chatRequestSchema } from "@/lib/validation";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const result = chatRequestSchema.safeParse(body);

    if (!result.success) {
      return NextResponse.json(
        { error: "잘못된 요청입니다.", details: result.error.issues },
        { status: 400 }
      );
    }

    const { message, chefConfig, context } = result.data;
    const response = await sendMessage(message, chefConfig, context);

    return NextResponse.json({ response });
  } catch (error) {
    console.error("Chat API Error:", error);
    return NextResponse.json(
      { error: "AI 응답 생성 중 오류가 발생했습니다." },
      { status: 500 }
    );
  }
}
