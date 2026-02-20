# AI Chef

> Smart ingredient management & personalized recipe recommendation app

AI Chef는 식재료 관리와 개인화된 레시피 추천을 결합한 요리 어시스턴트 앱입니다. Google Gemini API를 활용하여 나만의 AI 셰프 경험을 제공합니다.

---

## 핵심 기능

- **나만의 AI 셰프** - 이름, 성격, 전문 분야를 커스터마이징한 개인 셰프
- **멀티스텝 온보딩** - 환영 → 셰프 선택 → 실력 → 시나리오 → 도구 → 선호 → 냉장고 → 완료
- **재료 관리** - 영수증 OCR 자동 등록, 유통기한 알림, 검색/카테고리 필터/정렬
- **쇼핑 리스트** - 레시피 부족 재료 자동 담기, 카테고리 그룹핑, 구매 완료 시 냉장고 자동 추가
- **맞춤 레시피** - 보유 재료와 도구 기반 AI 레시피 추천, 저장/북마크
- **빠른 액션** - 혼밥/급해요/재료정리 원탭 필터로 상황별 레시피 즉시 추천
- **요리 시작 모드** - 단계별 PageView, 카운트다운 타이머, 화면 꺼짐 방지, 완료 시 기록 자동 저장
- **AI 채팅 + 레시피 변환** - 셰프와 실시간 대화, 응답에서 레시피 패턴 감지 시 구조화된 레시피로 변환/저장
- **음성 명령 (핸즈프리)** - 조리 모드에서 "다음", "이전", "타이머 시작" 등 한국어 음성 명령으로 핸즈프리 조작
- **TTS 단계 읽기** - 조리 단계를 한국어 음성으로 자동 읽기, 토글 ON/OFF
- **Function Calling** - Gemini Function Calling으로 재료 조회, 레시피 생성, 북마크 등 자연어 명령 실행
- **스마트 추천** - 유통기한 임박 재료 + 시간대별 맞춤 인사 기반 AI 레시피 추천 알림
- **오디오/진동 피드백** - 타이머 완료 시 효과음 + 진동으로 알림
- **프로필 관리** - 셰프 변경, 조리 도구 관리, 요리 설정 편집
- **요리 통계** - 총 요리 횟수, 연속 요리, 자주 만든 레시피, 요일별 패턴 대시보드
- **레시피 공유** - share_plus 활용 텍스트 공유 (재료/조리법/영양 정보 포함)
- **시각적 가이드** - 사진 분석으로 실시간 요리 피드백
- **알림 설정** - 유통기한 알림 스케줄/해제, SharedPreferences 영구 저장
- **웹 AI 채팅** - 8가지 셰프 프리셋으로 웹에서 실시간 AI 대화
- **웹 레시피 생성** - 재료/도구/선호도 입력으로 웹에서 맞춤 레시피 생성

---

## 기술 스택

### Mobile (Flutter)
| 구분 | 기술 |
|------|------|
| Framework | Flutter 3.10+, Dart 3.10+ |
| State Management | Riverpod 3 |
| Navigation | Go Router 17 |
| Backend SDK | Supabase Flutter 2.12 |
| AI | Google Generative AI 0.4 |
| Camera | Image Picker |
| Notifications | Flutter Local Notifications 19 |
| Wakelock | Wakelock Plus |
| Persistence | SharedPreferences |
| TTS | Flutter TTS 4 |
| 음성 인식 | Speech to Text 7 |
| 오디오 | Audioplayers 6 |
| 진동 | Vibration 2 |
| 공유 | Share Plus 10 |

### Web (Next.js)
| 구분 | 기술 |
|------|------|
| Framework | Next.js 16, React 19 |
| Styling | Tailwind CSS 4, shadcn/ui |
| State | Zustand 5 |
| Backend SDK | Supabase SSR 0.8 |
| AI | Google Generative AI 0.24 |
| Animation | Framer Motion 12 |

### Backend
| 구분 | 기술 |
|------|------|
| Database | Supabase (PostgreSQL + RLS) |
| Auth | Supabase Auth + Google Sign-In |
| AI Model | Gemini 2.5 Flash / Pro |
| Deploy | Google Cloud Run |

---

## 프로젝트 구조

