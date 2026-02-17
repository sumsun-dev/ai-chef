# AI Chef

> Smart ingredient management & personalized recipe recommendation app

AI Chef는 식재료 관리와 개인화된 레시피 추천을 결합한 요리 어시스턴트 앱입니다. Google Gemini API를 활용하여 나만의 AI 셰프 경험을 제공합니다.

---

## 핵심 기능

- **나만의 AI 셰프** - 이름, 성격, 전문 분야를 커스터마이징한 개인 셰프
- **재료 관리** - 영수증 OCR 자동 등록, 유통기한 알림, 보관위치별 분류
- **맞춤 레시피** - 보유 재료와 도구 기반 AI 레시피 추천
- **시각적 가이드** - 사진 분석으로 실시간 요리 피드백

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
│       ├── app/            # App Router (pages, API routes)
│       │   └── api/        # chat, recipe API endpoints
│       ├── components/     # UI components (shadcn/ui)
│       └── lib/            # Gemini client, utilities
├── mobile/                 # Flutter 모바일 앱
│   ├── lib/
│   │   ├── models/         # Ingredient, Recipe, Chef 등 데이터 모델
│   │   ├── screens/        # 화면 (Home, Refrigerator, Recipe, Profile)
│   │   │   └── tabs/       # Bottom navigation 탭 화면
│   │   └── services/       # Supabase CRUD, Gemini, OCR, 알림 서비스
│   └── test/               # 단위 테스트
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
```

---

## 개발 명령어

### Web (Next.js)
```bash
pnpm dev              # 개발 서버 (port 3000)
pnpm build            # 프로덕션 빌드
pnpm lint             # ESLint
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
| `cooking_history` | 조리 이력 |
| `chat_sessions` | AI 셰프 채팅 세션 |
| `chat_messages` | 채팅 메시지 |

---

## AI 모델 비용

| 용도 | 모델 | Input / Output (1M tokens) |
|------|------|---------------------------|
| 빠른 대화, 이미지 분석 | Gemini 2.5 Flash | $0.30 / $2.50 |
| 레시피 생성 | Gemini 2.5 Pro | $1.25 / $10.00 |

---

## 라이선스

MIT License
