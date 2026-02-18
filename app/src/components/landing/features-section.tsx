import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Sparkles,
  MessageSquare,
  BookOpen,
  Refrigerator,
} from "lucide-react";

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

export function FeaturesSection() {
  return (
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
  );
}
