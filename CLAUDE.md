# AI Chef 프로젝트 - Claude Code 지침

## 프로젝트 개요

AI Chef는 스마트 재료 관리 & 맞춤형 레시피 추천 앱입니다. Google Gemini API를 활용하여 개인화된 AI 셰프 경험을 제공합니다.

### 기술 스택
- **웹**: Next.js 16, React 19, TypeScript, Tailwind CSS 4, shadcn/ui
- **모바일**: Flutter 3.10+, Riverpod, Go Router
- **백엔드**: Supabase (PostgreSQL, 인증, RLS)
- **AI**: Google Gemini 2.5 Flash/Pro
- **배포**: Google Cloud Run

### 프로젝트 구조
```
ai-chef/
├── app/              # Next.js 웹 애플리케이션
│   └── src/
│       ├── app/      # App Router (pages, API routes)
│       ├── components/  # UI 컴포넌트 (shadcn/ui)
│       └── lib/      # 유틸리티, Gemini 클라이언트
├── mobile/           # Flutter 모바일 앱
│   └── lib/
│       ├── models/   # 데이터 모델
│       ├── screens/  # 화면 컴포넌트
│       └── services/ # 비즈니스 로직
└── docs/             # 문서 (PRD, 스키마, 비용 추정)
```

---

## 핵심 규칙

### 1. 코드 스타일
- **불변성(Immutability) 강제**: 객체/배열 직접 변경 금지, 스프레드 연산자 사용
- **파일 크기**: 200-400줄 권장, 최대 800줄
- **중첩 깊이**: 최대 4단계
- **console.log 금지**: 프로덕션 코드에서 디버그 문 제거

```typescript
// ❌ 잘못된 패턴
user.name = 'New Name'
items.push(newItem)

// ✅ 올바른 패턴
const updatedUser = { ...user, name: 'New Name' }
const updatedItems = [...items, newItem]
```

### 2. 타입 안전성
- 모든 함수에 명시적 타입 정의
- `any` 타입 사용 금지, 필요시 `unknown` 사용
- Zod로 런타임 입력 검증

```typescript
import { z } from 'zod'

const IngredientSchema = z.object({
  name: z.string().min(1).max(100),
  quantity: z.number().positive(),
  unit: z.string(),
  expiryDate: z.string().datetime().optional()
})
```

### 3. 에러 처리
- try-catch로 모든 비동기 작업 래핑
- 사용자 친화적 에러 메시지 제공
- 에러 로깅 필수

```typescript
try {
  const result = await geminiService.generateRecipe(ingredients)
  return { success: true, data: result }
} catch (error) {
  console.error('Recipe generation failed:', error)
  return { success: false, error: '레시피 생성에 실패했습니다.' }
}
```

### 4. API 응답 형식
```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total?: number
    page?: number
    limit?: number
  }
}
```

---

## 테스팅 규칙

### TDD 워크플로우 (필수)
1. **RED**: 실패하는 테스트 작성
2. **GREEN**: 최소한의 코드로 테스트 통과
3. **REFACTOR**: 코드 개선 (테스트 유지)

### 커버리지 요구사항
- **목표**: 80% 이상
- **단위 테스트**: 모든 서비스 함수
- **통합 테스트**: API 라우트
- **E2E 테스트**: 핵심 사용자 흐름

### 테스트 파일 위치
```
app/src/
├── __tests__/
│   ├── unit/         # 단위 테스트
│   ├── integration/  # 통합 테스트
│   └── e2e/          # E2E 테스트 (Playwright)
```

---

## 보안 규칙 (CRITICAL)

### 절대 금지 항목
- 하드코딩된 API 키, 시크릿, 토큰
- 환경 변수를 클라이언트 코드에 노출
- SQL 인젝션 가능한 쿼리
- XSS 취약점이 있는 입력 처리

### 필수 검증
- 모든 사용자 입력 검증 (Zod)
- Supabase RLS 정책 검증
- CORS 설정 확인
- 인증/인가 검사

### 환경 변수
```env
# 서버 전용 (절대 클라이언트에 노출 금지)
GEMINI_API_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# 클라이언트 허용 (NEXT_PUBLIC_ 접두사)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

---

## AI 셰프 관련 규칙

### Gemini 모델 선택
| 용도 | 모델 | 비용 |
|------|------|------|
| 빠른 대화, 이미지 분석 | Gemini 2.5 Flash | $0.30 / $2.50 per 1M |
| 복잡한 레시피 생성 | Gemini 2.5 Pro | $1.25 / $10.00 per 1M |

### 시스템 프롬프트 규칙
1. AI 셰프 설정(이름, 성격, 전문 분야) 반영
2. 사용자 컨텍스트(재료, 도구) 자동 주입
3. 개인정보 보호 규칙 명시
4. 안전한 요리법만 제공

### JSON 응답 파싱
레시피 생성 시 반드시 구조화된 JSON 형식 사용:
```typescript
interface RecipeResponse {
  title: string
  description: string
  ingredients: IngredientStep[]
  instructions: CookingStep[]
  nutrition: Nutrition
  chefNote: string
}
```

---

## 사용 가능한 명령어

```
/plan            - 구현 계획 수립 (사용자 승인 필요)
/tdd             - TDD 워크플로우 실행
/code-review     - 코드 품질 및 보안 검토
/build-fix       - 빌드/타입 오류 수정
/e2e             - E2E 테스트 생성 및 실행
/test-coverage   - 테스트 커버리지 분석
/update-docs     - 문서 동기화
```

---

## Git 워크플로우

### 커밋 메시지 형식 (Conventional Commits)
```
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 수정
test: 테스트 추가/수정
chore: 빌드, 설정 변경
```

### 브랜치 전략
```
main              - 프로덕션 배포
develop           - 개발 통합
feature/*         - 새 기능
fix/*             - 버그 수정
```

### PR 생성 시
1. 모든 테스트 통과 확인
2. 코드 리뷰 완료
3. 보안 검토 완료
4. 문서 업데이트

---

## 성능 최적화

### Next.js
- Server Components 우선 사용
- 클라이언트 번들 최소화
- 이미지 최적화 (`next/image`)
- 동적 임포트 활용

### Flutter
- `cached_network_image` 사용
- 상태 관리 최적화 (Riverpod)
- 불필요한 리빌드 방지

### Supabase
- 인덱스 적절히 설정
- RLS 정책 최적화
- 쿼리 최소화

---

## 파일 수정 체크리스트

코드 작성/수정 후 반드시 확인:
- [ ] TypeScript 타입 오류 없음
- [ ] ESLint 경고/오류 없음
- [ ] 테스트 통과
- [ ] console.log 제거
- [ ] 하드코딩된 시크릿 없음
- [ ] 불변성 패턴 준수
- [ ] 에러 처리 완료
