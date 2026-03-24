import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_gradients.dart';
import '../theme/fq_tokens.dart';

class FQSurfaceCard extends StatelessWidget {
  const FQSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FQSpacing.md),
    this.radius = FQRadius.medium,
    this.color,
    this.gradient,
    this.shadow = FQShadows.soft,
    this.useHighlightOverlay = true,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow> shadow;
  final bool useHighlightOverlay;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null
            ? color ?? FQColors.surfaceLow.withValues(alpha: 0.94)
            : null,
        gradient: gradient,
        borderRadius: radius,
        boxShadow: shadow,
        border:
            border ??
            Border.all(color: Colors.white.withValues(alpha: 0.32), width: 1.2),
      ),
      child: Stack(
        children: [
          if (useHighlightOverlay)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: FQGradients.highlight,
                ),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
