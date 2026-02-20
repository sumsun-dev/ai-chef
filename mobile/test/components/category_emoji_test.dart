import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/category_emoji.dart';

void main() {
  group('getCategoryEmoji', () {
    test('vegetable -> 🥬', () {
      expect(getCategoryEmoji('vegetable'), '🥬');
    });

    test('fruit -> 🍎', () {
      expect(getCategoryEmoji('fruit'), '🍎');
    });

    test('meat -> 🍖', () {
      expect(getCategoryEmoji('meat'), '🍖');
    });

    test('seafood -> 🐟', () {
      expect(getCategoryEmoji('seafood'), '🐟');
    });

    test('dairy -> 🥛', () {
      expect(getCategoryEmoji('dairy'), '🥛');
    });

    test('egg -> 🥚', () {
      expect(getCategoryEmoji('egg'), '🥚');
    });

    test('grain -> 🍚', () {
      expect(getCategoryEmoji('grain'), '🍚');
    });

    test('seasoning -> 🧂', () {
      expect(getCategoryEmoji('seasoning'), '🧂');
    });

    test('null -> 🍽️ (default)', () {
      expect(getCategoryEmoji(null), '🍽️');
    });

    test('unknown -> 🍽️ (default)', () {
      expect(getCategoryEmoji('unknown'), '🍽️');
    });
  });

  group('getCategoryLabel', () {
    test('vegetable -> 채소', () {
      expect(getCategoryLabel('vegetable'), '채소');
    });

    test('fruit -> 과일', () {
      expect(getCategoryLabel('fruit'), '과일');
    });

    test('meat -> 고기', () {
      expect(getCategoryLabel('meat'), '고기');
    });

    test('seafood -> 해산물', () {
      expect(getCategoryLabel('seafood'), '해산물');
    });

    test('dairy -> 유제품', () {
      expect(getCategoryLabel('dairy'), '유제품');
    });

    test('egg -> 계란', () {
      expect(getCategoryLabel('egg'), '계란');
    });

    test('grain -> 곡류', () {
      expect(getCategoryLabel('grain'), '곡류');
    });

    test('seasoning -> 양념', () {
      expect(getCategoryLabel('seasoning'), '양념');
    });

    test('null -> 기타 (default)', () {
      expect(getCategoryLabel(null), '기타');
    });

    test('unknown -> 기타 (default)', () {
      expect(getCategoryLabel('unknown'), '기타');
    });
  });
}
