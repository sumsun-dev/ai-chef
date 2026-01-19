import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/ingredient.dart';
import 'ingredient_service.dart';

/// 유통기한 알림 서비스
/// D-3, D-1, D-Day 재료에 대한 로컬 푸시 알림 관리
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final IngredientService _ingredientService = IngredientService();

  bool _isInitialized = false;

  /// 알림 채널 ID
  static const String _channelId = 'expiry_alerts';
  static const String _channelName = '유통기한 알림';
  static const String _channelDescription = '재료 유통기한 알림';

  /// 알림 ID 범위
  static const int _dailyCheckNotificationId = 0;
  static const int _expiryNotificationBaseId = 1000;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 앱 내 유통기한 화면으로 이동하는 로직
    // GoRouter를 통한 네비게이션은 앱 레벨에서 처리
  }

  /// 유통기한 알림 체크 및 표시
  Future<void> checkAndShowExpiryNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      final expiryGroup = await _ingredientService.getExpiryIngredientGroup();

      // 만료된 재료 알림
      if (expiryGroup.expiredCount > 0) {
        await _showExpiryNotification(
          id: _expiryNotificationBaseId,
          title: '유통기한 경고',
          body: '${expiryGroup.expiredCount}개 재료의 유통기한이 지났습니다. 확인해주세요!',
          priority: NotificationPriority.high,
        );
      }

      // D-Day 재료 (오늘 만료)
      final todayItems = expiryGroup.criticalItems
          .where((i) => i.daysUntilExpiry == 0)
          .toList();
      if (todayItems.isNotEmpty) {
        final names = todayItems.take(3).map((i) => i.name).join(', ');
        final suffix = todayItems.length > 3 ? ' 외 ${todayItems.length - 3}개' : '';
        await _showExpiryNotification(
          id: _expiryNotificationBaseId + 1,
          title: '오늘 만료되는 재료',
          body: '$names$suffix - 오늘 중으로 사용해주세요!',
          priority: NotificationPriority.high,
        );
      }

      // D-1 재료 (내일 만료)
      final tomorrowItems = expiryGroup.criticalItems
          .where((i) => i.daysUntilExpiry == 1)
          .toList();
      if (tomorrowItems.isNotEmpty) {
        final names = tomorrowItems.take(3).map((i) => i.name).join(', ');
        final suffix = tomorrowItems.length > 3 ? ' 외 ${tomorrowItems.length - 3}개' : '';
        await _showExpiryNotification(
          id: _expiryNotificationBaseId + 2,
          title: '내일 만료 예정 재료',
          body: '$names$suffix - 내일까지 사용해주세요!',
          priority: NotificationPriority.defaultPriority,
        );
      }

      // D-3 재료 (3일 내 만료)
      final threeDayItems = expiryGroup.criticalItems
          .where((i) => i.daysUntilExpiry == 3)
          .toList();
      if (threeDayItems.isNotEmpty) {
        final names = threeDayItems.take(3).map((i) => i.name).join(', ');
        final suffix = threeDayItems.length > 3 ? ' 외 ${threeDayItems.length - 3}개' : '';
        await _showExpiryNotification(
          id: _expiryNotificationBaseId + 3,
          title: '3일 후 만료 예정',
          body: '$names$suffix - 곧 만료됩니다. 미리 계획하세요!',
          priority: NotificationPriority.low,
        );
      }
    } catch (e) {
      // 알림 체크 실패 시 무시 (백그라운드 작업이므로)
    }
  }

  /// 알림 표시
  Future<void> _showExpiryNotification({
    required int id,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: _getImportance(priority),
      priority: _getAndroidPriority(priority),
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// 매일 아침 9시에 유통기한 체크 알림 스케줄
  Future<void> scheduleDailyExpiryCheck() async {
    if (!_isInitialized) await initialize();

    // 기존 스케줄 취소
    await _notifications.cancel(_dailyCheckNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 오전 9시
    );

    // 이미 오늘 9시가 지났으면 내일로
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _dailyCheckNotificationId,
      '유통기한 체크',
      '오늘의 재료 유통기한을 확인해보세요!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
    );
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
    }
  }
}

/// 알림 우선순위
enum NotificationPriority {
  high,
  defaultPriority,
  low,
}
