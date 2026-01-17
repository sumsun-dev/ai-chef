-- =====================================================
-- AI Chef - Supabase Database Schema
-- Version: 1.0
-- Date: 2026-01-17
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USER PROFILES (사용자 프로필)
-- Supabase Auth와 연동되는 확장 프로필
-- =====================================================
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  profile_image TEXT,

  -- AI 셰프 설정
  ai_chef_name TEXT DEFAULT 'AI 셰프',
  ai_chef_personality TEXT DEFAULT 'friendly' CHECK (ai_chef_personality IN ('professional', 'friendly', 'motherly', 'coach', 'scientific', 'custom')),
  ai_chef_custom_personality TEXT,
  ai_chef_expertise TEXT[] DEFAULT ARRAY['한식'],
  ai_chef_cooking_philosophy TEXT,
  ai_chef_formality TEXT DEFAULT 'formal' CHECK (ai_chef_formality IN ('formal', 'casual')),
  ai_chef_emoji_usage TEXT DEFAULT 'medium' CHECK (ai_chef_emoji_usage IN ('high', 'medium', 'low', 'none')),
  ai_chef_technicality TEXT DEFAULT 'general' CHECK (ai_chef_technicality IN ('expert', 'general', 'beginner')),
  ai_chef_avatar_url TEXT,

  -- 사용자 선호도
  dietary_restrictions TEXT[],
  favorite_cuisines TEXT[],
  cooking_skill TEXT DEFAULT 'beginner' CHECK (cooking_skill IN ('beginner', 'intermediate', 'advanced')),

  -- 레시피 추천 설정
  ingredient_priority TEXT[] DEFAULT ARRAY['expiring'],
  preferred_cooking_time INTEGER, -- 분 단위
  preferred_difficulty TEXT DEFAULT 'any' CHECK (preferred_difficulty IN ('easy', 'medium', 'hard', 'any')),
  cuisine_mode TEXT DEFAULT 'ai_chef_expertise' CHECK (cuisine_mode IN ('ai_chef_expertise', 'rotate', 'favorite', 'random')),
  allow_substitution BOOLEAN DEFAULT true,
  allow_omission BOOLEAN DEFAULT true,
  strict_mode BOOLEAN DEFAULT false,
  tool_constraint BOOLEAN DEFAULT true,

  -- 개인정보 설정
  data_retention_days INTEGER DEFAULT 365,
  auto_delete_images BOOLEAN DEFAULT false,
  share_data_for_improvement BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 2. INGREDIENTS (재료)
-- =====================================================
CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,

  name TEXT NOT NULL,
  category TEXT NOT NULL,
  quantity DECIMAL NOT NULL DEFAULT 1,
  unit TEXT NOT NULL DEFAULT '개',

  purchase_date DATE DEFAULT CURRENT_DATE,
  expiry_date DATE NOT NULL,
  price DECIMAL,

  storage_location TEXT DEFAULT 'refrigerated' CHECK (storage_location IN ('refrigerated', 'frozen', 'room_temp')),
  memo TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스: 유통기한 순 조회 최적화
CREATE INDEX idx_ingredients_user_expiry ON ingredients(user_id, expiry_date);
CREATE INDEX idx_ingredients_user_category ON ingredients(user_id, category);

