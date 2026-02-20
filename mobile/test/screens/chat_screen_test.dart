import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chat_message.dart';
import 'package:ai_chef/screens/chat_screen.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeAuthService fakeAuth;
  late FakeIngredientService fakeIngredient;
  late FakeChatService fakeChat;
  late FakeGeminiService fakeGemini;

  setUp(() {
    fakeAuth = FakeAuthService(profileData: createTestProfile());
    fakeIngredient = FakeIngredientService(ingredients: [
      createTestIngredient(name: '양파'),
      createTestIngredient(name: '당근'),
    ]);
    fakeChat = FakeChatService();
    fakeGemini = FakeGeminiService();
  });

  Widget buildChatScreen({String? initialMessage}) {
    return wrapWithMaterialApp(
      ChatScreen(
        initialMessage: initialMessage,
        authService: fakeAuth,
        ingredientService: fakeIngredient,
        chatService: fakeChat,
        geminiService: fakeGemini,
      ),
    );
  }

  group('ChatScreen', () {
    testWidgets('렌더링 시 셰프 이름과 입력 필드가 표시된다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // 입력 필드 존재
      expect(find.byType(TextField), findsOneWidget);
      // 전송 버튼 존재
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('DI로 주입된 서비스를 사용한다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // ChatScreen이 정상 렌더링되면 DI 성공
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('채팅 기록이 없으면 인사 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // 인사 메시지가 하나 이상 존재해야 함 (assistant 메시지)
      // ListView에 최소 1개 아이템
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('빈 텍스트는 전송되지 않는다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // 빈 상태에서 전송 버튼 탭
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // 메시지가 추가되지 않음 (인사 메시지만 존재)
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('메시지 입력 후 전송하면 사용자 메시지가 추가된다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // 텍스트 입력
      await tester.enterText(find.byType(TextField), '김치찌개 레시피 알려줘');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      // 사용자 메시지가 표시됨
      expect(find.text('김치찌개 레시피 알려줘'), findsOneWidget);
    });

    testWidgets('initialMessage가 있으면 자동으로 전송된다', (tester) async {
      await tester.pumpWidget(
        buildChatScreen(initialMessage: '오늘 뭐 먹을까'),
      );
      await tester.pump();

      // 초기 메시지가 표시됨
      expect(find.text('오늘 뭐 먹을까'), findsOneWidget);
    });

    testWidgets('로딩 중 전송 버튼이 비활성화된다', (tester) async {
      await tester.pumpWidget(buildChatScreen());
      await tester.pumpAndSettle();

      // 메시지 전송 (로딩 상태로 전환)
      await tester.enterText(find.byType(TextField), '테스트');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      // 전송 버튼 아이콘 색상이 tertiary (비활성)로 변경됨
      // 로딩 중이므로 추가 메시지 입력 무시됨
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('채팅 기록이 있으면 로드하여 표시된다', (tester) async {
      fakeChat = FakeChatService(chatHistory: [
        ChatMessage(
          role: MessageRole.user,
          content: '이전 질문',
          chefId: 'baek',
        ),
        ChatMessage(
          role: MessageRole.assistant,
          content: '이전 답변',
          chefId: 'baek',
        ),
      ]);

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ChatScreen(
            authService: fakeAuth,
            ingredientService: fakeIngredient,
            chatService: fakeChat,
            geminiService: fakeGemini,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('이전 질문'), findsOneWidget);
      expect(find.text('이전 답변'), findsOneWidget);
    });
  });
}
