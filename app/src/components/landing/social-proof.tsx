import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Star, Users } from "lucide-react";

const testimonials = [
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
];

export function SocialProof() {
  return (
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
          {testimonials.map((testimonial, index) => (
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
  );
}
