import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/cooking_feedback.dart';

void main() {
  group('Doneness', () {
    test('fromString - undercooked', () {
      expect(Doneness.fromString('undercooked'), Doneness.undercooked);
    });

    test('fromString - perfect', () {
      expect(Doneness.fromString('perfect'), Doneness.perfect);
    });

    test('fromString - overcooked', () {
      expect(Doneness.fromString('overcooked'), Doneness.overcooked);
    });

    test('fromString - 알 수 없는 값은 notApplicable', () {
      expect(Doneness.fromString('unknown'), Doneness.notApplicable);
      expect(Doneness.fromString(''), Doneness.notApplicable);
    });

    test('displayName이 올바르다', () {
      expect(Doneness.undercooked.displayName, '덜 익음');
      expect(Doneness.perfect.displayName, '적절함');
      expect(Doneness.overcooked.displayName, '과하게 익음');
      expect(Doneness.notApplicable.displayName, '해당 없음');
    });
  });

  group('CookingFeedback', () {
    test('fromJson이 올바르게 파싱된다', () {
      final json = {
        'doneness': 'perfect',
        'donenessDescription': '잘 익었습니다',
        'platingScore': 8,
        'platingFeedback': '플레이팅이 좋습니다',
        'overallAssessment': '훌륭합니다',
        'suggestions': ['소금을 조금 더', '더 얇게 썰기'],
        'encouragement': '잘하셨어요!',
      };

      final feedback = CookingFeedback.fromJson(json);
      expect(feedback.doneness, Doneness.perfect);
      expect(feedback.donenessDescription, '잘 익었습니다');
      expect(feedback.platingScore, 8);
      expect(feedback.platingFeedback, '플레이팅이 좋습니다');
      expect(feedback.overallAssessment, '훌륭합니다');
      expect(feedback.suggestions, ['소금을 조금 더', '더 얇게 썰기']);
      expect(feedback.encouragement, '잘하셨어요!');
    });

    test('fromJson - 빈 필드에 기본값 적용', () {
      final feedback = CookingFeedback.fromJson({});
      expect(feedback.doneness, Doneness.notApplicable);
      expect(feedback.donenessDescription, '');
      expect(feedback.platingScore, 5);
      expect(feedback.platingFeedback, '');
      expect(feedback.overallAssessment, '');
      expect(feedback.suggestions, isEmpty);
      expect(feedback.encouragement, '');
    });

    test('toJson이 올바른 맵을 반환한다', () {
      const feedback = CookingFeedback(
        doneness: Doneness.overcooked,
        donenessDescription: '조금 탔어요',
        platingScore: 6,
        platingFeedback: '좋아요',
        overallAssessment: '괜찮습니다',
        suggestions: ['불 줄이기'],
        encouragement: '다음엔 더 잘할 거예요!',
      );

      final json = feedback.toJson();
      expect(json['doneness'], 'overcooked');
      expect(json['donenessDescription'], '조금 탔어요');
      expect(json['platingScore'], 6);
      expect(json['platingFeedback'], '좋아요');
      expect(json['overallAssessment'], '괜찮습니다');
      expect(json['suggestions'], ['불 줄이기']);
      expect(json['encouragement'], '다음엔 더 잘할 거예요!');
    });

    test('fromJson → toJson 왕복 테스트', () {
      final original = {
        'doneness': 'perfect',
        'donenessDescription': '적절합니다',
        'platingScore': 9,
        'platingFeedback': '예쁘게 담았네요',
        'overallAssessment': '완벽합니다',
        'suggestions': ['파슬리 뿌리기'],
        'encouragement': '최고예요!',
      };

      final feedback = CookingFeedback.fromJson(original);
      final roundTripped = feedback.toJson();

      expect(roundTripped['doneness'], original['doneness']);
      expect(roundTripped['donenessDescription'], original['donenessDescription']);
      expect(roundTripped['platingScore'], original['platingScore']);
      expect(roundTripped['platingFeedback'], original['platingFeedback']);
      expect(roundTripped['overallAssessment'], original['overallAssessment']);
      expect(roundTripped['suggestions'], original['suggestions']);
      expect(roundTripped['encouragement'], original['encouragement']);
    });
  });
}
