import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_gradients.dart';
import '../theme/fq_tokens.dart';

class FQProgressBar extends StatelessWidget {
  const FQProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.fillGradient = FQGradients.primaryCta,
    this.trackColor,
  });

  final double value;
  final double height;
  final Gradient fillGradient;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: FQRadius.pill,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color:
                    trackColor ?? FQColors.surfaceHigh.withValues(alpha: 0.72),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: fillGradient),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
