-- =============================================
-- 003: 원격 DB 스키마를 앱 코드 기대에 맞게 정렬
-- 원격 DB는 레거시 docs 스키마 기반, migration 001과 다름
-- 멱등성: 모든 변경에 IF NOT EXISTS / IF EXISTS 사용
-- =============================================

-- =========================================
-- 1. user_profiles: 누락 컬럼 추가
--    원격: cooking_skill 존재, skill_level/household_size 등 없음
-- =========================================
DO $$
BEGIN
  -- 앱에서 사용하는 핵심 프로필 컬럼
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'skill_level'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN skill_level TEXT DEFAULT 'beginner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'nickname'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN nickname TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'household_size'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN household_size INTEGER DEFAULT 1;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'has_children'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN has_children BOOLEAN DEFAULT FALSE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'children_ages'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN children_ages INTEGER[];
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'time_preference'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN time_preference TEXT DEFAULT '20min';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'budget_preference'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN budget_preference TEXT DEFAULT 'medium';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'scenarios'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN scenarios TEXT[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'disliked_ingredients'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN disliked_ingredients TEXT[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'primary_chef_id'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN primary_chef_id TEXT DEFAULT 'baek';
  END IF;
END $$;

-- cooking_skill → skill_level 데이터 마이그레이션 (기존 값 복사)
UPDATE user_profiles
  SET skill_level = cooking_skill
  WHERE cooking_skill IS NOT NULL
    AND (skill_level IS NULL OR skill_level = 'beginner');

-- =========================================
-- 2. ingredients: storage_location → location 리네임 + 값 마이그레이션
-- =========================================

-- 2a. 컬럼 리네임
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'storage_location'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'ingredients' AND column_name = 'location'
    ) THEN
      ALTER TABLE ingredients RENAME COLUMN storage_location TO location;
    END IF;
  END IF;
END $$;

-- 2b. 기존 CHECK 제약조건 제거 (storage_location_check)
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  SELECT con.conname INTO constraint_name
  FROM pg_constraint con
  JOIN pg_attribute att ON att.attnum = ANY(con.conkey)
    AND att.attrelid = con.conrelid
  WHERE con.conrelid = 'ingredients'::regclass
    AND con.contype = 'c'
    AND att.attname = 'location';

  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE ingredients DROP CONSTRAINT %I', constraint_name);
  END IF;
END $$;

-- 2c. 보관위치 값 마이그레이션
UPDATE ingredients SET location = 'fridge'  WHERE location = 'refrigerated';
UPDATE ingredients SET location = 'freezer' WHERE location = 'frozen';
UPDATE ingredients SET location = 'pantry'  WHERE location = 'room_temp';

-- 2d. 새 CHECK 제약조건 추가
ALTER TABLE ingredients
  ADD CONSTRAINT ingredients_location_check
  CHECK (location IN ('fridge', 'freezer', 'pantry'));

-- 2e. NOT NULL 제약 해제 (앱에서 nullable로 사용)
ALTER TABLE ingredients ALTER COLUMN quantity DROP NOT NULL;
ALTER TABLE ingredients ALTER COLUMN unit DROP NOT NULL;
ALTER TABLE ingredients ALTER COLUMN expiry_date DROP NOT NULL;

-- 2f. 누락 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'is_staple'
  ) THEN
    ALTER TABLE ingredients ADD COLUMN is_staple BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- 2g. 인덱스
CREATE INDEX IF NOT EXISTS idx_ingredients_user_expiry ON ingredients(user_id, expiry_date);
CREATE INDEX IF NOT EXISTS idx_ingredients_user_category ON ingredients(user_id, category);
CREATE INDEX IF NOT EXISTS idx_ingredients_user_location ON ingredients(user_id, location);

-- =========================================
-- 3. cooking_tools: name → tool_name 리네임 + tool_key/is_available 추가
-- =========================================

-- 3a. name → tool_name 리네임
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cooking_tools' AND column_name = 'name'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'cooking_tools' AND column_name = 'tool_name'
    ) THEN
      ALTER TABLE cooking_tools RENAME COLUMN name TO tool_name;
    END IF;
  END IF;
END $$;

-- 3b. tool_key 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cooking_tools' AND column_name = 'tool_key'
  ) THEN
    ALTER TABLE cooking_tools ADD COLUMN tool_key TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cooking_tools' AND column_name = 'is_available'
  ) THEN
    ALTER TABLE cooking_tools ADD COLUMN is_available BOOLEAN DEFAULT TRUE;
  END IF;
END $$;

-- 3c. tool_name → tool_key 매핑 (기존 데이터 마이그레이션)
UPDATE cooking_tools SET tool_key = 'frying_pan'  WHERE tool_name LIKE '%프라이팬%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'pot'         WHERE tool_name LIKE '%냄비%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'stove'       WHERE tool_name LIKE '%가스레인지%' OR tool_name LIKE '%인덕션%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'microwave'   WHERE tool_name LIKE '%전자레인지%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'rice_cooker' WHERE tool_name LIKE '%밥솥%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'air_fryer'   WHERE tool_name LIKE '%에어프라이어%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'oven'        WHERE tool_name LIKE '%오븐%' AND tool_key IS NULL;
UPDATE cooking_tools SET tool_key = 'blender'     WHERE tool_name LIKE '%블렌더%' OR tool_name LIKE '%믹서%' AND tool_key IS NULL;
-- 매핑되지 않은 항목은 tool_name을 tool_key로 사용
UPDATE cooking_tools SET tool_key = tool_name WHERE tool_key IS NULL;

