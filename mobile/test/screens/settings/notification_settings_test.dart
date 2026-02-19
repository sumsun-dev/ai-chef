import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/settings/notification_settings_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('NotificationSettingsScreen', () {
    testWidgets('알림 설정 타이틀 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const NotificationSettingsScreen()),
      );

      expect(find.text('알림 설정'), findsOneWidget);
    });

    testWidgets('스위치 토글 항목들 표시 및 동작', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const NotificationSettingsScreen()),
      );

      expect(find.text('유통기한 알림'), findsOneWidget);
      expect(find.text('레시피 추천 알림'), findsOneWidget);

      // 유통기한 알림은 기본 켜짐
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      ).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);

      // 레시피 추천 알림 토글
      await tester.tap(find.text('레시피 추천 알림'));
      await tester.pump();

      final updatedSwitches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      ).toList();
      expect(updatedSwitches[1].value, isTrue);
    });
  });
}
