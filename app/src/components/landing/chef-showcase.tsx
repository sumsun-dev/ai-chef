"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ChefHat, ArrowRight } from "lucide-react";

const chefPersonas = [
  { name: "김미식", specialty: "한식", emoji: "🍲", color: "from-orange-500 to-red-500" },
  { name: "사토 유키", specialty: "일식", emoji: "🍣", color: "from-pink-500 to-rose-500" },
  { name: "마르코", specialty: "양식", emoji: "🍝", color: "from-amber-500 to-orange-500" },
  { name: "마리", specialty: "디저트", emoji: "🧁", color: "from-pink-400 to-purple-500" },
];

export function ChefShowcase() {
  const [hoveredChef, setHoveredChef] = useState<number | null>(null);

  return (
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
  );
}
