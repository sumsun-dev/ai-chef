"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ChefHat,
  Sparkles,
  Clock,
  Users,
  Leaf,
  ArrowRight,
  Play,
  Star,
  MessageSquare,
  BookOpen,
  Refrigerator,
} from "lucide-react";

// AI Chef personas for the showcase
const chefPersonas = [
  { name: "김미식", specialty: "한식", emoji: "🍲", color: "from-orange-500 to-red-500" },
  { name: "사토 유키", specialty: "일식", emoji: "🍣", color: "from-pink-500 to-rose-500" },
  { name: "마르코", specialty: "양식", emoji: "🍝", color: "from-amber-500 to-orange-500" },
  { name: "마리", specialty: "디저트", emoji: "🧁", color: "from-pink-400 to-purple-500" },
];

const features = [
  {
    icon: Refrigerator,
    title: "스마트 재료 관리",
    description: "냉장고 속 재료를 AI가 인식하고 유통기한까지 관리해드려요",
    color: "text-emerald-500",
    bgColor: "bg-emerald-50 dark:bg-emerald-950/30",
  },
  {
    icon: Sparkles,
    title: "AI 맞춤 레시피",
    description: "보유 재료와 취향을 분석해 나만을 위한 레시피를 추천해요",
    color: "text-primary",
    bgColor: "bg-primary/5",
  },
  {
    icon: MessageSquare,
    title: "요리 멘토 대화",
    description: "요리 중 궁금한 점은 AI 셰프에게 언제든 물어보세요",
    color: "text-blue-500",
    bgColor: "bg-blue-50 dark:bg-blue-950/30",
  },
  {
    icon: BookOpen,
    title: "레시피 저장",
    description: "마음에 드는 레시피는 저장하고 나만의 요리책을 만들어요",
    color: "text-violet-500",
    bgColor: "bg-violet-50 dark:bg-violet-950/30",
  },
];

const howItWorks = [
  {
    step: "01",
    title: "재료 입력",
    description: "냉장고 속 재료를 사진으로 찍거나 직접 입력하세요",
  },
  {
    step: "02",
    title: "AI 셰프 선택",
    description: "8명의 개성 넘치는 AI 셰프 중 원하는 셰프를 선택하세요",
  },
  {
    step: "03",
    title: "맞춤 레시피",
    description: "AI가 분석한 최적의 레시피를 받아 요리를 시작하세요",
  },
];

const stats = [
  { value: "10K+", label: "생성된 레시피" },
  { value: "8명", label: "AI 셰프" },
  { value: "98%", label: "만족도" },
  { value: "5분", label: "평균 추천 시간" },
];

