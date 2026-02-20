import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/ai_response.dart';
import '../models/ingredient.dart';
import 'ingredient_service.dart';
import 'recipe_service.dart';

/// Function Calling 서비스
///
/// Gemini의 FunctionDeclaration을 정의하고,
/// FunctionCall을 실제 서비스로 dispatch 합니다.
class FunctionCallingService {
  final IngredientService _ingredientService;
  final RecipeService _recipeService;

  FunctionCallingService({
    IngredientService? ingredientService,
    RecipeService? recipeService,
  })  : _ingredientService = ingredientService ?? IngredientService(),
        _recipeService = recipeService ?? RecipeService();

  /// Function Declaration 목록
  List<Tool> get tools => [
        Tool(functionDeclarations: functionDeclarations),
      ];

  /// 5개 Function Declaration 정의
  List<FunctionDeclaration> get functionDeclarations => [
        FunctionDeclaration(
          'get_user_ingredients',
          '사용자의 냉장고에 있는 재료 목록을 조회합니다.',
          Schema(SchemaType.object, properties: {}),
        ),
        FunctionDeclaration(
          'get_expiring_ingredients',
          '유통기한이 임박한 재료를 조회합니다.',
          Schema(SchemaType.object, properties: {
            'days': Schema(
              SchemaType.integer,
              description: '며칠 이내 만료 재료를 조회할지 (기본값: 7)',
            ),
          }),
        ),
        FunctionDeclaration(
          'search_ingredients',
          '재료를 이름으로 검색합니다.',
          Schema(SchemaType.object, properties: {
            'query': Schema(
              SchemaType.string,
              description: '검색할 재료 이름',
            ),
          }, requiredProperties: [
            'query'
          ]),
        ),
        FunctionDeclaration(
          'generate_recipe',
          '사용자의 재료로 맞춤 레시피를 생성합니다.',
          Schema(SchemaType.object, properties: {
            'cuisine': Schema(
              SchemaType.string,
              description: '요리 스타일 (예: 한식, 양식, 일식)',
            ),
            'difficulty': Schema(
              SchemaType.string,
              description: '난이도 (easy, medium, hard)',
            ),
            'maxCookingTime': Schema(
              SchemaType.integer,
              description: '최대 조리 시간 (분)',
            ),
          }),
        ),
        FunctionDeclaration(
          'bookmark_recipe',
          '레시피를 북마크에 추가하거나 제거합니다.',
          Schema(SchemaType.object, properties: {
            'recipeId': Schema(
              SchemaType.string,
              description: '레시피 ID',
            ),
            'isBookmarked': Schema(
              SchemaType.boolean,
              description: '북마크 여부',
            ),
          }, requiredProperties: [
            'recipeId',
            'isBookmarked'
          ]),
        ),
      ];

  /// FunctionCall을 dispatch하여 실행
  Future<FunctionCallResult> dispatch(FunctionCall call) async {
    switch (call.name) {
      case 'get_user_ingredients':
        return _getUserIngredients();
      case 'get_expiring_ingredients':
        return _getExpiringIngredients(call.args);
      case 'search_ingredients':
        return _searchIngredients(call.args);
      case 'generate_recipe':
        return _generateRecipeInfo(call.args);
      case 'bookmark_recipe':
        return _bookmarkRecipe(call.args);
      default:
        return FunctionCallResult(
          name: call.name,
          response: {'error': '알 수 없는 함수: ${call.name}'},
        );
    }
  }

  Future<FunctionCallResult> _getUserIngredients() async {
    try {
      final ingredients = await _ingredientService.getIngredients();
      return FunctionCallResult(
        name: 'get_user_ingredients',
        response: {
          'ingredients': ingredients
              .map((i) => {
                    'name': i.name,
                    'category': i.category,
                    'quantity': i.quantity,
                    'unit': i.unit,
                    'expiryDate': i.expiryDate.toIso8601String(),
                    'daysUntilExpiry': i.daysUntilExpiry,
                  })
              .toList(),
          'totalCount': ingredients.length,
        },
      );
    } catch (e) {
      return FunctionCallResult(
        name: 'get_user_ingredients',
        response: {'error': e.toString()},
      );
    }
  }

  Future<FunctionCallResult> _getExpiringIngredients(
      Map<String, Object?> args) async {
    try {
      final days = (args['days'] as num?)?.toInt() ?? 7;
      final ingredients =
          await _ingredientService.getExpiringIngredients(days: days);
      return FunctionCallResult(
        name: 'get_expiring_ingredients',
        response: {
          'ingredients': ingredients
              .map((i) => {
                    'name': i.name,
                    'expiryDate': i.expiryDate.toIso8601String(),
                    'daysUntilExpiry': i.daysUntilExpiry,
                    'quantity': i.quantity,
                    'unit': i.unit,
                  })
              .toList(),
          'count': ingredients.length,
        },
      );
    } catch (e) {
      return FunctionCallResult(
        name: 'get_expiring_ingredients',
        response: {'error': e.toString()},
      );
    }
  }

