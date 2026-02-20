import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/screens/cooking_mode_screen.dart';
import '../helpers/widget_test_helpers.dart';

Recipe _createTestRecipe() {
  return Recipe(
    id: 'test-recipe',
    title: '김치찌개',
    description: '맛있는 김치찌개',
    cuisine: '한식',
    difficulty: RecipeDifficulty.easy,
    cookingTime: 30,
    servings: 2,
    ingredients: [],
    tools: [],
    instructions: [
      RecipeInstruction(
        step: 1,
        title: '재료 준비',
        description: '김치를 썰어주세요',
        time: 5,
        tips: '잘 익은 김치를 사용하세요',
      ),
      RecipeInstruction(
        step: 2,
        title: '볶기',
        description: '김치를 볶아주세요',
        time: 3,
      ),
      RecipeInstruction(
        step: 3,
        title: '끓이기',
        description: '물을 넣고 끓여주세요',
        time: 10,
      ),
    ],
  );
}

void main() {
  group('CookingModeScreen', () {
    testWidgets('레시피 제목을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('김치찌개'), findsOneWidget);
    });

    testWidgets('첫 단계 제목과 설명을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('재료 준비'), findsOneWidget);
      expect(find.text('김치를 썰어주세요'), findsOneWidget);
    });

    testWidgets('단계 번호와 페이지 카운터를 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('타이머가 표시된다 (time > 0)', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('팁이 있으면 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('잘 익은 김치를 사용하세요'), findsOneWidget);
    });

    testWidgets('"완료" 버튼을 탭하면 다음 단계로 이동', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(find.text('볶기'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('진행률 표시기가 존재한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('첫 단계에서는 "이전" 버튼이 없다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
        )),
      );

      expect(find.text('이전'), findsNothing);
    });

    testWidgets('두 번째 단계에서 "이전" 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: FakeTtsService(),
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(find.text('이전'), findsOneWidget);
    });

    testWidgets('TTS 토글 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: FakeTtsService(),
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('TTS 토글 시 아이콘이 변경되고 speak이 호출된다', (tester) async {
      final fakeTts = FakeTtsService();

      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: fakeTts,
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(fakeTts.speakCallCount, greaterThan(0));
    });

    testWidgets('TTS 비활성화 시 stop이 호출된다', (tester) async {
      final fakeTts = FakeTtsService();

      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: fakeTts,
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      // 활성화
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pumpAndSettle();

      // 비활성화
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();

      expect(fakeTts.stopCalled, isTrue);
    });

    testWidgets('음성 명령 버튼이 존재한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: FakeTtsService(),
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('모든 단계 완료 시 완료 다이얼로그가 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: _createTestRecipe(),
          recipeService: FakeRecipeService(),
          ttsService: FakeTtsService(),
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();
      }

      expect(find.text('요리 완료!'), findsAtLeast(1));
      expect(find.text('확인'), findsAtLeast(1));
    });

    testWidgets('빈 instructions 레시피도 안전하게 렌더링된다', (tester) async {
      final emptyRecipe = Recipe(
        title: '빈 레시피',
        description: '단계 없음',
        cuisine: '한식',
        difficulty: RecipeDifficulty.easy,
        cookingTime: 0,
        servings: 1,
        ingredients: [],
        tools: [],
        instructions: [],
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(CookingModeScreen(
          recipe: emptyRecipe,
          recipeService: FakeRecipeService(),
          ttsService: FakeTtsService(),
          voiceCommandService: FakeVoiceCommandService(),
          audioService: FakeCookingAudioService(),
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('빈 레시피'), findsOneWidget);
    });
  });
}