export default function Home() {
  const [hoveredChef, setHoveredChef] = useState<number | null>(null);

  return (
    <div className="min-h-screen bg-background overflow-hidden">
      {/* Hero Section */}
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

      {/* AI Chef Showcase */}
      <section className="py-24 px-4 bg-gradient-to-b from-background to-secondary/30">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16 animate-fade-in-up">
            <Badge variant="outline" className="mb-4">
              <ChefHat className="w-4 h-4 mr-2" />
              AI 셰프 라인업
            </Badge>
            <h2 className="text-4xl md:text-5xl font-bold mb-4">
              당신만을 위한 <span className="text-primary">AI 셰프</span>
            </h2>
            <p className="text-lg text-muted-foreground max-w-xl mx-auto">
              8명의 개성 넘치는 AI 셰프가 각자의 전문 분야로 당신의 요리를 도와드립니다
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {chefPersonas.map((chef, index) => (
              <Card
                key={index}
                className={`group cursor-pointer transition-all duration-300 hover:scale-105 hover:shadow-xl border-0 overflow-hidden ${
                  hoveredChef === index ? "ring-2 ring-primary" : ""
                }`}
                onMouseEnter={() => setHoveredChef(index)}
                onMouseLeave={() => setHoveredChef(null)}
              >
                <CardContent className="p-6 text-center">
                  <div
                    className={`w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br ${chef.color} flex items-center justify-center text-4xl shadow-lg group-hover:scale-110 transition-transform duration-300`}
                  >
                    {chef.emoji}
                  </div>
                  <h3 className="font-bold text-lg mb-1">{chef.name}</h3>
                  <p className="text-sm text-muted-foreground">{chef.specialty} 전문</p>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="text-center mt-8">
            <Button variant="outline" className="rounded-full">
              모든 AI 셰프 보기
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24 px-4">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <Badge variant="outline" className="mb-4">
              <Sparkles className="w-4 h-4 mr-2" />
              핵심 기능
            </Badge>
            <h2 className="text-4xl md:text-5xl font-bold mb-4">
              요리가 <span className="text-primary">쉬워지는</span> 순간
            </h2>
            <p className="text-lg text-muted-foreground max-w-xl mx-auto">
              AI Chef의 스마트한 기능으로 매일의 요리가 즐거워집니다
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            {features.map((feature, index) => (
              <Card
                key={index}
                className="group border-0 shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden"
              >
                <CardContent className="p-8 flex gap-6">
                  <div
                    className={`w-14 h-14 rounded-2xl ${feature.bgColor} flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform duration-300`}
                  >
                    <feature.icon className={`w-7 h-7 ${feature.color}`} />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold mb-2">{feature.title}</h3>
                    <p className="text-muted-foreground leading-relaxed">{feature.description}</p>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-24 px-4 bg-gradient-to-b from-secondary/30 to-background">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <Badge variant="outline" className="mb-4">
              <Clock className="w-4 h-4 mr-2" />
              사용 방법
            </Badge>
            <h2 className="text-4xl md:text-5xl font-bold mb-4">
              <span className="text-primary">3단계</span>로 시작하세요
            </h2>
            <p className="text-lg text-muted-foreground max-w-xl mx-auto">
              복잡한 설정 없이 바로 AI 셰프의 도움을 받을 수 있어요
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {howItWorks.map((item, index) => (
              <div key={index} className="relative group">
                <div className="text-center">
                  <div className="relative inline-block mb-6">
                    <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center group-hover:bg-primary/20 transition-colors duration-300">
                      <span className="text-3xl font-bold text-primary">{item.step}</span>
                    </div>
                    {index < howItWorks.length - 1 && (
                      <div className="hidden md:block absolute top-1/2 left-full w-full h-0.5 bg-gradient-to-r from-primary/30 to-transparent" />
                    )}
                  </div>
                  <h3 className="text-xl font-bold mb-2">{item.title}</h3>
                  <p className="text-muted-foreground">{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Social Proof */}
      <section className="py-24 px-4">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <Badge variant="outline" className="mb-4">
              <Star className="w-4 h-4 mr-2" />
              사용자 후기
            </Badge>
            <h2 className="text-4xl md:text-5xl font-bold mb-4">
              이미 많은 분들이 <span className="text-primary">사랑하고 있어요</span>
            </h2>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                quote: "냉장고 속 재료로 이렇게 다양한 요리를 할 수 있는지 몰랐어요. AI 셰프 덕분에 매일 새로운 요리에 도전하고 있어요!",
                author: "김지현",
                role: "직장인",
                rating: 5,
              },
              {
                quote: "요리 초보인 저도 AI 셰프의 상세한 가이드 덕분에 맛있는 요리를 만들 수 있게 됐어요. 정말 감사해요!",
                author: "박서연",
                role: "대학생",
                rating: 5,
              },
              {
                quote: "아이들 식단 고민이 많았는데, AI 셰프가 영양까지 고려해서 레시피를 추천해줘서 너무 만족스러워요.",
                author: "이민정",
                role: "주부",
                rating: 5,
              },
            ].map((testimonial, index) => (
              <Card key={index} className="border-0 shadow-sm hover:shadow-lg transition-all duration-300">
                <CardContent className="p-6">
                  <div className="flex gap-1 mb-4">
                    {Array.from({ length: testimonial.rating }).map((_, i) => (
                      <Star key={i} className="w-5 h-5 fill-amber-400 text-amber-400" />
                    ))}
                  </div>
                  <p className="text-muted-foreground mb-6 leading-relaxed">&ldquo;{testimonial.quote}&rdquo;</p>
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                      <Users className="w-5 h-5 text-primary" />
                    </div>
                    <div>
                      <div className="font-semibold">{testimonial.author}</div>
                      <div className="text-sm text-muted-foreground">{testimonial.role}</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
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

      {/* Footer */}
      <footer className="py-12 px-4 border-t">
        <div className="container mx-auto max-w-6xl">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-2">
              <ChefHat className="w-6 h-6 text-primary" />
              <span className="font-bold text-xl">AI 셰프</span>
            </div>
            <p className="text-sm text-muted-foreground">
              &copy; 2026 AI Chef. Powered by Google Gemini.
            </p>
            <div className="flex gap-6">
              <Link href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                이용약관
              </Link>
              <Link href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                개인정보처리방침
              </Link>
              <Link href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                문의하기
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
