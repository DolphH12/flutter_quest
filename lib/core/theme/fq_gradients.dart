import 'package:flutter/material.dart';

import 'fq_colors.dart';

abstract final class FQGradients {
  static const LinearGradient appBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF1FF), FQColors.surface, Color(0xFFF1F5FF)],
  );

  static const LinearGradient primaryCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FQColors.primary, FQColors.primaryBright],
  );

  static const LinearGradient heroBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E5CA5), Color(0xFF2D79D8), Color(0xFF5CADFE)],
  );

  static const LinearGradient deepQuest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E1A36), Color(0xFF183562), Color(0xFF245089)],
  );

  static const LinearGradient highlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x80FFFFFF), Color(0x22FFFFFF)],
  );

  static const LinearGradient subtlePanel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F9FF), Color(0xFFECF1FF)],
  );
}