  Future<FunctionCallResult> _searchIngredients(
      Map<String, Object?> args) async {
    try {
      final query = args['query'] as String? ?? '';
      final ingredients = await _ingredientService.searchIngredients(query);
      return FunctionCallResult(
        name: 'search_ingredients',
        response: {
          'ingredients': ingredients
              .map((i) => {
                    'name': i.name,
                    'category': i.category,
                    'quantity': i.quantity,
                    'unit': i.unit,
                  })
              .toList(),
          'count': ingredients.length,
        },
      );
    } catch (e) {
      return FunctionCallResult(
        name: 'search_ingredients',
        response: {'error': e.toString()},
      );
    }
  }

  Future<FunctionCallResult> _generateRecipeInfo(
      Map<String, Object?> args) async {
    // 레시피 생성에 필요한 정보를 반환 (실제 생성은 GeminiService에서)
    try {
      final ingredients = await _ingredientService.getIngredients();
      return FunctionCallResult(
        name: 'generate_recipe',
        response: {
          'availableIngredients':
              ingredients.map((i) => i.name).toList(),
          'requestedCuisine': args['cuisine'],
          'requestedDifficulty': args['difficulty'],
          'maxCookingTime': args['maxCookingTime'],
          'ingredientCount': ingredients.length,
        },
      );
    } catch (e) {
      return FunctionCallResult(
        name: 'generate_recipe',
        response: {'error': e.toString()},
      );
    }
  }

  Future<FunctionCallResult> _bookmarkRecipe(
      Map<String, Object?> args) async {
    try {
      final recipeId = args['recipeId'] as String? ?? '';
      final isBookmarked = args['isBookmarked'] as bool? ?? true;
      await _recipeService.toggleBookmark(recipeId, isBookmarked);
      return FunctionCallResult(
        name: 'bookmark_recipe',
        response: {
          'success': true,
          'recipeId': recipeId,
          'isBookmarked': isBookmarked,
        },
      );
    } catch (e) {
      return FunctionCallResult(
        name: 'bookmark_recipe',
        response: {'error': e.toString(), 'success': false},
      );
    }
  }

  /// FunctionCallResult에서 AIResponse를 파싱
  AIResponse? parseResponseMetadata(
      String functionName, Map<String, Object?> responseData) {
    switch (functionName) {
      case 'get_user_ingredients':
      case 'get_expiring_ingredients':
      case 'search_ingredients':
        final ingredientsList = responseData['ingredients'];
        if (ingredientsList is! List) return null;

        final ingredients = <Ingredient>[];
        for (final item in ingredientsList) {
          if (item is! Map) continue;
          try {
            final name = item['name'] as String?;
            if (name == null || name.isEmpty) continue;

            DateTime expiryDate;
            try {
              expiryDate = item['expiryDate'] != null
                  ? DateTime.parse(item['expiryDate'] as String)
                  : DateTime.now().add(const Duration(days: 7));
            } catch (_) {
              expiryDate = DateTime.now().add(const Duration(days: 7));
            }

            ingredients.add(Ingredient(
              name: name,
              category: item['category'] as String? ?? 'unknown',
              quantity: (item['quantity'] as num?)?.toDouble() ?? 1.0,
              unit: item['unit'] as String? ?? '개',
              expiryDate: expiryDate,
              storageLocation: StorageLocation.fridge,
              purchaseDate: DateTime.now(),
            ));
          } catch (e) {
            assert(() {
              debugPrint('FunctionCalling: 재료 파싱 실패 - $e');
              return true;
            }());
            continue;
          }
        }

        if (ingredients.isEmpty) return null;
        return IngredientListResponse(
          ingredients: ingredients,
          commentary: '',
        );
      case 'bookmark_recipe':
        final success = responseData['success'] as bool? ?? false;
        return ActionResponse(
          actionType: 'bookmark',
          success: success,
          message: success ? '북마크가 업데이트되었습니다.' : '북마크 업데이트에 실패했습니다.',
        );
      default:
        return null;
    }
  }
}

/// Function Call 실행 결과
class FunctionCallResult {
  final String name;
  final Map<String, Object?> response;

  FunctionCallResult({required this.name, required this.response});

  /// FunctionResponse 생성 (Gemini API로 전송용)
  FunctionResponse toFunctionResponse() {
    return FunctionResponse(name, response);
  }
}
