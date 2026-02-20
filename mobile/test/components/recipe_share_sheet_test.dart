import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/components/recipe_share_sheet.dart';
import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/services/recipe_sharing_service.dart';
import '../helpers/widget_test_helpers.dart';

/// share_plus 호출을 방지하는 Fake
class _FakeRecipeSharingService extends RecipeSharingService {
  bool shareCalled = false;

  @override
  Future<void> shareRecipe(Recipe recipe) async {
    shareCalled = true;
  }
}

void main() {
  late _FakeRecipeSharingService fakeSharingService;

  setUp(() {
    fakeSharingService = _FakeRecipeSharingService();
  });

  Widget buildSubject(Recipe recipe) {
    return wrapWithMaterialApp(
      Scaffold(
        body: RecipeShareSheet(
          recipe: recipe,
          sharingService: fakeSharingService,
        ),
      ),
    );
  }

  group('RecipeShareSheet', () {
    testWidgets('제목 표시', (tester) async {
      final recipe = createTestRecipe(title: '김치찌개');
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('레시피 공유'), findsOneWidget);
    });

    testWidgets('미리보기 텍스트에 레시피 내용 포함', (tester) async {
      final recipe = createTestRecipe(title: '비빔밥', description: '건강한 비빔밥');
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.textContaining('비빔밥'), findsAtLeast(1));
    });

    testWidgets('공유하기 버튼 표시', (tester) async {
      final recipe = createTestRecipe();
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      expect(find.text('공유하기'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsAtLeast(1));
    });

    testWidgets('공유하기 버튼 클릭 시 shareRecipe 호출', (tester) async {
      final recipe = createTestRecipe();
      await tester.pumpWidget(buildSubject(recipe));
      await tester.pumpAndSettle();

      await tester.tap(find.text('공유하기'));
      await tester.pumpAndSettle();

      expect(fakeSharingService.shareCalled, isTrue);
    });
  });
}
