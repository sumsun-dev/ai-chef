import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_chef/screens/settings/notification_settings_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('NotificationSettingsScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('알림 설정 타이틀 표시', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        wrapWithMaterialApp(NotificationSettingsScreen(
          prefs: prefs,
          notificationService: FakeNotificationService(),
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('알림 설정'), findsOneWidget);
    });

    testWidgets('스위치 토글 항목들 표시 및 동작', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        wrapWithMaterialApp(NotificationSettingsScreen(
          prefs: prefs,
          notificationService: FakeNotificationService(),
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('유통기한 알림'), findsOneWidget);
      expect(find.text('레시피 추천 알림'), findsOneWidget);

      // 유통기한 알림은 기본 켜짐
      final switches = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      ).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);
    });

    testWidgets('설정 변경 시 SharedPreferences에 저장', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final fakeNotification = FakeNotificationService();
      await tester.pumpWidget(
        wrapWithMaterialApp(NotificationSettingsScreen(
          prefs: prefs,
          notificationService: fakeNotification,
        )),
      );
      await tester.pumpAndSettle();

      // 유통기한 알림 끄기
      await tester.tap(find.text('유통기한 알림'));
      await tester.pumpAndSettle();

      expect(prefs.getBool('notification_expiry_alert'), isFalse);
      expect(fakeNotification.cancelCalled, isTrue);
    });
  });
}
