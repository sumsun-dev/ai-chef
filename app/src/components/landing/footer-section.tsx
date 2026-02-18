import Link from "next/link";
import { ChefHat } from "lucide-react";

export function FooterSection() {
  return (
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
  );
}
