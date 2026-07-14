import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_header.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_state_views.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../lesson_flow/widgets/quest_code_editor.dart';
import '../models/daily_challenge_models.dart';
import 'daily_challenge_copy.dart';
import '../state/daily_challenge_providers.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overviewAsync = ref.watch(dailyChallengeOverviewProvider);
    final historyAsync = ref.watch(dailyChallengeHistoryProvider);

    return FQPageContainer(
      child: ListView(
        children: [
          FQHeader(
            kicker: l10n.dailyChallengeKicker,
            title: l10n.dailyChallengeTitle,
            subtitle: l10n.dailyChallengeSubtitle,
          ),
          const SizedBox(height: FQSpacing.lg),
          overviewAsync.when(
            loading: () => const _DailyChallengeLoadingState(),
            error: (error, _) => _DailyChallengeErrorState(
              title: l10n.dailyChallengeLoadErrorTitle,
              message: l10n.dailyChallengeLoadErrorBody,
              actionLabel: l10n.retryButton,
              onRetry: () => _reloadChallenge(ref),
            ),
            data: (overview) => _ChallengeOverviewBody(overview: overview),
          ),
          const SizedBox(height: FQSpacing.xl),
          historyAsync.when(
            loading: () => const _RecentChallengesLoadingState(),
            error: (_, _) => const SizedBox.shrink(),
            data: (history) => _RecentChallengesSection(history: history),
          ),
        ],
      ),
    );
  }
}

class _ChallengeOverviewBody extends ConsumerWidget {
  const _ChallengeOverviewBody({required this.overview});

  final DailyChallengeOverviewState overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return switch (overview.status) {
      DailyChallengeOverviewStatus.ready => _ChallengeReadyCard(
        challenge: overview.challenge!,
      ),
      DailyChallengeOverviewStatus.completed => _ChallengeCompletedCard(
        challenge: overview.challenge!,
        answeredCorrectly: overview.answeredCorrectly ?? false,
        xpEarned: overview.xpEarned ?? 0,
        completedAt: overview.completedAt,
      ),
      DailyChallengeOverviewStatus.offline => _DailyChallengeOfflineState(
        title: l10n.dailyChallengeInternetTitle,
        message: l10n.dailyChallengeInternetBody,
        actionLabel: l10n.retryButton,
        onRetry: () => _reloadChallenge(ref),
      ),
      DailyChallengeOverviewStatus.empty || DailyChallengeOverviewStatus.unavailable
          => FQEmptyState(
            title: l10n.dailyChallengeSoonTitle,
            message: l10n.dailyChallengeSoonBody,
            icon: Icons.schedule_rounded,
          ),
      DailyChallengeOverviewStatus.error => FQErrorState(
        title: l10n.dailyChallengeLoadErrorTitle,
        message: l10n.dailyChallengeLoadErrorBody,
        primaryActionLabel: l10n.retryButton,
        onPrimaryAction: () => _reloadChallenge(ref),
      ),
    };
  }
}

void _reloadChallenge(WidgetRef ref) {
  ref.invalidate(dailyChallengeOverviewProvider);
  ref.invalidate(dailyChallengeHistoryProvider);
  ref.read(dailyChallengeOverviewProvider.future);
}

