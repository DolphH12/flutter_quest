import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_tokens.dart';

class FQPlaceholderBlock extends StatelessWidget {
  const FQPlaceholderBlock({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = FQRadius.small,
    this.opacity = 0.85,
  });

  final double width;
  final double height;
  final BorderRadius radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: FQColors.surfaceHigh.withValues(alpha: opacity),
        borderRadius: radius,
      ),
    );
  }
}
