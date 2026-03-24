import 'package:flutter/material.dart';

import 'fq_colors.dart';

abstract final class FQTypography {
  // To use branded fonts in the next step, add Plus Jakarta Sans and
  // Be Vietnam Pro in pubspec.yaml under `flutter/fonts` and keep these names.
  static const String headingFamily = 'Plus Jakarta Sans';
  static const String bodyFamily = 'Be Vietnam Pro';

  static TextTheme textTheme() {
    return const TextTheme(
      displaySmall: TextStyle(
        fontFamily: headingFamily,
        fontFamilyFallback: [bodyFamily, 'sans-serif'],
        fontWeight: FontWeight.w800,
        color: FQColors.onSurface,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFamily,
        fontFamilyFallback: [bodyFamily, 'sans-serif'],
        fontWeight: FontWeight.w700,
        color: FQColors.onSurface,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFamily,
        fontFamilyFallback: [bodyFamily, 'sans-serif'],
        fontWeight: FontWeight.w700,
        color: FQColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: [headingFamily, 'sans-serif'],
        fontWeight: FontWeight.w600,
        color: FQColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: [headingFamily, 'sans-serif'],
        fontWeight: FontWeight.w500,
        color: FQColors.onSurface,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: [headingFamily, 'sans-serif'],
        fontWeight: FontWeight.w500,
        color: FQColors.onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: [headingFamily, 'sans-serif'],
        fontWeight: FontWeight.w600,
        color: FQColors.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: [headingFamily, 'sans-serif'],
        fontWeight: FontWeight.w600,
        color: FQColors.onSurface,
      ),
    );
  }
}
