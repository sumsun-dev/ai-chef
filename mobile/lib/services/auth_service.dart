import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../models/onboarding_state.dart';

/// 인증 서비스
/// Google 로그인 및 Supabase 인증 관리
class AuthService {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  static const _googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  AuthService({SupabaseClient? supabase, GoogleSignIn? googleSignIn})
      : _supabase = supabase ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb ? _googleWebClientId : null,
              serverClientId: kIsWeb ? null : _googleWebClientId,
              scopes: ['email', 'profile'],
            );

  /// 현재 사용자 가져오기
  User? get currentUser => _supabase.auth.currentUser;

  /// 로그인 상태 스트림
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google 로그인
  Future<AuthResponse> signInWithGoogle() async {
    // Google Sign-In 실행
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google 로그인이 취소되었습니다.');
    }

    // Google 인증 정보 가져오기
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('Google ID 토큰을 가져올 수 없습니다.');
    }

    // Supabase에 로그인
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  /// 사용자 프로필 가져오기
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  /// 사용자 프로필 업데이트 (허용 필드만 통과)
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    final filtered = Map<String, dynamic>.fromEntries(
      data.entries.where(
        (e) => AppConstants.allowedProfileFields.contains(e.key),
      ),
    );

    if (filtered.isEmpty) return;

    await _supabase
        .from('user_profiles')
        .update(filtered)
        .eq('id', user.id);
  }

  /// AI 셰프 설정 업데이트
  Future<void> updateAIChefSettings({
    required String name,
    required String personality,
    String? customPersonality,
    required List<String> expertise,
    String? cookingPhilosophy,
    required String formality,
    required String emojiUsage,
    required String technicality,
  }) async {
    await updateUserProfile({
      'ai_chef_name': name,
      'ai_chef_personality': personality,
      'ai_chef_custom_personality': customPersonality,
      'ai_chef_expertise': expertise,
      'ai_chef_cooking_philosophy': cookingPhilosophy,
      'ai_chef_formality': formality,
      'ai_chef_emoji_usage': emojiUsage,
      'ai_chef_technicality': technicality,
    });
  }

  /// 온보딩 전체 데이터 저장
  Future<void> saveOnboardingData(OnboardingState state) async {
    final user = currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    debugPrint('[Onboarding] saveOnboardingData: userId=${user.id}, chefName=${state.chefName}, skillLevel=${state.skillLevel}');

    // 0. user_profiles 행 존재 확인
    final existing = await _supabase
        .from('user_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    debugPrint('[Onboarding] existing profile row: $existing');

    if (existing == null) {
      // 행이 없으면 INSERT
      debugPrint('[Onboarding] No profile row found, inserting...');
      await _supabase.from('user_profiles').insert({
        'id': user.id,
        'skill_level': state.skillLevel,
        'scenarios': state.scenarios,
        'time_preference': state.timePreference,
        'budget_preference': state.budgetPreference,
        'primary_chef_id': state.selectedPresetId ?? 'baek',
        'ai_chef_name': state.chefName,
        'ai_chef_personality': state.personality,
        'ai_chef_expertise': state.expertise,
        'ai_chef_formality': state.formality,
        'ai_chef_emoji_usage': state.emojiUsage,
        'ai_chef_technicality': state.technicality,
      });
    } else {
      // 행이 있으면 UPDATE
      debugPrint('[Onboarding] Profile row exists, updating...');
      await _supabase.from('user_profiles').update({
        'skill_level': state.skillLevel,
        'scenarios': state.scenarios,
        'time_preference': state.timePreference,
        'budget_preference': state.budgetPreference,
        'primary_chef_id': state.selectedPresetId ?? 'baek',
        'ai_chef_name': state.chefName,
        'ai_chef_personality': state.personality,
        'ai_chef_expertise': state.expertise,
        'ai_chef_formality': state.formality,
        'ai_chef_emoji_usage': state.emojiUsage,
        'ai_chef_technicality': state.technicality,
      }).eq('id', user.id);
    }

    // 검증: 저장 결과 확인
    final verify = await _supabase
        .from('user_profiles')
        .select('ai_chef_name')
        .eq('id', user.id)
        .maybeSingle();
    debugPrint('[Onboarding] verify after save: $verify');

    // 2. cooking_tools upsert
    for (final entry in state.tools.entries) {
      await _supabase.from('cooking_tools').upsert(
        {
          'user_id': user.id,
          'tool_key': entry.key,
          'tool_name': OnboardingState.toolKeyToName[entry.key] ?? entry.key,
          'is_available': entry.value,
        },
        onConflict: 'user_id,tool_key',
      );
    }

    // 3. ingredients 등록 (첫 냉장고)
    for (final ingredient in state.firstIngredients) {
      await _supabase.from('ingredients').insert({
        'user_id': user.id,
        'name': ingredient.name,
        'category': ingredient.category,
        'location': 'fridge',
      });
    }
  }
}
