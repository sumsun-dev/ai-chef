import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/recipe_card.dart';
import 'package:ai_chef/models/recipe.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late Recipe testRecipe;

  setUp(() {
    testRecipe = Recipe(
      title: '김치찌개',
      description: '깊고 진한 맛의 김치찌개입니다',
      cuisine: '한식',
      difficulty: RecipeDifficulty.easy,
      cookingTime: 30,
      servings: 2,
      ingredients: [],
      tools: [],
      instructions: [],
    );
  });

  group('RecipeCard', () {
    testWidgets('title을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.text('김치찌개'), findsOneWidget);
    });

    testWidgets('description을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.text('깊고 진한 맛의 김치찌개입니다'), findsOneWidget);
    });

    testWidgets('cookingTime 뱃지를 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.text('30분'), findsOneWidget);
    });

    testWidgets('difficulty 라벨을 한글로 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.text('쉬움'), findsOneWidget);
    });

    testWidgets('servings 뱃지를 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.text('2인분'), findsOneWidget);
    });

    testWidgets('onTap 콜백이 호출된다', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(
            recipe: testRecipe,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('trailing이 없으면 arrow_forward_ios 아이콘을 표시한다',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(recipe: testRecipe, onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('trailing이 있으면 커스텀 위젯을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecipeCard(
            recipe: testRecipe,
            onTap: () {},
            trailing: const Icon(Icons.bookmark),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });
  });
}
