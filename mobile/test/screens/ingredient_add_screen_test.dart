import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/screens/ingredient_add_screen.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;

  setUp(() {
    fakeIngredientService = FakeIngredientService();
  });

  Widget buildSubject({Ingredient? ingredient}) {
    return wrapWithMaterialApp(
      IngredientAddScreen(
        ingredient: ingredient,
        ingredientService: fakeIngredientService,
      ),
    );
  }

  group('IngredientAddScreen', () {
    testWidgets('추가 모드 AppBar 제목', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('재료 추가'), findsOneWidget);
    });

    testWidgets('수정 모드 AppBar 제목', (tester) async {
      final ingredient = createTestIngredient(name: '양파');
      await tester.pumpWidget(buildSubject(ingredient: ingredient));
      await tester.pumpAndSettle();
      expect(find.text('재료 수정'), findsOneWidget);
    });

    testWidgets('재료명 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('재료명 *'), findsOneWidget);
    });

    testWidgets('카테고리 드롭다운 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('카테고리'), findsOneWidget);
    });

    testWidgets('수량 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('수량'), findsOneWidget);
    });

    testWidgets('단위 드롭다운 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('단위'), findsOneWidget);
    });

    testWidgets('보관 위치 SegmentedButton 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('보관 위치'), findsOneWidget);
      expect(find.byType(SegmentedButton<StorageLocation>), findsOneWidget);
    });

    testWidgets('유통기한 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('유통기한 *'), findsOneWidget);
    });

    testWidgets('구매일 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('구매일'), findsOneWidget);
    });

    testWidgets('가격 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('가격 (원)'), findsOneWidget);
    });

    testWidgets('메모 필드 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Scroll down to reveal the memo field
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('메모'), findsOneWidget);
    });

    testWidgets('저장 버튼 렌더링', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('수정 모드 프리필', (tester) async {
      final ingredient = Ingredient(
        id: 'edit-1',
        name: '삼겹살',
        category: 'meat',
        quantity: 500,
        unit: 'g',
        expiryDate: DateTime(2026, 3, 1),
        storageLocation: StorageLocation.fridge,
        purchaseDate: DateTime(2026, 2, 20),
        price: 15000,
        memo: '마트에서 구매',
      );
      await tester.pumpWidget(buildSubject(ingredient: ingredient));
      await tester.pumpAndSettle();

      // TextFormField values visible in viewport
      expect(find.text('삼겹살'), findsOneWidget);
      expect(find.text('500.0'), findsOneWidget);

      // Scroll down to see price and memo
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('15000'), findsOneWidget);
      expect(find.text('마트에서 구매'), findsOneWidget);
    });

    testWidgets('재료명 빈칸 검증 오류', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 재료명 비우기
      final nameField = find.widgetWithText(TextFormField, '재료명 *');
      await tester.enterText(nameField, '');

      // 저장 탭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('재료명을 입력해주세요'), findsOneWidget);
    });

    testWidgets('닫기 버튼 표시', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
