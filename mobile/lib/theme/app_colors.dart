import 'package:flutter/material.dart';

/// 디자인 토큰: 앱 전체 색상 팔레트
///
/// 웹(oklch CSS 변수)과 시각적으로 동기화됨.
/// | 토큰       | 웹 oklch             | 모바일 hex  |
/// |-----------|---------------------|------------|
/// | primary   | oklch(0.65 0.2 35)  | #FF6B35    |
/// | background| oklch(0.985 0.008 85)| #FFFBF5   |
/// | foreground| oklch(0.25 0.02 30) | #3D2B1F    |
/// | accent    | oklch(0.7 0.15 145) | #4CAF50    |
/// | border    | oklch(0.9 0.02 85)  | #E8DDD4    |
abstract final class AppColors {
  // ── Brand ──
  static const primary = Color(0xFFFF6B35);
  static const primaryLight = Color(0xFFFF8C42);
  static const primaryDark = Color(0xFFE55A2B);
  static const accent = Color(0xFF4CAF50);
  static const accentLight = Color(0xFF81C784);

  // ── Semantic ──
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
  static const success = Color(0xFF4CAF50);

  // ── Expiry Status ──
  static const expiryExpired = Color(0xFFD32F2F);
  static const expiryCritical = Color(0xFFFF9800);
  static const expiryWarning = Color(0xFF2196F3);
  static const expirySafe = Color(0xFF4CAF50);

  // ── Light Neutral ──
  static const surface = Color(0xFFFFFBF5);
  static const surfaceDim = Color(0xFFF5F0EA);
  static const textPrimary = Color(0xFF3D2B1F);
  static const textSecondary = Color(0xFF8D7B6E);
  static const textTertiary = Color(0xFFB8A99E);
  static const border = Color(0xFFE8DDD4);
  static const divider = Color(0xFFF0E8E0);
  static const inputFill = Color(0xFFF8F3EE);

  // ── Card ──
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardElevated = Color(0xFFFFFDF9);

  // ── Dark Neutral ──
  static const darkSurface = Color(0xFF2C2017);
  static const darkCardBackground = Color(0xFF3A2E23);
  static const darkTextPrimary = Color(0xFFF5EDE5);
  static const darkTextSecondary = Color(0xFFB8A99E);
  static const darkBorder = Color(0xFF4A3E33);
  static const darkInputFill = Color(0xFF3A2E23);
}
