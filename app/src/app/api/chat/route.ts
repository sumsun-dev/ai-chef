import { NextRequest, NextResponse } from "next/server";
import { sendMessage, AIChefConfig } from "@/lib/gemini";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { message, chefConfig, context } = body as {
      message: string;
      chefConfig: AIChefConfig;
      context?: {
        ingredients?: string[];
        tools?: string[];
      };
    };

    if (!message) {
      return NextResponse.json(
        { error: "메시지를 입력해주세요." },
        { status: 400 }
      );
    }

    if (!chefConfig) {
      return NextResponse.json(
        { error: "AI 셰프 설정이 필요합니다." },
        { status: 400 }
      );
    }

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
