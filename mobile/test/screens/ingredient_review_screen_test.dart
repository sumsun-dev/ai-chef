import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/screens/ingredient_review_screen.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  /// 테스트용 OCR 결과 생성
  ReceiptOcrResult createOcrResult({
    List<Ingredient>? ingredients,
    String? storeName,
    DateTime? purchaseDate,
  }) {
    return ReceiptOcrResult(
      ingredients: ingredients ??
          [
            Ingredient(
              name: '삼겹살',
              category: 'meat',
              quantity: 1,
              unit: '팩',
              expiryDate: DateTime(2026, 2, 25),
              storageLocation: StorageLocation.fridge,
              ocrConfidence: OcrConfidence.high,
              purchaseDate: DateTime(2026, 2, 20),
            ),
            Ingredient(
              name: '양파',
              category: 'vegetable',
              quantity: 3,
              unit: '개',
              expiryDate: DateTime(2026, 2, 27),
              storageLocation: StorageLocation.fridge,
              ocrConfidence: OcrConfidence.medium,
              purchaseDate: DateTime(2026, 2, 20),
            ),
            Ingredient(
              name: '우유',
              category: 'dairy',
              quantity: 1,
              unit: 'L',
              expiryDate: DateTime(2026, 3, 6),
              storageLocation: StorageLocation.fridge,
              ocrConfidence: OcrConfidence.low,
              purchaseDate: DateTime(2026, 2, 20),
            ),
          ],
      storeName: storeName ?? '이마트',
      purchaseDate: purchaseDate ?? DateTime(2026, 2, 20),
    );
  }

  Widget buildScreen({
    ReceiptOcrResult? ocrResult,
    FakeIngredientService? ingredientService,
  }) {
    return wrapWithMaterialApp(
      IngredientReviewScreen(
        ocrResult: ocrResult ?? createOcrResult(),
        ingredientService: ingredientService ?? FakeIngredientService(),
      ),
    );
  }

  group('IngredientReviewScreen', () {
    testWidgets('재료 목록이 체크박스와 함께 표시된다', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('삼겹살'), findsOneWidget);
      expect(find.text('양파'), findsOneWidget);
      expect(find.text('우유'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('기본적으로 모든 재료가 선택되어 있다', (tester) async {
      await tester.pumpWidget(buildScreen());

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final checkbox in checkboxes) {
        expect(checkbox.value, isTrue);
      }
    });

    testWidgets('체크박스 탭 시 선택/해제가 토글된다', (tester) async {
      await tester.pumpWidget(buildScreen());

      // 첫 번째 체크박스 탭 → 해제
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(checkboxes[0].value, isFalse);
      expect(checkboxes[1].value, isTrue);
      expect(checkboxes[2].value, isTrue);

      // 다시 탭 → 선택
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      final restored = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
      expect(restored[0].value, isTrue);
    });

    testWidgets('"전체 선택/해제" 버튼이 동작한다', (tester) async {
      await tester.pumpWidget(buildScreen());

      // 초기: 모두 선택됨 → 버튼 텍스트는 "전체 해제"
      expect(find.text('전체 해제'), findsOneWidget);

      // 전체 해제 탭
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 모든 체크박스 해제됨
      final unchecked = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final checkbox in unchecked) {
        expect(checkbox.value, isFalse);
      }
      expect(find.text('전체 선택'), findsOneWidget);

      // 전체 선택 탭
      await tester.tap(find.text('전체 선택'));
      await tester.pump();

      final checked = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final checkbox in checked) {
        expect(checkbox.value, isTrue);
      }
    });

    testWidgets('삭제 버튼 탭 시 재료가 제거된다', (tester) async {
      await tester.pumpWidget(buildScreen());

      // 삼겹살 존재 확인
      expect(find.text('삼겹살'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(3));

      // 첫 번째 삭제 버튼 탭 (delete_outline 아이콘)
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      // 삼겹살 제거됨
      expect(find.text('삼겹살'), findsNothing);
      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('선택된 재료 카운터가 업데이트된다', (tester) async {
      await tester.pumpWidget(buildScreen());

      // 초기: 3/3개 (모두 선택)
      expect(find.text('3/3개'), findsOneWidget);

      // 하나 해제 → 2/3개
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(find.text('2/3개'), findsOneWidget);

      // 하나 더 해제 → 1/3개
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      expect(find.text('1/3개'), findsOneWidget);
    });

    testWidgets('선택 없을 때 저장 버튼이 비활성화된다', (tester) async {
      await tester.pumpWidget(buildScreen());

      // 초기: 모두 선택 → "전체 해제" 탭
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 0/3개 확인
      expect(find.text('0/3개'), findsOneWidget);

      // 저장 버튼 비활성화 확인
      // FilledButton.icon은 서브클래스를 생성하므로 byWidgetPredicate 사용
      final saveButtonFinder = find.byWidgetPredicate(
        (widget) => widget is FilledButton,
      );
      expect(saveButtonFinder, findsOneWidget);

      final saveButton = tester.widget<FilledButton>(saveButtonFinder);
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('매장명/구매일이 있으면 상단에 표시된다', (tester) async {
      await tester.pumpWidget(buildScreen(
        ocrResult: createOcrResult(
          storeName: '홈플러스',
          purchaseDate: DateTime(2026, 2, 20),
        ),
      ));

      expect(find.text('홈플러스'), findsOneWidget);
      expect(find.text('2026.02.20'), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(1));
    });

    testWidgets('빈 재료 목록일 때 빈 상태 메시지 표시', (tester) async {
      await tester.pumpWidget(buildScreen(
        ocrResult: createOcrResult(ingredients: []),
      ));

      expect(find.text('인식된 재료가 없습니다.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('OCR 신뢰도 배지(높음/보통/낮음) 표시', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.text('높음'), findsOneWidget);
      expect(find.text('보통'), findsOneWidget);
      expect(find.text('낮음'), findsOneWidget);
    });

    testWidgets('DI로 주입된 IngredientService가 정상 동작한다', (tester) async {
      final fakeService = FakeIngredientService();

      await tester.pumpWidget(buildScreen(
        ingredientService: fakeService,
      ));

      // 위젯이 정상적으로 렌더링됨 (DI 성공)
      expect(find.text('인식된 재료'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('매장명/구매일이 없으면 상단 정보 영역이 표시되지 않는다', (tester) async {
      await tester.pumpWidget(buildScreen(
        ocrResult: ReceiptOcrResult(
          ingredients: [
            Ingredient(
              name: '사과',
              category: 'fruit',
              expiryDate: DateTime(2026, 2, 27),
            ),
          ],
          storeName: null,
          purchaseDate: null,
        ),
      ));

      expect(find.byIcon(Icons.store), findsNothing);
    });
  });
}
