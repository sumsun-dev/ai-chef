import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/components/cooking_timer.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('CookingTimer', () {
    testWidgets('초기 시간을 mm:ss 형식으로 표시한다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const CookingTimer(minutes: 5)),
      );

      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('"시작" 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const CookingTimer(minutes: 3)),
      );

      expect(find.text('시작'), findsOneWidget);
    });

    testWidgets('시작 후 카운트다운이 진행된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const CookingTimer(minutes: 1)),
      );

      // 시작 버튼 탭
      await tester.tap(find.text('시작'));
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('00:57'), findsOneWidget);
    });

    testWidgets('시작 후 일시정지 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const CookingTimer(minutes: 1)),
      );

      await tester.tap(find.text('시작'));
      await tester.pump();

      expect(find.text('일시정지'), findsOneWidget);
    });

    testWidgets('타이머 완료 시 audioService.notifyTimerComplete()를 호출한다',
        (tester) async {
      final audioService = FakeCookingAudioService();
      bool completed = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          CookingTimer(
            minutes: 1,
            audioService: audioService,
            onComplete: () => completed = true,
          ),
        ),
      );

      // 시작 버튼 탭
      await tester.tap(find.text('시작'));
      // 60초 pump → 타이머 완료
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(audioService.notifyCount, 1);
      expect(completed, true);
    });

    testWidgets('audioService 없이도 타이머가 정상 완료된다', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          CookingTimer(
            minutes: 1,
            onComplete: () => completed = true,
          ),
        ),
      );

      await tester.tap(find.text('시작'));
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(completed, true);
    });
  });
}
