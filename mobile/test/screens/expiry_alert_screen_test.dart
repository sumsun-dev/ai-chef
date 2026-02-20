import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/screens/expiry_alert_screen.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('ExpiryAlertScreen', () {
    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      // FakeIngredientService가 즉시 반환하므로 pump 1프레임만
      final fakeService = FakeIngredientService();
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );

      // 첫 프레임에서 로딩 상태 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppBar에 "유통기한 알림" 텍스트가 표시된다', (tester) async {
      final fakeService = FakeIngredientService();
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('유통기한 알림'), findsOneWidget);
    });

    testWidgets('3개의 탭이 표시된다', (tester) async {
      final fakeService = FakeIngredientService();
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('만료됨'), findsOneWidget);
      expect(find.text('3일 이내'), findsOneWidget);
      expect(find.text('7일 이내'), findsOneWidget);
    });

    testWidgets('빈 리스트일 때 안내 메시지가 표시된다', (tester) async {
      final fakeService = FakeIngredientService(
        expiryGroup: ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [],
          warningItems: [],
          safeItems: [],
        ),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('유통기한이 지난 재료가 없습니다'), findsOneWidget);
    });

    testWidgets('만료된 재료가 있으면 카드가 표시된다', (tester) async {
      final expiredIngredient = Ingredient(
        id: 'expired-1',
        name: '오래된 우유',
        category: 'dairy',
        quantity: 1,
        unit: '개',
        expiryDate: DateTime.now().subtract(const Duration(days: 3)),
        storageLocation: StorageLocation.fridge,
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
      );

      final fakeService = FakeIngredientService(
        expiryGroup: ExpiryIngredientGroup(
          expiredItems: [expiredIngredient],
          criticalItems: [],
          warningItems: [],
          safeItems: [],
        ),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오래된 우유'), findsOneWidget);
    });

    testWidgets('에러 발생 시 오류 메시지와 다시 시도 버튼이 표시된다', (tester) async {
      final fakeService = _ThrowingIngredientService();

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ExpiryAlertScreen(ingredientService: fakeService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });
  });
}

/// 에러를 throw하는 IngredientService
class _ThrowingIngredientService extends FakeIngredientService {
  @override
  Future<ExpiryIngredientGroup> getExpiryIngredientGroup() async {
    throw Exception('테스트 에러');
  }
}
