# AI 셰프 (AI Chef)

> 스마트 재료 관리 & 맞춤형 레시피 추천 앱

나만의 AI 셰프와 함께 개인 취향에 맞는 건강하고 맛있는 식사를 낭비 없이 즐기세요.

---

## 프로젝트 개요

AI 셰프는 식재료 관리와 개인화된 레시피 추천을 결합한 요리 어시스턴트 앱입니다.

### 핵심 기능

- **나만의 AI 셰프**: 이름, 성격, 전문 분야를 커스터마이징한 개인 셰프
- **재료 관리**: 영수증 사진으로 자동 등록, 유통기한 알림
- **맞춤 레시피**: 보유 재료와 도구 기반 추천
- **시각적 가이드**: 사진 분석으로 실시간 요리 피드백
- **개인정보 보호**: 계정별 완전 격리된 메모리

---

## 문서 구조

```
ai-chef-project/
├── README.md                    # 프로젝트 개요 (현재 파일)
├── docs/
│   ├── PRD_v1.3.md             # 제품 요구사항 정의서
│   └── COST_ESTIMATION.md      # 비용 추정 문서
└── src/                         # (개발 시 추가)
```

---

## 기술 스택

### AI
| 용도 | 모델 | 비용 (1M tokens) |
|------|------|------------------|
| 레시피 생성 (최신) | Gemini 3 Pro | $2.00 / $12.00 |
| 레시피 생성 (안정) | Gemini 2.5 Pro | $1.25 / $10.00 |
| 빠른 대화 (최신) | Gemini 3 Flash | $0.50 / $3.00 |
| 빠른 대화 (안정) | Gemini 2.5 Flash | $0.30 / $2.50 |
| 영상 가이드 | Veo 3.1 | 별도 과금 |
| 온디바이스 | Gemini Nano | 무료 |

### 프론트엔드
- React 18+ / Next.js 14+
- Tailwind CSS + shadcn/ui
- Zustand + React Query

### 백엔드
- Node.js 20 LTS / Python 3.12
- Supabase (PostgreSQL)
- Google Cloud Run

---

## 개발 로드맵

| Phase | 기간 | 주요 내용 |
|-------|------|-----------|
| MVP | 5주 | 재료 관리, AI 셰프, 레시피 추천 |
| 확장 | 4주 | OCR, 음성 입력, 쇼핑 리스트 |
| 네이티브 | 6주 | React Native 앱 |

---

## 비용 추정 (Gemini 3 Batch 기준)

| 규모 | 월 비용 | 사용자당 |
|------|---------|----------|
| 100 MAU | $97 | $0.97 |
| 1,000 MAU | $454 | $0.45 |
| 5,000 MAU | $1,995 | $0.40 |

**모델 선택 권장:**
- MVP: Gemini 2.5 Batch ($351/월, $0.35/user)
- 프로덕션: Gemini 3 Batch ($454/월, $0.45/user)

> 상세 내용: [COST_ESTIMATION.md](docs/COST_ESTIMATION.md)

---

## 시작하기

### 사전 요구사항

- Node.js 20+
- pnpm (권장) 또는 npm
- Google Cloud 계정 (Gemini API)
- Supabase 계정

### 설치 (예정)

```bash
# 저장소 클론
git clone https://github.com/your-org/ai-chef.git
cd ai-chef

# 의존성 설치
pnpm install

# 환경 변수 설정
cp .env.example .env.local

# 개발 서버 실행
pnpm dev
```

---

## 환경 변수

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

---

## 라이선스

MIT License

---

## 연락처

- 프로젝트 문의: [이메일 주소]
- 버그 리포트: GitHub Issues
