import 'package:flutter/foundation.dart' show debugPrint;

import '../models/ingredient.dart';
import 'ingredient_service.dart';
import 'notification_service.dart';

/// 스마트 레시피 추천 서비스
///
/// 유통기한 임박 재료 기반으로 시간대별 추천 메시지를 생성하고,
/// 로컬 알림으로 사용자에게 전달합니다.
class SmartRecommendationService {
  final IngredientService _ingredientService;
  final NotificationService _notificationService;

  SmartRecommendationService({
    IngredientService? ingredientService,
    NotificationService? notificationService,
  })  : _ingredientService = ingredientService ?? IngredientService(),
        _notificationService = notificationService ?? NotificationService();

  /// 정적 추천 메시지 빌더 (서비스 인스턴스 생성 불필요)
  static String buildRecommendationMessage({
    required List<Ingredient> expiringIngredients,
    DateTime? now,
  }) {
    final greeting = _getTimeGreeting(now: now);

    if (expiringIngredients.isEmpty) {
      return '$greeting 오늘은 어떤 요리를 만들어볼까요?';
    }

    final names = expiringIngredients.take(3).map((i) => i.name).join(', ');
    final suffix =
        expiringIngredients.length > 3 ? ' 외 ${expiringIngredients.length - 3}개' : '';

    return '$greeting $names$suffix 재료가 곧 만료돼요. '
        '이걸로 맛있는 요리를 만들어볼까요?';
  }

  static String _getTimeGreeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 6 && hour < 11) return '좋은 아침이에요!';
    if (hour >= 11 && hour < 14) return '점심 메뉴 고민 중이세요?';
    if (hour >= 14 && hour < 17) return '오후 간식은 어떠세요?';
    if (hour >= 17 && hour < 21) return '저녁 뭐 먹을까요?';
    return '야식이 당기는 밤이네요!';
  }

  /// 시간대별 인사말 생성 (정적 메서드에 위임)
  String getTimeBasedGreeting({DateTime? now}) => _getTimeGreeting(now: now);

  /// 임박 재료 기반 추천 메시지 생성 (정적 메서드에 위임)
  String generateRecommendationMessage({
    required List<Ingredient> expiringIngredients,
    DateTime? now,
  }) =>
      buildRecommendationMessage(
        expiringIngredients: expiringIngredients,
        now: now,
      );

  /// 추천 확인 및 알림 전송
  Future<String?> checkAndRecommend() async {
    try {
      final expiring =
          await _ingredientService.getExpiringIngredients(days: 3);
      if (expiring.isEmpty) return null;

      final message = generateRecommendationMessage(
        expiringIngredients: expiring,
      );

      await _notificationService.showRecipeRecommendation(
        message: message,
      );

      return message;
    } catch (e) {
      assert(() {
        debugPrint('SmartRecommendation: 추천 생성 실패 - $e');
        return true;
      }());
      return null;
    }
  }
}