-- 3d. category CHECK 제약조건 제거 (앱에서 사용하지 않음)
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  SELECT con.conname INTO constraint_name
  FROM pg_constraint con
  JOIN pg_attribute att ON att.attnum = ANY(con.conkey)
    AND att.attrelid = con.conrelid
  WHERE con.conrelid = 'cooking_tools'::regclass
    AND con.contype = 'c'
    AND att.attname = 'category';

  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE cooking_tools DROP CONSTRAINT %I', constraint_name);
  END IF;
END $$;

-- 3e. UNIQUE 제약조건 추가 (중복 방지)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'cooking_tools'::regclass
      AND conname = 'cooking_tools_user_id_tool_key_key'
  ) THEN
    -- 기존 중복 데이터 정리 (가장 최근 것만 유지)
    DELETE FROM cooking_tools a
    USING cooking_tools b
    WHERE a.user_id = b.user_id
      AND a.tool_key = b.tool_key
      AND a.id < b.id;

    ALTER TABLE cooking_tools ADD CONSTRAINT cooking_tools_user_id_tool_key_key UNIQUE(user_id, tool_key);
  END IF;
END $$;

-- =========================================
-- 4. recipes: 누락 컬럼 추가 + 데이터 마이그레이션
-- =========================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recipes' AND column_name = 'chef_id'
  ) THEN
    ALTER TABLE recipes ADD COLUMN chef_id TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recipes' AND column_name = 'tags'
  ) THEN
    ALTER TABLE recipes ADD COLUMN tags TEXT[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recipes' AND column_name = 'image_url'
  ) THEN
    ALTER TABLE recipes ADD COLUMN image_url TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recipes' AND column_name = 'tools'
  ) THEN
    ALTER TABLE recipes ADD COLUMN tools JSONB DEFAULT '[]';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'recipes' AND column_name = 'is_bookmarked'
  ) THEN
    ALTER TABLE recipes ADD COLUMN is_bookmarked BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- required_tools → tools 데이터 복사
UPDATE recipes SET tools = required_tools WHERE required_tools IS NOT NULL AND (tools IS NULL OR tools = '[]'::jsonb);
-- is_favorite → is_bookmarked 데이터 복사
UPDATE recipes SET is_bookmarked = is_favorite WHERE is_favorite IS NOT NULL AND is_bookmarked = false;
-- ai_chef_name → chef_id 데이터 복사
UPDATE recipes SET chef_id = ai_chef_name WHERE ai_chef_name IS NOT NULL AND chef_id IS NULL;

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_recipes_user ON recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_bookmarked ON recipes(user_id, is_bookmarked);

-- =========================================
-- 5. chat_messages: chef_id 컬럼 추가
-- =========================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'chat_messages' AND column_name = 'chef_id'
  ) THEN
    ALTER TABLE chat_messages ADD COLUMN chef_id TEXT;
  END IF;
END $$;

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_chef
  ON chat_messages(user_id, chef_id, created_at ASC);

-- =========================================
-- 6. cooking_history → recipe_history 테이블 리네임
-- =========================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'cooking_history' AND table_schema = 'public'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_name = 'recipe_history' AND table_schema = 'public'
    ) THEN
      ALTER TABLE cooking_history RENAME TO recipe_history;
    END IF;
  END IF;
END $$;

-- recipe_history에 chef_id 추가 (nullable)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'recipe_history' AND table_schema = 'public'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'recipe_history' AND column_name = 'chef_id'
    ) THEN
      ALTER TABLE recipe_history ADD COLUMN chef_id TEXT;
    END IF;
  END IF;
END $$;

-- recipe_history RLS (cooking_history에서 리네임 시 기존 정책은 유지됨)
ALTER TABLE recipe_history ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_recipe_history_user ON recipe_history(user_id, cooked_at DESC);

-- =========================================
-- 7. chef_settings 테이블 생성
-- =========================================
CREATE TABLE IF NOT EXISTS chef_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  primary_chef_id TEXT NOT NULL DEFAULT 'baek',
  favorite_chef_ids TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chef_settings ENABLE ROW LEVEL SECURITY;

-- chef_settings RLS 정책
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
    WHERE polrelid = 'chef_settings'::regclass
      AND polname = 'Users can manage own chef settings'
  ) THEN
    CREATE POLICY "Users can manage own chef settings"
      ON chef_settings FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- updated_at 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'update_chef_settings_updated_at'
  ) THEN
    CREATE TRIGGER update_chef_settings_updated_at
      BEFORE UPDATE ON chef_settings
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- =========================================
-- 8. 기존 유저에 대한 chef_settings 초기 데이터 삽입
-- =========================================
INSERT INTO chef_settings (user_id, primary_chef_id)
SELECT id, COALESCE(primary_chef_id, 'baek')
FROM user_profiles
WHERE id NOT IN (SELECT user_id FROM chef_settings)
ON CONFLICT (user_id) DO NOTHING;
