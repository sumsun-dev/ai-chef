import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// SharedPreferences 키
const _kExpiryAlert = 'notification_expiry_alert';
const _kRecipeRecommendation = 'notification_recipe_recommendation';

/// 알림 설정 화면
///
/// SharedPreferences로 설정값을 저장하고
/// NotificationService와 연동합니다.
class NotificationSettingsScreen extends StatefulWidget {
  final SharedPreferences? prefs;
  final NotificationService? notificationService;

  const NotificationSettingsScreen({
    super.key,
    this.prefs,
    this.notificationService,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _expiryAlert = true;
  bool _recipeRecommendation = false;
  bool _isLoading = true;
  SharedPreferences? _prefs;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService ?? NotificationService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = widget.prefs ?? await SharedPreferences.getInstance();
    setState(() {
      _expiryAlert = _prefs!.getBool(_kExpiryAlert) ?? true;
      _recipeRecommendation = _prefs!.getBool(_kRecipeRecommendation) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _onExpiryAlertChanged(bool value) async {
    setState(() => _expiryAlert = value);
    await _prefs?.setBool(_kExpiryAlert, value);

    if (value) {
      await _notificationService.requestPermission();
      await _notificationService.scheduleDailyExpiryCheck();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _onRecipeRecommendationChanged(bool value) async {
    setState(() => _recipeRecommendation = value);
    await _prefs?.setBool(_kRecipeRecommendation, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  title: Text(
                    '유통기한 알림',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'D-3, D-1, D-Day 재료 알림을 매일 아침 9시에 받습니다',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _expiryAlert,
                  onChanged: _onExpiryAlertChanged,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    '레시피 추천 알림',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '보유 재료 기반 새로운 맞춤 레시피 추천',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _recipeRecommendation,
                  onChanged: _onRecipeRecommendationChanged,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                ),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    '알림 권한은 기기 설정에서도 변경할 수 있습니다.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
