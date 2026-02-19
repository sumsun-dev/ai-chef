import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../theme/app_colors.dart';

/// 유통기한 상태에 따른 색상 반환
Color getExpiryColor(ExpiryStatus status) {
  switch (status) {
    case ExpiryStatus.expired:
      return AppColors.expiryExpired;
    case ExpiryStatus.critical:
      return AppColors.expiryCritical;
    case ExpiryStatus.warning:
      return AppColors.expiryWarning;
    case ExpiryStatus.safe:
      return AppColors.expirySafe;
  }
}

/// D-Day 뱃지 위젯
class ExpiryBadge extends StatelessWidget {
  final ExpiryStatus status;
  final String dDayString;

  const ExpiryBadge({
    super.key,
    required this.status,
    required this.dDayString,
  });

  @override
  Widget build(BuildContext context) {
    final color = getExpiryColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dDayString,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
