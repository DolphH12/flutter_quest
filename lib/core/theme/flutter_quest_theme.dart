import 'package:flutter/material.dart';

import 'fq_colors.dart';
import 'fq_gradients.dart';
import 'fq_tokens.dart';
import 'fq_typography.dart';

abstract final class FlutterQuestTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FQColors.primary,
      brightness: Brightness.light,
      primary: FQColors.primary,
      secondary: FQColors.primaryBright,
      tertiary: FQColors.tertiary,
      surface: FQColors.surface,
      onSurface: FQColors.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FQColors.surface,
      textTheme: FQTypography.textTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: FQColors.surfaceLow,
        shape: RoundedRectangleBorder(borderRadius: FQRadius.medium),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        labelStyle: FQTypography.textTheme().labelMedium,
        backgroundColor: FQColors.surfaceLow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 82,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return FQTypography.textTheme().labelMedium!.copyWith(
            color: selected
                ? FQColors.primary
                : FQColors.onSurface.withValues(alpha: 0.7),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FQColors.primary,
        linearTrackColor: FQColors.surfaceHigh,
      ),
      iconTheme: const IconThemeData(color: FQColors.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: FQRadius.pill),
          textStyle: FQTypography.textTheme().labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FQColors.primary,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: FQRadius.pill),
          backgroundColor: FQColors.surfaceLow,
          textStyle: FQTypography.textTheme().labelLarge,
        ),
      ),
      extensions: const [_FQThemeExtension()],
    );
  }
}

class _FQThemeExtension extends ThemeExtension<_FQThemeExtension> {
  const _FQThemeExtension();

  LinearGradient get primaryGradient => FQGradients.primaryCta;

  @override
  ThemeExtension<_FQThemeExtension> copyWith() {
    return const _FQThemeExtension();
  }

  @override
  ThemeExtension<_FQThemeExtension> lerp(
    covariant ThemeExtension<_FQThemeExtension>? other,
    double t,
  ) {
    return this;
  }
}
