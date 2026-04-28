import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_progress_bar.dart';
import '../../../core/widgets/fq_state_views.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/data/route_asset_source.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/state/app_state_providers.dart';

class HomeOverviewScreen extends ConsumerWidget {
  const HomeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final routesAsync = ref.watch(allRoutesProvider);
    final progressAsync = ref.watch(appProgressNotifierProvider);
    final unlockRequirements = ref.watch(routeUnlockRequirementsProvider);
    final routeLoadErrors = ref.watch(routeLoadErrorsProvider);
    final manifests = ref.watch(routeManifestsProvider);

    if (routesAsync.isLoading || progressAsync.isLoading) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (routesAsync.hasError || progressAsync.hasError) {
      return FQPageContainer(
        child: Center(
          child: FQErrorState(
            title: l10n.loadRoutesError,
            message: '${routesAsync.error ?? ''} ${progressAsync.error ?? ''}'
                .trim(),
            primaryActionLabel: l10n.continueButton,
            onPrimaryAction: () =>
                ref.read(appProgressNotifierProvider.notifier).loadProgress(),
          ),
        ),
      );
    }

    final routes = routesAsync.value;
    final progress = progressAsync.value;
    if (routes == null || routes.isEmpty || progress == null) {
      return FQPageContainer(
        child: Center(
          child: FQEmptyState(
            title: l10n.routesAvailable,
            message: routeLoadErrors.isEmpty
                ? l10n.loadRoutesError
                : _buildLoadErrorMessage(routeLoadErrors, l10n: l10n),
            icon: Icons.route_rounded,
            actionLabel: l10n.continueButton,
            onAction: () =>
                ref.read(appProgressNotifierProvider.notifier).loadProgress(),
          ),
        ),
      );
    }

