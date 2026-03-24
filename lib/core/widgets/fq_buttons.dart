import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_gradients.dart';
import '../theme/fq_tokens.dart';

class FQPrimaryButton extends StatelessWidget {
  const FQPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: FQRadius.pill,
        gradient: FQGradients.primaryCta,
        boxShadow: FQShadows.glow,
      ),
      child: FilledButton(
        onPressed: onPressed ?? () {},
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class FQSecondaryButton extends StatelessWidget {
  const FQSecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: FQGradients.subtlePanel,
        borderRadius: FQRadius.pill,
        border: Border.all(
          color: FQColors.primary.withValues(alpha: 0.16),
          width: 1.2,
        ),
      ),
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: FQColors.primary,
        ),
        child: Text(label),
      ),
    );
  }
}
