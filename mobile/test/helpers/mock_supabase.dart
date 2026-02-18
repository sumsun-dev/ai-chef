import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<GoTrueClient>(),
])
import 'mock_supabase.mocks.dart';
export 'mock_supabase.mocks.dart';

// --- Fake Query Chain ---

/// SupabaseQueryBuilder fake: 모든 쿼리 메서드 → FakeListBuilder 반환
class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> _data;
  FakeSupabaseQueryBuilder(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) => FakeListBuilder(_data);
}

/// PostgrestFilterBuilder List fake: 체인 메서드는 this 반환, await 시 _data 반환
class FakeListBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  FakeListBuilder(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      final onValue = invocation.positionalArguments[0] as Function;
      return Future<dynamic>.value(onValue(_data));
    }
    if (invocation.memberName == #single) {
      return FakeSingleBuilder(
          _data.isNotEmpty ? _data.first : <String, dynamic>{});
    }
    return this;
  }
}

/// PostgrestFilterBuilder<Map> fake: await 시 단일 _data 반환
class FakeSingleBuilder extends Fake
    implements PostgrestFilterBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  FakeSingleBuilder(this._data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      final onValue = invocation.positionalArguments[0] as Function;
      return Future<dynamic>.value(onValue(_data));
    }
    return this;
  }
}

// --- Helpers ---

/// 테스트용 User 생성
User createTestUser({String id = 'test-user-id'}) {
  return User(
    id: id,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
}

/// 로그인된 MockSupabaseClient 생성
MockSupabaseClient createLoggedInClient({String userId = 'test-user-id'}) {
  final client = MockSupabaseClient();
  final auth = MockGoTrueClient();
  when(client.auth).thenReturn(auth);
  when(auth.currentUser).thenReturn(createTestUser(id: userId));
  return client;
}

/// 로그아웃된 MockSupabaseClient 생성
MockSupabaseClient createLoggedOutClient() {
  final client = MockSupabaseClient();
  final auth = MockGoTrueClient();
  when(client.auth).thenReturn(auth);
  when(auth.currentUser).thenReturn(null);
  return client;
}
