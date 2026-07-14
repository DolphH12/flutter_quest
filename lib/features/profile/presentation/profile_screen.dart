import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_header.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_progress_bar.dart';
import '../../../core/widgets/fq_state_views.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/data/badge_catalog.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/models/progress_view_models.dart';
import '../../learning/state/app_state_providers.dart';
import '../../notifications/models/habit_notification_settings.dart';
import '../../notifications/state/habit_notifications_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.onAfterReset});

  final VoidCallback? onAfterReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final routesAsync = ref.watch(allRoutesProvider);
    final progressAsync = ref.watch(appProgressNotifierProvider);
    final summary = ref.watch(profileSummaryProvider);
    final preferredLanguage = ref.watch(preferredLanguageCodeProvider);
    final effectiveLanguage = ref.watch(effectiveLanguageCodeProvider);
    final notifications = ref.watch(habitNotificationsProvider);

    if (routesAsync.isLoading || progressAsync.isLoading || summary == null) {
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
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final activeRoute = _pickPrimaryRoute(routes, progress);

    final badges = progress.unlockedBadgeIds
        .map(BadgeCatalog.byId)
        .whereType<BadgeDefinition>()
        .toList();
    final isDesktop = FQBreakpoints.isDesktop(context);

    return FQPageContainer(
      child: ListView(
        children: [
          if (isDesktop)
            _ProfileTopDesktop(
              summary: summary,
              preferredLanguageCode: preferredLanguage,
              onChanged: (value) => ref
                  .read(appProgressNotifierProvider.notifier)
                  .setPreferredLanguage(value),
            )
          else
            FQHeader(
              kicker: l10n.profileKicker,
              title: l10n.profileTitle,
              subtitle: l10n.profileSubtitle,
              trailing: _LanguageMenuButton(
                preferredLanguageCode: preferredLanguage,
                onChanged: (value) => ref
                    .read(appProgressNotifierProvider.notifier)
                    .setPreferredLanguage(value),
              ),
            ),
          const SizedBox(height: FQSpacing.lg),
          if (!isDesktop) _ProfileHero(summary: summary),
          const SizedBox(height: FQSpacing.lg),
          _StatsGrid(summary: summary),
          const SizedBox(height: FQSpacing.lg),
          if (isDesktop)
            _DesktopProfileSections(
              children: [
                _RouteProgressCard(route: activeRoute, progress: progress),
                _BadgesSection(badges: badges),
                _RecentActivity(progress: progress, routes: routes),
                _NotificationsHabitSection(
                  enabled:
                      notifications.valueOrNull?.enabled ??
                      HabitNotificationSettings.defaults.enabled,
                  hour:
                      notifications.valueOrNull?.hour ??
                      HabitNotificationSettings.defaults.hour,
                  minute:
                      notifications.valueOrNull?.minute ??
                      HabitNotificationSettings.defaults.minute,
                  loading: notifications.isLoading,
                  onChanged: (enabled) async {
                    final result = await ref
                        .read(habitNotificationsProvider.notifier)
                        .setEnabled(
                          enabled: enabled,
                          progress: progress,
                          languageCode: effectiveLanguage,
                        );
                    if (!context.mounted) return;
                    if (result == NotificationToggleResult.permissionDenied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.notificationPermissionDenied),
                        ),
                      );
                    }
                  },
                  onPickTime: () => _pickReminderTime(
                    context,
                    ref,
                    progress,
                    notifications.valueOrNull ??
                        HabitNotificationSettings.defaults,
                  ),
                ),
                _BackupSection(
                  onExport: () => _exportBackup(context, ref),
                  onImport: () => _importBackup(context, ref),
                ),
              ],
            )
          else ...[
            _RouteProgressCard(route: activeRoute, progress: progress),
            const SizedBox(height: FQSpacing.lg),
            _BadgesSection(badges: badges),
            const SizedBox(height: FQSpacing.lg),
            _RecentActivity(progress: progress, routes: routes),
            const SizedBox(height: FQSpacing.lg),
            _NotificationsHabitSection(
              enabled:
                  notifications.valueOrNull?.enabled ??
                  HabitNotificationSettings.defaults.enabled,
              hour:
                  notifications.valueOrNull?.hour ??
                  HabitNotificationSettings.defaults.hour,
              minute:
                  notifications.valueOrNull?.minute ??
                  HabitNotificationSettings.defaults.minute,
              loading: notifications.isLoading,
              onChanged: (enabled) async {
                final result = await ref
                    .read(habitNotificationsProvider.notifier)
                    .setEnabled(
                      enabled: enabled,
                      progress: progress,
                      languageCode: effectiveLanguage,
                    );
                if (!context.mounted) return;
                if (result == NotificationToggleResult.permissionDenied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.notificationPermissionDenied)),
                  );
                }
              },
              onPickTime: () => _pickReminderTime(
                context,
                ref,
                progress,
                notifications.valueOrNull ?? HabitNotificationSettings.defaults,
              ),
            ),
            const SizedBox(height: FQSpacing.lg),
            _BackupSection(
              onExport: () => _exportBackup(context, ref),
              onImport: () => _importBackup(context, ref),
            ),
            const SizedBox(height: FQSpacing.lg),
            _ResetProgressSection(onReset: () => _confirmReset(context, ref)),
          ],
          if (isDesktop) ...[
            const SizedBox(height: FQSpacing.lg),
            _ResetProgressSection(onReset: () => _confirmReset(context, ref)),
          ],
          const SizedBox(height: FQSpacing.xl),
        ],
      ),
    );
  }

  DartRouteContent _pickPrimaryRoute(
    List<DartRouteContent> routes,
    LearningProgressState progress,
  ) {
    if (progress.lastLessonResult != null) {
      final lastRouteId = progress.lastLessonResult!.routeId;
      for (final route in routes) {
        if (route.routeId == lastRouteId) return route;
      }
    }
    for (final route in routes) {
      if (progress.routeProgress(route.routeId) > 0) return route;
    }
    return routes.first;
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.resetDialogTitle),
          content: Text(l10n.resetDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC23737),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteAllButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(appProgressNotifierProvider.notifier).resetAllProgress();
    onAfterReset?.call();
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    LearningProgressState progress,
    HabitNotificationSettings currentSettings,
  ) async {
    final initialDate = DateTime(
      2026,
      1,
      1,
      currentSettings.hour,
      currentSettings.minute,
    );
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ReminderTimeSheet(initialDate: initialDate),
    );
    if (picked == null) return;
    await ref
        .read(habitNotificationsProvider.notifier)
        .setReminderTime(
          hour: picked.hour,
          minute: picked.minute,
          progress: progress,
          languageCode: ref.read(effectiveLanguageCodeProvider),
        );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await ref
          .read(appProgressNotifierProvider.notifier)
          .exportBackup(sharePositionOrigin: shareOrigin);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportSuccess)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExportError(error.toString()))),
      );
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final preview = await ref
        .read(appProgressNotifierProvider.notifier)
        .pickBackupPreview();
    if (preview == null || !context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.backupImportTitle),
          content: Text(
            l10n.backupImportPreview(
              preview.progress.userName ?? l10n.backupUnknownUser,
              preview.progress.totalXp,
              preview.progress.completedRouteIds.length,
              preview.exportedAt,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: FQColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.backupImportButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(appProgressNotifierProvider.notifier)
          .importBackup(preview);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupImportSuccess)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupImportError(error.toString()))),
      );
    }
  }
}

