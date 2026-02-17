import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/ingredient.dart';

void main() {
  group('StorageLocation', () {
    group('fromString', () {
      test('DB 값을 올바르게 매핑한다', () {
        expect(StorageLocation.fromString('fridge'), StorageLocation.fridge);
        expect(StorageLocation.fromString('freezer'), StorageLocation.freezer);
        expect(StorageLocation.fromString('pantry'), StorageLocation.pantry);
      });

      test('레거시 값을 올바르게 매핑한다', () {
        expect(
            StorageLocation.fromString('refrigerated'), StorageLocation.fridge);
        expect(
            StorageLocation.fromString('refrigerator'), StorageLocation.fridge);
        expect(StorageLocation.fromString('frozen'), StorageLocation.freezer);
        expect(StorageLocation.fromString('room_temp'), StorageLocation.pantry);
      });

      test('알 수 없는 값은 fridge로 기본 매핑한다', () {
        expect(StorageLocation.fromString('unknown'), StorageLocation.fridge);
        expect(StorageLocation.fromString(''), StorageLocation.fridge);
      });
    });

    test('value가 DB CHECK 제약조건 값과 일치한다', () {
      const dbValues = {'fridge', 'freezer', 'pantry'};
      for (final location in StorageLocation.values) {
        expect(dbValues.contains(location.value), isTrue,
            reason: '${location.value}가 DB 허용 값에 포함되어야 합니다');
      }
    });
  });

  group('Ingredient', () {
    group('fromJson / toJson round-trip', () {
      test('모든 필드가 보존된다', () {
        final json = {
          'id': 'test-id-123',
          'user_id': 'user-456',
          'name': '삼겹살',
          'category': 'meat',
          'quantity': 1.5,
          'unit': 'kg',
          'purchase_date': '2026-02-10',
          'expiry_date': '2026-02-15',
          'price': 15000.0,
          'location': 'fridge',
          'memo': '마트 할인',
          'created_at': '2026-02-10T09:00:00.000Z',
          'updated_at': '2026-02-10T09:00:00.000Z',
        };

        final ingredient = Ingredient.fromJson(json);
        final output = ingredient.toJson();

        expect(ingredient.id, 'test-id-123');
        expect(ingredient.name, '삼겹살');
        expect(ingredient.category, 'meat');
        expect(ingredient.quantity, 1.5);
        expect(ingredient.unit, 'kg');
        expect(ingredient.storageLocation, StorageLocation.fridge);
        expect(ingredient.memo, '마트 할인');

        // toJson은 DB에 저장하는 키 이름 사용
        expect(output['location'], 'fridge');
        expect(output.containsKey('storage_location'), isFalse);
        expect(output['name'], '삼겹살');
        expect(output['category'], 'meat');
      });

      test('location 키로 보관위치를 읽는다', () {
        final json = {
          'name': '우유',
          'category': 'dairy',
          'expiry_date': '2026-02-20',
          'location': 'fridge',
        };

        final ingredient = Ingredient.fromJson(json);
        expect(ingredient.storageLocation, StorageLocation.fridge);
      });

      test('레거시 storage_location 키도 fallback으로 읽는다', () {
        final json = {
          'name': '우유',
          'category': 'dairy',
          'expiry_date': '2026-02-20',
          'storage_location': 'refrigerated',
        };

        final ingredient = Ingredient.fromJson(json);
        expect(ingredient.storageLocation, StorageLocation.fridge);
      });

      test('두 키 모두 없으면 fridge 기본값', () {
        final json = {
          'name': '사과',
          'category': 'fruit',
          'expiry_date': '2026-02-25',
        };

        final ingredient = Ingredient.fromJson(json);
        expect(ingredient.storageLocation, StorageLocation.fridge);
      });

      test('optional 필드가 없어도 정상 파싱된다', () {
        final json = {
          'name': '양파',
          'category': 'vegetable',
          'expiry_date': '2026-03-01',
        };

        final ingredient = Ingredient.fromJson(json);
        expect(ingredient.name, '양파');
        expect(ingredient.quantity, 1);
        expect(ingredient.unit, '개');
        expect(ingredient.purchaseDate, isNull);
        expect(ingredient.price, isNull);
        expect(ingredient.memo, isNull);
      });
    });

    group('toJson', () {
      test('location 키를 사용하여 보관위치를 저장한다', () {
        final ingredient = Ingredient(
          name: '달걀',
          category: 'egg',
          expiryDate: DateTime(2026, 3, 1),
          storageLocation: StorageLocation.fridge,
        );

        final json = ingredient.toJson();
        expect(json['location'], 'fridge');
        expect(json.containsKey('storage_location'), isFalse);
      });

      test('freezer 값이 올바르게 직렬화된다', () {
        final ingredient = Ingredient(
          name: '냉동 만두',
          category: 'other',
          expiryDate: DateTime(2026, 6, 1),
          storageLocation: StorageLocation.freezer,
        );

        final json = ingredient.toJson();
        expect(json['location'], 'freezer');
      });
    });
  });

  group('ReceiptOcrResult.fromJson', () {
    test('DB 카테고리에 맞는 유통기한이 설정된다', () {
      final json = {
        'items': [
          {'name': '양파', 'category': 'vegetable'},
          {'name': '삼겹살', 'category': 'meat'},
          {'name': '새우', 'category': 'seafood'},
          {'name': '쌀', 'category': 'grain'},
          {'name': '간장', 'category': 'seasoning'},
        ],
        'date': '2026-02-17',
      };

      final result = ReceiptOcrResult.fromJson(json);
      final items = result.ingredients;

      // vegetable: 7일
      expect(items[0].expiryDate.difference(DateTime(2026, 2, 17)).inDays, 7);
      // meat: 5일
      expect(items[1].expiryDate.difference(DateTime(2026, 2, 17)).inDays, 5);
      // seafood: 3일
      expect(items[2].expiryDate.difference(DateTime(2026, 2, 17)).inDays, 3);
      // grain: 180일
      expect(items[3].expiryDate.difference(DateTime(2026, 2, 17)).inDays, 180);
      // seasoning: 90일
      expect(items[4].expiryDate.difference(DateTime(2026, 2, 17)).inDays, 90);
    });

    test('DB 카테고리에 맞는 보관위치가 설정된다', () {
      final json = {
        'items': [
          {'name': '양파', 'category': 'vegetable'},
          {'name': '쌀', 'category': 'grain'},
          {'name': '간장', 'category': 'seasoning'},
        ],
        'date': '2026-02-17',
      };

      final result = ReceiptOcrResult.fromJson(json);
      final items = result.ingredients;

      expect(items[0].storageLocation, StorageLocation.fridge);
      expect(items[1].storageLocation, StorageLocation.pantry);
      expect(items[2].storageLocation, StorageLocation.pantry);
    });
  });

  group('ExpiryStatus', () {
    test('만료 상태가 올바르게 계산된다', () {
      final expired = Ingredient(
        name: '만료',
        category: 'other',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.expiryStatus, ExpiryStatus.expired);

      final critical = Ingredient(
        name: '긴급',
        category: 'other',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      );
      expect(critical.expiryStatus, ExpiryStatus.critical);

      final warning = Ingredient(
        name: '주의',
        category: 'other',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(warning.expiryStatus, ExpiryStatus.warning);

      final safe = Ingredient(
        name: '양호',
        category: 'other',
        expiryDate: DateTime.now().add(const Duration(days: 14)),
      );
      expect(safe.expiryStatus, ExpiryStatus.safe);
    });
  });
}
