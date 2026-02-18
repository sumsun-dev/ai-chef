import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_chef/models/onboarding_state.dart';
import 'package:ai_chef/services/auth_service.dart';
import '../helpers/mock_supabase.dart';

/// GoogleSignIn Fake - signOut 호출 추적
class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  bool signOutCalled = false;

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signOutCalled = true;
    return null;
  }
}

void main() {
  group('not logged in', () {
    late AuthService service;

    setUp(() {
      service = AuthService(
        supabase: createLoggedOutClient(),
        googleSignIn: FakeGoogleSignIn(),
      );
    });

    test('currentUser returns null', () {
      expect(service.currentUser, isNull);
    });

    test('getUserProfile returns null', () async {
      final result = await service.getUserProfile();
      expect(result, isNull);
    });

    test('updateUserProfile throws', () {
      expect(() => service.updateUserProfile({'name': '테스트'}),
          throwsA(isA<Exception>()));
    });

    test('saveOnboardingData throws', () {
      expect(
        () => service.saveOnboardingData(OnboardingState()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('logged in', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late FakeGoogleSignIn fakeGoogleSignIn;
    late AuthService service;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      fakeGoogleSignIn = FakeGoogleSignIn();

      when(mockClient.auth).thenReturn(mockAuth);
      when(mockAuth.currentUser).thenReturn(createTestUser());

      service = AuthService(
        supabase: mockClient,
        googleSignIn: fakeGoogleSignIn,
      );
    });

    test('currentUser returns user', () {
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.id, 'test-user-id');
    });

    test('signOut calls both signOut methods', () async {
      await service.signOut();

      expect(fakeGoogleSignIn.signOutCalled, isTrue);
      verify(mockAuth.signOut()).called(1);
    });

    test('getUserProfile returns profile data', () async {
      final profileData = {'id': 'test-user-id', 'skill_level': 'beginner'};
      when(mockClient.from('user_profiles'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([profileData]));

      final result = await service.getUserProfile();
      expect(result, isNotNull);
      expect(result!['skill_level'], 'beginner');
    });

    test('updateUserProfile completes', () async {
      when(mockClient.from('user_profiles'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.updateUserProfile({'skill_level': 'intermediate'});
    });
  });
}
