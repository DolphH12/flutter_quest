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
        final fallback = _memoryFallback ?? LearningProgressState.initial();
        final decayed = _applyStreakDecay(fallback);
        if (decayed != fallback) {
          await save(decayed);
        }
        return decayed;
      }
      final decoded = LearningProgressState.decode(raw);
      final decayed = _applyStreakDecay(decoded);
      if (decayed != decoded) {
        await save(decayed);
      }
      return decayed;
    } on MissingPluginException {
      final fallback = _memoryFallback ?? LearningProgressState.initial();
      return _applyStreakDecay(fallback);
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
    required List<DartRouteContent> routes,
  }) async {
    final current = await ensureRoutesInitialized(routes);
    final cleaned = userName.trim();
    final next = current.copyWith(userName: cleaned.isEmpty ? null : cleaned);
    await save(next);
    return next;
  }

  Future<LearningProgressState> resetAll({
    required List<DartRouteContent> routes,
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
    return ensureRoutesInitialized(routes);
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
    final list = await ensureRoutesInitialized([route]);
    return list;
  }

  Future<LearningProgressState> ensureRoutesInitialized(
    List<DartRouteContent> routes,
  ) async {
    final current = await load();
    final nextRouteProgress = <String, double>{
      ...current.routeProgressPercentById,
    };
    final nextUnlockedExams = <String>{...current.unlockedExamIds};
    final nextCompletedRoutes = <String>{...current.completedRouteIds};

    String? nextActiveNodeId = current.activeNodeId;

    for (final route in routes) {
      final progress = RouteProgressMapper.routeCompletion(
        route: route,
        completedNodeIds: current.completedNodeIds,
      );
      nextRouteProgress[route.routeId] = progress;

      final examIndex = route.nodes.indexWhere(
        (node) => node.id == route.examNodeId,
      );
      final previous = examIndex <= 0
          ? <LearningNodeContent>[]
          : route.nodes.take(examIndex).toList();
      final examUnlocked = previous.every(
        (node) => current.completedNodeIds.contains(node.id),
      );
      if (examUnlocked) {
        nextUnlockedExams.add(route.examNodeId);
      }
      if (current.completedNodeIds.contains(route.examNodeId)) {
        nextCompletedRoutes.add(route.routeId);
      }
    }

    final activeBelongsToKnownRoute =
        nextActiveNodeId != null &&
        routes.any(
          (route) => route.nodes.any((node) => node.id == nextActiveNodeId),
        );

    if (!activeBelongsToKnownRoute) {
      for (final route in routes) {
        final candidate = RouteProgressMapper.nextActiveNodeId(
          route: route,
          completedNodeIds: current.completedNodeIds,
        );
        if (candidate != null) {
          nextActiveNodeId = candidate;
          break;
        }
      }
    }

    final updated = current.copyWith(
      activeNodeId: nextActiveNodeId,
      routeProgressPercentById: nextRouteProgress,
      unlockedExamIds: nextUnlockedExams,
      completedRouteIds: nextCompletedRoutes,
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

  LearningProgressState _applyStreakDecay(LearningProgressState state) {
    final lastRaw = state.lastStudyDate;
    if (lastRaw == null || lastRaw.trim().isEmpty) return state;
    final parsed = DateTime.tryParse(lastRaw);
    if (parsed == null) return state;
    final lastDay = DateTime(parsed.year, parsed.month, parsed.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(lastDay).inDays;
    if (difference <= 1) return state;
    if (state.currentStreak == 0) return state;
    return state.copyWith(currentStreak: 0);
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
