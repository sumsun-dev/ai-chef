# AI Chef Mobile

Flutter 기반 AI 요리 셰프 모바일 앱.

## 실행 방법

```bash
# 환경변수를 --dart-define으로 전달
flutter run \
  --dart-define=GEMINI_API_KEY=xxx \
  --dart-define=SUPABASE_URL=xxx \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxx

# 테스트
flutter test

# 정적 분석
flutter analyze
```

## 주요 기능

- Google 로그인 + Supabase 인증
- AI 셰프 (Gemini Flash/Pro) 채팅 및 레시피 생성
- 냉장고 재료 관리 + 유통기한 알림
- 영수증 OCR 자동 재료 등록
- 프로필/요리 설정/조리 도구 관리

## 디자인 시스템

`lib/theme/` 디렉토리에 디자인 토큰이 중앙 관리됩니다:

| 파일 | 역할 |
|------|------|
| `app_colors.dart` | 브랜드/시맨틱/유통기한/다크모드 색상 팔레트 |
| `app_typography.dart` | Display/Heading/Body/Label 4단계 텍스트 스타일 |
| `app_spacing.dart` | 간격(xs~xxxl) 및 라운딩(sm~full) 스케일 |
| `app_theme.dart` | Light/Dark ThemeData + 컴포넌트 테마 |

## 공통 컴포넌트

`lib/components/` 디렉토리에 재사용 가능한 위젯이 추출되어 있습니다:

| 파일 | 역할 |
|------|------|
| `chef_greeting_card.dart` | 셰프 인사 카드 (그라디언트 배경) |
| `recipe_card.dart` | 레시피 카드 (홈/레시피 탭 공용) |
| `expiry_badge.dart` | 유통기한 D-Day 뱃지 + 색상 유틸 |
| `category_emoji.dart` | 카테고리 → 이모지 매핑 |
| `section_header.dart` | 섹션 제목 (이모지 + 텍스트 + 액션) |
| `quick_action_card.dart` | 홈 퀵 액션 카드 |
| `empty_state.dart` | 빈 상태 일러스트레이션 |

## 프로젝트 구조

```
lib/
├── components/     # 공통 UI 컴포넌트
├── constants/      # 앱 상수
├── models/         # 데이터 모델
├── screens/        # 화면
│   ├── tabs/       # 4탭 (홈/레시피/냉장고/프로필)
│   ├── onboarding/ # 3단계 온보딩
│   └── profile/    # 프로필 관리
├── services/       # 비즈니스 로직
└── theme/          # 디자인 토큰
```
