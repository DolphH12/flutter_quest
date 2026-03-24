import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_gradients.dart';
import '../theme/fq_tokens.dart';

class FQProgressBar extends StatelessWidget {
  const FQProgressBar({super.key, required this.value, this.height = 12});

  final double value;
  final double height;

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
                color: FQColors.surfaceHigh.withValues(alpha: 0.72),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: FQGradients.primaryCta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
