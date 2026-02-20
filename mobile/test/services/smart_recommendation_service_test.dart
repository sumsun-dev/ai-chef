import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/services/smart_recommendation_service.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeIngredientService fakeIngredientService;
  late FakeNotificationService fakeNotificationService;
  late SmartRecommendationService service;

  setUp(() {
    fakeIngredientService = FakeIngredientService();
    fakeNotificationService = FakeNotificationService();
    service = SmartRecommendationService(
      ingredientService: fakeIngredientService,
      notificationService: fakeNotificationService,
    );
  });

  group('SmartRecommendationService', () {
    group('getTimeBasedGreeting', () {
      test('아침 (6-11시)은 아침 인사를 반환한다', () {
        final morning = DateTime(2026, 2, 20, 8, 0);
        expect(service.getTimeBasedGreeting(now: morning), '좋은 아침이에요!');
      });

      test('점심 (11-14시)은 점심 메시지를 반환한다', () {
        final noon = DateTime(2026, 2, 20, 12, 0);
        expect(service.getTimeBasedGreeting(now: noon), '점심 메뉴 고민 중이세요?');
      });

      test('오후 (14-17시)은 간식 메시지를 반환한다', () {
        final afternoon = DateTime(2026, 2, 20, 15, 0);
        expect(service.getTimeBasedGreeting(now: afternoon), '오후 간식은 어떠세요?');
      });

      test('저녁 (17-21시)은 저녁 메시지를 반환한다', () {
        final evening = DateTime(2026, 2, 20, 19, 0);
        expect(service.getTimeBasedGreeting(now: evening), '저녁 뭐 먹을까요?');
      });

      test('밤 (21시~6시)은 야식 메시지를 반환한다', () {
        final night = DateTime(2026, 2, 20, 23, 0);
        expect(service.getTimeBasedGreeting(now: night), '야식이 당기는 밤이네요!');
      });
    });

    group('generateRecommendationMessage', () {
      test('임박 재료가 없으면 기본 메시지를 반환한다', () {
        final message = service.generateRecommendationMessage(
          expiringIngredients: [],
          now: DateTime(2026, 2, 20, 8, 0),
        );

        expect(message, contains('좋은 아침이에요!'));
        expect(message, contains('어떤 요리'));
      });

      test('임박 재료가 있으면 재료명을 포함한다', () {
        final ingredients = [
          createTestIngredient(name: '양파'),
          createTestIngredient(name: '당근'),
        ];

        final message = service.generateRecommendationMessage(
          expiringIngredients: ingredients,
          now: DateTime(2026, 2, 20, 19, 0),
        );

        expect(message, contains('저녁 뭐 먹을까요?'));
        expect(message, contains('양파'));
        expect(message, contains('당근'));
        expect(message, contains('곧 만료'));
      });

      test('3개 초과 시 "외 N개"를 포함한다', () {
        final ingredients = [
          createTestIngredient(name: '양파'),
          createTestIngredient(name: '당근'),
          createTestIngredient(name: '감자'),
          createTestIngredient(name: '토마토'),
        ];

        final message = service.generateRecommendationMessage(
          expiringIngredients: ingredients,
          now: DateTime(2026, 2, 20, 12, 0),
        );

        expect(message, contains('외 1개'));
      });
    });

    group('checkAndRecommend', () {
      test('임박 재료 없으면 null을 반환한다', () async {
        fakeIngredientService.ingredients = [];
        final result = await service.checkAndRecommend();
        expect(result, isNull);
      });
    });
  });
}
