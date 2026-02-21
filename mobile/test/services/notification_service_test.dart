import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_chef/services/notification_service.dart';

import '../helpers/widget_test_helpers.dart';

/// Fake FlutterLocalNotificationsPlugin for testing
class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool initializeCalled = false;
  int showCallCount = 0;
  List<(int, String?, String?)> showCalls = [];
  int cancelAllCallCount = 0;
  List<int> cancelledIds = [];

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalled = true;
    return true;
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    showCallCount++;
    showCalls.add((id, title, body));
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    cancelledIds.add(id);
  }

  @override
  T? resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    return null;
  }
}

void main() {
  late FakeFlutterLocalNotificationsPlugin fakeNotifications;
  late FakeIngredientService fakeIngredientService;
  late NotificationService service;

  setUp(() {
    fakeNotifications = FakeFlutterLocalNotificationsPlugin();
    fakeIngredientService = FakeIngredientService();
    service = NotificationService.forTesting(
      notifications: fakeNotifications,
      ingredientService: fakeIngredientService,
    );
  });

  group('NotificationService', () {
    group('initialize', () {
      test('플러그인 초기화를 호출한다', () async {
        // Act
        await service.initialize();

        // Assert
        expect(fakeNotifications.initializeCalled, isTrue);
      });

      test('중복 호출 시 한 번만 실행된다', () async {
        // Act
        await service.initialize();
        fakeNotifications.initializeCalled = false;
        await service.initialize();

        // Assert
        expect(fakeNotifications.initializeCalled, isFalse);
      });
    });

    group('requestPermission', () {
      test('platform 구현이 없으면 true를 반환한다', () async {
        // Act
        final result = await service.requestPermission();

        // Assert
        expect(result, isTrue);
      });
    });

    group('checkAndShowExpiryNotifications', () {
      test('만료된 재료가 있으면 high 알림을 표시한다', () async {
        // Arrange
        fakeIngredientService.expiryGroup = ExpiryIngredientGroup(
          expiredItems: [
            createTestIngredient(
              name: '우유',
              expiryDate: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
          criticalItems: [],
          warningItems: [],
          safeItems: [],
        );

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        expect(fakeNotifications.showCallCount, 1);
        expect(fakeNotifications.showCalls.first.$2, '유통기한 경고');
      });

      test('D-Day 재료에 오늘 만료 알림을 표시한다', () async {
        // Arrange - DateTime.now()로 daysUntilExpiry == 0 보장
        fakeIngredientService.expiryGroup = ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [
            createTestIngredient(name: '두부', expiryDate: DateTime.now()),
          ],
          warningItems: [],
          safeItems: [],
        );

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        final todayCalls = fakeNotifications.showCalls
            .where((c) => c.$2 == '오늘 만료되는 재료')
            .toList();
        expect(todayCalls.length, 1);
        expect(todayCalls.first.$3, contains('두부'));
      });

      test('D-1 재료에 내일 만료 알림을 표시한다', () async {
        // Arrange - +25h로 daysUntilExpiry == 1 확실히 보장 (시간차 방지)
        final tomorrowExpiry =
            DateTime.now().add(const Duration(hours: 25));
        fakeIngredientService.expiryGroup = ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [
            createTestIngredient(name: '계란', expiryDate: tomorrowExpiry),
          ],
          warningItems: [],
          safeItems: [],
        );

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        final tomorrowCalls = fakeNotifications.showCalls
            .where((c) => c.$2 == '내일 만료 예정 재료')
            .toList();
        expect(tomorrowCalls.length, 1);
        expect(tomorrowCalls.first.$3, contains('계란'));
      });

      test('D-3 재료에 3일 후 만료 알림을 표시한다', () async {
        // Arrange - +73h로 daysUntilExpiry == 3 확실히 보장 (시간차 방지)
        final threeDayExpiry =
            DateTime.now().add(const Duration(hours: 73));
        fakeIngredientService.expiryGroup = ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [
            createTestIngredient(name: '양파', expiryDate: threeDayExpiry),
          ],
          warningItems: [],
          safeItems: [],
        );

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        final threeDayCalls = fakeNotifications.showCalls
            .where((c) => c.$2 == '3일 후 만료 예정')
            .toList();
        expect(threeDayCalls.length, 1);
        expect(threeDayCalls.first.$3, contains('양파'));
      });

      test('재료가 없으면 알림을 표시하지 않는다', () async {
        // Arrange - default empty group

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        expect(fakeNotifications.showCallCount, 0);
      });

      test('3개 초과 시 외 N개 요약을 포함한다', () async {
        // Arrange - DateTime.now()로 daysUntilExpiry == 0 보장
        final now = DateTime.now();
        fakeIngredientService.expiryGroup = ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [
            createTestIngredient(name: '두부', expiryDate: now),
            createTestIngredient(name: '우유', expiryDate: now),
            createTestIngredient(name: '계란', expiryDate: now),
            createTestIngredient(name: '치즈', expiryDate: now),
            createTestIngredient(name: '햄', expiryDate: now),
          ],
          warningItems: [],
          safeItems: [],
        );

        // Act
        await service.initialize();
        await service.checkAndShowExpiryNotifications();

        // Assert
        final todayCalls = fakeNotifications.showCalls
            .where((c) => c.$2 == '오늘 만료되는 재료')
            .toList();
        expect(todayCalls.length, 1);
        expect(todayCalls.first.$3, contains('외 2개'));
      });
    });

    group('showRecipeRecommendation', () {
      test('메시지 알림을 표시한다', () async {
        // Act
        await service.initialize();
        await service.showRecipeRecommendation(message: '김치찌개 어때요?');

        // Assert
        expect(fakeNotifications.showCallCount, 1);
        expect(fakeNotifications.showCalls.first.$2, '오늘의 추천');
        expect(fakeNotifications.showCalls.first.$3, '김치찌개 어때요?');
      });
    });

    group('cancelAllNotifications', () {
      test('전체 알림을 취소한다', () async {
        // Act
        await service.cancelAllNotifications();

        // Assert
        expect(fakeNotifications.cancelAllCallCount, 1);
      });
    });

    group('cancelNotification', () {
      test('특정 ID의 알림을 취소한다', () async {
        // Act
        await service.cancelNotification(42);

        // Assert
        expect(fakeNotifications.cancelledIds, [42]);
      });
    });
  });
}
