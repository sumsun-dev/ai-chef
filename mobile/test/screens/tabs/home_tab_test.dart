import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/tabs/home_tab.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('HomeTab', () {
    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      final authService = FakeAuthService(profileData: createTestProfile());
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: authService,
          ingredientService: FakeIngredientService(),
          toolService: FakeToolService(),
        )),
      );

      // 첫 프레임에는 로딩 표시
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('데이터 로드 후 셰프 이름과 빠른 선택 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI 셰프'), findsOneWidget);
      expect(find.text('혼밥'), findsOneWidget);
      expect(find.text('급해요'), findsOneWidget);
      expect(find.text('재료정리'), findsOneWidget);
    });

    testWidgets('오늘의 추천 섹션에 "추천 받기" 버튼 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('오늘의 추천'), findsOneWidget);
      expect(find.text('추천 받기'), findsOneWidget);
    });

    testWidgets('유통기한 임박 재료가 있으면 섹션 표시', (tester) async {
      final expiringIngredient = createTestIngredient(
        name: '두부',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(
            expiryGroup: ExpiryIngredientGroup(
              expiredItems: [],
              criticalItems: [expiringIngredient],
              warningItems: [],
              safeItems: [],
            ),
          ),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('유통기한 임박'), findsOneWidget);
      expect(find.text('두부'), findsOneWidget);
    });

    testWidgets('유통기한 임박 재료가 없으면 섹션 미표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('유통기한 임박'), findsNothing);
    });

    testWidgets('재료가 있으면 냉장고 요약 카드 표시', (tester) async {
      final ingredients = [
        createTestIngredient(name: '양파'),
        createTestIngredient(name: '당근'),
        createTestIngredient(name: '감자'),
      ];
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(ingredients: ingredients),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('내 냉장고'), findsOneWidget);
      expect(find.text('총 3개'), findsOneWidget);
    });

    testWidgets('카메라 아이콘이 채팅 입력에 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(HomeTab(
          authService: FakeAuthService(profileData: createTestProfile()),
          ingredientService: FakeIngredientService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });
  });
}
