import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chef/models/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    group('constructor', () {
      test('기본값이 올바르게 설정된다', () {
        final state = OnboardingState();

        expect(state.skillLevel, 'beginner');
        expect(state.scenarios, isEmpty);
        expect(state.tools, isNotEmpty);
        expect(state.timePreference, '20min');
        expect(state.budgetPreference, 'medium');
        expect(state.chefName, 'AI 셰프');
        expect(state.personality, 'friendly');
        expect(state.expertise, ['한식']);
        expect(state.formality, 'formal');
        expect(state.emojiUsage, 'medium');
        expect(state.technicality, 'general');
        expect(state.selectedPresetId, isNull);
        expect(state.firstIngredients, isEmpty);
      });

      test('기본 조리 도구가 DB 함수와 일치한다', () {
        final state = OnboardingState();
        final tools = state.tools;

        expect(tools['frying_pan'], true);
        expect(tools['pot'], true);
        expect(tools['stove'], true);
        expect(tools['microwave'], true);
        expect(tools['rice_cooker'], true);
        expect(tools['air_fryer'], false);
        expect(tools['oven'], false);
        expect(tools['blender'], false);
        expect(tools.length, 8);
      });
    });

    group('skillLevel 유효성', () {
      test('유효한 skill level 값들을 허용한다', () {
        for (final level in ['beginner', 'novice', 'intermediate', 'advanced']) {
          final state = OnboardingState();
          state.skillLevel = level;
          expect(state.skillLevel, level);
        }
      });
    });

    group('scenarios', () {
      test('시나리오를 추가할 수 있다', () {
        final state = OnboardingState();
        state.scenarios = ['solo', 'lunchbox'];

        expect(state.scenarios.length, 2);
        expect(state.scenarios.contains('solo'), isTrue);
        expect(state.scenarios.contains('lunchbox'), isTrue);
      });
    });

    group('tools', () {
      test('도구 상태를 변경할 수 있다', () {
        final state = OnboardingState();
        state.tools['air_fryer'] = true;

        expect(state.tools['air_fryer'], true);
      });
    });

    group('timePreference', () {
      test('유효한 time preference 값들을 허용한다', () {
        for (final pref in ['10min', '20min', '40min', 'unlimited']) {
          final state = OnboardingState();
          state.timePreference = pref;
          expect(state.timePreference, pref);
        }
      });
    });

    group('budgetPreference', () {
      test('유효한 budget preference 값들을 허용한다', () {
        for (final pref in ['low', 'medium', 'high', 'unlimited']) {
          final state = OnboardingState();
          state.budgetPreference = pref;
          expect(state.budgetPreference, pref);
        }
      });
    });

    group('chef settings', () {
      test('셰프 설정을 변경할 수 있다', () {
        final state = OnboardingState();
        state.selectedPresetId = 'korean_grandma';
        state.chefName = '할머니 셰프';
        state.personality = 'motherly';
        state.expertise = ['한식'];
        state.formality = 'casual';
        state.emojiUsage = 'medium';
        state.technicality = 'beginner';

        expect(state.selectedPresetId, 'korean_grandma');
        expect(state.chefName, '할머니 셰프');
        expect(state.personality, 'motherly');
        expect(state.expertise, ['한식']);
        expect(state.formality, 'casual');
        expect(state.emojiUsage, 'medium');
        expect(state.technicality, 'beginner');
      });
    });

    group('firstIngredients', () {
      test('첫 냉장고 재료를 추가할 수 있다', () {
        final state = OnboardingState();
        state.firstIngredients.add(
          SimpleIngredient(name: '양파', category: 'vegetable'),
        );
        state.firstIngredients.add(
          SimpleIngredient(name: '우유', category: 'dairy'),
        );

        expect(state.firstIngredients.length, 2);
        expect(state.firstIngredients[0].name, '양파');
        expect(state.firstIngredients[1].category, 'dairy');
      });
    });

    group('toolKeyToName', () {
      test('모든 도구 키에 대한 이름이 존재한다', () {
        final state = OnboardingState();
        for (final key in state.tools.keys) {
          expect(OnboardingState.toolKeyToName.containsKey(key), isTrue,
              reason: '$key에 대한 이름이 없습니다');
        }
      });

      test('도구 이름이 올바르다', () {
        expect(OnboardingState.toolKeyToName['frying_pan'], '프라이팬');
        expect(OnboardingState.toolKeyToName['pot'], '냄비');
        expect(OnboardingState.toolKeyToName['stove'], '가스레인지/인덕션');
        expect(OnboardingState.toolKeyToName['microwave'], '전자레인지');
        expect(OnboardingState.toolKeyToName['rice_cooker'], '전기밥솥');
        expect(OnboardingState.toolKeyToName['air_fryer'], '에어프라이어');
        expect(OnboardingState.toolKeyToName['oven'], '오븐');
        expect(OnboardingState.toolKeyToName['blender'], '블렌더/믹서기');
      });
    });
  });

  group('SimpleIngredient', () {
    test('name과 category가 올바르게 설정된다', () {
      final ingredient = SimpleIngredient(name: '달걀', category: 'egg');

      expect(ingredient.name, '달걀');
      expect(ingredient.category, 'egg');
    });
  });
}
