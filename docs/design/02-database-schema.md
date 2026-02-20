# Supabase 데이터베이스 스키마

> RLS (Row Level Security)를 활용한 사용자 데이터 격리

## ERD 개요

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   users     │────<│  user_profiles  │────<│ cooking_tools    │
└─────────────┘     └─────────────────┘     └──────────────────┘
      │                     │
      │                     │
      ▼                     ▼
┌─────────────────┐   ┌─────────────────┐
│  ingredients    │   │  chef_settings  │
│  (냉장고 재료)   │   │  (셰프 설정)     │
└─────────────────┘   └─────────────────┘
      │       ▲
      │       │ (냉장고 이동)
      ▼       │
┌─────────────────┐   ┌─────────────────┐
│ recipe_history  │───│    recipes      │
│  (요리 기록)     │   │  (생성된 레시피) │
└─────────────────┘   └─────────────────┘
                            │
                            │ (부족 재료 담기)
                            ▼
                      ┌─────────────────┐
                      │ shopping_items  │
                      │  (쇼핑 리스트)   │
                      └─────────────────┘
```

---

## 테이블 스키마

### 1. user_profiles (사용자 프로필)

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT,
  skill_level TEXT CHECK (skill_level IN ('beginner', 'novice', 'intermediate', 'advanced')),
  household_size INTEGER DEFAULT 1,
  has_children BOOLEAN DEFAULT FALSE,
  children_ages INTEGER[],
  time_preference TEXT CHECK (time_preference IN ('10min', '20min', '40min', 'unlimited')),
  budget_preference TEXT CHECK (budget_preference IN ('low', 'medium', 'high', 'unlimited')),
  scenarios TEXT[],
  dietary_restrictions TEXT[],
  disliked_ingredients TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. cooking_tools (조리 도구)

```sql
CREATE TABLE cooking_tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tool_name TEXT NOT NULL,
  tool_key TEXT NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, tool_key)
);
```

### 3. ingredients (냉장고 재료) ⭐ 핵심 테이블

```sql
CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT CHECK (category IN (
    'vegetable', 'fruit', 'meat', 'seafood',
    'dairy', 'egg', 'grain', 'seasoning', 'other'
  )),
  quantity DECIMAL,
  unit TEXT,
  expiry_date DATE,
  location TEXT CHECK (location IN ('fridge', 'freezer', 'pantry')) DEFAULT 'fridge',
  is_staple BOOLEAN DEFAULT FALSE,
  memo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_ingredients_user_expiry ON ingredients(user_id, expiry_date);
CREATE INDEX idx_ingredients_user_category ON ingredients(user_id, category);
```

### 4. chef_settings (셰프 설정)

```sql
CREATE TABLE chef_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  primary_chef_id TEXT NOT NULL DEFAULT 'baek',
  favorite_chef_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5. recipes (생성된 레시피)

```sql
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  chef_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  ingredients JSONB NOT NULL,
  instructions JSONB NOT NULL,
  nutrition JSONB,
  cooking_time INTEGER,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  servings INTEGER DEFAULT 1,
  tags TEXT[],
  chef_note TEXT,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 6. shopping_items (쇼핑 리스트)

```sql
CREATE TABLE shopping_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT CHECK (category IN (
    'vegetable','fruit','meat','seafood','dairy','egg','grain','seasoning','other'
  )) DEFAULT 'other',
  quantity DECIMAL DEFAULT 1,
  unit TEXT DEFAULT '개',
  is_checked BOOLEAN DEFAULT FALSE,
  source TEXT CHECK (source IN ('manual','recipe')) DEFAULT 'manual',
  recipe_title TEXT,
  memo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_shopping_items_user ON shopping_items(user_id);
CREATE INDEX idx_shopping_items_user_checked ON shopping_items(user_id, is_checked);
```

### 7. recipe_history (요리 기록)

```sql
CREATE TABLE recipe_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  recipe_title TEXT NOT NULL,
  chef_id TEXT NOT NULL,
  cooked_at TIMESTAMPTZ DEFAULT NOW(),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  memo TEXT
);
```

---

## RLS (Row Level Security) 정책

### RLS 활성화

```sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cooking_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE chef_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_history ENABLE ROW LEVEL SECURITY;
```

### 정책 정의

```sql
-- user_profiles
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- cooking_tools
CREATE POLICY "Users can manage own tools"
  ON cooking_tools FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ingredients (냉장고 재료)
CREATE POLICY "Users can manage own ingredients"
  ON ingredients FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- chef_settings
CREATE POLICY "Users can manage own chef settings"
  ON chef_settings FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- shopping_items (쇼핑 리스트)
CREATE POLICY "Users can manage own shopping items"
  ON shopping_items FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- recipes
CREATE POLICY "Users can manage own recipes"
  ON recipes FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- recipe_history
CREATE POLICY "Users can manage own history"
  ON recipe_history FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

---

## 유틸리티 함수

### 유통기한 임박 재료 조회

```sql
CREATE OR REPLACE FUNCTION get_expiring_ingredients(days_ahead INTEGER DEFAULT 3)
RETURNS SETOF ingredients AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM ingredients
  WHERE user_id = auth.uid()
    AND expiry_date IS NOT NULL
    AND expiry_date <= CURRENT_DATE + days_ahead
    AND expiry_date >= CURRENT_DATE
  ORDER BY expiry_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 카테고리별 재료 개수

```sql
CREATE OR REPLACE FUNCTION get_ingredient_counts()
RETURNS TABLE(category TEXT, count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT i.category, COUNT(*)
  FROM ingredients i
  WHERE i.user_id = auth.uid()
  GROUP BY i.category;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### updated_at 자동 갱신 트리거

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_ingredients_updated_at
  BEFORE UPDATE ON ingredients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_chef_settings_updated_at
  BEFORE UPDATE ON chef_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_shopping_items_updated_at
  BEFORE UPDATE ON shopping_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 보안 아키텍처

```
┌─────────────────────────────────────────┐
│           보안 레이어                    │
├─────────────────────────────────────────┤
│                                         │
│  1. 인증: Supabase Auth                 │
│     • 이메일/비밀번호                    │
│     • 소셜 로그인 (Google, Apple)        │
│                                         │
│  2. 데이터 격리: RLS                     │
│     • 모든 테이블에 RLS 활성화           │
│     • auth.uid() = user_id 조건         │
│     • 다른 유저 데이터 접근 불가          │
│                                         │
│  3. API 키 관리                         │
│     • anon key: 클라이언트용 (제한적)    │
│     • service_role: 서버용 (절대 노출X)  │
│                                         │
│  4. 민감 정보 처리                       │
│     • 비밀번호: Supabase 자동 해시       │
│     • API 키: 환경변수로만 관리          │
│                                         │
└─────────────────────────────────────────┘
```
