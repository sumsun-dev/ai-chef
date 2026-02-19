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
