import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/screens/recipe_detail_screen.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeRecipeService fakeRecipeService;
  late FakeShoppingService fakeShoppingService;

  setUp(() {
    fakeRecipeService = FakeRecipeService();
    fakeShoppingService = FakeShoppingService();
  });

  Widget buildSubject(Recipe recipe) {
    return wrapWithMaterialApp(
      RecipeDetailScreen(
        recipe: recipe,
        recipeService: fakeRecipeService,
        shoppingService: fakeShoppingService,
      ),
    );
  }

  group('RecipeDetailScreen', () {
    testWidgets('제목과 설명 표시', (tester) async {
      final recipe = createTestRecipe(
        title: '김치찌개',
        description: '맛있는 김치찌개',
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      // AppBar + header both show title
      expect(find.text('김치찌개'), findsAtLeast(1));
      expect(find.text('맛있는 김치찌개'), findsOneWidget);
    });

    testWidgets('난이도/시간/인분 뱃지 표시', (tester) async {
      final recipe = createTestRecipe(
        difficulty: RecipeDifficulty.medium,
        cookingTime: 30,
        servings: 4,
        cuisine: '한식',
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('보통'), findsOneWidget);
      expect(find.text('30분'), findsOneWidget);
      expect(find.text('4인분'), findsOneWidget);
      expect(find.text('한식'), findsOneWidget);
    });

    testWidgets('재료 섹션 가용/부족 아이콘 표시', (tester) async {
      final recipe = createTestRecipe(
        ingredients: [
          createTestRecipeIngredient(name: '양파', isAvailable: true),
          createTestRecipeIngredient(name: '당근', isAvailable: false),
        ],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('재료'), findsOneWidget);
      expect(find.text('양파'), findsOneWidget);
      expect(find.text('당근'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('부족한 재료 쇼핑리스트 버튼 표시', (tester) async {
      final recipe = createTestRecipe(
        ingredients: [
          createTestRecipeIngredient(name: '양파', isAvailable: false),
          createTestRecipeIngredient(name: '당근', isAvailable: false),
        ],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.textContaining('쇼핑리스트 담기'), findsOneWidget);
    });

    testWidgets('쇼핑리스트 담기 버튼 클릭 시 ShoppingService 호출', (tester) async {
      final recipe = createTestRecipe(
        ingredients: [
          createTestRecipeIngredient(name: '양파', isAvailable: false),
        ],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('쇼핑리스트 담기'));
      await tester.pumpAndSettle();

      expect(fakeShoppingService.addItemsCalled, isTrue);
    });

    testWidgets('조리 순서 섹션 표시', (tester) async {
      final recipe = createTestRecipe(
        instructions: [
          createTestInstruction(step: 1, title: '재료 준비', time: 5),
          createTestInstruction(step: 2, title: '볶기', time: 10),
        ],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('조리 순서'), findsOneWidget);
      expect(find.text('재료 준비'), findsOneWidget);
      expect(find.text('볶기'), findsOneWidget);
      expect(find.text('5분'), findsOneWidget);
      expect(find.text('10분'), findsOneWidget);
    });

    testWidgets('조리 팁 표시', (tester) async {
      final recipe = createTestRecipe(
        instructions: [
          createTestInstruction(
            step: 1,
            title: '볶기',
            tips: '센 불에서 빠르게 볶으세요',
          ),
        ],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('센 불에서 빠르게 볶으세요'), findsOneWidget);
    });

    testWidgets('영양 정보 표시 (nutrition이 있을 때)', (tester) async {
      final recipe = createTestRecipe(
        nutrition: NutritionInfo(
          calories: 500,
          protein: 20,
          carbs: 60,
          fat: 15,
        ),
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('영양 정보'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('영양 정보 미표시 (nutrition이 null일 때)', (tester) async {
      final recipe = createTestRecipe(nutrition: null);
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('영양 정보'), findsNothing);
    });

    testWidgets('셰프 노트 표시 (chefNote가 있을 때)', (tester) async {
      final recipe = createTestRecipe(chefNote: '맛있게 드세요!');
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('셰프 노트'), findsOneWidget);
      expect(find.text('맛있게 드세요!'), findsOneWidget);
    });

    testWidgets('셰프 노트 미표시 (chefNote가 null일 때)', (tester) async {
      final recipe = createTestRecipe(chefNote: null);
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('셰프 노트'), findsNothing);
    });

    testWidgets('저장 버튼 표시 (미저장 레시피)', (tester) async {
      final recipe = createTestRecipe(id: null);
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
    });

    testWidgets('북마크 버튼 표시', (tester) async {
      final recipe = createTestRecipe(id: 'saved-1', isBookmarked: false);
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('요리 시작 FAB 표시 (instructions가 있을 때)', (tester) async {
      final recipe = createTestRecipe(
        instructions: [createTestInstruction()],
      );
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('요리 시작'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}
