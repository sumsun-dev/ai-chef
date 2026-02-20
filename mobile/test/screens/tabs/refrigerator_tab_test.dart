import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/screens/tabs/refrigerator_tab.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;

  setUp(() {
    fakeIngredientService = FakeIngredientService();
  });

  Widget buildSubject({List<Ingredient>? ingredients}) {
    if (ingredients != null) {
      fakeIngredientService = FakeIngredientService(ingredients: ingredients);
    }
    return wrapWithMaterialApp(
      RefrigeratorTab(ingredientService: fakeIngredientService),
    );
  }

  group('RefrigeratorTab', () {
    testWidgets('로딩 중 CircularProgressIndicator 표시', (tester) async {
      final completer = Completer<List<Ingredient>>();
      fakeIngredientService = _CompleterIngredientService(completer);
      await tester.pumpWidget(wrapWithMaterialApp(
        RefrigeratorTab(ingredientService: fakeIngredientService),
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Complete the future to clean up pending timers
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('빈 상태에서 EmptyState 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();
      expect(find.text('냉장고가 비어있어요'), findsOneWidget);
      expect(find.text('재료 추가하기'), findsOneWidget);
    });

    testWidgets('재료 리스트 표시', (tester) async {
      final ingredients = [
        createTestIngredient(name: '양파', category: 'vegetable'),
        createTestIngredient(name: '우유', category: 'dairy'),
      ];
      await tester.pumpWidget(buildSubject(ingredients: ingredients));
      await tester.pumpAndSettle();
      expect(find.text('양파'), findsOneWidget);
      expect(find.text('우유'), findsOneWidget);
    });

    testWidgets('AppBar에 냉장고 제목 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();
      expect(find.text('냉장고'), findsOneWidget);
    });

    testWidgets('위치 필터 SegmentedButton 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
      expect(find.textContaining('전체'), findsWidgets);
      expect(find.textContaining('냉장'), findsWidgets);
      expect(find.textContaining('냉동'), findsWidgets);
      expect(find.textContaining('실온'), findsWidgets);
    });

    testWidgets('위치 필터로 냉동만 표시', (tester) async {
      final ingredients = [
        createTestIngredient(name: '양파', category: 'vegetable'),
        _createIngredientWithLocation('아이스크림', StorageLocation.freezer),
      ];
      await tester.pumpWidget(buildSubject(ingredients: ingredients));
      await tester.pumpAndSettle();

      // 처음에 양파와 아이스크림 둘 다 표시
      expect(find.widgetWithText(Card, '양파'), findsOneWidget);
      expect(find.widgetWithText(Card, '아이스크림'), findsOneWidget);

      // 냉동 필터 선택 (🧊 냉동)
      await tester.tap(find.text('🧊 냉동'));
      await tester.pumpAndSettle();

      // 냉동 필터 후 아이스크림만 표시
      expect(find.widgetWithText(Card, '아이스크림'), findsOneWidget);
      expect(find.widgetWithText(Card, '양파'), findsNothing);
    });

    testWidgets('카테고리 FilterChip 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('검색 토글 동작', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();

      // 검색 아이콘 탭
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('재료 검색...'), findsOneWidget);
    });

    testWidgets('검색으로 재료 필터링', (tester) async {
      final ingredients = [
        createTestIngredient(name: '양파', category: 'vegetable'),
        createTestIngredient(name: '감자', category: 'vegetable'),
      ];
      await tester.pumpWidget(buildSubject(ingredients: ingredients));
      await tester.pumpAndSettle();

      // 검색 모드 활성화
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 검색어 입력
      await tester.enterText(find.byType(TextField), '양파');
      await tester.pumpAndSettle();

      // 양파 appears both in ListTile and TextField, so use ListTile match
      expect(find.widgetWithText(Card, '양파'), findsOneWidget);
      expect(find.widgetWithText(Card, '감자'), findsNothing);
    });

    testWidgets('정렬 메뉴 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('유통기한순'), findsOneWidget);
      expect(find.text('이름순'), findsOneWidget);
      expect(find.text('카테고리순'), findsOneWidget);
    });

    testWidgets('유통기한 임박 경고 배너 표시', (tester) async {
      final ingredients = [
        createTestIngredient(
          name: '상한 우유',
          category: 'dairy',
          expiryDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ];
      await tester.pumpWidget(buildSubject(ingredients: ingredients));
      await tester.pumpAndSettle();

      expect(find.textContaining('유통기한 임박'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('FAB 재료 추가 버튼 표시', (tester) async {
      await tester.pumpWidget(buildSubject(ingredients: []));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('재료 추가'), findsOneWidget);
    });

    testWidgets('검색 결과 없을 때 검색 EmptyState 표시', (tester) async {
      final ingredients = [
        createTestIngredient(name: '양파', category: 'vegetable'),
      ];
      await tester.pumpWidget(buildSubject(ingredients: ingredients));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '없는재료');
      await tester.pumpAndSettle();

      expect(find.text('검색 결과가 없어요'), findsOneWidget);
    });
  });
}

class _CompleterIngredientService extends FakeIngredientService {
  final Completer<List<Ingredient>> completer;

  _CompleterIngredientService(this.completer);

  @override
  Future<List<Ingredient>> getUserIngredients() => completer.future;
}

Ingredient _createIngredientWithLocation(String name, StorageLocation location) {
  return Ingredient(
    id: 'test-$name',
    name: name,
    category: 'other',
    quantity: 1,
    unit: '개',
    expiryDate: DateTime.now().add(const Duration(days: 30)),
    storageLocation: location,
    purchaseDate: DateTime.now(),
  );
}
