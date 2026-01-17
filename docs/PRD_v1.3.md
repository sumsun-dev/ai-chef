# **Product Requirements Document (PRD) v1.3**
## **AI 셰프 - 스마트 재료 관리 & 레시피 추천 앱**

---

## **변경 사항 요약 (v1.2 → v1.3)**

| 변경 항목 | 기존 (v1.2) | 변경 후 (v1.3) |
|----------|-------------|---------------|
| **AI 모델** | Gemini 3 Pro/Flash | **Gemini 3 Pro/Flash** + **Gemini 2.5 Pro/Flash** (가격 정보 추가) |
| **Vision 모델** | Gemini 3 Vision | **Gemini 3 Flash (Vision)** - 멀티모달 네이티브 |
| **Video 모델** | Veo 3.1 | **Veo 3.1** (네이티브 오디오 포함) |
| **On-Device** | Nanobanana Pro | **Gemini Nano** (실제 모델명) |
| **비용 추정** | 없음 | **상세 비용 추정 추가** (2026년 1월 기준 가격) |

---

## **1. 문서 정보**

| 항목 | 내용 |
|------|------|
| **문서 버전** | 1.3 |
| **작성일** | 2025-01-16 |
| **최종 수정일** | 2026-01-17 (최신 AI 모델 가격 반영) |
| **작성자** | AI 셰프 개발팀 |
| **제품명** | AI 셰프 (AI Chef) |
| **제품 유형** | 웹/모바일 애플리케이션 |

---

## **2. 제품 개요**

### **2.1 제품 비전**
"모든 사람이 자신만의 AI 셰프와 함께 개인 취향에 완벽히 맞는 건강하고 맛있는 식사를 낭비 없이 즐길 수 있도록 돕는 초개인화 요리 어시스턴트"

### **2.2 제품 미션**
- 식재료 낭비를 최소화하여 지속 가능한 식생활 지원
- AI 기반 완전 맞춤형 레시피로 요리의 장벽 낮추기
- 유통기한 관리를 자동화하여 식품 안전성 향상
- 모든 요리 전통의 전문 셰프 노하우를 개인 취향에 맞춰 제공
- 보유 재료와 도구에 맞춘 현실적인 레시피 제안
- 절대적인 개인정보 보호와 계정 간 데이터 격리

### **2.3 타겟 유저**

**Primary:**
- 1-2인 가구 (20-40대)
- 요리에 관심은 있지만 시간/도구가 부족한 직장인
- 식재료 관리에 어려움을 겪는 사람
- 건강한 식단에 관심 있는 사람
- 특정 요리 스타일에 애착이 있는 사람

**Secondary:**
- 다양한 요리를 시도하고 싶은 요리 애호가
- 식비 절약을 원하는 사람
- 음식물 쓰레기를 줄이고 싶은 환경 의식이 있는 사람
- 최소한의 주방 도구로 요리하는 자취생
- 자신만의 요리 스타일을 만들고 싶은 사람

### **2.4 핵심 가치 제안 (Value Proposition)**
1. **자동화된 재료 관리**: 영수증 사진만 찍으면 AI가 자동으로 재료 등록 및 유통기한 설정
2. **똑똑한 유통기한 알림**: 비침입적 인앱 알림으로 재료 낭비 방지
3. **나만의 AI 셰프 캐릭터**: 이름, 성격, 전문 분야를 자유롭게 커스터마이징
4. **무제한 요리 스타일**: 한식, 일식, 중식, 프랑스식, 멕시칸, 인도식 등 모든 요리 지원
5. **완전 맞춤형 레시피 추천**: 보유 재료, 도구, 개인 선호도 기반
6. **현실적인 대안 제시**: 없는 재료는 대체 또는 생략 방법 안내
7. **시각적 AI 요리 가이드**: Gemini 3 & Veo 3.1 기반 실시간 사진/영상 분석
8. **철저한 개인정보 보호**: 계정별 완전 격리된 메모리 시스템

---

## **3. AI 기술 스택**

### **3.1 Google Gemini 모델 선택**