-- =====================================================
-- 3. COOKING TOOLS (요리 도구)
-- =====================================================
CREATE TABLE cooking_tools (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,

  name TEXT NOT NULL,
  category TEXT DEFAULT 'other' CHECK (category IN ('cookware', 'knife', 'measuring', 'appliance', 'other')),

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_cooking_tools_user ON cooking_tools(user_id);

-- =====================================================
-- 4. RECIPES (레시피)
-- =====================================================
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,

  title TEXT NOT NULL,
  description TEXT,
  cuisine TEXT,
  cooking_time INTEGER, -- 분 단위
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  servings INTEGER DEFAULT 1,

  -- AI 생성 정보
  ai_generated BOOLEAN DEFAULT true,
  ai_chef_name TEXT,
  ai_model TEXT,
  recommendation_reason TEXT,

  -- 레시피 내용 (JSON)
  ingredients JSONB NOT NULL DEFAULT '[]',
  required_tools JSONB DEFAULT '[]',
  instructions JSONB NOT NULL DEFAULT '[]',
  nutrition JSONB,
  chef_note TEXT,

  -- 사용자 상호작용
  is_favorite BOOLEAN DEFAULT false,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  user_memo TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_recipes_user ON recipes(user_id);
CREATE INDEX idx_recipes_user_favorite ON recipes(user_id, is_favorite) WHERE is_favorite = true;

-- =====================================================
-- 5. COOKING HISTORY (조리 이력)
-- =====================================================
CREATE TABLE cooking_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,

  recipe_title TEXT NOT NULL,
  cooked_at TIMESTAMPTZ DEFAULT NOW(),

  -- 사용한 재료 기록
  used_ingredients JSONB,

  -- 평가
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  memo TEXT,
  photo_url TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_cooking_history_user ON cooking_history(user_id, cooked_at DESC);

-- =====================================================
-- 6. CHAT SESSIONS (채팅 세션)
-- =====================================================
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,

  title TEXT DEFAULT '새 대화',
  context JSONB, -- 재료, 도구 등 컨텍스트

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 7. CHAT MESSAGES (채팅 메시지)
-- =====================================================
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,

  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,

  -- 메타데이터
  ai_model TEXT,
  tokens_used INTEGER,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id, created_at);

-- =====================================================
-- 8. AUDIT LOGS (감사 로그)
-- =====================================================
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,

  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address TEXT,
  user_agent TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at DESC);

-- =====================================================
-- TRIGGERS: updated_at 자동 업데이트
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_ingredients_updated_at
  BEFORE UPDATE ON ingredients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_recipes_updated_at
  BEFORE UPDATE ON recipes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_chat_sessions_updated_at
  BEFORE UPDATE ON chat_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- TRIGGER: 새 사용자 가입 시 프로필 자동 생성
-- =====================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) 활성화
-- =====================================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE cooking_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cooking_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES: user_profiles
-- =====================================================
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- =====================================================
-- RLS POLICIES: ingredients
-- =====================================================
CREATE POLICY "Users can view own ingredients"
  ON ingredients FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ingredients"
  ON ingredients FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ingredients"
  ON ingredients FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ingredients"
  ON ingredients FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: cooking_tools
-- =====================================================
CREATE POLICY "Users can view own cooking_tools"
  ON cooking_tools FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cooking_tools"
  ON cooking_tools FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cooking_tools"
  ON cooking_tools FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cooking_tools"
  ON cooking_tools FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: recipes
-- =====================================================
CREATE POLICY "Users can view own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert own recipes"
  ON recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes"
  ON recipes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: cooking_history
-- =====================================================
CREATE POLICY "Users can view own cooking_history"
  ON cooking_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cooking_history"
  ON cooking_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cooking_history"
  ON cooking_history FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cooking_history"
  ON cooking_history FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: chat_sessions
-- =====================================================
CREATE POLICY "Users can view own chat_sessions"
  ON chat_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat_sessions"
  ON chat_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own chat_sessions"
  ON chat_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat_sessions"
  ON chat_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: chat_messages
-- =====================================================
CREATE POLICY "Users can view own chat_messages"
  ON chat_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat_messages"
  ON chat_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- RLS POLICIES: audit_logs (읽기 전용)
-- =====================================================
CREATE POLICY "Users can view own audit_logs"
  ON audit_logs FOR SELECT
  USING (auth.uid() = user_id);

-- =====================================================
-- 기본 데이터: 재료 카테고리
-- =====================================================
COMMENT ON TABLE user_profiles IS '사용자 프로필 및 AI 셰프 설정';
COMMENT ON TABLE ingredients IS '사용자 보유 재료';
COMMENT ON TABLE cooking_tools IS '사용자 보유 요리 도구';
COMMENT ON TABLE recipes IS 'AI 생성 및 저장된 레시피';
COMMENT ON TABLE cooking_history IS '조리 완료 이력';
COMMENT ON TABLE chat_sessions IS 'AI 셰프와의 대화 세션';
COMMENT ON TABLE chat_messages IS '대화 메시지';
COMMENT ON TABLE audit_logs IS '보안 감사 로그';

-- =====================================================
-- 완료!
-- =====================================================
