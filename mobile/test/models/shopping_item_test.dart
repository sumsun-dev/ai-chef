import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/shopping_item.dart';

void main() {
  group('ShoppingItemSource', () {
    test('fromString이 올바르게 매핑한다', () {
      expect(ShoppingItemSource.fromString('manual'), ShoppingItemSource.manual);
      expect(ShoppingItemSource.fromString('recipe'), ShoppingItemSource.recipe);
    });

    test('알 수 없는 값은 manual로 기본 매핑한다', () {
      expect(ShoppingItemSource.fromString('unknown'), ShoppingItemSource.manual);
      expect(ShoppingItemSource.fromString(''), ShoppingItemSource.manual);
    });
  });

  group('ShoppingItem', () {
    group('fromJson', () {
      test('모든 필드가 올바르게 파싱된다', () {
        final json = {
          'id': 'item-123',
          'user_id': 'user-456',
          'name': '양파',
          'category': 'vegetable',
          'quantity': 3.0,
          'unit': '개',
          'is_checked': false,
          'source': 'manual',
          'recipe_title': null,
          'memo': '대파도 확인',
          'created_at': '2026-02-20T09:00:00.000Z',
          'updated_at': '2026-02-20T09:00:00.000Z',
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.id, 'item-123');
        expect(item.userId, 'user-456');
        expect(item.name, '양파');
        expect(item.category, 'vegetable');
        expect(item.quantity, 3.0);
        expect(item.unit, '개');
        expect(item.isChecked, false);
        expect(item.source, ShoppingItemSource.manual);
        expect(item.recipeTitle, isNull);
        expect(item.memo, '대파도 확인');
        expect(item.createdAt, isNotNull);
        expect(item.updatedAt, isNotNull);
      });

      test('recipe 소스가 올바르게 파싱된다', () {
        final json = {
          'name': '소고기',
          'category': 'meat',
          'source': 'recipe',
          'recipe_title': '소고기 불고기',
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.source, ShoppingItemSource.recipe);
        expect(item.recipeTitle, '소고기 불고기');
      });

      test('optional 필드가 없어도 기본값으로 파싱된다', () {
        final json = {
          'name': '우유',
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.name, '우유');
        expect(item.category, 'other');
        expect(item.quantity, 1);
        expect(item.unit, '개');
        expect(item.isChecked, false);
        expect(item.source, ShoppingItemSource.manual);
        expect(item.recipeTitle, isNull);
        expect(item.memo, isNull);
      });
    });

    group('toJson', () {
      test('모든 필드가 올바르게 직렬화된다', () {
        final item = ShoppingItem(
          id: 'item-123',
          name: '양파',
          category: 'vegetable',
          quantity: 3,
          unit: '개',
          isChecked: false,
          source: ShoppingItemSource.manual,
          memo: '메모',
        );

        final json = item.toJson();

        expect(json['id'], 'item-123');
        expect(json['name'], '양파');
        expect(json['category'], 'vegetable');
        expect(json['quantity'], 3);
        expect(json['unit'], '개');
        expect(json['is_checked'], false);
        expect(json['source'], 'manual');
        expect(json['memo'], '메모');
      });

      test('null id는 제외된다', () {
        final item = ShoppingItem(
          name: '양파',
          category: 'vegetable',
        );

        final json = item.toJson();
        expect(json.containsKey('id'), isFalse);
      });

      test('null optional 필드는 제외된다', () {
        final item = ShoppingItem(name: '양파');

        final json = item.toJson();
        expect(json.containsKey('recipe_title'), isFalse);
        expect(json.containsKey('memo'), isFalse);
      });
    });

    group('copyWith', () {
      test('변경된 필드만 업데이트된다', () {
        final original = ShoppingItem(
          id: 'item-123',
          name: '양파',
          category: 'vegetable',
          quantity: 3,
          unit: '개',
          isChecked: false,
        );

        final updated = original.copyWith(isChecked: true, quantity: 5);

        expect(updated.id, 'item-123');
        expect(updated.name, '양파');
        expect(updated.isChecked, true);
        expect(updated.quantity, 5);
        // 원본 불변성 확인
        expect(original.isChecked, false);
        expect(original.quantity, 3);
      });
    });

    test('categoryDisplayName이 올바른 한글명을 반환한다', () {
      expect(
        ShoppingItem(name: '양파', category: 'vegetable').categoryDisplayName,
        '채소',
      );
      expect(
        ShoppingItem(name: '사과', category: 'fruit').categoryDisplayName,
        '과일',
      );
      expect(
        ShoppingItem(name: '기타', category: 'other').categoryDisplayName,
        '기타',
      );
      expect(
        ShoppingItem(name: '알수없음', category: 'xyz').categoryDisplayName,
        '기타',
      );
    });
  });
}
