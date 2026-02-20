import { HeroSection } from "@/components/landing/hero-section";
import { ChefShowcase } from "@/components/landing/chef-showcase";
import { FeaturesSection } from "@/components/landing/features-section";
import { HowItWorks } from "@/components/landing/how-it-works";
import { SocialProof } from "@/components/landing/social-proof";
import { FinalCTA } from "@/components/landing/final-cta";
import { FooterSection } from "@/components/landing/footer-section";

export default function Home() {
  return (
    <div className="min-h-screen bg-background overflow-hidden">
      <HeroSection />
      <ChefShowcase />
      <FeaturesSection />
      <HowItWorks />
      <SocialProof />
      <FinalCTA />
      <FooterSection />
    </div>
  );
}
