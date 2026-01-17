-- =====================================================
-- AI Chef - Supabase 디버그 및 수정 스크립트
-- "Database error saving new user" 오류 해결
-- =====================================================

-- =====================================================
-- 1단계: 기존 트리거 및 함수 완전 삭제
-- =====================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- =====================================================
-- 2단계: user_profiles 테이블 확인 및 수정
-- email을 NULL 허용으로 변경 (Google 로그인 시 이메일이 늦게 올 수 있음)
-- =====================================================
ALTER TABLE public.user_profiles
ALTER COLUMN email DROP NOT NULL;

-- email 기본값 설정
ALTER TABLE public.user_profiles
ALTER COLUMN email SET DEFAULT '';

-- =====================================================
-- 3단계: RLS 정책 확인 - INSERT 정책 추가
-- (서비스 역할에서 삽입 허용)
-- =====================================================

-- 기존 정책 삭제 후 재생성
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Service role can insert profiles" ON user_profiles;

-- SELECT 정책
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

-- UPDATE 정책
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- INSERT 정책 (본인 프로필만)
CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- =====================================================
-- 4단계: 새로운 트리거 함수 생성 (더 안전한 버전)
-- =====================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_email TEXT;
  user_name TEXT;
BEGIN
  -- 이메일 추출 (여러 소스에서 시도)
  user_email := COALESCE(
    NEW.email,
    NEW.raw_user_meta_data->>'email',
    ''
  );

  -- 이름 추출 (여러 소스에서 시도)
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'user_name',
    SPLIT_PART(user_email, '@', 1),
    'User'
  );

  -- user_profiles에 삽입 (충돌 시 무시)
  INSERT INTO public.user_profiles (
    id,
    email,
    name,
    profile_image
  ) VALUES (
    NEW.id,
    user_email,
    user_name,
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    name = COALESCE(user_profiles.name, EXCLUDED.name),
    profile_image = COALESCE(EXCLUDED.profile_image, user_profiles.profile_image),
    updated_at = NOW();

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- 오류 발생해도 인증은 진행되도록 함
    RAISE LOG 'handle_new_user error: % %', SQLERRM, SQLSTATE;
    RETURN NEW;
END;
$$;

-- =====================================================
-- 5단계: 트리거 생성
-- =====================================================
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 6단계: 기존 auth.users에 프로필이 없는 사용자 처리
-- (이미 가입했지만 프로필이 생성 안 된 경우)
-- =====================================================
INSERT INTO public.user_profiles (id, email, name, profile_image)
SELECT
  au.id,
  COALESCE(au.email, ''),
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'name',
    SPLIT_PART(au.email, '@', 1),
    'User'
  ),
  au.raw_user_meta_data->>'avatar_url'
FROM auth.users au
LEFT JOIN public.user_profiles up ON au.id = up.id
WHERE up.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 7단계: 검증 쿼리
-- =====================================================

-- 트리거 확인
SELECT
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- user_profiles 테이블 구조 확인
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'user_profiles'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- RLS 정책 확인
SELECT
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'user_profiles';

-- =====================================================
-- 완료! 이제 다시 로그인을 시도하세요.
-- =====================================================
