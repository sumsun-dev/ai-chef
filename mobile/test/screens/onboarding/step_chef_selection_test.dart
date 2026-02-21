import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/models/chef_presets.dart';
import 'package:ai_chef/screens/onboarding/step_chef_selection.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('StepChefSelection', () {
    late String? capturedPresetId;
    late String capturedName;

    Widget buildWidget({String? selectedPresetId}) {
      return wrapWithMaterialApp(
        StepChefSelection(
          selectedPresetId: selectedPresetId,
          chefName: '',
          personality: '',
          expertise: const [],
          formality: '',
          emojiUsage: '',
          technicality: '',
          onChanged: ({
            String? presetId,
            required String name,
            required String personality,
            required List<String> expertise,
            required String formality,
            required String emojiUsage,
            required String technicality,
          }) {
            capturedPresetId = presetId;
            capturedName = name;
          },
        ),
      );
    }

    setUp(() {
      capturedPresetId = null;
      capturedName = '';
    });

    testWidgets('8개 프리셋 카드가 렌더링된다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget());

      // Assert
      for (final preset in ChefPresets.all) {
        expect(find.text(preset.name), findsOneWidget);
      }
    });

    testWidgets('카드 탭 시 onChanged 콜백이 호출된다', (tester) async {
      // Arrange
      await tester.pumpWidget(buildWidget());

      // Act
      await tester.tap(find.text(ChefPresets.all.first.name));
      await tester.pump();

      // Assert
      expect(capturedPresetId, ChefPresets.all.first.id);
      expect(capturedName, ChefPresets.all.first.config.name);
    });

    testWidgets('선택된 프리셋 카드에 2px 테두리가 표시된다', (tester) async {
      // Arrange & Act
      final presetId = ChefPresets.all.first.id;
      await tester.pumpWidget(buildWidget(selectedPresetId: presetId));

      // Assert - 선택된 카드의 AnimatedContainer가 2px border를 가짐
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final selectedContainer = containers.first;
      final decoration = selectedContainer.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border as Border).top.width,
        2,
      );
    });

    testWidgets('미선택 상태에서 전체 카드가 표시된다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget(selectedPresetId: null));

      // Assert
      expect(find.byType(AnimatedContainer), findsNWidgets(8));
    });
  });
}
