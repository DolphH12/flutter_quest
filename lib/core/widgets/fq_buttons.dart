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
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: FQRadius.pill,
        gradient: enabled
            ? FQGradients.primaryCta
            : LinearGradient(
                colors: [
                  FQColors.primary.withValues(alpha: 0.38),
                  FQColors.primaryBright.withValues(alpha: 0.34),
                ],
              ),
        boxShadow: enabled ? FQShadows.glow : const [],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
  const FQSecondaryButton({
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
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: FQGradients.subtlePanel,
        borderRadius: FQRadius.pill,
        border: Border.all(
          color: enabled
              ? FQColors.primary.withValues(alpha: 0.16)
              : FQColors.primary.withValues(alpha: 0.08),
          width: 1.2,
        ),
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: enabled
              ? FQColors.primary
              : FQColors.primary.withValues(alpha: 0.48),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: enabled
                    ? FQColors.primary
                    : FQColors.primary.withValues(alpha: 0.48),
              ),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
