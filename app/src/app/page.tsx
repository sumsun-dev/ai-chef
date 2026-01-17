"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ChefHat, Send, Sparkles, Loader2 } from "lucide-react";

// 기본 AI 셰프 설정
const defaultChefConfig = {
  name: "AI 셰프",
  personality: "friendly" as const,
  expertise: ["한식", "일식", "양식"],
  cookingPhilosophy: "간편하고 맛있는 요리를 함께 만들어요!",
  speakingStyle: {
    formality: "casual" as const,
    emojiUsage: "medium" as const,
    technicality: "general" as const,
  },
};

export default function Home() {
  const [message, setMessage] = useState("");
  const [chatResponse, setChatResponse] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const [ingredients, setIngredients] = useState("계란, 파, 간장, 참기름");
  const [tools, setTools] = useState("프라이팬, 냄비, 도마, 칼");
  const [recipeResponse, setRecipeResponse] = useState<string>("");
  const [isRecipeLoading, setIsRecipeLoading] = useState(false);

  // 채팅 테스트
  const handleChat = async () => {
    if (!message.trim()) return;

    setIsLoading(true);
    setChatResponse("");

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message,
          chefConfig: defaultChefConfig,
          context: {
            ingredients: ingredients.split(",").map((i) => i.trim()),
            tools: tools.split(",").map((t) => t.trim()),
          },
        }),
      });

      const data = await res.json();

      if (data.error) {
        setChatResponse(`오류: ${data.error}`);
      } else {
        setChatResponse(data.response);
      }
    } catch (error) {
      setChatResponse(`오류 발생: ${error}`);
    } finally {
      setIsLoading(false);
    }
  };

  // 레시피 생성 테스트
  const handleRecipe = async () => {
    setIsRecipeLoading(true);
    setRecipeResponse("");

    try {
      const res = await fetch("/api/recipe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ingredients: ingredients.split(",").map((i) => i.trim()),
          tools: tools.split(",").map((t) => t.trim()),
          preferences: {
            difficulty: "easy",
            servings: 1,
          },
          chefConfig: defaultChefConfig,
        }),
      });

      const data = await res.json();

      if (data.error) {
        setRecipeResponse(`오류: ${data.error}`);
      } else {
        setRecipeResponse(JSON.stringify(data.recipe, null, 2));
      }
    } catch (error) {
      setRecipeResponse(`오류 발생: ${error}`);
    } finally {
      setIsRecipeLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50 to-white dark:from-zinc-900 dark:to-zinc-950">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        {/* 헤더 */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <ChefHat className="w-10 h-10 text-orange-500" />
            <h1 className="text-4xl font-bold text-zinc-900 dark:text-white">
              AI 셰프
            </h1>
          </div>
          <p className="text-zinc-600 dark:text-zinc-400">
            Gemini API 연동 테스트
          </p>
          <div className="flex gap-2 justify-center mt-4">
            <Badge variant="outline">Gemini 2.5 Flash</Badge>
            <Badge variant="outline">Gemini 2.5 Pro</Badge>
          </div>
        </div>

        {/* 재료 & 도구 입력 */}
        <Card className="mb-6">
          <CardHeader>
            <CardTitle className="text-lg">보유 재료 & 도구</CardTitle>
            <CardDescription>
              쉼표(,)로 구분하여 입력하세요
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium mb-2 block">재료</label>
              <Input
                value={ingredients}
                onChange={(e) => setIngredients(e.target.value)}
                placeholder="계란, 파, 간장, 참기름"
              />
            </div>
            <div>
              <label className="text-sm font-medium mb-2 block">도구</label>
              <Input
                value={tools}
                onChange={(e) => setTools(e.target.value)}
                placeholder="프라이팬, 냄비, 도마, 칼"
              />
            </div>
          </CardContent>
        </Card>

        {/* 탭 */}
        <Tabs defaultValue="chat" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="chat">채팅 테스트</TabsTrigger>
            <TabsTrigger value="recipe">레시피 생성</TabsTrigger>
          </TabsList>

          {/* 채팅 테스트 탭 */}
          <TabsContent value="chat">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Send className="w-5 h-5" />
                  AI 셰프와 대화
                </CardTitle>
                <CardDescription>
                  Gemini 2.5 Flash 모델 사용
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex gap-2">
                  <Input
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="오늘 뭐 먹을까요?"
                    onKeyDown={(e) => e.key === "Enter" && handleChat()}
                  />
                  <Button onClick={handleChat} disabled={isLoading}>
                    {isLoading ? (
                      <Loader2 className="w-4 h-4 animate-spin" />
                    ) : (
                      <Send className="w-4 h-4" />
                    )}
                  </Button>
                </div>

                {chatResponse && (
                  <div className="p-4 bg-zinc-50 dark:bg-zinc-800 rounded-lg">
                    <p className="text-sm font-medium text-orange-600 mb-2">
                      AI 셰프:
                    </p>
                    <p className="text-zinc-700 dark:text-zinc-300 whitespace-pre-wrap">
                      {chatResponse}
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          {/* 레시피 생성 탭 */}
          <TabsContent value="recipe">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Sparkles className="w-5 h-5" />
                  맞춤 레시피 생성
                </CardTitle>
                <CardDescription>
                  Gemini 2.5 Pro 모델 사용 (복잡한 추론)
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Button
                  onClick={handleRecipe}
                  disabled={isRecipeLoading}
                  className="w-full"
                >
                  {isRecipeLoading ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin mr-2" />
                      레시피 생성 중...
                    </>
                  ) : (
                    <>
                      <Sparkles className="w-4 h-4 mr-2" />
                      보유 재료로 레시피 추천받기
                    </>
                  )}
                </Button>

                {recipeResponse && (
                  <div className="p-4 bg-zinc-50 dark:bg-zinc-800 rounded-lg">
                    <p className="text-sm font-medium text-orange-600 mb-2">
                      생성된 레시피:
                    </p>
                    <Textarea
                      value={recipeResponse}
                      readOnly
                      className="font-mono text-xs h-96"
                    />
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* API 상태 */}
        <div className="mt-8 text-center text-sm text-zinc-500">
          <p>
            .env.local 파일에 GEMINI_API_KEY를 설정하세요
          </p>
        </div>
      </div>
    </div>
  );
}
