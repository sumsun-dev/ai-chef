import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/screens/receipt_scan_screen.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  group('ReceiptScanScreen', () {
    testWidgets('초기 UI 표시 (안내, 이미지 선택 영역, 팁)', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ReceiptScanScreen(
          ocrService: FakeReceiptOcrService(),
        )),
      );

      expect(find.text('영수증 스캔'), findsOneWidget);
      expect(find.text('영수증 이미지 선택'), findsOneWidget);
      expect(find.text('카메라'), findsOneWidget);
      expect(find.text('갤러리'), findsOneWidget);
    });

    testWidgets('촬영 팁 섹션 표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ReceiptScanScreen(
          ocrService: FakeReceiptOcrService(),
        )),
      );

      expect(find.text('촬영 팁'), findsOneWidget);
      expect(find.text('밝은 곳에서 촬영하세요'), findsOneWidget);
      expect(find.text('영수증 전체가 보이도록 촬영하세요'), findsOneWidget);
      expect(find.text('글자가 선명하게 보이도록 촬영하세요'), findsOneWidget);
    });

    testWidgets('이미지 선택 전 분석 버튼 미표시', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(ReceiptScanScreen(
          ocrService: FakeReceiptOcrService(),
        )),
      );

      expect(find.text('재료 인식 시작'), findsNothing);
    });
  });
}
