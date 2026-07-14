import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_state_views.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../lesson_flow/widgets/activity_renderers.dart';
import '../../lesson_flow/widgets/quest_code_editor.dart';
import '../../learning/state/app_state_providers.dart';
import '../models/daily_challenge_models.dart';
import 'daily_challenge_copy.dart';
import '../state/daily_challenge_providers.dart';

class DailyChallengeAttemptScreen extends ConsumerStatefulWidget {
  const DailyChallengeAttemptScreen({
    super.key,
    this.publishDateKey,
    this.initialChallenge,
  });

  final String? publishDateKey;
  final DailyChallengeQuestion? initialChallenge;

  @override
  ConsumerState<DailyChallengeAttemptScreen> createState() =>
      _DailyChallengeAttemptScreenState();
}

class _DailyChallengeAttemptScreenState
    extends ConsumerState<DailyChallengeAttemptScreen> {
  Timer? _timer;
  DailyChallengeQuestion? _challenge;
  int _secondsLeft = 30;
  int? _selectedIndex;
  bool _submitted = false;
  bool _saving = false;
  bool _timedOut = false;
  bool? _wasCorrect;

  @override
  void initState() {
    super.initState();
    _challenge = widget.initialChallenge;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cachedChallenge = _challenge;

    return FQPageContainer(
      child: cachedChallenge != null
          ? _buildChallengeBody(context, cachedChallenge, l10n)
          : ref
                .watch(dailyChallengePlayableProvider(widget.publishDateKey))
                .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FQErrorState(
            title: l10n.dailyChallengeLoadErrorTitle,
            message: l10n.dailyChallengeLoadErrorBody,
            primaryActionLabel: l10n.retryButton,
            onPrimaryAction: _retryLoad,
          ),
        ),
        data: (overview) {
          if (overview.status == DailyChallengePlayableStatus.offline) {
            return Center(
              child: FQErrorState(
                title: l10n.dailyChallengeInternetTitle,
                message: l10n.dailyChallengeInternetBody,
                primaryActionLabel: l10n.retryButton,
                onPrimaryAction: _retryLoad,
              ),
            );
          }

          if (overview.status == DailyChallengePlayableStatus.error) {
            return Center(
              child: FQErrorState(
                title: l10n.dailyChallengeLoadErrorTitle,
                message: l10n.dailyChallengeLoadErrorBody,
                primaryActionLabel: l10n.retryButton,
                onPrimaryAction: _retryLoad,
              ),
            );
          }

          if (overview.status == DailyChallengePlayableStatus.unavailable) {
            return Center(
              child: FQErrorState(
                title: l10n.dailyChallengeUnavailableTitle,
                message: l10n.dailyChallengeUnavailableBody,
                primaryActionLabel: l10n.backToChallenges,
                onPrimaryAction: () => context.go('/challenges'),
              ),
            );
          }

          if (overview.isCompleted) {
            return Center(
              child: FQSurfaceCard(
                radius: FQRadius.xLarge,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 42,
                      color: Color(0xFF1D8D4A),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      DailyChallengeCopy.completedPastChallengeTitle(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: FQColors.deepNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DailyChallengeCopy.completedPastChallengeBody(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: FQColors.onSurface.withValues(alpha: 0.74),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FQPrimaryButton(
                        label: DailyChallengeCopy.backToRecentChallenges(context),
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.go('/challenges'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final challenge = overview.challenge!;
          _challenge = challenge;
          return _buildChallengeBody(context, challenge, l10n);
        },
      ),
    );
  }

  void _retryLoad() {
    _challenge = widget.initialChallenge;
    ref.invalidate(dailyChallengePlayableProvider(widget.publishDateKey));
  }

  Widget _buildChallengeBody(
    BuildContext context,
    DailyChallengeQuestion challenge,
    AppLocalizations l10n,
  ) {
    _ensureTimerStarted();
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _submitted ? null : () => context.go('/challenges'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Expanded(
              child: Text(
                challenge.topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: FQColors.deepNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FQPill(
              label: '${_secondsLeft}s',
              icon: Icons.timer_outlined,
              color: _secondsLeft <= 10
                  ? const Color(0xFFFFE4E1)
                  : const Color(0xFFE4EDFF),
              textColor: _secondsLeft <= 10
                  ? const Color(0xFFC23737)
                  : FQColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            children: [
              FQSurfaceCard(
                radius: FQRadius.xLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.question,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: FQColors.deepNavy,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                    if (challenge.hasCodeSnippet) ...[
                      const SizedBox(height: 14),
                      QuestCodePreview(
                        content: challenge.codeSnippet!,
                        fileName: 'daily_challenge.dart',
                        maxHeight: 240,
                      ),
                    ],
                    const SizedBox(height: 14),
                    for (int index = 0; index < challenge.options.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DailyChallengeOptionTile(
                          label: challenge.options[index],
                          selected: _selectedIndex == index,
                          revealed: _submitted,
                          isCorrectOption: index == challenge.correctIndex,
                          isWrongSelection:
                              _submitted &&
                              _selectedIndex == index &&
                              index != challenge.correctIndex,
                          onTap: _submitted
                              ? null
                              : () => setState(() => _selectedIndex = index),
                        ),
                      ),
                    if (_submitted && _wasCorrect != null) ...[
                      const SizedBox(height: 8),
                      LessonFeedbackCard(
                        isCorrect: _wasCorrect!,
                        title: _wasCorrect!
                            ? l10n.dailyChallengeResultCorrectTitle
                            : (_timedOut
                                  ? l10n.dailyChallengeResultTimeoutTitle
                                  : l10n.dailyChallengeResultIncorrectTitle),
                        message: challenge.explanation,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: _submitted
                ? FQPrimaryButton(
                    label: l10n.backToChallenges,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      ref.invalidate(dailyChallengeOverviewProvider);
                      context.go('/challenges');
                    },
                  )
                : FQPrimaryButton(
                    label: _saving
                        ? l10n.dailyChallengeSavingButton
                        : l10n.dailyChallengeVerifyButton,
                    icon: Icons.bolt_rounded,
                    onPressed: (_saving || _selectedIndex == null)
                        ? null
                        : () => _submit(challenge),
                  ),
          ),
        ),
      ],
    );
  }

  void _ensureTimerStarted() {
    if (_timer != null || _submitted) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _submitted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
        final overview = ref
            .read(dailyChallengePlayableProvider(widget.publishDateKey))
            .valueOrNull;
        final challenge = overview?.challenge;
        if (challenge != null) {
          _timedOut = true;
          _submit(challenge, timedOut: true);
        }
        return;
      }
      setState(() {
        _secondsLeft -= 1;
      });
    });
  }

  Future<void> _submit(
    DailyChallengeQuestion challenge, {
    bool timedOut = false,
  }) async {
    if (_submitted || _saving) return;
    final selectedIndex = _selectedIndex;
    final isCorrect = !timedOut && selectedIndex == challenge.correctIndex;
    final todayKey = dailyChallengeLocalDayKey();
    final awardsXp = challenge.publishDateKey == todayKey;
    final xpEarned = awardsXp
        ? (isCorrect
              ? dailyChallengeCorrectXpReward
              : dailyChallengeIncorrectXpReward)
        : 0;

    setState(() {
      _saving = true;
      _submitted = true;
      _wasCorrect = isCorrect;
      _timedOut = timedOut;
    });
    _timer?.cancel();

    await ref
        .read(appProgressNotifierProvider.notifier)
        .applyDailyChallengeResult(
          challengeId: challenge.id,
          publishDate: challenge.publishDateKey,
          answeredCorrectly: isCorrect,
          xpEarned: xpEarned,
          completedAt: DateTime.now(),
        );

    if (!mounted) return;
    ref.invalidate(dailyChallengeOverviewProvider);
    ref.invalidate(dailyChallengeHistoryProvider);
    ref.invalidate(dailyChallengePlayableProvider(widget.publishDateKey));
    setState(() {
      _saving = false;
    });
  }
}

class _DailyChallengeOptionTile extends StatelessWidget {
  const _DailyChallengeOptionTile({
    required this.label,
    required this.selected,
    required this.revealed,
    required this.isCorrectOption,
    required this.isWrongSelection,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool revealed;
  final bool isCorrectOption;
  final bool isWrongSelection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = revealed
        ? (isCorrectOption
              ? const Color(0xFFDFF7E8)
              : (isWrongSelection
                    ? const Color(0xFFFFE5E5)
                    : FQColors.surfaceHigh))
        : (selected ? FQColors.surfaceHigh : Colors.white.withValues(alpha: 0.82));
    final borderColor = revealed
        ? (isCorrectOption
              ? const Color(0xFF1D8D4A)
              : (isWrongSelection
                    ? const Color(0xFFC23737)
                    : Colors.transparent))
        : (selected
              ? FQColors.primary.withValues(alpha: 0.28)
              : Colors.transparent);

    return InkWell(
      borderRadius: FQRadius.large,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: FQRadius.large,
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FQColors.deepNavy,
                  height: 1.2,
                ),
              ),
            ),
            if (revealed && isCorrectOption)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF1D8D4A)),
            if (revealed && isWrongSelection)
              const Icon(Icons.cancel_rounded, color: Color(0xFFC23737)),
          ],
        ),
      ),
    );
  }
}