| 용도 | 모델 | 출시 | 비용 (1M tokens, ≤200K) |
|------|------|------|-------------------------|
| **레시피 생성 (고품질)** | Gemini 3 Pro Preview | 2025.11 | Input $2.00 / Output $12.00 |
| **빠른 대화/이미지** | Gemini 3 Flash Preview | 2025.12 | Input $0.50 / Output $3.00 |
| **레시피 생성 (안정)** | Gemini 2.5 Pro | 2025.06 | Input $1.25 / Output $10.00 |
| **빠른 대화 (안정)** | Gemini 2.5 Flash | 2025.06 | Input $0.30 / Output $2.50 |
| **영상 생성** | Veo 3.1 | Latest | 별도 과금 |
| **온디바이스** | Gemini Nano | - | 무료 (디바이스 내장) |

### **3.2 모델별 상세 스펙**

#### **Gemini 3 Pro Preview**
- **용도**: 복잡한 레시피 생성, 창의적인 요리 제안
- **출시**: 2025년 11월
- **가격** (Standard, per 1M tokens):
  - Input: $2.00 (≤200K) / $4.00 (>200K)
  - Output: $12.00 (≤200K) / $18.00 (>200K)
- **Batch 가격** (50% 할인):
  - Input: $1.00 / $2.00
  - Output: $6.00 / $9.00
- **특징**:
  - 최신 추론 능력
  - 복잡한 대체 재료 추론
  - 창의적인 퓨전 레시피

#### **Gemini 3 Flash Preview**
- **용도**: 일상 대화, 간단한 레시피, 이미지/비디오 분석
- **출시**: 2025년 12월
- **가격** (Standard, per 1M tokens):
  - Input (text/image/video): $0.50
  - Input (audio): $1.00
  - Output: $3.00
- **Batch 가격** (50% 할인):
  - Input: $0.25 / $0.50
  - Output: $1.50
- **특징**:
  - 응답 속도 우수 (< 1초)
  - 멀티모달 네이티브 지원 (이미지, 비디오, 오디오)
  - 비용 효율적

#### **Gemini 2.5 Pro (Stable)**
- **용도**: 복잡한 레시피 생성 (안정 버전)
- **출시**: 2025년 6월
- **가격** (Standard, per 1M tokens):
  - Input: $1.25 (≤200K) / $2.50 (>200K)
  - Output: $10.00 (≤200K) / $15.00 (>200K)
- **특징**:
  - 프로덕션 안정성
  - 긴 컨텍스트 지원

#### **Gemini 2.5 Flash (Stable)**
- **용도**: 빠른 대화, 간단한 레시피, 이미지 분석 (안정 버전)
- **출시**: 2025년 6월
- **가격** (Standard, per 1M tokens):
  - Input (text/image/video): $0.30
  - Input (audio): $1.00
  - Output: $2.50
- **특징**:
  - 프로덕션 안정성
  - 비용 효율적

#### **Veo 3.1**
- **용도**: 조리 과정 가이드 영상 생성
- **특징**:
  - 네이티브 오디오 생성 (영상과 함께 음성/효과음)
  - 향상된 물리 시뮬레이션 (현실적인 움직임)
  - 1080p / 4K 해상도 지원
  - 확장된 창작 컨트롤
- **접근 방법**: Gemini, Flow, Google AI Studio, Gemini API

#### **Gemini Nano**
- **용도**: 오프라인 기본 기능
- **지원 디바이스**: Pixel 8 Pro+, Samsung Galaxy S24+
- **기능 범위**:
  - 기본 레시피 검색 (캐시)
  - 간단한 대화
  - 재료 정보 조회
- **제한사항**:
  - 복잡한 레시피 생성 불가
  - 이미지 분석 제한적

### **3.3 API 호출 전략**

```
[사용자 요청 분류]
│
├─ 간단한 질문/대화 ─────────────> Gemini 3 Flash (또는 2.5 Flash)
│   예: "파스타 삶는 시간?"
│
├─ 레시피 생성 요청 ─────────────> Gemini 3 Pro (또는 2.5 Pro)
│   예: "냉장고 재료로 저녁 추천해줘"
│
├─ 이미지 포함 질문 ─────────────> Gemini 3 Flash (멀티모달)
│   예: "이 정도로 썰었는데 맞아?" + 사진
│
├─ 오프라인 상태 ────────────────> Gemini Nano (캐시)
│   예: 기본 레시피 조회
│
└─ 영상 가이드 요청 ─────────────> Veo 3.1
    예: "파스타 삶는 법 영상으로 보여줘"
```

