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
    final routeLoadErrors = ref.watch(routeLoadErrorsProvider);
    final manifests = ref.watch(routeManifestsProvider);
    final visibleLiveRouteIds = ref.watch(visibleLiveRouteIdsProvider);
    final previewManifest = ref.watch(upcomingPreviewManifestProvider);

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
    final routeById = {for (final route in routes) route.routeId: route};
    final visibleLiveManifests = manifests
        .where((manifest) => visibleLiveRouteIds.contains(manifest.routeId))
        .toList(growable: false);

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
          _MonthlyReleaseBanner(isDesktop: isDesktop),
          const SizedBox(height: 12),
          if (isDesktop)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 1200 ? 3 : 2;
                final desktopTiles = _buildDesktopTiles(
                  context: context,
                  ref: ref,
                  visibleLiveManifests: visibleLiveManifests,
                  visibleLiveRouteIds: visibleLiveRouteIds,
                  routeById: routeById,
                  progress: progress,
                  routeLoadErrors: routeLoadErrors,
                  previewManifest: previewManifest,
                  l10n: l10n,
                );
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: desktopTiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 188,
                  ),
                  itemBuilder: (context, index) => desktopTiles[index],
                );
              },
            )
          else
            ..._buildMobileRouteCards(
              context: context,
              ref: ref,
              visibleLiveManifests: visibleLiveManifests,
              visibleLiveRouteIds: visibleLiveRouteIds,
              routeById: routeById,
              progress: progress,
              routeLoadErrors: routeLoadErrors,
              previewManifest: previewManifest,
              l10n: l10n,
            ),
        ],
      ),
    );
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
    required List<RouteAssetManifest> visibleLiveManifests,
    required List<String> visibleLiveRouteIds,
    required Map<String, DartRouteContent> routeById,
    required LearningProgressState progress,
    required Map<String, String> routeLoadErrors,
    required RouteAssetManifest? previewManifest,
    required AppLocalizations l10n,
  }) {
    final children = <Widget>[];
    for (final manifest in visibleLiveManifests) {
      final route = routeById[manifest.routeId];
      final loadError = routeLoadErrors[manifest.routeId];
      if (route != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RouteCardTile(
              route: route,
              progress: progress,
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
    final previewTile = _buildPreviewTile(
      context: context,
      manifest: previewManifest,
      route: previewManifest == null ? null : routeById[previewManifest.routeId],
      lastVisibleRouteId: visibleLiveRouteIds.isEmpty ? null : visibleLiveRouteIds.last,
      progress: progress,
      l10n: l10n,
    );
    if (previewTile != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: previewTile,
        ),
      );
    }
    return children;
  }

  List<Widget> _buildDesktopTiles({
    required BuildContext context,
    required WidgetRef ref,
    required List<RouteAssetManifest> visibleLiveManifests,
    required List<String> visibleLiveRouteIds,
    required Map<String, DartRouteContent> routeById,
    required LearningProgressState progress,
    required Map<String, String> routeLoadErrors,
    required RouteAssetManifest? previewManifest,
    required AppLocalizations l10n,
  }) {
    final children = <Widget>[];
    for (final manifest in visibleLiveManifests) {
      final route = routeById[manifest.routeId];
      final loadError = routeLoadErrors[manifest.routeId];
      if (route != null) {
        children.add(
          _RouteCardTile(
            route: route,
            progress: progress,
            onTap: () => context.go('/home/route/${route.routeId}'),
          ),
        );
      } else if (loadError != null) {
        children.add(
          _RouteErrorCardTile(
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
        );
      }
    }
    final previewTile = _buildPreviewTile(
      context: context,
      manifest: previewManifest,
      route: previewManifest == null ? null : routeById[previewManifest.routeId],
      lastVisibleRouteId: visibleLiveRouteIds.isEmpty ? null : visibleLiveRouteIds.last,
      progress: progress,
      l10n: l10n,
    );
    if (previewTile != null) {
      children.add(previewTile);
    }
    return children;
  }

  Widget? _buildPreviewTile({
    required BuildContext context,
    required RouteAssetManifest? manifest,
    required DartRouteContent? route,
    required String? lastVisibleRouteId,
    required LearningProgressState progress,
    required AppLocalizations l10n,
  }) {
    if (manifest == null) return null;
    return _UpcomingRouteCardTile(
      route: route,
      fallbackTitle: _humanizeRouteId(manifest.routeId),
      isReadyForRelease:
          lastVisibleRouteId != null &&
          progress.completedRouteIds.contains(lastVisibleRouteId),
      l10n: l10n,
    );
  }
}

class _MonthlyReleaseBanner extends StatelessWidget {
  const _MonthlyReleaseBanner({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.monthlyRouteBannerTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF14503B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.monthlyRouteBannerBody,
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
    required this.onTap,
  });

  final DartRouteContent route;
  final LearningProgressState progress;
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
      gradient: FQGradients.subtlePanel,
      padding: isCompleted
          ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
          : const EdgeInsets.all(FQSpacing.md),
      border: Border.all(
        color: _routeBorderColor(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: true,
        ),
        width: _routeBorderWidth(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: true,
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
              gradient: FQGradients.heroBlue,
            ),
            child: Icon(
              iconFromName(route.icon),
              color: Colors.white,
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
                          color: FQColors.deepNavy,
                        ),
                      ),
                    ),
                    if (isPending)
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

    return InkWell(borderRadius: FQRadius.large, onTap: onTap, child: cardBody);
  }
}

class _UpcomingRouteCardTile extends StatelessWidget {
  const _UpcomingRouteCardTile({
    required this.route,
    required this.fallbackTitle,
    required this.isReadyForRelease,
    required this.l10n,
  });

  final DartRouteContent? route;
  final String fallbackTitle;
  final bool isReadyForRelease;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: FQColors.surfaceHigh.withValues(alpha: 0.72),
      border: Border.all(
        color: FQColors.primary.withValues(alpha: 0.18),
        width: 1.1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: FQRadius.medium,
              gradient: const LinearGradient(
                colors: [Color(0xFFD7E0F8), Color(0xFFC7D3F2)],
              ),
            ),
            child: Icon(
              iconFromName(route?.icon ?? 'rocket_launch'),
              color: FQColors.primary.withValues(alpha: 0.42),
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
                        route?.title ?? fallbackTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: FQColors.deepNavy.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    FQPill(
                      label: l10n.upcomingRouteBadge,
                      icon: Icons.schedule_rounded,
                      color: const Color(0xFFE4EDFF),
                      textColor: FQColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isReadyForRelease
                      ? l10n.upcomingRouteReadyBody
                      : l10n.upcomingRouteLockedBody,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: FQColors.primary,
                    fontWeight: FontWeight.w700,
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
