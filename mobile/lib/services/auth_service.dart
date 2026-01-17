import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증 서비스
/// Google 로그인 및 Supabase 인증 관리
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      scopes: ['email', 'profile'],
    );
  }

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

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    await _supabase
        .from('user_profiles')
        .update(data)
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
}