class _RecentChallengesLoadingState extends StatelessWidget {
  const _RecentChallengesLoadingState();

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DailyChallengeCopy.recentChallengesTitle(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DailyChallengeCopy.recentChallengesSubtitle(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.74),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentChallengesSection extends StatelessWidget {
  const _RecentChallengesSection({required this.history});

  final DailyChallengeHistoryState history;

  @override
  Widget build(BuildContext context) {
    final title = DailyChallengeCopy.recentChallengesTitle(context);
    final subtitle = DailyChallengeCopy.recentChallengesSubtitle(context);

    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DailyChallengeCopy.recentChallengeSectionKicker(context),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: FQColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.74),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          if (history.status == DailyChallengeHistoryFetchStatus.offline)
            _RecentChallengesInfoBanner(
              icon: Icons.wifi_off_rounded,
              message: DailyChallengeCopy.recentChallengesOffline(context),
            )
          else if (history.items.isEmpty)
            _RecentChallengesInfoBanner(
              icon: Icons.schedule_rounded,
              message: DailyChallengeCopy.recentChallengesEmpty(context),
            )
          else
            Column(
              children: [
                for (int index = 0; index < history.items.length; index++) ...[
                  _RecentChallengeTile(item: history.items[index]),
                  if (index != history.items.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentChallengesInfoBanner extends StatelessWidget {
  const _RecentChallengesInfoBanner({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: FQColors.surfaceHigh,
      child: Row(
        children: [
          Icon(icon, color: FQColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FQColors.onSurface.withValues(alpha: 0.78),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentChallengeTile extends StatelessWidget {
  const _RecentChallengeTile({required this.item});

  final DailyChallengeHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final badgeDate = DateFormat('dd MMM', locale)
        .format(item.challenge.publishDate)
        .toUpperCase();
    final completedSuccessfully = item.isCompleted && (item.answeredCorrectly ?? false);
    final completedFailed = item.isCompleted && !(item.answeredCorrectly ?? false);

    return FQSurfaceCard(
      radius: FQRadius.large,
      color: Colors.white.withValues(alpha: 0.82),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecentChallengeDateBadge(dateLabel: badgeDate),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.challenge.topic,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FQColors.deepNavy,
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FQPill(
                      label: completedSuccessfully
                          ? DailyChallengeCopy.completedBadge(context)
                          : completedFailed
                          ? DailyChallengeCopy.failedBadge(context)
                          : DailyChallengeCopy.noXpLabel(context),
                      icon: completedSuccessfully
                          ? Icons.check_circle_rounded
                          : completedFailed
                          ? Icons.cancel_rounded
                          : Icons.auto_awesome_outlined,
                      color: completedSuccessfully
                          ? const Color(0xFFDFF7E8)
                          : completedFailed
                          ? const Color(0xFFFFE4E1)
                          : const Color(0xFFFFF2CF),
                      textColor: completedSuccessfully
                          ? const Color(0xFF1D8D4A)
                          : completedFailed
                          ? const Color(0xFFC23737)
                          : const Color(0xFF8D6800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.challenge.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.76),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: item.canOpen
                      ? FQSecondaryButton(
                          label: DailyChallengeCopy.solveWithoutXp(context),
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.go(
                            '/challenges/play?date=${item.challenge.publishDateKey}',
                            extra: item.challenge,
                          ),
                        )
                      : FQSecondaryButton(
                          label: DailyChallengeCopy.alreadyDone(context),
                          icon: Icons.check_rounded,
                          onPressed: null,
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

class _RecentChallengeDateBadge extends StatelessWidget {
  const _RecentChallengeDateBadge({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: FQGradients.primaryCta,
        borderRadius: FQRadius.large,
        boxShadow: FQShadows.soft,
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.white.withValues(alpha: 0.96),
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeLoadingState extends StatelessWidget {
  const _DailyChallengeLoadingState();

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final title = localeCode == 'es'
        ? 'Buscando el reto de hoy'
        : 'Fetching today\'s challenge';
    final body = localeCode == 'es'
        ? 'Estamos revisando si ya salió la pregunta diaria o si toca esperar un poco más.'
        : 'We are checking whether the daily question is already live or if it still needs a little more time.';
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: FQGradients.subtlePanel,
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: FQRadius.xLarge,
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset('assets/images/perfil_FC.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeOfflineState extends StatelessWidget {
  const _DailyChallengeOfflineState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      color: const Color(0xFFFFF8EF),
      border: Border.all(color: const Color(0xFFFFD68A), width: 1.2),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0C7),
              borderRadius: FQRadius.xLarge,
            ),
            padding: const EdgeInsets.all(14),
            child: Image.asset('assets/images/perfil_FC.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FQSecondaryButton(
              label: actionLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeErrorState extends StatelessWidget {
  const _DailyChallengeErrorState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      color: const Color(0xFFFFF0EE),
      border: Border.all(color: const Color(0xFFFFC9C2), width: 1.2),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC23737), size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF8F2B1D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF8F2B1D),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FQPrimaryButton(
              label: actionLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeReadyCard extends StatelessWidget {
  const _ChallengeReadyCard({required this.challenge});

  final DailyChallengeQuestion challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formattedDate = DateFormat.MMMMd(locale).format(challenge.publishDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FQSurfaceCard(
          radius: FQRadius.xLarge,
          gradient: FQGradients.heroBlue,
          useHighlightOverlay: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FQPill(
                    label: l10n.dailyChallengeReadyBadge,
                    icon: Icons.bolt_rounded,
                    color: Colors.white.withValues(alpha: 0.18),
                    textColor: Colors.white,
                  ),
                  FQPill(
                    label: formattedDate,
                    icon: Icons.calendar_today_rounded,
                    color: Colors.white.withValues(alpha: 0.14),
                    textColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                challenge.topic,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                challenge.question,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.42,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FQStatChip(
                      icon: Icons.workspace_premium_rounded,
                      label: l10n.dailyChallengeLevelLabel,
                      value: '${challenge.level}',
                      accent: const Color(0xFFFDC003),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FQStatChip(
                      icon: Icons.timer_outlined,
                      label: l10n.dailyChallengeTimerLabel,
                      value: l10n.dailyChallengeThirtySeconds,
                      accent: const Color(0xFF8DD7FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (challenge.hasCodeSnippet) ...[
          const SizedBox(height: 14),
          QuestCodePreview(
            content: challenge.codeSnippet!,
            fileName: 'challenge.dart',
            maxHeight: 220,
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FQPrimaryButton(
            label: l10n.dailyChallengeOpenButton,
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.go(
              '/challenges/play?date=${challenge.publishDateKey}',
              extra: challenge,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeCompletedCard extends StatelessWidget {
  const _ChallengeCompletedCard({
    required this.challenge,
    required this.answeredCorrectly,
    required this.xpEarned,
    required this.completedAt,
  });

  final DailyChallengeQuestion challenge;
  final bool answeredCorrectly;
  final int xpEarned;
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formattedDate = DateFormat.yMMMMd(locale).format(challenge.publishDate);
    final dateBadge = DateFormat('dd MMM', locale)
        .format(challenge.publishDate)
        .toUpperCase();

    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: FQGradients.subtlePanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dailyChallengeCompletedTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: FQColors.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FQPill(
                label: answeredCorrectly
                    ? l10n.dailyChallengeCorrectLabel
                    : l10n.dailyChallengeIncorrectLabel,
                icon: answeredCorrectly
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: answeredCorrectly
                    ? const Color(0xFFDFF7E8)
                    : const Color(0xFFFFE4E1),
                textColor: answeredCorrectly
                    ? const Color(0xFF1D8D4A)
                    : const Color(0xFFC23737),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.topic,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FQColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dailyChallengeCompletedBody(formattedDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'XP',
                  value: '+$xpEarned',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: l10n.dailyChallengeDateLabel,
                  value: dateBadge,
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FQSurfaceCard(
            radius: FQRadius.large,
            color: answeredCorrectly
                ? const Color(0xFFDFF7E8)
                : const Color(0xFFFFF0EE),
            child: Text(
              answeredCorrectly
                  ? l10n.dailyChallengeSeeYouTomorrow
                  : l10n.dailyChallengeRetryTomorrow,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.42,
                color: answeredCorrectly
                    ? const Color(0xFF1D8D4A)
                    : const Color(0xFF8F2B1D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FQColors.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.66),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
