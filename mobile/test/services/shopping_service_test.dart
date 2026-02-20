import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ai_chef/models/shopping_item.dart';
import 'package:ai_chef/services/shopping_service.dart';

import '../helpers/mock_supabase.dart';

void main() {
  group('ShoppingService - 미로그인', () {
    late ShoppingService service;

    setUp(() {
      final client = createLoggedOutClient();
      service = ShoppingService(supabase: client);
    });

    test('getShoppingItems는 Exception을 throw한다', () {
      expect(() => service.getShoppingItems(), throwsException);
    });

    test('addShoppingItem은 Exception을 throw한다', () {
      final item = ShoppingItem(name: '양파');
      expect(() => service.addShoppingItem(item), throwsException);
    });

    test('addShoppingItems는 Exception을 throw한다', () {
      final items = [ShoppingItem(name: '양파')];
      expect(() => service.addShoppingItems(items), throwsException);
    });

    test('toggleCheck는 Exception을 throw한다', () {
      expect(() => service.toggleCheck('id', true), throwsException);
    });

    test('deleteShoppingItem은 Exception을 throw한다', () {
      expect(() => service.deleteShoppingItem('id'), throwsException);
    });

    test('deleteCheckedItems는 Exception을 throw한다', () {
      expect(() => service.deleteCheckedItems(), throwsException);
    });

    test('getCheckedItems는 Exception을 throw한다', () {
      expect(() => service.getCheckedItems(), throwsException);
    });
  });

  group('ShoppingService - 로그인', () {
    late MockSupabaseClient client;
    late ShoppingService service;

    setUp(() {
      client = createLoggedInClient();
      service = ShoppingService(supabase: client);
    });

    test('getShoppingItems가 아이템 목록을 반환한다', () async {
      final mockData = [
        {
          'id': 'item-1',
          'user_id': 'test-user-id',
          'name': '양파',
          'category': 'vegetable',
          'quantity': 3,
          'unit': '개',
          'is_checked': false,
          'source': 'manual',
        },
      ];
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

      final items = await service.getShoppingItems();
      expect(items.length, 1);
      expect(items.first.name, '양파');
    });

    test('addShoppingItem이 추가된 아이템을 반환한다', () async {
      final mockData = [
        {
          'id': 'new-1',
          'user_id': 'test-user-id',
          'name': '당근',
          'category': 'vegetable',
          'quantity': 2,
          'unit': '개',
          'is_checked': false,
          'source': 'manual',
        },
      ];
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

      final item = ShoppingItem(name: '당근', category: 'vegetable', quantity: 2);
      final result = await service.addShoppingItem(item);
      expect(result.name, '당근');
    });

    test('addShoppingItems가 추가된 아이템 목록을 반환한다', () async {
      final mockData = [
        {
          'id': 'new-1',
          'user_id': 'test-user-id',
          'name': '양파',
          'category': 'vegetable',
          'quantity': 1,
          'unit': '개',
          'is_checked': false,
          'source': 'recipe',
          'recipe_title': '된장찌개',
        },
        {
          'id': 'new-2',
          'user_id': 'test-user-id',
          'name': '두부',
          'category': 'other',
          'quantity': 1,
          'unit': '모',
          'is_checked': false,
          'source': 'recipe',
          'recipe_title': '된장찌개',
        },
      ];
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

      final items = [
        ShoppingItem(name: '양파', source: ShoppingItemSource.recipe, recipeTitle: '된장찌개'),
        ShoppingItem(name: '두부', source: ShoppingItemSource.recipe, recipeTitle: '된장찌개'),
      ];
      final result = await service.addShoppingItems(items);
      expect(result.length, 2);
    });

    test('toggleCheck가 에러 없이 완료된다', () async {
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await expectLater(
        service.toggleCheck('item-1', true),
        completes,
      );
    });

    test('deleteShoppingItem이 에러 없이 완료된다', () async {
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await expectLater(
        service.deleteShoppingItem('item-1'),
        completes,
      );
    });

    test('deleteCheckedItems가 에러 없이 완료된다', () async {
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder([]));

      await expectLater(
        service.deleteCheckedItems(),
        completes,
      );
    });

    test('getCheckedItems가 체크된 아이템만 반환한다', () async {
      final mockData = [
        {
          'id': 'item-1',
          'user_id': 'test-user-id',
          'name': '완료된 양파',
          'category': 'vegetable',
          'quantity': 1,
          'unit': '개',
          'is_checked': true,
          'source': 'manual',
        },
      ];
      when(client.from('shopping_items'))
          .thenAnswer((_) => FakeSupabaseQueryBuilder(mockData));

      final items = await service.getCheckedItems();
      expect(items.length, 1);
      expect(items.first.isChecked, true);
    });
  });
}
