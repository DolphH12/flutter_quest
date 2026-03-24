import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_models.dart';
import 'badge_catalog.dart';
import 'route_progress_mapper.dart';

class LocalProgressStore {
  LocalProgressStore._();
  factory LocalProgressStore() => _instance;
  static final LocalProgressStore _instance = LocalProgressStore._();

  static const _progressKey = 'learning_progress_v2';
  static LearningProgressState? _memoryFallback;

  Future<LearningProgressState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_progressKey);
      if (raw == null || raw.isEmpty) {
        return _memoryFallback ?? LearningProgressState.initial();
      }
      return LearningProgressState.decode(raw);
    } on MissingPluginException {
      return _memoryFallback ?? LearningProgressState.initial();
    }
  }

  Future<void> save(LearningProgressState state) async {
    _memoryFallback = state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, state.encode());
    } on MissingPluginException {
      // Keep app functional when plugin bridge is unavailable.
    }
  }

  Future<LearningProgressState> setUserName({
    required String userName,
    required DartRouteContent route,
  }) async {
    final current = await ensureRouteInitialized(route);
    final cleaned = userName.trim();
    final next = current.copyWith(userName: cleaned.isEmpty ? null : cleaned);
    await save(next);
    return next;
  }

  Future<LearningProgressState> resetAll({
    required DartRouteContent route,
  }) async {
    _memoryFallback = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } on MissingPluginException {
      // Continue with in-memory fallback.
    }
    final initial = LearningProgressState.initial();
    await save(initial);
    return ensureRouteInitialized(route);
  }

  Future<LearningProgressState> applyLessonResult({
    required LessonAttemptResult result,
    required DartRouteContent route,
  }) async {
    final current = await load();

    var completedNodeIds = {...current.completedNodeIds};
    var completedLessonsCount = current.completedLessonsCount;
    var totalXp = current.totalXp;
    final completedRouteIds = {...current.completedRouteIds};
    final unlockedExamIds = {...current.unlockedExamIds};
    final unlockedBadgeIds = {...current.unlockedBadgeIds};
    final badgeUnlockedAt = {...current.badgeUnlockedAt};

    final streak = _computeStreak(
      current: current,
      completionDate: result.completedAt,
    );

    if (result.passed) {
      final wasCompleted = completedNodeIds.contains(result.nodeId);
      completedNodeIds.add(result.nodeId);
      if (!wasCompleted) {
        completedLessonsCount += 1;
        totalXp += result.xpEarned;
      }
    }

    final examNodeIndex = route.nodes.indexWhere(
      (node) => node.id == route.examNodeId,
    );
    final previousBeforeExam = examNodeIndex <= 0
        ? <LearningNodeContent>[]
        : route.nodes.take(examNodeIndex).toList();
    final examUnlocked = previousBeforeExam.every(
      (node) => completedNodeIds.contains(node.id),
    );

    if (examUnlocked) {
      unlockedExamIds.add(route.examNodeId);
    }

    final examPassed = completedNodeIds.contains(route.examNodeId);
    if (examPassed) {
      completedRouteIds.add(route.routeId);
    }

    final routeProgress = RouteProgressMapper.routeCompletion(
      route: route,
      completedNodeIds: completedNodeIds,
    );

    final activeNodeId = RouteProgressMapper.nextActiveNodeId(
      route: route,
      completedNodeIds: completedNodeIds,
    );

    final routeProgressById = {
      ...current.routeProgressPercentById,
      route.routeId: routeProgress,
    };

    _unlockBadges(
      route: route,
      result: result,
      completedNodeIds: completedNodeIds,
      completedLessonsCount: completedLessonsCount,
      completedRouteIds: completedRouteIds,
      unlockedBadgeIds: unlockedBadgeIds,
      badgeUnlockedAt: badgeUnlockedAt,
      unlockedAt: result.completedAt,
    );

    final updated = current.copyWith(
      completedNodeIds: completedNodeIds,
      activeNodeId: activeNodeId,
      completedRouteIds: completedRouteIds,
      unlockedExamIds: unlockedExamIds,
      routeProgressPercentById: routeProgressById,
      totalXp: totalXp,
      completedLessonsCount: completedLessonsCount,
      lastStudyDate: streak.lastStudyDate,
      currentStreak: streak.current,
      bestStreak: streak.best,
      unlockedBadgeIds: unlockedBadgeIds,
      badgeUnlockedAt: badgeUnlockedAt,
      lastLessonResult: result,
    );

    await save(updated);
    return updated;
  }

  Future<LearningProgressState> ensureRouteInitialized(
    DartRouteContent route,
  ) async {
    final current = await load();
    final nextActive =
        current.activeNodeId ??
        RouteProgressMapper.nextActiveNodeId(
          route: route,
          completedNodeIds: current.completedNodeIds,
        ) ??
        (route.nodes.isEmpty ? null : route.nodes.first.id);

    final progress = RouteProgressMapper.routeCompletion(
      route: route,
      completedNodeIds: current.completedNodeIds,
    );

    final updated = current.copyWith(
      activeNodeId: nextActive,
      routeProgressPercentById: {
        ...current.routeProgressPercentById,
        route.routeId: progress,
      },
    );

    await save(updated);
    return updated;
  }

  void _unlockBadges({
    required DartRouteContent route,
    required LessonAttemptResult result,
    required Set<String> completedNodeIds,
    required int completedLessonsCount,
    required Set<String> completedRouteIds,
    required Set<String> unlockedBadgeIds,
    required Map<String, String> badgeUnlockedAt,
    required DateTime unlockedAt,
  }) {
    void unlock(String id) {
      if (unlockedBadgeIds.contains(id)) return;
      unlockedBadgeIds.add(id);
      badgeUnlockedAt[id] = unlockedAt.toIso8601String();
    }

    if (completedNodeIds.isNotEmpty) {
      unlock(BadgeCatalog.firstNodeCompleted.id);
    }
    if (completedLessonsCount >= 3) {
      unlock(BadgeCatalog.threeLessonsCompleted.id);
    }
    if (result.isExam && result.passed) {
      unlock(BadgeCatalog.firstExamPassed.id);
    }
    if (completedRouteIds.contains(route.routeId)) {
      unlock(BadgeCatalog.dartRouteCompleted.id);
    }

    final errorNodeDone = completedNodeIds.any(
      (id) =>
          id.toLowerCase().contains('error') ||
          id.toLowerCase().contains('bug'),
    );
    if (errorNodeDone) {
      unlock(BadgeCatalog.bugHunter.id);
    }

    final nullSafetyDone = completedNodeIds.any(
      (id) => id.toLowerCase().contains('null'),
    );
    if (nullSafetyDone) {
      unlock(BadgeCatalog.nullSafetySurvivor.id);
    }
  }

  _StreakSnapshot _computeStreak({
    required LearningProgressState current,
    required DateTime completionDate,
  }) {
    final today = DateTime(
      completionDate.year,
      completionDate.month,
      completionDate.day,
    );
    final last = current.lastStudyDate == null
        ? null
        : DateTime.tryParse(current.lastStudyDate!);

    if (last == null) {
      return const _StreakSnapshot(
        current: 1,
        best: 1,
        lastStudyDate: null,
      ).withDate(today);
    }

    final lastDay = DateTime(last.year, last.month, last.day);
    final difference = today.difference(lastDay).inDays;

    if (difference == 0) {
      return _StreakSnapshot(
        current: current.currentStreak,
        best: current.bestStreak,
        lastStudyDate: current.lastStudyDate,
      );
    }

    final nextCurrent = difference == 1 ? current.currentStreak + 1 : 1;
    final nextBest = nextCurrent > current.bestStreak
        ? nextCurrent
        : current.bestStreak;
    return _StreakSnapshot(
      current: nextCurrent,
      best: nextBest,
      lastStudyDate: null,
    ).withDate(today);
  }
}

class _StreakSnapshot {
  const _StreakSnapshot({
    required this.current,
    required this.best,
    required this.lastStudyDate,
  });

  final int current;
  final int best;
  final String? lastStudyDate;

  _StreakSnapshot withDate(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day).toIso8601String();
    return _StreakSnapshot(
      current: current,
      best: best,
      lastStudyDate: normalized,
    );
  }
}
