import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/services/ingredient_service.dart';
import '../helpers/mock_supabase.dart';

void main() {
  final now = DateTime.now();
  final testIngredientJson = {
    'id': '1',
    'user_id': 'test-user-id',
    'name': '당근',
    'category': 'vegetable',
    'quantity': 2,
    'unit': '개',
    'expiry_date': '2026-03-01',
    'location': 'fridge',
  };

  group('not logged in', () {
    late IngredientService service;

    setUp(() {
      service = IngredientService(supabase: createLoggedOutClient());
    });

    test('getIngredients throws', () {
      expect(() => service.getIngredients(), throwsA(isA<Exception>()));
    });

    test('addIngredient throws', () {
      final ingredient = Ingredient(
        name: '당근',
        category: 'vegetable',
        expiryDate: now.add(const Duration(days: 7)),
      );
      expect(
          () => service.addIngredient(ingredient), throwsA(isA<Exception>()));
    });

    test('updateIngredient throws', () {
      final ingredient = Ingredient(
        id: '1',
        name: '당근',
        category: 'vegetable',
        expiryDate: now.add(const Duration(days: 7)),
      );
      expect(() => service.updateIngredient(ingredient),
          throwsA(isA<Exception>()));
    });

    test('deleteIngredient throws', () {
      expect(() => service.deleteIngredient('1'), throwsA(isA<Exception>()));
    });

    test('searchIngredients throws', () {
      expect(
          () => service.searchIngredients('당근'), throwsA(isA<Exception>()));
    });
  });

  group('logged in', () {
    late MockSupabaseClient mockClient;
    late IngredientService service;

    setUp(() {
      mockClient = createLoggedInClient();
      service = IngredientService(supabase: mockClient);
    });

    test('getIngredients returns list of ingredients', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testIngredientJson]));

      final result = await service.getIngredients();
      expect(result.length, 1);
      expect(result.first.name, '당근');
      expect(result.first.category, 'vegetable');
    });

    test('getIngredients returns empty list', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      final result = await service.getIngredients();
      expect(result, isEmpty);
    });

    test('addIngredient returns saved ingredient', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testIngredientJson]));

      final ingredient = Ingredient(
        name: '당근',
        category: 'vegetable',
        expiryDate: DateTime.parse('2026-03-01'),
      );
      final result = await service.addIngredient(ingredient);
      expect(result.name, '당근');
      expect(result.id, '1');
    });

    test('updateIngredient throws when id is null', () {
      final ingredient = Ingredient(
        name: '당근',
        category: 'vegetable',
        expiryDate: now.add(const Duration(days: 7)),
      );
      expect(
        () => service.updateIngredient(ingredient),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('ID'),
        )),
      );
    });

    test('updateIngredient returns updated ingredient', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testIngredientJson]));

      final ingredient = Ingredient(
        id: '1',
        name: '당근',
        category: 'vegetable',
        expiryDate: DateTime.parse('2026-03-01'),
      );
      final result = await service.updateIngredient(ingredient);
      expect(result.name, '당근');
    });

    test('deleteIngredient throws when id is null', () {
      expect(
        () => service.deleteIngredient(null),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('ID'),
        )),
      );
    });

    test('deleteIngredient completes without error', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await service.deleteIngredient('1');
    });

    test('searchIngredients returns matching results', () async {
      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([testIngredientJson]));

      final result = await service.searchIngredients('당근');
      expect(result.length, 1);
      expect(result.first.name, '당근');
    });

    test('getExpiryIngredientGroup classifies by status', () async {
      final expiredDate =
          now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      final criticalDate =
          now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
      final warningDate =
          now.add(const Duration(days: 5)).toIso8601String().split('T')[0];
      final safeDate =
          now.add(const Duration(days: 30)).toIso8601String().split('T')[0];

      when(mockClient.from('ingredients'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([
                {'id': '1', 'name': '만료', 'category': 'vegetable', 'expiry_date': expiredDate, 'location': 'fridge'},
                {'id': '2', 'name': '위험', 'category': 'meat', 'expiry_date': criticalDate, 'location': 'fridge'},
                {'id': '3', 'name': '주의', 'category': 'dairy', 'expiry_date': warningDate, 'location': 'fridge'},
                {'id': '4', 'name': '안전', 'category': 'grain', 'expiry_date': safeDate, 'location': 'pantry'},
              ]));

      final group = await service.getExpiryIngredientGroup();
      expect(group.expiredItems.length, 1);
      expect(group.criticalItems.length, 1);
      expect(group.warningItems.length, 1);
      expect(group.safeItems.length, 1);
      expect(group.totalCount, 4);
    });
  });
}
