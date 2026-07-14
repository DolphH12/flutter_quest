enum DailyChallengeDifficulty { easy, medium, hard, unknown }

enum DailyChallengeFetchStatus { ready, empty, offline, unavailable, error }

String dailyChallengeLocalDayKey([DateTime? value]) {
  final now = value ?? DateTime.now();
  final localDay = DateTime(now.year, now.month, now.day);
  return localDay.toIso8601String().split('T').first;
}

class DailyChallengeQuestion {
  const DailyChallengeQuestion({
    required this.id,
    required this.publishDate,
    required this.level,
    required this.difficulty,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.codeSnippet,
  });

  final String id;
  final DateTime publishDate;
  final int level;
  final DailyChallengeDifficulty difficulty;
  final String topic;
  final String question;
  final String? codeSnippet;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  bool get hasCodeSnippet =>
      codeSnippet != null && codeSnippet!.trim().isNotEmpty;

  String get publishDateKey => dailyChallengeLocalDayKey(publishDate);
}

class DailyChallengeFetchResult {
  const DailyChallengeFetchResult._({
    required this.status,
    this.challenge,
    this.debugMessage,
  });

  const DailyChallengeFetchResult.ready(DailyChallengeQuestion challenge)
    : this._(status: DailyChallengeFetchStatus.ready, challenge: challenge);

  const DailyChallengeFetchResult.empty({String? debugMessage})
    : this._(
        status: DailyChallengeFetchStatus.empty,
        debugMessage: debugMessage,
      );

  const DailyChallengeFetchResult.offline({String? debugMessage})
    : this._(
        status: DailyChallengeFetchStatus.offline,
        debugMessage: debugMessage,
      );

  const DailyChallengeFetchResult.unavailable({String? debugMessage})
    : this._(
        status: DailyChallengeFetchStatus.unavailable,
        debugMessage: debugMessage,
      );

  const DailyChallengeFetchResult.error({String? debugMessage})
    : this._(
        status: DailyChallengeFetchStatus.error,
        debugMessage: debugMessage,
      );

  final DailyChallengeFetchStatus status;
  final DailyChallengeQuestion? challenge;
  final String? debugMessage;
}

enum DailyChallengeOverviewStatus {
  ready,
  completed,
  offline,
  empty,
  unavailable,
  error,
}

class DailyChallengeOverviewState {
  const DailyChallengeOverviewState({
    required this.status,
    this.challenge,
    this.answeredCorrectly,
    this.xpEarned,
    this.completedAt,
    this.debugMessage,
  });

  final DailyChallengeOverviewStatus status;
  final DailyChallengeQuestion? challenge;
  final bool? answeredCorrectly;
  final int? xpEarned;
  final DateTime? completedAt;
  final String? debugMessage;

  bool get canOpen =>
      status == DailyChallengeOverviewStatus.ready && challenge != null;

  bool get isCompleted =>
      status == DailyChallengeOverviewStatus.completed && challenge != null;
}

enum DailyChallengeHistoryStatus { available, completed }

class DailyChallengeHistoryItem {
  const DailyChallengeHistoryItem({
    required this.challenge,
    required this.status,
    required this.answeredCorrectly,
    required this.xpEarned,
    required this.completedAt,
  });

  final DailyChallengeQuestion challenge;
  final DailyChallengeHistoryStatus status;
  final bool? answeredCorrectly;
  final int xpEarned;
  final DateTime? completedAt;

  bool get canOpen => status == DailyChallengeHistoryStatus.available;
  bool get isCompleted => status == DailyChallengeHistoryStatus.completed;
}

enum DailyChallengeHistoryFetchStatus { ready, offline, unavailable, error }

class DailyChallengeHistoryState {
  const DailyChallengeHistoryState({
    required this.status,
    required this.items,
    this.debugMessage,
  });

  final DailyChallengeHistoryFetchStatus status;
  final List<DailyChallengeHistoryItem> items;
  final String? debugMessage;
}

enum DailyChallengePlayableStatus {
  ready,
  completed,
  offline,
  unavailable,
  error,
}

class DailyChallengePlayableState {
  const DailyChallengePlayableState({
    required this.status,
    this.challenge,
    this.answeredCorrectly,
    this.xpEarned,
    this.completedAt,
    this.debugMessage,
  });

  final DailyChallengePlayableStatus status;
  final DailyChallengeQuestion? challenge;
  final bool? answeredCorrectly;
  final int? xpEarned;
  final DateTime? completedAt;
  final String? debugMessage;

  bool get canOpen =>
      status == DailyChallengePlayableStatus.ready && challenge != null;

  bool get isCompleted =>
      status == DailyChallengePlayableStatus.completed && challenge != null;
}
