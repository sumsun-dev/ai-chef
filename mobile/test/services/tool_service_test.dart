import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ai_chef/services/tool_service.dart';
import '../helpers/mock_supabase.dart';

/// cooking_tools 전용 MockSupabaseClient 생성
MockSupabaseClient _createClientWithTools(List<Map<String, dynamic>> rows) {
  final client = MockSupabaseClient();
  final auth = MockGoTrueClient();
  when(client.auth).thenReturn(auth);
  when(auth.currentUser).thenReturn(createTestUser());
  when(client.from('cooking_tools'))
      .thenAnswer((_) => FakeSupabaseQueryBuilder(rows));
  return client;
}

void main() {
  group('ToolService', () {
    test('로그인 안 된 경우 기본 도구 반환', () async {
      final client = createLoggedOutClient();
      final service = ToolService(supabase: client);

      final tools = await service.getAvailableToolNames();

      expect(tools, equals(['프라이팬', '냄비', '전자레인지', '오븐']));
    });

    test('defaultTools 상수 확인', () {
      expect(ToolService.defaultTools, hasLength(4));
      expect(ToolService.defaultTools, contains('프라이팬'));
      expect(ToolService.defaultTools, contains('냄비'));
    });

    test('DB에서 도구 조회 - 빈 결과 시 기본 도구', () async {
      final client = _createClientWithTools([]);

      final service = ToolService(supabase: client);
      final tools = await service.getAvailableToolNames();

      expect(tools, equals(['프라이팬', '냄비', '전자레인지', '오븐']));
    });

    test('DB에서 도구 조회 - 결과 있으면 해당 도구 반환', () async {
      final client = _createClientWithTools([
        {'tool_name': '에어프라이어'},
        {'tool_name': '믹서기'},
      ]);

      final service = ToolService(supabase: client);
      final tools = await service.getAvailableToolNames();

      expect(tools, equals(['에어프라이어', '믹서기']));
    });
  });
}