```
ai-chef/
├── app/                    # Next.js 16 웹 앱
│   └── src/
│       ├── app/
│       │   ├── (landing)/  # 랜딩 페이지 (/)
│       │   ├── (app)/      # 앱 기능 페이지
│       │   │   ├── chat/   # AI 채팅 (/chat)
│       │   │   └── recipe/ # 레시피 생성 (/recipe)
│       │   └── api/        # chat, recipe API endpoints
│       ├── components/     # UI components (shadcn/ui)
│       │   ├── ui/         # shadcn/ui 기본 컴포넌트
│       │   ├── intro/      # WelcomeModal, IntroVideoPlayer
│       │   └── landing/    # 랜딩 페이지 컴포넌트
│       ├── hooks/          # useFirstVisit 등
│       └── lib/            # Gemini client, Zustand stores, utilities
│           ├── stores/     # chat-store, recipe-store
│           └── __tests__/  # Vitest 단위 테스트 (54개)
├── mobile/                 # Flutter 모바일 앱
│   ├── lib/
│   │   ├── components/     # 공통 UI 컴포넌트 (ChefGreetingCard, RecipeCard, CookingTimer 등)
│   │   ├── constants/      # 재료 카테고리, 기본값 상수
│   │   ├── models/         # Ingredient, Recipe, Chef, ChatMessage, RecipeQuickFilter 등
│   │   ├── screens/        # 화면 (Home, Refrigerator, Recipe, CookingMode, Chat 등)
│   │   │   ├── tabs/       # Bottom navigation 탭 화면
│   │   │   ├── onboarding/ # 멀티스텝 온보딩 (환영→셰프→실력→시나리오→도구→선호→냉장고→완료)
│   │   │   ├── profile/    # 프로필 관리 (셰프/도구/설정/통계)
│   │   │   └── settings/   # 설정 (알림, 개인정보, 도움말)
│   │   ├── services/       # Supabase CRUD, Gemini, Chat, Recipe, Notification, TTS, Voice, Audio, Sharing 서비스
│   │   └── theme/          # 디자인 토큰 (AppColors, AppTypography, AppSpacing, AppTheme)
│   └── test/               # 위젯/단위 테스트 (517개)
├── supabase/
│   └── migrations/         # DB 마이그레이션 (source of truth)
├── docs/                   # PRD, 비용 추정, 설계 문서
└── CLAUDE.md               # Claude Code 프로젝트 가이드라인
```

---

## 시작하기

### 사전 요구사항

- Flutter 3.10+ & Dart 3.10+
- Node.js 20+ & pnpm
- Google Cloud 계정 (Gemini API)
- Supabase 계정

### 설치

```bash
# 저장소 클론
git clone https://github.com/your-org/ai-chef.git
cd ai-chef

# Web 앱 의존성 설치
cd app && pnpm install && cd ..

# Mobile 앱 의존성 설치
cd mobile && flutter pub get && cd ..

# 환경 변수 설정
# app/.env.local (Web)
# mobile/.env (Flutter)
```

### 환경 변수

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Google Gemini
GEMINI_API_KEY=your_gemini_api_key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 실행

```bash
# Web 개발 서버
cd app && pnpm dev

# Mobile (에뮬레이터/디바이스)
cd mobile && flutter run

# 테스트
cd mobile && flutter test

# Web 테스트
cd app && pnpm test
```

---

## 개발 명령어

### Web (Next.js)
```bash
pnpm dev              # 개발 서버 (port 3000)
pnpm build            # 프로덕션 빌드
pnpm lint             # ESLint
pnpm test             # Vitest 단위 테스트
pnpm remotion:studio  # Remotion 영상 편집기
pnpm remotion:render  # 인트로 영상 렌더링
```

### Mobile (Flutter)
```bash
flutter run           # 디바이스/에뮬레이터 실행
flutter test          # 단위 테스트
flutter analyze       # 정적 분석
flutter build apk     # Android 빌드
flutter build ios     # iOS 빌드
```

---

## DB 스키마

Source of truth: `supabase/migrations/`

| 테이블 | 설명 |
|--------|------|
| `user_profiles` | 사용자 프로필 + AI 셰프 설정 |
| `ingredients` | 재료 (location: fridge/freezer/pantry) |
| `cooking_tools` | 요리 도구 |
| `recipes` | AI 생성 레시피 |
| `recipe_history` | 요리 기록 (통계용) |
| `shopping_items` | 쇼핑 리스트 (source: manual/recipe) |
| `chat_sessions` | AI 셰프 채팅 세션 |
| `chat_messages` | 채팅 메시지 |

---

## AI 모델 비용

| 용도 | 모델 | Input / Output (1M tokens) |
|------|------|---------------------------|
| 빠른 대화, 이미지 분석 | Gemini 2.5 Flash | $0.15 / $0.60 |
| 레시피 생성 | Gemini 2.5 Pro | $1.25 / $10.00 |

---

## 라이선스

MIT License