class _ProfileTopDesktop extends StatelessWidget {
  const _ProfileTopDesktop({
    required this.summary,
    required this.preferredLanguageCode,
    required this.onChanged,
  });

  final ProfileSummary summary;
  final String? preferredLanguageCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FQHeader(
            kicker: l10n.profileKicker,
            title: l10n.profileTitle,
            subtitle: l10n.profileSubtitleDesktop,
            trailing: _LanguageMenuButton(
              preferredLanguageCode: preferredLanguageCode,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 440, child: _ProfileHero(summary: summary)),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final level = (summary.totalXp ~/ 120) + 1;
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: FQGradients.heroBlue,
      padding: const EdgeInsets.all(FQSpacing.lg),
      shadow: FQShadows.floating,
      useHighlightOverlay: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FQColors.tertiary,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      'assets/images/perfil_FC.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.userName,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.levelAdventurer(level),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FQStatChip(
                icon: Icons.auto_awesome_rounded,
                label: 'XP',
                value: '${summary.totalXp}',
                accent: Colors.white,
              ),
              FQStatChip(
                icon: Icons.local_fire_department_rounded,
                label: l10n.streakLabel,
                value: '${summary.currentStreak}',
                accent: const Color(0xFFFFDF70),
              ),
              FQStatChip(
                icon: Icons.emoji_events_rounded,
                label: l10n.bestLabel,
                value: '${summary.bestStreak}',
                accent: const Color(0xFFFFDF70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDesktop = FQBreakpoints.isDesktop(context);
    final l10n = AppLocalizations.of(context)!;
    final cards = <Map<String, String>>[
      {
        'label': l10n.completedLessons,
        'value': '${summary.completedLessonsCount}',
      },
      {
        'label': l10n.completedRoutes,
        'value': '${summary.completedRoutesCount}',
      },
      {'label': l10n.unlockedBadges, 'value': '${summary.unlockedBadgesCount}'},
      {'label': l10n.currentNode, 'value': summary.currentNodeTitle},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.55 : 1.25,
      ),
      itemBuilder: (context, index) {
        final item = cards[index];
        return FQSurfaceCard(
          radius: FQRadius.large,
          gradient: index.isEven ? FQGradients.subtlePanel : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['label']!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FQColors.onSurface.withValues(alpha: 0.66),
                ),
              ),
              Text(
                item['value']!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: item['label'] == l10n.currentNode
                      ? (isDesktop ? 17 : 20)
                      : (isDesktop ? 24 : 30),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopProfileSections extends StatelessWidget {
  const _DesktopProfileSections({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _RouteProgressCard extends StatelessWidget {
  const _RouteProgressCard({required this.route, required this.progress});

  final DartRouteContent route;
  final LearningProgressState progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routeProgress = progress.routeProgress(route.routeId);
    final examPassed = progress.completedNodeIds.contains(route.examNodeId);
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.subtlePanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  route.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(routeProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: FQColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FQProgressBar(
            value: routeProgress,
            fillGradient: const LinearGradient(
              colors: [Color(0xFF39C97D), Color(0xFF0F6E38)],
            ),
            trackColor: const Color(0xFFB8E8C8),
          ),
          const SizedBox(height: 10),
          FQPill(
            label: examPassed
                ? l10n.finalExamPassed
                : (progress.unlockedExamIds.contains(route.examNodeId)
                      ? l10n.finalExamUnlocked
                      : l10n.finalExamLocked),
            icon: Icons.military_tech_rounded,
            color: examPassed
                ? const Color(0xFFDFF7E8)
                : FQColors.surfaceHigh.withValues(alpha: 0.6),
            textColor: examPassed
                ? const Color(0xFF1D8D4A)
                : FQColors.onSurface,
          ),
        ],
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  final List<BadgeDefinition> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.subtlePanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.badgesTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (badges.isEmpty)
            Text(
              l10n.badgesEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FQColors.onSurface.withValues(alpha: 0.66),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map(
                    (badge) => FQPill(
                      label: badge.title,
                      icon: badge.icon,
                      color: FQColors.primary.withValues(alpha: 0.14),
                      textColor: FQColors.primary,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.progress, required this.routes});

  final LearningProgressState progress;
  final List<DartRouteContent> routes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = progress.lastLessonResult;
    String? nodeTitle;
    if (result != null) {
      for (final route in routes) {
        if (route.routeId != result.routeId) continue;
        for (final node in route.nodes) {
          if (node.id == result.nodeId) {
            nodeTitle = node.title;
            break;
          }
        }
      }
    }
    return FQSurfaceCard(
      radius: FQRadius.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivityTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (result == null)
            Text(
              l10n.noRecentActivity,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: FQGradients.subtlePanel,
                borderRadius: FQRadius.medium,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: FQRadius.small,
                        color: result.passed
                            ? const Color(0xFFDFF7E8)
                            : const Color(0xFFFFE5E5),
                      ),
                      child: Icon(
                        result.passed
                            ? Icons.check_circle_rounded
                            : Icons.refresh_rounded,
                        size: 18,
                        color: result.passed
                            ? const Color(0xFF1D8D4A)
                            : const Color(0xFFC23737),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${nodeTitle ?? l10n.lessonFallbackTitle} · ${result.passed ? l10n.passedStatus : l10n.retryStatus} · +${result.xpEarned} XP',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResetProgressSection extends StatelessWidget {
  const _ResetProgressSection({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: FQColors.surfaceHigh.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.devToolsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.devToolsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FQPrimaryButton(
              label: l10n.resetProgressButton,
              icon: Icons.restart_alt_rounded,
              onPressed: onReset,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsHabitSection extends StatelessWidget {
  const _NotificationsHabitSection({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.loading,
    required this.onChanged,
    required this.onPickTime,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final bool loading;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedTime = _formatReminderTime(context, hour, minute);
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final titleText = localeCode == 'es'
        ? 'Hora del recordatorio'
        : 'Reminder time';
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.subtlePanel,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.habitReminderTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.habitReminderSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: FQRadius.large,
                  onTap: (!enabled || loading) ? null : onPickTime,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: (!enabled || loading) ? 0.55 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8FAFF), Color(0xFFEAF0FF)],
                        ),
                        borderRadius: FQRadius.large,
                        border: Border.all(
                          color: FQColors.primary.withValues(alpha: 0.14),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: FQColors.primary.withValues(alpha: 0.12),
                              borderRadius: FQRadius.medium,
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              color: FQColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                titleText,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: FQColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedTime,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: FQColors.deepNavy,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FQColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: enabled,
            onChanged: loading ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection({required this.onExport, required this.onImport});

  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.subtlePanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.backupSectionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.backupSectionSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FQSecondaryButton(
                  label: l10n.backupExportButton,
                  icon: Icons.download_rounded,
                  onPressed: onExport,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FQPrimaryButton(
                  label: l10n.backupImportButton,
                  icon: Icons.upload_file_rounded,
                  onPressed: onImport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatReminderTime(BuildContext context, int hour, int minute) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final date = DateTime(2026, 1, 1, hour, minute);
  return DateFormat('h:mm a', locale).format(date).toUpperCase();
}

class _ReminderTimeSheet extends StatefulWidget {
  const _ReminderTimeSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_ReminderTimeSheet> createState() => _ReminderTimeSheetState();
}

class _ReminderTimeSheetState extends State<_ReminderTimeSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final titleText = localeCode == 'es'
        ? 'Elige la hora del recordatorio'
        : 'Choose your reminder time';
    final subtitleText = localeCode == 'es'
        ? 'Usaremos este horario para enviarte el recordatorio diario.'
        : 'We will use this time for your daily reminder.';
    final cancelText = localeCode == 'es' ? 'Cancelar' : 'Cancel';
    final saveText = localeCode == 'es' ? 'Guardar' : 'Save';
    final previewText = _formatReminderTime(
      context,
      _selected.hour,
      _selected.minute,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: FQRadius.xLarge,
            boxShadow: FQShadows.floating,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: FQColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: FQRadius.pill,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: FQColors.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFEAF0FF)],
                    ),
                    borderRadius: FQRadius.large,
                    border: Border.all(
                      color: FQColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    previewText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: FQColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.light,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      initialDateTime: _selected,
                      minuteInterval: 5,
                      onDateTimeChanged: (value) {
                        setState(() {
                          _selected = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FQSecondaryButton(
                        label: cancelText,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FQPrimaryButton(
                        label: saveText,
                        onPressed: () => Navigator.of(context).pop(_selected),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageMenuButton extends StatelessWidget {
  const _LanguageMenuButton({
    required this.preferredLanguageCode,
    required this.onChanged,
  });

  final String? preferredLanguageCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String?>(
      tooltip: l10n.languageMenuTooltip,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: FQRadius.medium),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: _LanguageMenuItem(
            label: l10n.languageAuto,
            selected: preferredLanguageCode == null,
          ),
        ),
        PopupMenuItem<String?>(
          value: 'es',
          child: _LanguageMenuItem(
            label: l10n.languageSpanish,
            selected: preferredLanguageCode == 'es',
          ),
        ),
        PopupMenuItem<String?>(
          value: 'en',
          child: _LanguageMenuItem(
            label: l10n.languageEnglish,
            selected: preferredLanguageCode == 'en',
          ),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FQColors.primary.withValues(alpha: 0.12),
        ),
        child: Icon(
          Icons.language_rounded,
          color: FQColors.primary,
          semanticLabel: l10n.profileTitle,
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        if (selected)
          const Icon(Icons.check_rounded, size: 18, color: FQColors.primary),
      ],
    );
  }
}
