import 'package:flutter/material.dart';

import '../theme/fq_colors.dart';
import '../theme/fq_tokens.dart';

class FQHeader extends StatelessWidget {
  const FQHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.kicker,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null) ...[
                Text(
                  kicker!,
                  style: textTheme.labelMedium?.copyWith(
                    color: FQColors.primary,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 32,
                  color: FQColors.deepNavy,
                  height: 1.03,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: FQColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: FQSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
