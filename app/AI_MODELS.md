# AI 셰프 - 사용 모델 가이드

> 이 문서는 개발 시 반드시 참조해야 합니다.
> 최종 업데이트: 2026-01-17

---

## 사용 가능한 Gemini 모델 ID

### 권장 모델 (본 프로젝트에서 사용)

| 용도 | 모델 ID | 상태 | 비고 |
|------|---------|------|------|
| **빠른 대화/이미지 분석** | `gemini-2.5-flash` | Stable | 가성비 최고, 기본 모델 |
| **복잡한 레시피 생성** | `gemini-2.5-pro` | Stable | 복잡한 추론, 창의적 레시피 |

### 대안 모델 (필요시 사용)

| 용도 | 모델 ID | 상태 | 비고 |
|------|---------|------|------|
| 최신 대화 | `gemini-3-flash-preview` | Preview | 최신 기능, 불안정 가능 |
| 최신 추론 | `gemini-3-pro-preview` | Preview | 최신 기능, 불안정 가능 |
| 경량화 | `gemini-2.5-flash-lite` | Stable | 가장 빠름, 기능 제한 |

---

## 모델 선택 기준

```
사용자 요청
    │
    ├─ 간단한 질문/대화 ────────> gemini-2.5-flash
    │   "파스타 삶는 시간?"
    │
    ├─ 이미지 분석 ─────────────> gemini-2.5-flash
    │   "이 정도로 썰었는데 맞아?" + 사진
    │
    ├─ 레시피 생성 ─────────────> gemini-2.5-pro
    │   "냉장고 재료로 저녁 추천해줘"
    │
    └─ 복잡한 추론 ─────────────> gemini-2.5-pro
        대체 재료 분석, 영양 계산
```

---

## 코드에서 모델 사용 예시

```typescript
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

// 빠른 대화용 (Flash)
const flashModel = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
});

// 복잡한 추론용 (Pro)
const proModel = genAI.getGenerativeModel({
  model: "gemini-2.5-pro",
});
```

---

## 주의사항

1. **모델 ID는 정확히 입력**: `gemini-2.5-flash` (O) / `gemini-2.5` (X)
2. **Preview 모델은 프로덕션 주의**: 2주 전 사전 통지 후 변경될 수 있음
3. **Stable 모델 우선 사용**: 안정성이 중요한 경우
4. **무료 티어 제한**: `gemini-2.5-pro`는 무료 티어에서 할당량이 0입니다. 유료 플랜 필요.

---

## 무료 티어 vs 유료 플랜

| 모델 | 무료 티어 | 유료 플랜 |
|------|-----------|-----------|
| gemini-2.5-flash | ✅ 사용 가능 | ✅ 사용 가능 |
| gemini-2.5-pro | ❌ 할당량 0 | ✅ 사용 가능 |

> **현재 설정**: Tier 1 (유료 플랜) 사용 중
> - 채팅: `gemini-2.5-flash` (빠른 응답)
> - 레시피 생성: `gemini-2.5-pro` (복잡한 추론)

---

## 가격 (2026년 1월 기준)

| 모델 | Input (1M tokens) | Output (1M tokens) |
|------|-------------------|---------------------|
| gemini-2.5-flash | $0.30 | $2.50 |
| gemini-2.5-pro | $1.25 | $10.00 |
| gemini-3-flash-preview | $0.50 | $3.00 |
| gemini-3-pro-preview | $2.00 | $12.00 |