### **3.4 모델 선택 전략**

| 상황 | 권장 모델 | 이유 |
|------|-----------|------|
| MVP 개발 | Gemini 2.5 Pro/Flash | 안정성, 예측 가능한 비용 |
| 프로덕션 초기 | Gemini 2.5 → 3 점진적 전환 | 안정성 확보 후 최신 기능 |
| 고품질 필요 | Gemini 3 Pro | 최신 추론 능력 |
| 비용 최적화 | Gemini 2.5 Flash + Batch | 최저 비용 |

---

## **4. 기능 요구사항**

### **4.1 핵심 기능 (MVP)**

#### **4.1.1 프로필 & AI 셰프 커스터마이징**

**F-001: 나만의 AI 셰프 캐릭터 생성**
- **우선순위**: P0 (필수)
- **설명**: 사용자가 자신만의 AI 셰프를 만들고 관계 형성
- **커스터마이징 옵션**:

  **1) AI 셰프 이름:**
  - 자유 입력 (예: "고든", "나나", "요리왕 김셰프")
  - 기본 제안 (예: "셰프 알렉스", "마스터 킴", "Chef 미소")

  **2) AI 셰프 성격:**
  - 프로페셔널: 정확하고 전문적인 설명
  - 친근한 친구: 편안하고 격의 없는 대화
  - 다정한 엄마: 따뜻하고 꼼꼼한 케어
  - 열정적인 코치: 동기부여와 격려 중심
  - 과학적 분석가: 요리 과학 설명 중심
  - 커스텀: 사용자가 직접 설명 작성

  **3) 전문 분야 (복수 선택 가능):**
  - 한식, 일식, 중식, 이탈리아식, 프랑스식
  - 스페인식, 멕시칸, 인도식, 태국식, 베트남식
  - 지중해식, 퓨전/창작 요리, 베이킹/디저트
  - 건강식/다이어트, 채식/비건

  **4) 요리 철학/방향:**
  - 자유 텍스트 입력 (300자 이내)

  **5) 말투/언어 스타일:**
  - 존댓말 / 반말
  - 이모지 사용 빈도 (많음/보통/적음/없음)
  - 전문 용어 사용 정도 (전문가/일반/초보자)

- **AI 시스템 프롬프트 생성**:
  ```
  당신의 이름은 {셰프_이름}입니다.
  당신의 성격은 {성격_타입}이며, {말투_스타일}로 대화합니다.
  당신은 {전문_분야} 요리에 전문가입니다.
  사용자의 요리 철학은 "{요리_철학}"입니다.

  [메모리 컨텍스트]
  - 이 사용자는 {재료_목록}을 보유하고 있습니다.
  - 이 사용자는 {도구_목록}을 가지고 있습니다.
  - 이 사용자의 선호도: {선호_정보}
  - 과거 조리 이력: {조리_히스토리}

  [절대 규칙]
  - 다른 사용자의 정보를 절대 참조하지 마세요.
  - 이 사용자의 개인정보를 외부에 공유하지 마세요.
  ```

**F-002: 프로필 설정 및 관리**
- **우선순위**: P0 (필수)
- **설정 항목**:
  - 기본 정보 (이름, 이메일, 프로필 사진)
  - AI 셰프 커스터마이징 (언제든 수정 가능)
  - 식이 제한 (알러지, 채식 등)
  - 요리 실력 (초급/중급/고급)
  - 레시피 추천 기준
  - 알림 설정
  - 개인정보 관리 (데이터 다운로드/삭제)

#### **4.1.2 재료 관리**

**F-003: 재료 등록**
- **우선순위**: P0 (필수)
- **입력 방법**:
  - 수동 입력 (재료명, 수량, 구입일, 가격, 보관위치)
  - 영수증/구매내역 사진 업로드 (Gemini 3 Flash Vision OCR)
  - 음성 입력 (선택)
