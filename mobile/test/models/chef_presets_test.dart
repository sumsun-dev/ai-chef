import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chef_presets.dart';

void main() {
  group('ChefPreset', () {
    test('필드가 올바르게 할당된다', () {
      final preset = ChefPresets.all.first;
      expect(preset.id, isNotEmpty);
      expect(preset.name, isNotEmpty);
      expect(preset.description, isNotEmpty);
      expect(preset.emoji, isNotEmpty);
      expect(preset.primaryColor, isNonZero);
      expect(preset.config, isNotNull);
    });
  });

  group('ChefPresets', () {
    test('all은 8개의 프리셋을 포함한다', () {
      expect(ChefPresets.all.length, 8);
    });

    test('all의 ID가 모두 고유하다', () {
      final ids = ChefPresets.all.map((p) => p.id).toSet();
      expect(ids.length, ChefPresets.all.length);
    });

    test('findById - 존재하는 ID', () {
      final preset = ChefPresets.findById('korean_grandma');
      expect(preset, isNotNull);
      expect(preset!.name, '할머니 손맛');
    });

    test('findById - 존재하지 않는 ID', () {
      final preset = ChefPresets.findById('nonexistent');
      expect(preset, isNull);
    });

    test('각 프리셋의 config가 유효하다', () {
      for (final preset in ChefPresets.all) {
        expect(preset.config.name, isNotEmpty);
        expect(preset.config.expertise, isNotEmpty);
        expect(preset.config.cookingPhilosophy, isNotNull);
      }
    });

    test('알려진 프리셋 ID가 모두 존재한다', () {
      final expectedIds = [
        'korean_grandma',
        'michelin_chef',
        'health_chef',
        'food_youtuber',
        'home_master',
        'baking_master',
        'global_explorer',
        'student_buddy',
      ];

      for (final id in expectedIds) {
        expect(ChefPresets.findById(id), isNotNull, reason: '$id should exist');
      }
    });
  });
}
