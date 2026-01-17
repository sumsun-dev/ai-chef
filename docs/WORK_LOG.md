# AI Chef 개발 작업 로그

## 2026-01-17 작업 내용

### 완료된 작업

#### 1. Supabase 설정
- **Supabase 프로젝트 생성**: `aichef`
- **데이터베이스 스키마 설계 및 적용**
  - `user_profiles` - 사용자 프로필 + AI 셰프 설정
  - `ingredients` - 보유 재료
  - `cooking_tools` - 요리 도구
  - `recipes` - 저장된 레시피
  - `cooking_history` - 조리 이력
  - `chat_sessions` - AI 대화 세션
  - `chat_messages` - 채팅 메시지
  - `audit_logs` - 보안 감사 로그
- **Row Level Security (RLS) 정책 적용**
- **파일**: `docs/supabase-schema.sql`

#### 2. Google OAuth 인증 설정
- **Google Cloud Console 설정**
  - Web OAuth 클라이언트 생성
  - Android OAuth 클라이언트 생성 (SHA-1 지문 등록)
- **Supabase Google Provider 설정**
  - Skip nonce checks 활성화 (모바일 네이티브 로그인용)

#### 3. Gemini 모델 업데이트
- `gemini-2.5-flash` → `gemini-3.0-flash`
- `gemini-2.5-pro` → `gemini-3.0-pro`
- **수정 파일**:
  - `app/src/lib/gemini.ts`
  - `mobile/lib/services/gemini_service.dart`

#### 4. Flutter 모바일 앱 구조 구현
- **main.dart**: Supabase 초기화, Riverpod 설정
- **app.dart**: GoRouter 라우팅, 테마 설정
- **screens/**:
  - `login_screen.dart` - Google 로그인 UI
  - `home_screen.dart` - 메인 대시보드
  - `onboarding_screen.dart` - AI 셰프 초기 설정
- **services/**:
  - `auth_service.dart` - Google 로그인 + Supabase 인증
  - `gemini_service.dart` - Gemini API 연동

#### 5. GitHub 저장소 연동
- 저장소: https://github.com/sosecrypto/ai-chef
- `.gitignore` 설정 (Node.js + Flutter)

---

### 발생한 이슈 및 해결

#### 이슈 1: Android Studio 설치 오류
- **증상**: NSIS Error - "Installer integrity check has failed"
- **원인**: 설치 파일 손상 또는 다운로드 오류
- **해결**: 설치 파일 재다운로드

#### 이슈 2: Google Sign-In clientId 경고
- **증상**: `clientId is not supported on Android and is interpreted as serverClientId`
- **원인**: Android에서는 `clientId` 대신 `serverClientId` 사용 필요
- **해결**: `auth_service.dart`에서 `serverClientId`로 변경
```dart
// 변경 전
GoogleSignIn(clientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'])

// 변경 후
GoogleSignIn(serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'])
```

#### 이슈 3: AuthRetryableFetchException (진행 중)
- **증상**: `{"code":"unexpected_failure","message":"Database error saving new user"}`, statusCode: 500
- **원인**: Supabase 트리거에서 새 사용자 프로필 생성 실패
- **분석된 원인들**:
  1. `email NOT NULL` 제약 조건
  2. 트리거 함수 오류 처리 미흡
  3. RLS INSERT 정책 누락
- **해결 스크립트**: `docs/supabase-debug-fix.sql`
- **수정 내용**:
  - email 컬럼 NULL 허용으로 변경
  - 트리거 함수에 예외 처리 추가
  - `ON CONFLICT DO UPDATE` 처리
  - RLS INSERT 정책 추가

---

### 환경 설정 파일

#### mobile/.env
```
GEMINI_API_KEY=<API_KEY>
SUPABASE_URL=https://fsjvkceaiozmlgknyozl.supabase.co
SUPABASE_ANON_KEY=<ANON_KEY>
GOOGLE_WEB_CLIENT_ID=940036707925-jrqhqq6v4eb1jehlck7b0oogauitf8nm.apps.googleusercontent.com
```

#### app/.env.local
```
GEMINI_API_KEY=<API_KEY>
NEXT_PUBLIC_SUPABASE_URL=https://fsjvkceaiozmlgknyozl.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<ANON_KEY>
SUPABASE_SERVICE_ROLE_KEY=<SERVICE_ROLE_KEY>
```

---

### 다음 작업 예정

1. **Supabase 트리거 오류 해결 완료** - `supabase-debug-fix.sql` 실행 후 테스트
2. **로그인 플로우 테스트** - Google 로그인 → 온보딩 → 홈 화면
3. **채팅 화면 구현** - AI 셰프와 대화 기능
4. **재료 관리 화면 구현** - CRUD 기능

---

### 프로젝트 구조

```
ai-chef-project/
├── app/                          # Next.js 웹앱
│   ├── src/
│   │   ├── app/
│   │   │   ├── api/chat/         # 채팅 API
│   │   │   └── api/recipe/       # 레시피 API
│   │   ├── components/ui/        # shadcn/ui 컴포넌트
│   │   └── lib/
│   │       └── gemini.ts         # Gemini API 통합
│   └── .env.local
├── mobile/                       # Flutter 모바일앱
│   ├── lib/
│   │   ├── main.dart             # 앱 진입점
│   │   ├── app.dart              # 라우터 + 테마
│   │   ├── models/               # 데이터 모델
│   │   ├── screens/              # UI 화면
│   │   └── services/             # API 서비스
│   └── .env
├── docs/
│   ├── PRD_v1.3.md               # 제품 요구사항
│   ├── COST_ESTIMATION.md        # 비용 추정
│   ├── WORK_LOG.md               # 작업 로그 (이 파일)
│   ├── supabase-schema.sql       # DB 스키마
│   └── supabase-debug-fix.sql    # DB 오류 수정
└── README.md
```

---

*마지막 업데이트: 2026-01-17*
