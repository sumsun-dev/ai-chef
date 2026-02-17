-- =============================================
-- 002: Ingredient 스키마 정렬
-- 목적: docs 스키마(storage_location, refrigerated 등)와
--       migration 스키마(location, fridge 등) 간 차이를 해소
-- 멱등성: 어느 스키마 상태에서든 안전하게 실행 가능
-- =============================================

-- -------------------------------------------------
-- 1. 컬럼 리네임: storage_location → location
--    (docs 스키마에서 실행된 경우만 적용)
-- -------------------------------------------------
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'storage_location'
  ) THEN
    ALTER TABLE ingredients RENAME COLUMN storage_location TO location;
  END IF;
END $$;

-- -------------------------------------------------
-- 2. 보관위치 값 마이그레이션
--    refrigerated → fridge, frozen → freezer, room_temp → pantry
-- -------------------------------------------------
UPDATE ingredients SET location = 'fridge'   WHERE location = 'refrigerated';
UPDATE ingredients SET location = 'freezer'  WHERE location = 'frozen';
UPDATE ingredients SET location = 'pantry'   WHERE location = 'room_temp';

-- -------------------------------------------------
-- 3. 카테고리 값 마이그레이션
--    produce → vegetable, condiments → seasoning 등
-- -------------------------------------------------
UPDATE ingredients SET category = 'vegetable' WHERE category = 'produce';
UPDATE ingredients SET category = 'seasoning' WHERE category = 'condiments';
UPDATE ingredients SET category = 'grain'     WHERE category = 'pantry';
UPDATE ingredients SET category = 'other'     WHERE category IN ('frozen', 'beverages', 'bakery');

-- -------------------------------------------------
-- 4. 누락 컬럼 추가 (docs 스키마에 없는 컬럼)
-- -------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'purchase_date'
  ) THEN
    ALTER TABLE ingredients ADD COLUMN purchase_date DATE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'price'
  ) THEN
    ALTER TABLE ingredients ADD COLUMN price DECIMAL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'ingredients' AND column_name = 'is_staple'
  ) THEN
    ALTER TABLE ingredients ADD COLUMN is_staple BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- -------------------------------------------------
-- 5. CHECK 제약조건 재설정
--    기존 제약조건 제거 후 올바른 값으로 재생성
-- -------------------------------------------------

-- location CHECK
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

ALTER TABLE ingredients
  ADD CONSTRAINT ingredients_location_check
  CHECK (location IN ('fridge', 'freezer', 'pantry'));

-- category CHECK
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
    AND att.attname = 'category';

  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE ingredients DROP CONSTRAINT %I', constraint_name);
  END IF;
END $$;

ALTER TABLE ingredients
  ADD CONSTRAINT ingredients_category_check
  CHECK (category IN (
    'vegetable', 'fruit', 'meat', 'seafood',
    'dairy', 'egg', 'grain', 'seasoning', 'other'
  ));

-- -------------------------------------------------
-- 6. location 인덱스 보장
-- -------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_ingredients_user_location
  ON ingredients(user_id, location);
