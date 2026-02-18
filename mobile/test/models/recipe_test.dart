import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/recipe.dart';

void main() {
  Map<String, dynamic> sampleGeminiJson() {
    return {
      'title': '김치볶음밥',
      'description': '간단하고 맛있는 김치볶음밥',
      'cuisine': '한식',
      'difficulty': 'easy',
      'cookingTime': 15,
      'servings': 2,
      'ingredients': [
        {'name': '김치', 'quantity': '200', 'unit': 'g', 'isAvailable': true},
        {'name': '밥', 'quantity': '2', 'unit': '공기', 'isAvailable': true},
      ],
      'tools': [
        {'name': '프라이팬', 'isAvailable': true},
      ],
      'instructions': [
        {
          'step': 1,
          'title': '김치 썰기',
          'description': '김치를 잘게 썰어주세요.',
          'time': 3,
          'tips': '잘게 썰수록 볶기 쉬워요',
        },
        {
          'step': 2,
          'title': '볶기',
          'description': '프라이팬에 기름을 두르고 볶아주세요.',
          'time': 10,
        },
      ],
      'nutrition': {
        'calories': 450,
        'protein': 12,
        'carbs': 65,
        'fat': 15,
      },
      'chefNote': '김치가 잘 익었을수록 맛있어요!',
    };
  }

  Map<String, dynamic> sampleDbJson() {
    return {
      'id': 'uuid-123',
      'title': '김치볶음밥',
      'description': '간단하고 맛있는 김치볶음밥',
      'cuisine': '한식',
      'difficulty': 'easy',
      'cooking_time': 15,
      'servings': 2,
      'ingredients': [
        {'name': '김치', 'quantity': '200', 'unit': 'g', 'is_available': true},
      ],
      'tools': [
        {'name': '프라이팬', 'is_available': true},
      ],
      'instructions': [
        {
          'step': 1,
          'title': '김치 썰기',
          'description': '김치를 잘게 썰어주세요.',
          'time': 3,
        },
      ],
      'nutrition': {
        'calories': 450,
        'protein': 12,
        'carbs': 65,
        'fat': 15,
      },
      'chef_note': '김치가 잘 익었을수록 맛있어요!',
      'user_id': 'user-abc',
      'chef_id': 'baek',
      'is_bookmarked': true,
      'created_at': '2026-02-18T12:00:00.000Z',
    };
  }

  group('Recipe', () {
    group('fromJson (Gemini camelCase)', () {
      test('Gemini 응답을 올바르게 파싱한다', () {
        final recipe = Recipe.fromJson(sampleGeminiJson());

        expect(recipe.title, '김치볶음밥');
        expect(recipe.description, '간단하고 맛있는 김치볶음밥');
        expect(recipe.cuisine, '한식');
        expect(recipe.difficulty, RecipeDifficulty.easy);
        expect(recipe.cookingTime, 15);
        expect(recipe.servings, 2);
        expect(recipe.ingredients.length, 2);
        expect(recipe.tools.length, 1);
        expect(recipe.instructions.length, 2);
        expect(recipe.nutrition, isNotNull);
        expect(recipe.chefNote, '김치가 잘 익었을수록 맛있어요!');
      });

      test('isBookmarked 기본값은 false이다', () {
        final recipe = Recipe.fromJson(sampleGeminiJson());

        expect(recipe.isBookmarked, isFalse);
        expect(recipe.id, isNull);
        expect(recipe.userId, isNull);
      });
    });

    group('fromJson (DB snake_case)', () {
      test('DB 응답을 올바르게 파싱한다', () {
        final recipe = Recipe.fromJson(sampleDbJson());

        expect(recipe.id, 'uuid-123');
        expect(recipe.cookingTime, 15);
        expect(recipe.chefNote, '김치가 잘 익었을수록 맛있어요!');
        expect(recipe.userId, 'user-abc');
        expect(recipe.chefId, 'baek');
        expect(recipe.isBookmarked, isTrue);
        expect(recipe.createdAt, isNotNull);
        expect(recipe.createdAt!.year, 2026);
      });

      test('snake_case is_available를 올바르게 파싱한다', () {
        final recipe = Recipe.fromJson(sampleDbJson());

        expect(recipe.ingredients.first.isAvailable, isTrue);
        expect(recipe.tools.first.isAvailable, isTrue);
      });
    });

    group('toJson', () {
      test('올바르게 직렬화한다 (snake_case)', () {
        final recipe = Recipe.fromJson(sampleGeminiJson());
        final json = recipe.toJson();

        expect(json['title'], '김치볶음밥');
        expect(json['cooking_time'], 15);
        expect(json['difficulty'], 'easy');
        expect(json['is_bookmarked'], false);
        expect(json['ingredients'], isA<List>());
        expect(json['nutrition'], isA<Map>());
      });

      test('null 필드는 포함하지 않는다', () {
        final recipe = Recipe.fromJson(sampleGeminiJson());
        final json = recipe.toJson();

        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('chef_id'), isFalse);
      });
    });

    group('round-trip', () {
      test('toJson → fromJson round-trip이 동작한다', () {
        final original = Recipe.fromJson(sampleGeminiJson());
        final json = original.toJson();
        final restored = Recipe.fromJson(json);

        expect(restored.title, original.title);
        expect(restored.cookingTime, original.cookingTime);
        expect(restored.difficulty, original.difficulty);
        expect(restored.ingredients.length, original.ingredients.length);
        expect(restored.instructions.length, original.instructions.length);
      });
    });

    group('copyWith', () {
      test('isBookmarked를 변경할 수 있다', () {
        final original = Recipe.fromJson(sampleGeminiJson());

        final updated = original.copyWith(isBookmarked: true);

        expect(updated.isBookmarked, isTrue);
        expect(updated.title, original.title);
      });

      test('여러 필드를 동시에 변경할 수 있다', () {
        final original = Recipe.fromJson(sampleGeminiJson());

        final updated = original.copyWith(
          id: 'new-id',
          userId: 'user-123',
          chefId: 'gordon',
        );

        expect(updated.id, 'new-id');
        expect(updated.userId, 'user-123');
        expect(updated.chefId, 'gordon');
        expect(updated.title, original.title);
      });
    });

    group('difficulty parsing', () {
      test('easy를 올바르게 파싱한다', () {
        final json = sampleGeminiJson()..['difficulty'] = 'easy';
        expect(Recipe.fromJson(json).difficulty, RecipeDifficulty.easy);
      });

      test('medium을 올바르게 파싱한다', () {
        final json = sampleGeminiJson()..['difficulty'] = 'medium';
        expect(Recipe.fromJson(json).difficulty, RecipeDifficulty.medium);
      });

      test('hard를 올바르게 파싱한다', () {
        final json = sampleGeminiJson()..['difficulty'] = 'hard';
        expect(Recipe.fromJson(json).difficulty, RecipeDifficulty.hard);
      });

      test('알 수 없는 값은 easy로 기본 처리한다', () {
        final json = sampleGeminiJson()..['difficulty'] = 'unknown';
        expect(Recipe.fromJson(json).difficulty, RecipeDifficulty.easy);
      });
    });
  });

  group('RecipeIngredient round-trip', () {
    test('toJson → fromJson이 동작한다', () {
      final original = RecipeIngredient(
        name: '김치',
        quantity: '200',
        unit: 'g',
        isAvailable: true,
        substitute: '깍두기',
      );

      final json = original.toJson();
      final restored = RecipeIngredient.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.quantity, original.quantity);
      expect(restored.unit, original.unit);
      expect(restored.isAvailable, original.isAvailable);
      expect(restored.substitute, original.substitute);
    });
  });

  group('RecipeTool round-trip', () {
    test('toJson → fromJson이 동작한다', () {
      final original = RecipeTool(
        name: '프라이팬',
        isAvailable: true,
        alternative: '냄비',
      );

      final json = original.toJson();
      final restored = RecipeTool.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.isAvailable, original.isAvailable);
      expect(restored.alternative, original.alternative);
    });
  });

  group('RecipeInstruction round-trip', () {
    test('toJson → fromJson이 동작한다', () {
      final original = RecipeInstruction(
        step: 1,
        title: '준비',
        description: '재료를 준비합니다',
        time: 5,
        tips: '신선한 재료를 사용하세요',
      );

      final json = original.toJson();
      final restored = RecipeInstruction.fromJson(json);

      expect(restored.step, original.step);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.time, original.time);
      expect(restored.tips, original.tips);
    });
  });

  group('NutritionInfo round-trip', () {
    test('toJson → fromJson이 동작한다', () {
      final original = NutritionInfo(
        calories: 450,
        protein: 12,
        carbs: 65,
        fat: 15,
      );

      final json = original.toJson();
      final restored = NutritionInfo.fromJson(json);

      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.carbs, original.carbs);
      expect(restored.fat, original.fat);
    });
  });
}
