import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning/state/app_state_providers.dart';
import '../data/daily_challenge_repository.dart';
import '../data/daily_challenge_supabase_source.dart';
import '../models/daily_challenge_models.dart';

const dailyChallengeCorrectXpReward = 15;
const dailyChallengeIncorrectXpReward = 5;

final dailyChallengeSourceProvider = Provider<DailyChallengeSupabaseSource>((
  ref,
) {
  return const DailyChallengeSupabaseSource();
});

final dailyChallengeRepositoryProvider = Provider<DailyChallengeRepository>((
  ref,
) {
  return DailyChallengeRepository(ref.watch(dailyChallengeSourceProvider));
});

final dailyChallengeOverviewProvider =
    FutureProvider<DailyChallengeOverviewState>((ref) async {
      final repository = ref.watch(dailyChallengeRepositoryProvider);
      final languageCode = ref.watch(effectiveLanguageCodeProvider);
      final progress = await ref.watch(appProgressNotifierProvider.future);
      final result = await repository.fetchTodayChallenge(
        languageCode: languageCode,
      );

      if (result.status == DailyChallengeFetchStatus.ready &&
          result.challenge != null) {
        final challenge = result.challenge!;
        final record = progress.dailyChallengeHistoryByDate[challenge.publishDateKey];
        if (record != null) {
          return DailyChallengeOverviewState(
            status: DailyChallengeOverviewStatus.completed,
            challenge: challenge,
            answeredCorrectly: record.answeredCorrectly,
            xpEarned: record.xpEarned,
            completedAt: DateTime.tryParse(record.completedAt),
          );
        }

        return DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.ready,
          challenge: challenge,
        );
      }

      return switch (result.status) {
        DailyChallengeFetchStatus.empty => DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.empty,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.offline => DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.offline,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.unavailable => DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.unavailable,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.error => DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.error,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.ready => const DailyChallengeOverviewState(
          status: DailyChallengeOverviewStatus.error,
        ),
      };
    });

final dailyChallengeHistoryProvider =
    FutureProvider<DailyChallengeHistoryState>((ref) async {
      final repository = ref.watch(dailyChallengeRepositoryProvider);
      final languageCode = ref.watch(effectiveLanguageCodeProvider);
      final progress = await ref.watch(appProgressNotifierProvider.future);

      try {
        final challenges = await repository.fetchRecentPreviousChallenges(
          languageCode: languageCode,
          limit: 7,
        );
        final items = challenges.map((challenge) {
          final record = progress.dailyChallengeHistoryByDate[challenge.publishDateKey];
          if (record != null) {
            return DailyChallengeHistoryItem(
              challenge: challenge,
              status: DailyChallengeHistoryStatus.completed,
              answeredCorrectly: record.answeredCorrectly,
              xpEarned: record.xpEarned,
              completedAt: DateTime.tryParse(record.completedAt),
            );
          }
          return DailyChallengeHistoryItem(
            challenge: challenge,
            status: DailyChallengeHistoryStatus.available,
            answeredCorrectly: null,
            xpEarned: 0,
            completedAt: null,
          );
        }).toList(growable: false);

        return DailyChallengeHistoryState(
          status: DailyChallengeHistoryFetchStatus.ready,
          items: items,
        );
      } catch (error) {
        final raw = error.toString().toLowerCase();
        if (raw.contains('socketexception') ||
            raw.contains('failed host lookup') ||
            raw.contains('timed out') ||
            raw.contains('network') ||
            raw.contains('clientexception')) {
          return DailyChallengeHistoryState(
            status: DailyChallengeHistoryFetchStatus.offline,
            items: const [],
            debugMessage: error.toString(),
          );
        }
        if (raw.contains('supabase is not configured')) {
          return DailyChallengeHistoryState(
            status: DailyChallengeHistoryFetchStatus.unavailable,
            items: const [],
            debugMessage: error.toString(),
          );
        }
        return DailyChallengeHistoryState(
          status: DailyChallengeHistoryFetchStatus.error,
          items: const [],
          debugMessage: error.toString(),
        );
      }
    });

final dailyChallengePlayableProvider =
    FutureProvider.family<DailyChallengePlayableState, String?>((ref, publishDate) async {
      final repository = ref.watch(dailyChallengeRepositoryProvider);
      final languageCode = ref.watch(effectiveLanguageCodeProvider);
      final progress = await ref.watch(appProgressNotifierProvider.future);
      final result = publishDate == null || publishDate.isEmpty
          ? await repository.fetchTodayChallenge(languageCode: languageCode)
          : await repository.fetchChallengeByPublishDate(
              languageCode: languageCode,
              publishDate: publishDate,
            );

      if (result.status == DailyChallengeFetchStatus.ready &&
          result.challenge != null) {
        final challenge = result.challenge!;
        final record = progress.dailyChallengeHistoryByDate[challenge.publishDateKey];
        if (record != null) {
          return DailyChallengePlayableState(
            status: DailyChallengePlayableStatus.completed,
            challenge: challenge,
            answeredCorrectly: record.answeredCorrectly,
            xpEarned: record.xpEarned,
            completedAt: DateTime.tryParse(record.completedAt),
          );
        }
        return DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.ready,
          challenge: challenge,
        );
      }

      return switch (result.status) {
        DailyChallengeFetchStatus.offline => DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.offline,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.unavailable => DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.unavailable,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.empty => DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.unavailable,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.error => DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.error,
          debugMessage: result.debugMessage,
        ),
        DailyChallengeFetchStatus.ready => const DailyChallengePlayableState(
          status: DailyChallengePlayableStatus.error,
        ),
      };
    });