- **자동 처리**:
  - 유통기한 미입력 시 신뢰할 수 있는 DB 기반 자동 설정
  - 카테고리 자동 분류
  - 보관 위치에 따른 유통기한 자동 조정

**F-004: 재료 목록 조회**
- **우선순위**: P0 (필수)
- **뷰 옵션**: 전체/카테고리별/보관위치별/유통기한순
- **표시 정보**: 재료명, 수량, 구입일, 유통기한, D-day, 상태 배지

**F-005: 재료 수정/삭제**
- **우선순위**: P0 (필수)

**F-006: 재료 사용 기록**
- **우선순위**: P1 (중요)
- 레시피 조리 시 수량 자동 차감

#### **4.1.3 유통기한 관리**

**F-007: 유통기한 인앱 알림**
- **우선순위**: P0 (필수)
- **알림 단계**:
  1. 유통기한 지남: "폐기 권장 재료 N개"
  2. 유통기한 임박 (3일 이내): "빨리 사용해야 할 재료 N개"
  3. 유통기한 주의 (7일 이내): "일주일 내 사용 권장 N개"
- **푸시 알림**: 없음 (비침입적)

**F-008: 유통기한 대시보드**
- **우선순위**: P0 (필수)
- 메인 화면에서 상태 한눈에 파악

#### **4.1.4 요리 도구 관리**

**F-009: 보유 도구 등록**
- **우선순위**: P0 (필수)
- **도구 카테고리**: 조리 도구, 칼/도마, 계량/믹싱, 기타

**F-010: 도구별 레시피 필터**
- **우선순위**: P1 (중요)
- 보유 도구로 만들 수 있는 레시피만 추천

#### **4.1.5 AI 레시피 추천**

**F-011: 맞춤형 레시피 추천**
- **우선순위**: P0 (필수)
- **AI 모델 선택**:
  - **Gemini 3 Pro**: 복잡한 레시피 생성, 창의적인 요리 제안 (최신)
  - **Gemini 2.5 Pro**: 복잡한 레시피 생성 (안정)
  - **Gemini 3/2.5 Flash**: 간단한 레시피, 빠른 응답
  - **Gemini Nano**: 오프라인 기본 레시피

- **추천 기준**:
  - 재료 활용 우선순위 (유통기한 임박/수량/가격)
  - 시간 및 난이도
  - AI 셰프 전문 분야 우선
  - 재료 유연성 (대체/생략 가능)
  - 보유 도구 제약
  - 영양 선호도

- **레시피 포맷**:
  ```
  [AI 셰프 인사]
  안녕하세요, {셰프_이름}입니다!
  오늘은 {이유}로 이 요리를 추천드려요.

  [요리명]
  조리시간 | 난이도 | 인원 | 스타일
  필요 도구: 프라이팬, 냄비, 주걱

  [재료 목록]
  - 보유 재료 (D-day 표시)
  - 없는 재료 → 대체/생략 안내

  [조리 과정]
  단계별 설명 (AI 셰프 성격에 맞춤)
  ```

**F-012: AI 시각적 요리 가이드**
- **우선순위**: P0 (필수)
- **기능**:
  - 사용자 사진 업로드 → Gemini 3 Flash Vision 분석
  - AI 피드백 제공 (썰기, 익힘 정도, 소스 농도 등)
  - 참고 이미지/영상 제공 (Veo 3.1 생성)
  - 실시간 Q&A (컨텍스트 유지)

**F-013: 레시피 저장 및 히스토리**
- **우선순위**: P1 (중요)
- 즐겨찾기, 조리 완료 기록, 평가 및 메모

#### **4.1.6 영양 관리**

**F-014: 영양 정보 제공**
- **우선순위**: P1 (중요)
- 레시피별 자동 계산 (칼로리, 탄단지, 나트륨 등)

#### **4.1.7 개인정보 보호 & 메모리 관리**

**F-015: 계정별 완전 격리된 메모리 시스템**
- **우선순위**: P0 (필수)
- **핵심 원칙**:
  - 제로 트러스트 아키텍처
  - AI 세션 격리
  - Row Level Security (RLS) 적용
  - 감사 로그 24시간 모니터링

