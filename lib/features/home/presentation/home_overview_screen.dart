import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_progress_bar.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/state/app_state_providers.dart';

class HomeOverviewScreen extends ConsumerWidget {
  const HomeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(allRoutesProvider);
    final progressAsync = ref.watch(appProgressNotifierProvider);
    final unlockRequirements = ref.watch(routeUnlockRequirementsProvider);
    final routeLoadErrors = ref.watch(routeLoadErrorsProvider);

    if (routesAsync.isLoading || progressAsync.isLoading) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (routesAsync.hasError || progressAsync.hasError) {
      return FQPageContainer(
        child: Center(
          child: Text(
            'No se pudo cargar el contenido de las rutas.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final routes = routesAsync.value;
    final progress = progressAsync.value;
    if (routes == null || routes.isEmpty || progress == null) {
      return FQPageContainer(
        child: Center(
          child: Text(
            routeLoadErrors.isEmpty
                ? 'No se pudo cargar el contenido de rutas.'
                : _buildLoadErrorMessage(routeLoadErrors),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FQPageContainer(
      child: ListView(
        children: [
          _OverviewHeader(progress: progress),
          const SizedBox(height: 14),
          Text(
            'Rutas disponibles',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: FQColors.deepNavy),
          ),
          const SizedBox(height: 10),
          if (routeLoadErrors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RouteLoadWarning(errors: routeLoadErrors),
            ),
          for (final route in routes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RouteCardTile(
                route: route,
                progress: progress,
                isUnlocked: _isUnlocked(route, progress, unlockRequirements),
                lockReason: _lockReason(
                  route,
                  routes,
                  progress,
                  unlockRequirements,
                ),
                onTap: () => context.go('/home/route/${route.routeId}'),
              ),
            ),
        ],
      ),
    );
  }

  bool _isUnlocked(
    DartRouteContent route,
    LearningProgressState progress,
    Map<String, String?> unlockRequirements,
  ) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return true;
    return progress.completedRouteIds.contains(requirement);
  }

  String? _lockReason(
    DartRouteContent route,
    List<DartRouteContent> routes,
    LearningProgressState progress,
    Map<String, String?> unlockRequirements,
  ) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return null;
    if (progress.completedRouteIds.contains(requirement)) return null;
    for (final item in routes) {
      if (item.routeId == requirement) {
        return 'Completa ${item.title} para desbloquear';
      }
    }
    return 'Completa la ruta requerida para desbloquear';
  }

  String _buildLoadErrorMessage(Map<String, String> errors) {
    final lines = <String>['No se pudieron cargar algunas rutas:'];
    errors.forEach((routeId, message) {
      lines.add('- $routeId: $message');
    });
    return lines.join('\n');
  }
}

class _RouteLoadWarning extends StatelessWidget {
  const _RouteLoadWarning({required this.errors});

  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: const Color(0xFFFFF4E0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algunas rutas no cargaron',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF755700),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in errors.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF755700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteCardTile extends StatelessWidget {
  const _RouteCardTile({
    required this.route,
    required this.progress,
    required this.isUnlocked,
    required this.lockReason,
    required this.onTap,
  });

  final DartRouteContent route;
  final LearningProgressState progress;
  final bool isUnlocked;
  final String? lockReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress.routeProgress(route.routeId);
    final cardBody = FQSurfaceCard(
      radius: FQRadius.large,
      gradient: isUnlocked ? FQGradients.subtlePanel : null,
      color: isUnlocked ? null : FQColors.surfaceHigh.withValues(alpha: 0.56),
      border: Border.all(
        color: _routeBorderColor(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: isUnlocked,
        ),
        width: _routeBorderWidth(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: isUnlocked,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: FQRadius.medium,
              gradient: isUnlocked
                  ? FQGradients.heroBlue
                  : const LinearGradient(
                      colors: [Color(0xFFC8D2EB), Color(0xFFB8C5E6)],
                    ),
            ),
            child: Icon(
              iconFromName(route.icon),
              color: isUnlocked ? Colors.white : FQColors.outlineVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isUnlocked
                              ? FQColors.deepNavy
                              : FQColors.onSurface.withValues(alpha: 0.66),
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      const Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: FQColors.outlineVariant,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  route.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                if (lockReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    lockReason!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: FQColors.tertiaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (progressValue > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: FQColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: FQColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FQProgressBar(value: progressValue),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!isUnlocked) return cardBody;
    return InkWell(borderRadius: FQRadius.large, onTap: onTap, child: cardBody);
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.progress});

  final LearningProgressState progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flutter Quest',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 36,
            color: FQColors.primary,
            height: 1.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige una ruta y sigue avanzando',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: FQColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FQStatChip(
              icon: Icons.auto_awesome_rounded,
              label: 'XP',
              value: '${progress.totalXp}',
              accent: FQColors.primary,
            ),
            const SizedBox(width: 8),
            FQStatChip(
              icon: Icons.local_fire_department_rounded,
              label: 'Streak',
              value: '${progress.currentStreak}',
              accent: FQColors.tertiaryDark,
            ),
          ],
        ),
      ],
    );
  }
}

Color _routeBorderColor({
  required LearningProgressState progress,
  required String routeId,
  required bool isUnlocked,
}) {
  if (!isUnlocked) return Colors.transparent;
  if (progress.completedRouteIds.contains(routeId)) {
    return const Color(0xFF34A853);
  }
  if (progress.routeProgress(routeId) > 0) {
    return FQColors.tertiary;
  }
  return Colors.transparent;
}

double _routeBorderWidth({
  required LearningProgressState progress,
  required String routeId,
  required bool isUnlocked,
}) {
  if (!isUnlocked) return 0;
  if (progress.completedRouteIds.contains(routeId)) return 2.2;
  if (progress.routeProgress(routeId) > 0) return 2.2;
  return 0;
}

IconData iconFromName(String value) {
  return switch (value) {
    'rocket_launch' => Icons.rocket_launch_rounded,
    'data_object' => Icons.data_object_rounded,
    'alt_route' => Icons.alt_route_rounded,
    'loop' => Icons.loop_rounded,
    'functions' => Icons.functions_rounded,
    'view_list' => Icons.view_list_rounded,
    'verified_user' => Icons.verified_user_rounded,
    'category' => Icons.category_rounded,
    'bolt' => Icons.bolt_rounded,
    'bug_report' => Icons.bug_report_rounded,
    'military_tech' => Icons.military_tech_rounded,
    'route_dart' => Icons.route_rounded,
    'flutter_dash' => Icons.flutter_dash_rounded,
    'folder_copy' => Icons.folder_copy_rounded,
    'play_circle' => Icons.play_circle_fill_rounded,
    'web_asset' => Icons.web_asset_rounded,
    'view_column' => Icons.view_column_rounded,
    'crop_square' => Icons.crop_square_rounded,
    'smart_button' => Icons.smart_button_rounded,
    'format_list_bulleted' => Icons.format_list_bulleted_rounded,
    'navigation' => Icons.navigation_rounded,
    'dashboard_customize' => Icons.dashboard_customize_rounded,
    'workspace_premium' => Icons.workspace_premium_rounded,
    'flutter' => Icons.flutter_dash_rounded,
    _ => Icons.circle_rounded,
  };
}
