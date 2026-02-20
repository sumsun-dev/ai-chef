import 'package:flutter_test/flutter_test.dart';

/// 채팅 메시지에서 레시피 패턴 감지 로직 단위 테스트
///
/// ChatScreen._containsRecipePattern()의 로직을 독립적으로 테스트합니다.
bool containsRecipePattern(String text) {
  final patterns = ['재료', '조리', '만드는 법', '레시피', '인분', '분량', '순서', '단계'];
  final matchCount = patterns.where((p) => text.contains(p)).length;
  return matchCount >= 2;
}

void main() {
  group('레시피 패턴 감지', () {
    test('재료 + 조리 포함 시 true', () {
      expect(
        containsRecipePattern('재료: 양파, 당근\n조리 순서: 1. 볶기'),
        isTrue,
      );
    });

    test('레시피 + 인분 포함 시 true', () {
      expect(
        containsRecipePattern('김치찌개 레시피 (2인분)'),
        isTrue,
      );
    });

    test('만드는 법 + 분량 포함 시 true', () {
      expect(
        containsRecipePattern('만드는 법을 알려드릴게요. 분량은 2인분 기준입니다.'),
        isTrue,
      );
    });

    test('패턴 1개만 있으면 false', () {
      expect(
        containsRecipePattern('오늘 재료를 사왔어요'),
        isFalse,
      );
    });

    test('패턴 없으면 false', () {
      expect(
        containsRecipePattern('안녕하세요! 좋은 아침이에요.'),
        isFalse,
      );
    });
  });
}
