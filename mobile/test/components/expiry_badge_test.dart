import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/expiry_badge.dart';
import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/theme/app_colors.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('getExpiryColor', () {
    test('expired -> expiryExpired', () {
      expect(getExpiryColor(ExpiryStatus.expired), AppColors.expiryExpired);
    });

    test('critical -> expiryCritical', () {
      expect(getExpiryColor(ExpiryStatus.critical), AppColors.expiryCritical);
    });

    test('warning -> expiryWarning', () {
      expect(getExpiryColor(ExpiryStatus.warning), AppColors.expiryWarning);
    });

    test('safe -> expirySafe', () {
      expect(getExpiryColor(ExpiryStatus.safe), AppColors.expirySafe);
    });
  });

  group('ExpiryBadge widget', () {
    testWidgets('dDayString 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ExpiryBadge(
            status: ExpiryStatus.critical,
            dDayString: 'D-3',
          ),
        ),
      );

      expect(find.text('D-3'), findsOneWidget);
    });

    testWidgets('expired 상태일 때 expiryExpired 색상 적용', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ExpiryBadge(
            status: ExpiryStatus.expired,
            dDayString: 'D+2',
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('D+2'));
      final textStyle = textWidget.style!;
      expect(textStyle.color, AppColors.expiryExpired);
    });
  });
}
