-- =============================================
-- AI Chef 데이터베이스 스키마
-- 버전: 1.0
-- 설명: 흑백요리사 스타일 AI 셰프 앱
-- =============================================

-- =============================================
-- 1. user_profiles (사용자 프로필)
-- =============================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT,
  skill_level TEXT CHECK (skill_level IN ('beginner', 'novice', 'intermediate', 'advanced')) DEFAULT 'beginner',
  household_size INTEGER DEFAULT 1,
  has_children BOOLEAN DEFAULT FALSE,
  children_ages INTEGER[],
  time_preference TEXT CHECK (time_preference IN ('10min', '20min', '40min', 'unlimited')) DEFAULT '20min',
  budget_preference TEXT CHECK (budget_preference IN ('low', 'medium', 'high', 'unlimited')) DEFAULT 'medium',
  scenarios TEXT[] DEFAULT '{}',
  dietary_restrictions TEXT[] DEFAULT '{}',
  disliked_ingredients TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 2. cooking_tools (조리 도구)
-- =============================================
CREATE TABLE IF NOT EXISTS cooking_tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tool_key TEXT NOT NULL,
  tool_name TEXT NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, tool_key)
);

-- =============================================
-- 3. ingredients (냉장고 재료)
-- =============================================
CREATE TABLE IF NOT EXISTS ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT CHECK (category IN (
    'vegetable', 'fruit', 'meat', 'seafood',
    'dairy', 'egg', 'grain', 'seasoning', 'other'
  )) DEFAULT 'other',
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
CREATE INDEX IF NOT EXISTS idx_ingredients_user_expiry ON ingredients(user_id, expiry_date);
CREATE INDEX IF NOT EXISTS idx_ingredients_user_category ON ingredients(user_id, category);
CREATE INDEX IF NOT EXISTS idx_ingredients_user_location ON ingredients(user_id, location);

-- =============================================
-- 4. chef_settings (셰프 설정)
-- =============================================
CREATE TABLE IF NOT EXISTS chef_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  primary_chef_id TEXT NOT NULL DEFAULT 'baek',
  favorite_chef_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 5. recipes (생성된 레시피)
-- =============================================
CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  chef_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  ingredients JSONB NOT NULL DEFAULT '[]',
  instructions JSONB NOT NULL DEFAULT '[]',
  nutrition JSONB,
  cooking_time INTEGER,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'easy',
  servings INTEGER DEFAULT 1,
  tags TEXT[] DEFAULT '{}',
  chef_note TEXT,
  image_url TEXT,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipes_user ON recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_bookmarked ON recipes(user_id, is_bookmarked);

-- =============================================
-- 6. recipe_history (요리 기록)
-- =============================================
CREATE TABLE IF NOT EXISTS recipe_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  recipe_title TEXT NOT NULL,
  chef_id TEXT NOT NULL,
  cooked_at TIMESTAMPTZ DEFAULT NOW(),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  memo TEXT
);

CREATE INDEX IF NOT EXISTS idx_recipe_history_user ON recipe_history(user_id, cooked_at DESC);

-- =============================================
-- 7. chat_messages (채팅 기록)
-- =============================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  chef_id TEXT NOT NULL,
  role TEXT CHECK (role IN ('user', 'assistant')) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_user ON chat_messages(user_id, created_at DESC);

-- =============================================
-- RLS (Row Level Security) 활성화
-- =============================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cooking_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE chef_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS 정책: user_profiles
-- =============================================
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- =============================================
-- RLS 정책: cooking_tools
-- =============================================
CREATE POLICY "Users can manage own tools"
  ON cooking_tools FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS 정책: ingredients
-- =============================================
CREATE POLICY "Users can manage own ingredients"
  ON ingredients FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS 정책: chef_settings
-- =============================================
CREATE POLICY "Users can manage own chef settings"
  ON chef_settings FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS 정책: recipes
-- =============================================
CREATE POLICY "Users can manage own recipes"
  ON recipes FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS 정책: recipe_history
-- =============================================
CREATE POLICY "Users can manage own history"
  ON recipe_history FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS 정책: chat_messages
-- =============================================
CREATE POLICY "Users can manage own messages"
  ON chat_messages FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- =============================================
-- 트리거: updated_at 자동 갱신
-- =============================================
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

-- =============================================
-- 함수: 유통기한 임박 재료 조회
-- =============================================
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

-- =============================================
-- 함수: 카테고리별 재료 개수
-- =============================================
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

-- =============================================
-- 함수: 새 사용자 프로필 자동 생성
-- =============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (id)
  VALUES (NEW.id);

  INSERT INTO chef_settings (user_id, primary_chef_id)
  VALUES (NEW.id, 'baek');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 새 사용자 등록 시 프로필 자동 생성 트리거
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =============================================
-- 기본 조리 도구 삽입 함수
-- =============================================
CREATE OR REPLACE FUNCTION insert_default_cooking_tools(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO cooking_tools (user_id, tool_key, tool_name, is_available) VALUES
    (p_user_id, 'frying_pan', '프라이팬', true),
    (p_user_id, 'pot', '냄비', true),
    (p_user_id, 'stove', '가스레인지/인덕션', true),
    (p_user_id, 'microwave', '전자레인지', true),
    (p_user_id, 'rice_cooker', '전기밥솥', true),
    (p_user_id, 'air_fryer', '에어프라이어', false),
    (p_user_id, 'oven', '오븐', false),
    (p_user_id, 'blender', '블렌더/믹서기', false)
  ON CONFLICT (user_id, tool_key) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
