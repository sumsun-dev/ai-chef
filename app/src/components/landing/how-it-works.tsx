import { Badge } from "@/components/ui/badge";
import { Clock } from "lucide-react";

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

export function HowItWorks() {
  return (
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
  );
}