**F-016: 개인정보 관리 도구**
- **우선순위**: P0 (필수)
- 데이터 다운로드/삭제, 접근 로그 확인

---

## **5. 비기능 요구사항**

### **5.1 성능**
- **일반 조회**: 1초 이내
- **AI 레시피 생성**: 2-4초 (Gemini 3 Pro)
- **AI 대화 응답**: 0.5-1.5초 (Gemini 3 Flash)
- **이미지 분석**: 1-3초 (Gemini 3 Flash Vision)
- **영상 생성**: 10-30초 (Veo 3.1)
- **동시 사용자**: 최소 100명

### **5.2 보안**
- AES-256 암호화 저장
- TLS 1.3 전송 암호화
- OAuth 2.0 인증
- Row Level Security 강제 적용
- GDPR/개인정보보호법 준수

### **5.3 가용성**
- 업타임: 99.9% 이상
- 실시간 백업

---

## **6. 기술 스택**

### **6.1 프론트엔드**
```
- Framework: React 18+ / Next.js 14+
- UI: Tailwind CSS + shadcn/ui
- State: Zustand + React Query
- 모바일 (Phase 2): React Native
```

### **6.2 백엔드**
```
- Runtime: Node.js 20 LTS 또는 Python 3.12
- Framework: Express.js 또는 FastAPI
- Database: Supabase (PostgreSQL 15+)
- Cache: Redis 7+
- Storage: Google Cloud Storage
- Auth: Supabase Auth
```

### **6.3 AI & ML**
```
- LLM: Google Gemini API
  - Gemini 3 Pro Preview: 복잡한 레시피 (최신)
  - Gemini 3 Flash Preview: 빠른 대화, 이미지 분석 (최신)
  - Gemini 2.5 Pro: 복잡한 레시피 (안정)
  - Gemini 2.5 Flash: 빠른 대화 (안정)
- Vision: Gemini 3 Flash (멀티모달 네이티브)
- Video: Veo 3.1 (네이티브 오디오)
- On-Device: Gemini Nano
- OCR: Gemini 3 Flash Vision
```

### **6.4 인프라**
```
- Frontend: Vercel
- Backend: Google Cloud Run
- CDN: Cloudflare
- Monitoring: Sentry + Google Cloud Monitoring
```

---

## **7. 데이터 모델**

### **7.1 핵심 엔티티**

#### **User (사용자)**
```typescript
interface User {
  id: string;
  email: string;
  name: string;
  profileImage?: string;

  aiChef: {
    name: string;
    personality: 'professional' | 'friendly' | 'motherly' | 'coach' | 'scientific' | 'custom';
    customPersonality?: string;
    expertise: string[];
    cookingPhilosophy?: string;
    speakingStyle: {
      formality: 'formal' | 'casual';
      emojiUsage: 'high' | 'medium' | 'low' | 'none';
      technicality: 'expert' | 'general' | 'beginner';
    };
    avatarUrl?: string;
  };

  preferences: {
    dietaryRestrictions?: string[];
    favoriteCuisines?: string[];
    cookingSkill?: 'beginner' | 'intermediate' | 'advanced';
    recipePreferences: {
      ingredientPriority: ('expiring' | 'quantity' | 'price' | 'favorite')[];
      cookingTime?: number;
      difficulty?: 'easy' | 'medium' | 'hard' | 'any';
      cuisineMode: 'ai_chef_expertise' | 'rotate' | 'favorite' | 'random';
      ingredientFlexibility: {
        allowSubstitution: boolean;
        allowOmission: boolean;
        strictMode: boolean;
      };
      toolConstraint: boolean;
    };
  };

  privacySettings: {
    dataRetentionDays: number;
    autoDeleteImages: boolean;
    shareDataForImprovement: boolean;
  };

  createdAt: Date;
  updatedAt: Date;
}
```

#### **Ingredient (재료)**
```typescript
interface Ingredient {
  id: string;
  userId: string;
  name: string;
  category: string;
  quantity: number;
  unit: string;
  purchaseDate: Date;
  expiryDate: Date;
  price?: number;
  storageLocation: 'refrigerated' | 'frozen' | 'room_temp';
  createdAt: Date;
  updatedAt: Date;
}
```

