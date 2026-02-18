import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Leaf, ArrowRight } from "lucide-react";

export function FinalCTA() {
  return (
    <section className="py-24 px-4">
      <div className="container mx-auto max-w-4xl">
        <Card className="border-0 bg-gradient-to-br from-primary via-primary to-accent overflow-hidden relative">
          <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10" />
          <CardContent className="p-12 md:p-16 text-center relative z-10">
            <div className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm rounded-full px-4 py-2 mb-6">
              <Leaf className="w-5 h-5 text-white" />
              <span className="text-white font-medium">지금 무료로 시작하세요</span>
            </div>
            <h2 className="text-3xl md:text-5xl font-bold text-white mb-6">
              오늘부터 AI 셰프와 함께
              <br />
              맛있는 요리를 시작해보세요
            </h2>
            <p className="text-lg text-white/80 mb-8 max-w-xl mx-auto">
              회원가입 없이 바로 시작할 수 있어요.
              <br />
              당신의 냉장고 속 재료가 맛있는 한 끼로 변신합니다.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Button
                size="lg"
                variant="secondary"
                className="text-lg px-8 py-6 rounded-full bg-white text-primary hover:bg-white/90 shadow-lg transition-all duration-300 group"
              >
                지금 시작하기
                <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>
  );
}
