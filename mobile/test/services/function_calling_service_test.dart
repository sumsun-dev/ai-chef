import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:ai_chef/models/ai_response.dart';
import 'package:ai_chef/services/function_calling_service.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;
  late FakeRecipeService fakeRecipeService;
  late FunctionCallingService service;

  setUp(() {
    fakeIngredientService = FakeIngredientService(
      ingredients: [
        createTestIngredient(name: '양파'),
        createTestIngredient(name: '당근', category: 'vegetable'),
      ],
    );
    fakeRecipeService = FakeRecipeService();
    service = FunctionCallingService(
      ingredientService: fakeIngredientService,
      recipeService: fakeRecipeService,
    );
  });

  group('FunctionCallingService', () {
    test('functionDeclarations는 5개 함수를 정의한다', () {
      expect(service.functionDeclarations.length, 5);
      final names =
          service.functionDeclarations.map((d) => d.name).toList();
      expect(names, containsAll([
        'get_user_ingredients',
        'get_expiring_ingredients',
        'search_ingredients',
        'generate_recipe',
        'bookmark_recipe',
      ]));
    });

    test('tools는 Tool 리스트를 반환한다', () {
      expect(service.tools.length, 1);
      expect(service.tools.first.functionDeclarations, isNotNull);
    });

    group('dispatch', () {
      test('get_user_ingredients는 재료 목록을 반환한다', () async {
        final call = FunctionCall('get_user_ingredients', {});
        final result = await service.dispatch(call);

        expect(result.name, 'get_user_ingredients');
        expect(result.response['totalCount'], 2);
        final ingredients = result.response['ingredients'] as List;
        expect(ingredients.length, 2);
      });

      test('get_expiring_ingredients는 임박 재료를 반환한다', () async {
        final call = FunctionCall('get_expiring_ingredients', {'days': 3});
        final result = await service.dispatch(call);

        expect(result.name, 'get_expiring_ingredients');
        expect(result.response.containsKey('ingredients'), true);
        expect(result.response.containsKey('count'), true);
      });

      test('search_ingredients는 검색 결과를 반환한다', () async {
        final call = FunctionCall('search_ingredients', {'query': '양파'});
        final result = await service.dispatch(call);

        expect(result.name, 'search_ingredients');
        expect(result.response.containsKey('ingredients'), true);
      });

      test('generate_recipe는 재료 정보를 반환한다', () async {
        final call = FunctionCall('generate_recipe', {
          'cuisine': '한식',
          'difficulty': 'easy',
        });
        final result = await service.dispatch(call);

        expect(result.name, 'generate_recipe');
        final available =
            result.response['availableIngredients'] as List;
        expect(available.length, 2);
        expect(result.response['requestedCuisine'], '한식');
      });

      test('bookmark_recipe는 북마크를 토글한다', () async {
        final call = FunctionCall('bookmark_recipe', {
          'recipeId': 'recipe-1',
          'isBookmarked': true,
        });
        final result = await service.dispatch(call);

        expect(result.name, 'bookmark_recipe');
        expect(result.response['success'], true);
        expect(result.response['isBookmarked'], true);
      });

      test('알 수 없는 함수는 에러를 반환한다', () async {
        final call = FunctionCall('unknown_function', {});
        final result = await service.dispatch(call);

        expect(result.response['error'], contains('알 수 없는 함수'));
      });
    });

    group('parseResponseMetadata', () {
      test('get_user_ingredients는 IngredientListResponse를 반환한다', () {
        final response = service.parseResponseMetadata(
          'get_user_ingredients',
          {
            'ingredients': [
              {
                'name': '양파',
                'category': 'vegetable',
                'quantity': 3.0,
                'unit': '개',
                'expiryDate': DateTime.now().toIso8601String(),
              },
            ],
            'totalCount': 1,
          },
        );

        expect(response, isA<IngredientListResponse>());
        final ingredientResponse = response as IngredientListResponse;
        expect(ingredientResponse.ingredients.length, 1);
        expect(ingredientResponse.ingredients.first.name, '양파');
      });

      test('bookmark_recipe 성공은 ActionResponse를 반환한다', () {
        final response = service.parseResponseMetadata(
          'bookmark_recipe',
          {'success': true, 'recipeId': 'r1', 'isBookmarked': true},
        );

        expect(response, isA<ActionResponse>());
        final actionResponse = response as ActionResponse;
        expect(actionResponse.success, true);
        expect(actionResponse.actionType, 'bookmark');
      });

      test('bookmark_recipe 실패는 실패 ActionResponse를 반환한다', () {
        final response = service.parseResponseMetadata(
          'bookmark_recipe',
          {'success': false, 'error': '권한 없음'},
        );

        expect(response, isA<ActionResponse>());
        expect((response as ActionResponse).success, false);
      });
    });

    group('FunctionCallResult', () {
      test('toFunctionResponse는 FunctionResponse를 생성한다', () {
        final result = FunctionCallResult(
          name: 'test_func',
          response: {'data': 'value'},
        );

        final funcResponse = result.toFunctionResponse();
        expect(funcResponse, isA<FunctionResponse>());
      });
    });
  });
}
