import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/recipe_history.dart';

void main() {
  group('RecipeHistory', () {
    test('fromJson 기본 필드 파싱', () {
      final json = {
        'id': '1',
        'user_id': 'user-1',
        'recipe_id': 'recipe-1',
        'chef_id': 'baek',
        'recipe_title': '김치찌개',
        'cooked_at': '2026-02-20T12:00:00.000Z',
        'rating': 5,
        'memo': '맛있었다',
      };

      final history = RecipeHistory.fromJson(json);

      expect(history.id, '1');
      expect(history.userId, 'user-1');
      expect(history.recipeId, 'recipe-1');
      expect(history.chefId, 'baek');
      expect(history.recipeTitle, '김치찌개');
      expect(history.cookedAt.year, 2026);
      expect(history.rating, 5);
      expect(history.memo, '맛있었다');
    });

    test('fromJson nullable 필드 처리', () {
      final json = {
        'id': '2',
        'recipe_title': '된장찌개',
        'cooked_at': '2026-02-19T12:00:00.000Z',
      };

      final history = RecipeHistory.fromJson(json);

      expect(history.userId, isNull);
      expect(history.recipeId, isNull);
      expect(history.chefId, isNull);
      expect(history.rating, isNull);
      expect(history.memo, isNull);
    });

    test('toJson 직렬화', () {
      final history = RecipeHistory(
        id: '1',
        userId: 'user-1',
        recipeTitle: '김치찌개',
        cookedAt: DateTime(2026, 2, 20, 12),
        rating: 5,
      );

      final json = history.toJson();

      expect(json['id'], '1');
      expect(json['user_id'], 'user-1');
      expect(json['recipe_title'], '김치찌개');
      expect(json['rating'], 5);
      expect(json.containsKey('cooked_at'), isTrue);
    });

    test('toJson nullable 필드 제외', () {
      final history = RecipeHistory(
        id: '1',
        recipeTitle: '된장찌개',
        cookedAt: DateTime(2026, 2, 19),
      );

      final json = history.toJson();

      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('recipe_id'), isFalse);
      expect(json.containsKey('chef_id'), isFalse);
      expect(json.containsKey('rating'), isFalse);
      expect(json.containsKey('memo'), isFalse);
    });

    test('copyWith 부분 복사', () {
      final original = RecipeHistory(
        id: '1',
        recipeTitle: '김치찌개',
        cookedAt: DateTime(2026, 2, 20),
        rating: 3,
      );

      final copied = original.copyWith(rating: 5, memo: '최고');

      expect(copied.id, '1');
      expect(copied.recipeTitle, '김치찌개');
      expect(copied.rating, 5);
      expect(copied.memo, '최고');
    });

    test('fromJson id가 int일 때 String 변환', () {
      final json = {
        'id': 42,
        'recipe_title': '비빔밥',
        'cooked_at': '2026-02-18T12:00:00.000Z',
      };

      final history = RecipeHistory.fromJson(json);
      expect(history.id, '42');
    });

    test('fromJson recipe_title 누락 시 빈 문자열', () {
      final json = {
        'id': '1',
        'cooked_at': '2026-02-18T12:00:00.000Z',
      };

      final history = RecipeHistory.fromJson(json);
      expect(history.recipeTitle, '');
    });
  });
}