    final isDesktop = FQBreakpoints.isDesktop(context);
    final allRoutesCompleted = _allRoutesCompleted(routes, progress);
    return FQPageContainer(
      child: ListView(
        children: [
          _OverviewHeader(progress: progress),
          const SizedBox(height: 14),
          Text(
            l10n.routesAvailable,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: FQColors.deepNavy),
          ),
          const SizedBox(height: 10),
          if (allRoutesCompleted) ...[
            _MoreRoutesSoonBanner(isDesktop: isDesktop),
            const SizedBox(height: 12),
          ],
          if (isDesktop)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 1200 ? 3 : 2;
                final routeById = {
                  for (final route in routes) route.routeId: route,
                };
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: manifests.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 188,
                  ),
                  itemBuilder: (context, index) {
                    final manifest = manifests[index];
                    final route = routeById[manifest.routeId];
                    final loadError = routeLoadErrors[manifest.routeId];
                    if (route != null) {
                      return _RouteCardTile(
                        route: route,
                        progress: progress,
                        isUnlocked: _isUnlocked(
                          route.routeId,
                          progress,
                          unlockRequirements,
                        ),
                        lockReason: _lockReason(
                          route,
                          routes,
                          progress,
                          unlockRequirements,
                          l10n,
                        ),
                        onTap: () => context.go('/home/route/${route.routeId}'),
                      );
                    }
                    if (loadError != null) {
                      return _RouteErrorCardTile(
                        routeId: manifest.routeId,
                        errorMessage: loadError,
                        isPending: progress.pendingRouteIds.contains(
                          manifest.routeId,
                        ),
                        onRetry: () => ref.invalidate(allRoutesProvider),
                        onMarkPending: () async {
                          await ref
                              .read(appProgressNotifierProvider.notifier)
                              .markRoutePending(manifest.routeId);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pendingRouteNotice)),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            )
          else
            ..._buildMobileRouteCards(
              context: context,
              ref: ref,
              manifests: manifests,
              routes: routes,
              progress: progress,
              unlockRequirements: unlockRequirements,
              routeLoadErrors: routeLoadErrors,
              l10n: l10n,
            ),
        ],
      ),
    );
  }

  bool _allRoutesCompleted(
    List<DartRouteContent> routes,
    LearningProgressState progress,
  ) {
    if (routes.isEmpty) return false;
    for (final route in routes) {
      if (!progress.completedRouteIds.contains(route.routeId)) return false;
    }
    return true;
  }

  bool _isUnlocked(
    String routeId,
    LearningProgressState progress,
    Map<String, String?> unlockRequirements,
  ) {
    final requirement = unlockRequirements[routeId];
    if (requirement == null) return true;
    return progress.completedRouteIds.contains(requirement) ||
        progress.pendingRouteIds.contains(requirement);
  }

  String? _lockReason(
    DartRouteContent route,
    List<DartRouteContent> routes,
    LearningProgressState progress,
    Map<String, String?> unlockRequirements,
    AppLocalizations l10n,
  ) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return null;
    if (progress.completedRouteIds.contains(requirement)) return null;
    for (final item in routes) {
      if (item.routeId == requirement) {
        return l10n.completeRouteToUnlock(item.title);
      }
    }
    return l10n.completeRequiredRouteToUnlock;
  }

  String _buildLoadErrorMessage(
    Map<String, String> errors, {
    required AppLocalizations l10n,
  }) {
    final lines = <String>[l10n.loadPartialRoutesErrorWithColon];
    errors.forEach((routeId, message) {
      lines.add('- $routeId: $message');
    });
    return lines.join('\n');
  }

  List<Widget> _buildMobileRouteCards({
    required BuildContext context,
    required WidgetRef ref,
    required List<RouteAssetManifest> manifests,
    required List<DartRouteContent> routes,
    required LearningProgressState progress,
    required Map<String, String?> unlockRequirements,
    required Map<String, String> routeLoadErrors,
    required AppLocalizations l10n,
  }) {
    final routeById = {for (final route in routes) route.routeId: route};
    final children = <Widget>[];
    for (final manifest in manifests) {
      final route = routeById[manifest.routeId];
      final loadError = routeLoadErrors[manifest.routeId];
      if (route != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RouteCardTile(
              route: route,
              progress: progress,
              isUnlocked: _isUnlocked(
                route.routeId,
                progress,
                unlockRequirements,
              ),
              lockReason: _lockReason(
                route,
                routes,
                progress,
                unlockRequirements,
                l10n,
              ),
              onTap: () => context.go('/home/route/${route.routeId}'),
            ),
          ),
        );
      } else if (loadError != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RouteErrorCardTile(
              routeId: manifest.routeId,
              errorMessage: loadError,
              isPending: progress.pendingRouteIds.contains(manifest.routeId),
              onRetry: () => ref.invalidate(allRoutesProvider),
              onMarkPending: () async {
                await ref
                    .read(appProgressNotifierProvider.notifier)
                    .markRoutePending(manifest.routeId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.pendingRouteNotice)));
              },
            ),
          ),
        );
      }
    }
    return children;
  }
}

