class CurrentNodeInfo {
  const CurrentNodeInfo({
    required this.nodeId,
    required this.nodeTitle,
    required this.hasStarted,
  });

  final String? nodeId;
  final String nodeTitle;
  final bool hasStarted;
}

class ProfileSummary {
  const ProfileSummary({
    required this.userName,
    required this.totalXp,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedLessonsCount,
    required this.completedRoutesCount,
    required this.unlockedBadgesCount,
    required this.currentNodeTitle,
    required this.currentNodeId,
    required this.routeProgress,
    required this.examCompleted,
  });

  final String userName;
  final int totalXp;
  final int currentStreak;
  final int bestStreak;
  final int completedLessonsCount;
  final int completedRoutesCount;
  final int unlockedBadgesCount;
  final String currentNodeTitle;
  final String? currentNodeId;
  final double routeProgress;
  final bool examCompleted;
}

class RouteCardState {
  const RouteCardState({
    required this.routeId,
    required this.progress,
    required this.isStarted,
    required this.isCompleted,
  });

  final String routeId;
  final double progress;
  final bool isStarted;
  final bool isCompleted;
}
