import 'package:flutter/material.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/data/badge_catalog.dart';
import '../../lesson_flow/presentation/lesson_flow_screen.dart';

class RouteCompletionScreen extends StatelessWidget {
  const RouteCompletionScreen({
    super.key,
    required this.data,
    required this.onGoHome,
    required this.onContinueLearning,
  });

  final RouteCompletionResultData data;
  final VoidCallback onGoHome;
  final VoidCallback onContinueLearning;

  @override
  Widget build(BuildContext context) {
    final badge = data.primaryBadge;
    final score = data.totalAnswers == 0
        ? 0
        : ((data.correctCount / data.totalAnswers) * 100).round();

    return FQPageContainer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                FQSurfaceCard(
                  radius: FQRadius.xLarge,
                  gradient: FQGradients.heroBlue,
                  useHighlightOverlay: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ruta completada',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.routeTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cerraste la ruta con criterio. Ya no solo sigues snippets: ya tomas decisiones con base.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FQSurfaceCard(
                  radius: FQRadius.large,
                  gradient: FQGradients.subtlePanel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen final',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: FQColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _SummaryChip(
                            icon: Icons.bolt_rounded,
                            label: '+${data.xpEarned} XP',
                          ),
                          _SummaryChip(
                            icon: Icons.check_circle_rounded,
                            label: '$score% aciertos',
                          ),
                          _SummaryChip(
                            icon: Icons.quiz_rounded,
                            label: '${data.correctCount}/${data.totalAnswers} correctas',
                          ),
                        ],
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 14),
                        _BadgeCelebrationCard(badge: badge),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FQPrimaryButton(
              label: 'Volver al Home',
              icon: Icons.home_rounded,
              onPressed: onGoHome,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FQSecondaryButton(
              label: 'Seguir aprendiendo',
              onPressed: onContinueLearning,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: FQRadius.medium,
        color: FQColors.surfaceHigh.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: FQColors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCelebrationCard extends StatelessWidget {
  const _BadgeCelebrationCard({required this.badge});

  final BadgeDefinition badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: FQRadius.large,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8DE), Color(0xFFFFF1C5)],
        ),
        border: Border.all(color: const Color(0xFFE5C45C), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD66E),
            ),
            child: Icon(badge.icon, color: const Color(0xFF755700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insignia desbloqueada',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF755700),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FQColors.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
