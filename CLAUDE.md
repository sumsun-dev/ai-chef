# AI Chef - Project Guidelines

## Overview

Smart ingredient management & personalized recipe recommendation app. Uses Google Gemini API to deliver a personalized AI chef experience.

### Tech Stack
- **Web**: Next.js 16, React 19, TypeScript, Tailwind CSS 4, shadcn/ui
- **Mobile**: Flutter 3.10+, Riverpod, Go Router
- **Backend**: Supabase (PostgreSQL, Auth, RLS)
- **AI**: Google Gemini 2.5 Flash/Pro
- **Deploy**: Google Cloud Run

### Project Structure
```
ai-chef/
├── app/              # Next.js web application
│   └── src/
│       ├── app/      # App Router (pages, API routes)
│       ├── components/  # UI components (shadcn/ui)
│       └── lib/      # Utilities, Gemini client
├── mobile/           # Flutter mobile app
│   └── lib/
│       ├── models/   # Data models
│       ├── screens/  # Screen components
│       └── services/ # Business logic
└── docs/             # Docs (PRD, schema, cost estimation)
```

## Type Safety
- Explicit types on all functions
- No `any` type, use `unknown` when needed
- Validate runtime inputs with Zod

## API Response Format
```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: { total?: number; page?: number; limit?: number }
}
```

## Gemini Model Selection
| Use Case | Model | Cost |
|----------|-------|------|
| Fast conversation, image analysis | Gemini 3.0 Flash | $0.30 / $2.50 per 1M |
| Complex recipe generation | Gemini 3.0 Pro | $1.25 / $10.00 per 1M |

## AI Chef Rules
1. Reflect AI chef settings (name, personality, expertise)
2. Auto-inject user context (ingredients, tools)
3. Enforce privacy rules
4. Only provide safe cooking instructions

## Recipe Response Format
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

## Environment Variables
```env
# Server only (never expose to client)
GEMINI_API_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Client allowed (NEXT_PUBLIC_ prefix)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

## Commands (Allowed)

### Web
```bash
pnpm dev              # Dev server (port 3000)
pnpm build            # Production build
pnpm lint             # ESLint
pnpm test             # Run tests
pnpm remotion:studio  # Remotion video editor
pnpm remotion:render  # Render intro video
```

### Mobile
```bash
flutter run           # Run on device/emulator
flutter build apk     # Android build
flutter build ios     # iOS build
flutter test          # Run tests
```

## Performance
### Next.js
- Server Components first
- Minimize client bundle
- Image optimization (next/image)
- Dynamic imports

### Flutter
- Use cached_network_image
- Optimize state with Riverpod
- Prevent unnecessary rebuilds

### Supabase
- Proper indexing
- Optimize RLS policies
- Minimize queries
