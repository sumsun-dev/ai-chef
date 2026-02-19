import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/tabs/recipe_tab.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('RecipeTab', () {
    testWidgets('재료 없을 때 등록 안내 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(RecipeTab(
          ingredientService: FakeIngredientService(ingredients: []),
          authService: FakeAuthService(profileData: createTestProfile()),
          recipeService: FakeRecipeService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('냉장고에 재료를 등록하면\n맞춤 레시피를 추천해드려요'), findsOneWidget);
      expect(find.text('재료 등록하기'), findsOneWidget);
    });

    testWidgets('재료 있을 때 추천 조건과 버튼 표시', (tester) async {
      final ingredient = createTestIngredient();
      await tester.pumpWidget(
        wrapWithMaterialApp(RecipeTab(
          ingredientService: FakeIngredientService(ingredients: [ingredient]),
          authService: FakeAuthService(profileData: createTestProfile()),
          recipeService: FakeRecipeService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('추천 조건'), findsOneWidget);
      expect(find.text('레시피 추천받기'), findsOneWidget);
    });

    testWidgets('탭 3개 (추천/저장됨/기록) 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(RecipeTab(
          ingredientService: FakeIngredientService(),
          authService: FakeAuthService(profileData: createTestProfile()),
          recipeService: FakeRecipeService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      expect(find.text('추천'), findsOneWidget);
      expect(find.text('저장됨'), findsOneWidget);
      expect(find.text('기록'), findsOneWidget);
    });

    testWidgets('저장됨 탭 빈 상태 메시지 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(RecipeTab(
          ingredientService: FakeIngredientService(),
          authService: FakeAuthService(profileData: createTestProfile()),
          recipeService: FakeRecipeService(),
          toolService: FakeToolService(),
        )),
      );

      await tester.pumpAndSettle();

      // 저장됨 탭으로 이동
      await tester.tap(find.text('저장됨'));
      await tester.pumpAndSettle();

      expect(find.text('저장한 레시피가 없어요'), findsOneWidget);
    });
  });
}
