import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/ingredient.dart';

/// ReceiptOcrService 파싱 로직 테스트
///
/// GenerativeModel은 final class라 모킹 불가하므로:
/// - ReceiptOcrResult.fromJson을 직접 테스트 (핵심 파싱 로직)
/// - _parseResponse의 JSON 추출 로직을 동일하게 재현하여 테스트
void main() {
  group('ReceiptOcrResult.fromJson', () {
    test('정상 JSON 파싱', () {
      final json = {
        'items': [
          {
            'name': '삼겹살',
            'quantity': 1,
            'unit': '팩',
            'price': 12900,
            'category': 'meat',
            'confidence': 'high',
          },
          {
            'name': '양파',
            'quantity': 3,
            'unit': '개',
            'price': 2000,
            'category': 'vegetable',
            'confidence': 'medium',
          },
        ],
        'date': '2026-02-20',
        'store': '이마트',
      };

      final result = ReceiptOcrResult.fromJson(json);

      expect(result.ingredients.length, 2);
      expect(result.storeName, '이마트');
      expect(result.purchaseDate, isNotNull);
      expect(result.purchaseDate!.year, 2026);
      expect(result.purchaseDate!.month, 2);
      expect(result.purchaseDate!.day, 20);

      final meat = result.ingredients[0];
      expect(meat.name, '삼겹살');
      expect(meat.category, 'meat');
      expect(meat.quantity, 1);
      expect(meat.unit, '팩');
      expect(meat.price, 12900);
      expect(meat.ocrConfidence, OcrConfidence.high);
      expect(meat.storageLocation, StorageLocation.fridge);

      final veggie = result.ingredients[1];
      expect(veggie.name, '양파');
      expect(veggie.category, 'vegetable');
      expect(veggie.ocrConfidence, OcrConfidence.medium);
    });

    test('빈 items 배열 처리', () {
      final json = {
        'items': <dynamic>[],
        'date': '2026-02-20',
        'store': '홈플러스',
      };

      final result = ReceiptOcrResult.fromJson(json);

      expect(result.ingredients, isEmpty);
      expect(result.storeName, '홈플러스');
    });

    test('items 키가 null이면 빈 목록 반환', () {
      final json = <String, dynamic>{
        'items': null,
        'date': null,
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);

      expect(result.ingredients, isEmpty);
      expect(result.storeName, isNull);
    });

    test('date가 null이면 현재 날짜 사용', () {
      final json = {
        'items': <dynamic>[],
        'date': null,
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);
      final now = DateTime.now();

      expect(result.purchaseDate!.year, now.year);
      expect(result.purchaseDate!.month, now.month);
      expect(result.purchaseDate!.day, now.day);
    });

    test('유효하지 않은 날짜 형식이면 현재 날짜 사용', () {
      final json = {
        'items': <dynamic>[],
        'date': 'not-a-valid-date',
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);
      final now = DateTime.now();

      expect(result.purchaseDate!.year, now.year);
      expect(result.purchaseDate!.month, now.month);
      expect(result.purchaseDate!.day, now.day);
    });

    test('카테고리별 기본 유통기한 설정', () {
      final json = {
        'items': [
          {'name': '고등어', 'category': 'seafood', 'confidence': 'high'},
          {'name': '쌀', 'category': 'grain', 'confidence': 'high'},
          {'name': '간장', 'category': 'seasoning', 'confidence': 'high'},
        ],
        'date': '2026-02-20',
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);
      final purchaseDate = DateTime.parse('2026-02-20');

      // seafood: 3일
      expect(
        result.ingredients[0].expiryDate,
        purchaseDate.add(const Duration(days: 3)),
      );
      // grain: 180일
      expect(
        result.ingredients[1].expiryDate,
        purchaseDate.add(const Duration(days: 180)),
      );
      // seasoning: 90일
      expect(
        result.ingredients[2].expiryDate,
        purchaseDate.add(const Duration(days: 90)),
      );
    });

    test('카테고리별 기본 보관 위치 설정', () {
      final json = {
        'items': [
          {'name': '소고기', 'category': 'meat', 'confidence': 'high'},
          {'name': '쌀', 'category': 'grain', 'confidence': 'high'},
          {'name': '소금', 'category': 'seasoning', 'confidence': 'high'},
        ],
        'date': '2026-02-20',
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);

      expect(result.ingredients[0].storageLocation, StorageLocation.fridge);
      expect(result.ingredients[1].storageLocation, StorageLocation.pantry);
      expect(result.ingredients[2].storageLocation, StorageLocation.pantry);
    });

    test('누락된 필드에 기본값 적용', () {
      final json = {
        'items': [
          {'name': '두부'},
        ],
        'date': null,
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);
      final ingredient = result.ingredients[0];

      expect(ingredient.name, '두부');
      expect(ingredient.category, 'other');
      expect(ingredient.quantity, 1);
      expect(ingredient.unit, '개');
      expect(ingredient.price, isNull);
      expect(ingredient.ocrConfidence, OcrConfidence.medium);
    });

    test('신뢰도(confidence) 파싱', () {
      final json = {
        'items': [
          {'name': '사과', 'confidence': 'high'},
          {'name': '배', 'confidence': 'medium'},
          {'name': '???', 'confidence': 'low'},
        ],
        'date': null,
        'store': null,
      };

      final result = ReceiptOcrResult.fromJson(json);

      expect(result.ingredients[0].ocrConfidence, OcrConfidence.high);
      expect(result.ingredients[1].ocrConfidence, OcrConfidence.medium);
      expect(result.ingredients[2].ocrConfidence, OcrConfidence.low);
    });
  });

  group('parseResponse JSON 추출 로직', () {
    // ReceiptOcrService._parseResponse의 핵심 로직을 동일하게 재현하여 테스트
    // (GenerativeModel이 final class라 서비스 인스턴스 생성 불가)

    test('정상 JSON 문자열 파싱', () {
      const jsonString =
          '{"items": [{"name": "우유", "category": "dairy", "confidence": "high"}], "date": "2026-02-20", "store": "GS25"}';

      final jsonData = extractJsonFromResponse(jsonString);
      expect(jsonData, isNotNull);

      final result = ReceiptOcrResult.fromJson(jsonData!);
      expect(result.ingredients.length, 1);
      expect(result.ingredients[0].name, '우유');
      expect(result.storeName, 'GS25');
    });

    test('```json 블록으로 래핑된 응답 파싱', () {
      const wrappedResponse = '''여기에 결과입니다:
```json
{"items": [{"name": "달걀", "category": "egg", "confidence": "high"}], "date": "2026-02-20", "store": "CU"}
```
끝.''';

      final jsonData = extractJsonFromResponse(wrappedResponse);
      expect(jsonData, isNotNull);

      final result = ReceiptOcrResult.fromJson(jsonData!);
      expect(result.ingredients.length, 1);
      expect(result.ingredients[0].name, '달걀');
      expect(result.storeName, 'CU');
    });

    test('잘못된 JSON → null 반환', () {
      const invalidJson = 'this is not json at all';
      final jsonData = extractJsonFromResponse(invalidJson);
      expect(jsonData, isNull);
    });

    test('빈 문자열 → null 반환', () {
      final jsonData = extractJsonFromResponse('');
      expect(jsonData, isNull);
    });

    test('여러 줄의 ```json 블록 파싱', () {
      const multiLineResponse = '''```json
{
  "items": [
    {"name": "토마토", "category": "vegetable", "quantity": 5, "unit": "개", "confidence": "high"}
  ],
  "date": "2026-02-20",
  "store": "농협"
}
```''';

      final jsonData = extractJsonFromResponse(multiLineResponse);
      expect(jsonData, isNotNull);

      final result = ReceiptOcrResult.fromJson(jsonData!);
      expect(result.ingredients.length, 1);
      expect(result.ingredients[0].name, '토마토');
      expect(result.ingredients[0].quantity, 5);
    });
  });
}

/// ReceiptOcrService._parseResponse의 JSON 추출 로직 재현 (테스트용)
Map<String, dynamic>? extractJsonFromResponse(String text) {
  try {
    final jsonMatch = RegExp(r'```json\n?([\s\S]*?)\n?```').firstMatch(text);
    String jsonString;

    if (jsonMatch != null) {
      jsonString = jsonMatch.group(1)!;
    } else {
      jsonString = text.trim();
    }

    return Map<String, dynamic>.from(
      json.decode(jsonString) as Map,
    );
  } catch (e) {
    return null;
  }
}
