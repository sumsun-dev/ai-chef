import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chef.dart';

void main() {
  group('Chef', () {
    test('생성자 필드가 올바르게 할당된다', () {
      const chef = Chef(
        id: 'test',
        name: '테스트셰프',
        title: '테스트 타이틀',
        philosophy: '테스트 철학',
        emoji: '🧑‍🍳',
        specialties: ['한식'],
        targetScenarios: ['solo'],
        personality: ChefPersonality(
          tone: 'casual',
          humor: 'medium',
          encouragement: 'high',
        ),
        greetings: ['안녕하세요!', '반갑습니다!'],
        encouragements: ['잘하셨어요!', '멋져요!'],
        primaryColor: 0xFFFF6B35,
      );

      expect(chef.id, 'test');
      expect(chef.name, '테스트셰프');
      expect(chef.title, '테스트 타이틀');
      expect(chef.philosophy, '테스트 철학');
      expect(chef.emoji, '🧑‍🍳');
      expect(chef.specialties, ['한식']);
      expect(chef.targetScenarios, ['solo']);
      expect(chef.primaryColor, 0xFFFF6B35);
    });

    test('randomGreeting이 greetings 중 하나를 반환한다', () {
      const chef = Chef(
        id: 'test',
        name: '테스트',
        title: '타이틀',
        philosophy: '철학',
        emoji: '🧑‍🍳',
        specialties: [],
        targetScenarios: [],
        personality: ChefPersonality(
          tone: 'casual',
          humor: 'low',
          encouragement: 'low',
        ),
        greetings: ['인사1', '인사2', '인사3'],
        encouragements: ['격려1'],
        primaryColor: 0xFF000000,
      );

      expect(chef.greetings, contains(chef.randomGreeting));
    });

    test('randomEncouragement이 encouragements 중 하나를 반환한다', () {
      const chef = Chef(
        id: 'test',
        name: '테스트',
        title: '타이틀',
        philosophy: '철학',
        emoji: '🧑‍🍳',
        specialties: [],
        targetScenarios: [],
        personality: ChefPersonality(
          tone: 'casual',
          humor: 'low',
          encouragement: 'low',
        ),
        greetings: ['인사1'],
        encouragements: ['격려1', '격려2', '격려3'],
        primaryColor: 0xFF000000,
      );

      expect(chef.encouragements, contains(chef.randomEncouragement));
    });
  });

  group('ChefPersonality', () {
    test('필드가 올바르게 할당된다', () {
      const personality = ChefPersonality(
        tone: 'professional',
        humor: 'high',
        encouragement: 'medium',
      );

      expect(personality.tone, 'professional');
      expect(personality.humor, 'high');
      expect(personality.encouragement, 'medium');
    });
  });

  group('Chefs', () {
    test('all은 8명의 셰프를 포함한다', () {
      expect(Chefs.all.length, 8);
    });

    test('all의 셰프 ID가 모두 고유하다', () {
      final ids = Chefs.all.map((c) => c.id).toSet();
      expect(ids.length, 8);
    });

    test('findById - 존재하는 ID', () {
      final chef = Chefs.findById('baek');
      expect(chef, isNotNull);
      expect(chef!.name, '백셰프');
    });

    test('findById - 존재하지 않는 ID', () {
      final chef = Chefs.findById('nonexistent');
      expect(chef, isNull);
    });

    test('defaultChef는 baek이다', () {
      expect(Chefs.defaultChef.id, 'baek');
    });

    test('recommendForScenario - 매칭되는 시나리오', () {
      final chef = Chefs.recommendForScenario('diet');
      expect(chef.id, 'yoon');
    });

    test('recommendForScenario - 매칭되지 않으면 defaultChef 반환', () {
      final chef = Chefs.recommendForScenario('unknown_scenario');
      expect(chef.id, Chefs.defaultChef.id);
    });

    test('각 셰프의 필수 필드가 비어있지 않다', () {
      for (final chef in Chefs.all) {
        expect(chef.id, isNotEmpty);
        expect(chef.name, isNotEmpty);
        expect(chef.title, isNotEmpty);
        expect(chef.philosophy, isNotEmpty);
        expect(chef.emoji, isNotEmpty);
        expect(chef.specialties, isNotEmpty);
        expect(chef.targetScenarios, isNotEmpty);
        expect(chef.greetings, isNotEmpty);
        expect(chef.encouragements, isNotEmpty);
      }
    });
  });
}