#### **CookingTool (요리 도구)**
```typescript
interface CookingTool {
  id: string;
  userId: string;
  name: string;
  category: 'cookware' | 'knife' | 'measuring' | 'appliance' | 'other';
  createdAt: Date;
}
```

#### **Recipe (레시피)**
```typescript
interface Recipe {
  id: string;
  userId?: string;
  title: string;
  cuisine: string;
  cookingTime: number;
  difficulty: 'easy' | 'medium' | 'hard';
  servings: number;

  generatedBy: {
    aiChefName: string;
    aiModel: 'gemini-3-pro' | 'gemini-3-flash' | 'gemini-2.5-pro' | 'gemini-2.5-flash';
    recommendationReason: string;
  };

  ingredients: RecipeIngredient[];
  requiredTools: RecipeTool[];
  instructions: RecipeStep[];
  nutrition: NutritionInfo;

  aiGenerated: boolean;
  createdAt: Date;
}
```

---

## **8. 개발 로드맵**

### **Phase 1: MVP (5주)**

**Week 1: 기반 구축 + AI 셰프**
- 프로젝트 셋업 (React + Supabase)
- Gemini API 연동 테스트 (2.5 Flash → 3 Flash 전환 준비)
- 사용자 인증 (Google 로그인)
- AI 셰프 캐릭터 생성 UI
- 데이터베이스 스키마 (RLS 포함)

**Week 2: 보안 & 재료 관리**
- Row Level Security 적용
- AI 세션 격리 시스템
- 재료 등록/조회 기능
- 유통기한 자동 설정

**Week 3: 도구 & AI 레시피**
- 보유 도구 관리
- Gemini 2.5/3 Pro 레시피 생성
- AI 셰프 성격별 프롬프트
- 재료 대체/생략 로직

**Week 4: AI 시각적 가이드**
- Gemini 3 Flash Vision 이미지 분석
- AI 대화형 요리 가이드
- 조리 이력 기록

**Week 5: 마무리**
- 감사 로그 시스템
- 개인정보 관리 도구
- 버그 수정 및 테스트
- 베타 배포

### **Phase 2: 기능 확장 (4주)**
- OCR (영수증 인식) 고도화
- 음성 입력 (STT)
- Veo 3.1 영상 가이드
- 쇼핑 리스트

### **Phase 3: 네이티브 앱 (6주)**
- React Native 포팅
- Gemini Nano 온디바이스 AI

---

## **9. 비용 추정**

> 상세 비용 추정은 별도 문서 참조: `COST_ESTIMATION.md`

### **요약 (MAU 1,000명 기준)**

| 항목 | 월 비용 (USD) |
|------|---------------|
| Gemini API | $400 ~ $600 |
| Supabase | $25 |
| Cloud Storage | $10 ~ $20 |
| Vercel | $20 |
| Cloud Run | $30 ~ $50 |
| **합계** | **$485 ~ $715** |

**사용자당 비용**: 약 $0.49 ~ $0.72 / 월

---

## **10. 리스크 및 대응**

| 리스크 | 영향 | 대응 방안 |
|--------|------|-----------|
| Gemini API 비용 급증 | 높음 | Batch API 활용 (50% 절감), 캐싱 |
| Gemini 3 Preview 불안정 | 중간 | Gemini 2.5 Stable 폴백 |
| Veo 3.1 API 접근 제한 | 중간 | 사전 제작 영상 라이브러리 활용 |
| 유통기한 정보 오류 | 높음 | 신뢰 DB만 사용 + 면책 조항 |
| 동시 접속 급증 | 중간 | Cloud Run 자동 스케일링 |

---

## **11. 성공 지표 (KPI)**

| 지표 | 목표 (6개월) |
|------|--------------|
| MAU | 5,000명 |
| DAU/MAU | 30% 이상 |
| 레시피 완료율 | 60% 이상 |
| 재료 낭비 감소율 | 30% (사용자 설문) |
| NPS | 40 이상 |
| 앱 평점 | 4.5 이상 |

---

*문서 끝*
