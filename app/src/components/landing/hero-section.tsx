import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Sparkles, ArrowRight, Play } from "lucide-react";

const stats = [
  { value: "10K+", label: "생성된 레시피" },
  { value: "8명", label: "AI 셰프" },
  { value: "98%", label: "만족도" },
  { value: "5분", label: "평균 추천 시간" },
];

export function HeroSection() {
  return (
    <section className="relative min-h-screen flex items-center justify-center px-4 py-20">
      {/* Background decorations */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-primary/10 rounded-full blur-3xl animate-float" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-accent/10 rounded-full blur-3xl animate-float animation-delay-200" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-gradient-to-r from-primary/5 via-transparent to-accent/5 rounded-full blur-3xl" />
      </div>

      <div className="container mx-auto max-w-6xl relative z-10">
        <div className="text-center space-y-8">
          {/* Badge */}
          <div className="animate-fade-in-up">
            <Badge
              variant="secondary"
              className="px-4 py-2 text-sm font-medium bg-secondary/80 backdrop-blur-sm border border-primary/20"
            >
              <Sparkles className="w-4 h-4 mr-2 text-primary" />
              Gemini AI 기반 스마트 요리 어시스턴트
            </Badge>
          </div>

          {/* Main headline */}
          <div className="space-y-4 animate-fade-in-up animation-delay-100">
            <h1 className="text-5xl md:text-7xl lg:text-8xl font-bold tracking-tight">
              <span className="block text-foreground">냉장고 속 재료로</span>
              <span className="block bg-gradient-to-r from-primary via-primary to-accent bg-clip-text text-transparent animate-gradient">
                맛있는 한 끼
              </span>
            </h1>
            <p className="text-xl md:text-2xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
              AI 셰프가 당신만을 위한 맞춤 레시피를 제안합니다.
              <br className="hidden sm:block" />
              8명의 전문 AI 셰프와 함께 요리의 즐거움을 느껴보세요.
            </p>
          </div>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 animate-fade-in-up animation-delay-200">
            <Button
              size="lg"
              className="text-lg px-8 py-6 rounded-full bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 transition-all duration-300 group"
            >
              무료로 시작하기
              <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="text-lg px-8 py-6 rounded-full border-2 hover:bg-secondary/50 transition-all duration-300 group"
            >
              <Play className="w-5 h-5 mr-2 group-hover:scale-110 transition-transform" />
              데모 영상 보기
            </Button>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 pt-12 animate-fade-in-up animation-delay-300">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl md:text-4xl font-bold text-foreground">{stat.value}</div>
                <div className="text-sm text-muted-foreground mt-1">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <div className="w-6 h-10 rounded-full border-2 border-muted-foreground/30 flex items-start justify-center p-2">
          <div className="w-1.5 h-3 bg-muted-foreground/50 rounded-full" />
        </div>
      </div>
    </section>
  );
}
