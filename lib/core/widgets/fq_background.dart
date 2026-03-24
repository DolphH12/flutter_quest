import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_gradients.dart';

class FQBackground extends StatelessWidget {
  const FQBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: FQGradients.appBackground),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: _GlowOrb(
              size: 220,
              color: FQColors.primaryBright.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            left: -40,
            bottom: 120,
            child: _GlowOrb(
              size: 180,
              color: FQColors.tertiary.withValues(alpha: 0.18),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 10),
          ],
        ),
      ),
    );
  }
}
