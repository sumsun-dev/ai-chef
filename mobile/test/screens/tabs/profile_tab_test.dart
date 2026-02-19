import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/tabs/profile_tab.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ProfileTab', () {
    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileTab(authService: FakeAuthService())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('프로필 정보 표시 (이름, 이메일)', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileTab(
          authService: FakeAuthService(
            profileData: createTestProfile(
              name: '홍길동',
              email: 'hong@test.com',
            ),
          ),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('hong@test.com'), findsOneWidget);
    });

    testWidgets('설정 메뉴 상단 항목들 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileTab(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      // 뷰포트에 보이는 상단 항목들
      expect(find.text('요리 실력'), findsOneWidget);
      expect(find.text('가구원 수'), findsOneWidget);
      expect(find.text('선호 조리시간'), findsOneWidget);
      expect(find.text('1인분 예산'), findsOneWidget);
    });

    testWidgets('스크롤 시 하단 설정 및 로그아웃 버튼 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ProfileTab(
          authService: FakeAuthService(profileData: createTestProfile()),
        )),
      );

      await tester.pumpAndSettle();

      // 하단으로 스크롤
      await tester.scrollUntilVisible(
        find.text('로그아웃'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('로그아웃'), findsOneWidget);
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('도움말'), findsOneWidget);
    });
  });
}
