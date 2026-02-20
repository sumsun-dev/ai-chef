import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/settings/privacy_screen.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('PrivacyScreen', () {
    late FakeAuthService fakeAuth;

    setUp(() {
      fakeAuth = FakeAuthService();
    });

    testWidgets('AppBar에 "개인정보 및 보안" 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      expect(find.text('개인정보 및 보안'), findsOneWidget);
    });

    testWidgets('내 데이터 다운로드 ListTile이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      expect(find.text('내 데이터 다운로드'), findsOneWidget);
    });

    testWidgets('내 데이터 다운로드 탭 시 SnackBar가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      await tester.tap(find.text('내 데이터 다운로드'));
      await tester.pumpAndSettle();

      expect(find.text('준비 중인 기능입니다.'), findsOneWidget);
    });

    testWidgets('계정 삭제 ListTile이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      expect(find.text('계정 삭제'), findsOneWidget);
    });

    testWidgets('계정 삭제 탭 시 확인 다이얼로그가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();

      expect(find.text('계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.\n정말 삭제하시겠습니까?'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('삭제'), findsOneWidget);
    });

    testWidgets('삭제 확인 시 signOut이 호출된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PrivacyScreen(authService: fakeAuth)),
      );

      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();

      // 다이얼로그에서 "삭제" 버튼 (두 번째 TextButton)
      await tester.tap(find.widgetWithText(TextButton, '삭제'));
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, true);
    });
  });
}