class _MoreRoutesSoonBanner extends StatelessWidget {
  const _MoreRoutesSoonBanner({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode
        .toLowerCase()
        .startsWith('es');
    final title = isSpanish ? '¡Más rutas muy pronto!' : 'More routes are coming soon!';
    final body = isSpanish
        ? 'Completaste todo por ahora. Estamos preparando nuevas rutas para que sigas subiendo de nivel.'
        : 'You completed everything for now. New learning routes are being crafted so you can keep leveling up.';

    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F8EE), Color(0xFFD9F3E4)],
      ),
      border: Border.all(color: const Color(0xFF7ED3A8), width: 1.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isDesktop ? 52 : 46,
            height: isDesktop ? 52 : 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1D8D4A).withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Color(0xFF1D8D4A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF14503B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1D8D4A),
                    height: 1.35,
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
    final isDesktop = FQBreakpoints.isDesktop(context);
    final progressValue = progress.routeProgress(route.routeId);
    final isPending = progress.pendingRouteIds.contains(route.routeId);
    final isCompleted =
        progress.completedRouteIds.contains(route.routeId) || progressValue >= 1;
    final l10n = AppLocalizations.of(context)!;
    final cardBody = FQSurfaceCard(
      radius: FQRadius.large,
      gradient: isUnlocked ? FQGradients.subtlePanel : null,
      color: isUnlocked ? null : FQColors.surfaceHigh.withValues(alpha: 0.56),
      padding: isCompleted
          ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
          : const EdgeInsets.all(FQSpacing.md),
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
            width: isCompleted ? (isDesktop ? 40 : 44) : (isDesktop ? 44 : 50),
            height: isCompleted
                ? (isDesktop ? 40 : 44)
                : (isDesktop ? 44 : 50),
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
                          fontSize: isDesktop
                              ? (isCompleted ? 20 : 22)
                              : (isCompleted ? 21 : null),
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
                      )
                    else if (isPending)
                      FQPill(
                        label: l10n.routePendingBadge,
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFFFF4D6),
                        textColor: FQColors.tertiaryDark,
                      ),
                  ],
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 2),
                  Text(
                    route.description,
                    maxLines: isDesktop ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FQColors.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      FQPill(
                        label: l10n.routeCompleted,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFFDFF7E8),
                        textColor: const Color(0xFF1D8D4A),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: FQColors.tertiaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '100%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: FQColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
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
                if (!isCompleted && progressValue > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        l10n.progressLabel,
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
                  FQProgressBar(
                    value: progressValue,
                    fillGradient: const LinearGradient(
                      colors: [Color(0xFF46D194), Color(0xFF1D8D4A)],
                    ),
                    trackColor: const Color(0xFFDFF7E8),
                  ),
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

class _RouteErrorCardTile extends StatelessWidget {
  const _RouteErrorCardTile({
    required this.routeId,
    required this.errorMessage,
    required this.isPending,
    required this.onRetry,
    required this.onMarkPending,
  });

  final String routeId;
  final String errorMessage;
  final bool isPending;
  final VoidCallback onRetry;
  final VoidCallback onMarkPending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = FQBreakpoints.isDesktop(context);
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: isPending ? const Color(0xFFFFF7E6) : const Color(0xFFFFF0EE),
      border: Border.all(
        color: isPending ? const Color(0xFFFFD68A) : const Color(0xFFFFC9C2),
        width: 1.3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _humanizeRouteId(routeId),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF8F2B1D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FQPill(
                label: isPending
                    ? l10n.routePendingBadge
                    : l10n.routeContentErrorBadge,
                icon: isPending
                    ? Icons.schedule_rounded
                    : Icons.error_rounded,
                color: isPending
                    ? const Color(0xFFFFF0C7)
                    : const Color(0xFFFFD9D4),
                textColor: isPending
                    ? FQColors.tertiaryDark
                    : const Color(0xFF8F2B1D),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.routeContentErrorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isPending
                  ? FQColors.tertiaryDark
                  : const Color(0xFF8F2B1D),
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(height: 6),
            Text(
              errorMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: (isPending
                        ? FQColors.tertiaryDark
                        : const Color(0xFF8F2B1D))
                    .withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FQSecondaryButton(
                  label: l10n.retryButton,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: isPending
                    ? FQSecondaryButton(
                        label: l10n.routePendingBadge,
                        icon: Icons.check_rounded,
                        onPressed: () {},
                      )
                    : FQPrimaryButton(
                        label: l10n.markPendingButton,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: onMarkPending,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _humanizeRouteId(String value) {
  final clean = value.replaceAll('_route', '').replaceAll('_', ' ').trim();
  if (clean.isEmpty) return value;
  return clean
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.progress});

  final LearningProgressState progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = FQBreakpoints.isDesktop(context);
    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FQStatChip(
          icon: Icons.auto_awesome_rounded,
          label: 'XP',
          value: '${progress.totalXp}',
          accent: FQColors.primary,
        ),
        FQStatChip(
          icon: Icons.local_fire_department_rounded,
          label: l10n.streakLabel,
          value: '${progress.currentStreak}',
          accent: FQColors.tertiaryDark,
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/LOGO_FC.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flutter Quest',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 44,
                        color: FQColors.primary,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.homeSubtitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 19,
                        color: FQColors.onSurface.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              chips,
            ],
          )
        else ...[
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
            l10n.homeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          chips,
        ],
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
