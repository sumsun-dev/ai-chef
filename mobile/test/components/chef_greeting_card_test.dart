import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/chef_greeting_card.dart';
import 'package:ai_chef/models/chef.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('ChefGreetingCard', () {
    testWidgets('셰프 이모지를 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ChefGreetingCard(chef: Chefs.baek),
        ),
      );

      expect(find.text(Chefs.baek.emoji), findsOneWidget);
    });

    testWidgets('셰프 이름을 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ChefGreetingCard(chef: Chefs.baek),
        ),
      );

      expect(find.text(Chefs.baek.name), findsOneWidget);
    });

    testWidgets('greetings 중 하나를 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ChefGreetingCard(chef: Chefs.baek),
        ),
      );

      final greetingFound = Chefs.baek.greetings.any(
        (greeting) => find.text(greeting).evaluate().isNotEmpty,
      );
      expect(greetingFound, isTrue);
    });
  });
}
