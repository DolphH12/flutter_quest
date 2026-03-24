import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/badge_catalog.dart';
import '../data/local_progress_store.dart';
import '../data/progress_repository.dart';
import '../data/route_asset_source.dart';
import '../data/route_content_repository.dart';
import '../data/route_progress_mapper.dart';
import '../models/learning_models.dart';
import '../models/progress_view_models.dart';

final routeManifestsProvider = Provider<List<RouteAssetManifest>>((ref) {
  return const [
    RouteAssetManifest(
      routeId: 'dart_route',
      assetPath: 'assets/content/dart_route.json',
    ),
    RouteAssetManifest(
      routeId: 'flutter_foundations_route',
      assetPath: 'assets/content/flutter_foundations_route.json',
      requiredCompletedRouteId: 'dart_route',
    ),
  ];
});

final routeUnlockRequirementsProvider = Provider<Map<String, String?>>((ref) {
  final manifests = ref.watch(routeManifestsProvider);
  return {
    for (final manifest in manifests)
      manifest.routeId: manifest.requiredCompletedRouteId,
  };
});

final routeAssetSourceProvider = Provider<RouteAssetSource>((ref) {
  return const RouteAssetSource();
});

final routeContentRepositoryProvider = Provider<RouteContentRepository>((ref) {
  return RouteContentRepository(ref.watch(routeAssetSourceProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(LocalProgressStore());
});

final allRoutesProvider = FutureProvider<List<DartRouteContent>>((ref) async {
  final repository = ref.watch(routeContentRepositoryProvider);
  final manifests = ref.watch(routeManifestsProvider);
  return repository.loadRoutes(manifests: manifests);
});

final routeLoadErrorsProvider = Provider<Map<String, String>>((ref) {
  ref.watch(allRoutesProvider);
  final repository = ref.watch(routeContentRepositoryProvider);
  return repository.loadErrorsByRouteId;
});

// Backward compatibility for screens/components still expecting the Dart route.
final routeContentProvider = FutureProvider<DartRouteContent>((ref) async {
  final routes = await ref.watch(allRoutesProvider.future);
  if (routes.isEmpty) {
    final errors = ref.read(routeContentRepositoryProvider).loadErrorsByRouteId;
    throw StateError(
      errors.isEmpty
          ? 'No routes available.'
          : 'No routes could be loaded: ${errors.values.join(' | ')}',
    );
  }
  for (final route in routes) {
    if (route.routeId == 'dart_route') return route;
  }
  return routes.first;
});

final routeByIdProvider = Provider.family<DartRouteContent?, String>((
  ref,
  routeId,
) {
  final routes = ref.watch(allRoutesProvider).valueOrNull;
  if (routes == null) return null;
  for (final route in routes) {
    if (route.routeId == routeId) return route;
  }
  return null;
});

final appProgressNotifierProvider =
    AsyncNotifierProvider<AppProgressNotifier, LearningProgressState>(
      AppProgressNotifier.new,
    );

final appProgressProvider = Provider<AsyncValue<LearningProgressState>>((ref) {
  return ref.watch(appProgressNotifierProvider);
});

final routeProgressProvider = Provider.family<double, String>((ref, routeId) {
  final progress = ref.watch(appProgressNotifierProvider);
  return progress.maybeWhen(
    data: (value) => value.routeProgress(routeId),
    orElse: () => 0,
  );
});

final routeUnlockedProvider = Provider.family<bool, String>((ref, routeId) {
  final requirement = ref.watch(routeUnlockRequirementsProvider)[routeId];
  if (requirement == null) return true;
  final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (progress == null) return false;
  return progress.completedRouteIds.contains(requirement);
});

final currentNodeProvider = Provider.family<CurrentNodeInfo, String>((
  ref,
  routeId,
) {
  final route = ref.watch(routeByIdProvider(routeId));
  final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (route == null || progress == null) {
    return const CurrentNodeInfo(
      nodeId: null,
      nodeTitle: 'Aun no has comenzado',
      hasStarted: false,
    );
  }

  final activeInRoute = RouteProgressMapper.nextActiveNodeId(
    route: route,
    completedNodeIds: progress.completedNodeIds,
  );
  if (activeInRoute == null) {
    return const CurrentNodeInfo(
      nodeId: null,
      nodeTitle: 'Aun no has comenzado',
      hasStarted: false,
    );
  }

  for (final node in route.nodes) {
    if (node.id == activeInRoute) {
      return CurrentNodeInfo(
        nodeId: node.id,
        nodeTitle: node.title,
        hasStarted: true,
      );
    }
  }

  return const CurrentNodeInfo(
    nodeId: null,
    nodeTitle: 'Aun no has comenzado',
    hasStarted: false,
  );
});

final routeCardStateProvider = Provider.family<RouteCardState, String>((
  ref,
  routeId,
) {
  final progressValue = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (progressValue == null) {
    return RouteCardState(
      routeId: routeId,
      progress: 0,
      isStarted: false,
      isCompleted: false,
    );
  }
  final progress = progressValue.routeProgress(routeId);
  return RouteCardState(
    routeId: routeId,
    progress: progress,
    isStarted: progress > 0,
    isCompleted: progressValue.completedRouteIds.contains(routeId),
  );
});

final profileSummaryProvider = Provider<ProfileSummary?>((ref) {
  final routes = ref.watch(allRoutesProvider).valueOrNull;
  final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (routes == null || routes.isEmpty || progress == null) return null;

  DartRouteContent primaryRoute = routes.first;
  if (progress.lastLessonResult != null) {
    final lastRouteId = progress.lastLessonResult!.routeId;
    for (final route in routes) {
      if (route.routeId == lastRouteId) {
        primaryRoute = route;
        break;
      }
    }
  } else {
    for (final route in routes) {
      if (progress.routeProgress(route.routeId) > 0) {
        primaryRoute = route;
        break;
      }
    }
  }

  final currentNode = ref.watch(currentNodeProvider(primaryRoute.routeId));

  return ProfileSummary(
    userName: (progress.userName == null || progress.userName!.trim().isEmpty)
        ? 'Quest Learner'
        : progress.userName!.trim(),
    totalXp: progress.totalXp,
    currentStreak: progress.currentStreak,
    bestStreak: progress.bestStreak,
    completedLessonsCount: progress.completedLessonsCount,
    completedRoutesCount: progress.completedRouteIds.length,
    unlockedBadgesCount: progress.unlockedBadgeIds.length,
    currentNodeTitle: currentNode.nodeTitle,
    currentNodeId: currentNode.nodeId,
    routeProgress: progress.routeProgress(primaryRoute.routeId),
    examCompleted: progress.completedNodeIds.contains(primaryRoute.examNodeId),
  );
});

class AppProgressNotifier extends AsyncNotifier<LearningProgressState> {
  ProgressRepository get _progressRepository =>
      ref.read(progressRepositoryProvider);

  @override
  Future<LearningProgressState> build() async {
    final routes = await ref.watch(allRoutesProvider.future);
    return _progressRepository.loadAndInitializeAll(routes);
  }

  Future<void> loadProgress() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      return _progressRepository.loadAndInitializeAll(routes);
    });
  }

  Future<LessonProgressUpdate?> completeLesson(
    LessonAttemptResult result,
  ) async {
    final previous = state.valueOrNull;
    if (previous == null) {
      return null;
    }
    final previousBadges = {...previous.unlockedBadgeIds};
    final previousCompletedRoutes = {...previous.completedRouteIds};
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      DartRouteContent? route;
      for (final item in routes) {
        if (item.routeId == result.routeId) {
          route = item;
          break;
        }
      }
      route ??= routes.first;
      return _progressRepository.applyLessonResult(
        result: result,
        route: route,
      );
    });
    final next = state.valueOrNull;
    if (next == null) return null;
    final newlyUnlockedBadgeIds = next.unlockedBadgeIds
        .where((id) => !previousBadges.contains(id))
        .toList();
    if (newlyUnlockedBadgeIds.isNotEmpty) {
      final events = <BadgeUnlockUiEvent>[];
      for (final badgeId in newlyUnlockedBadgeIds) {
        final definition = BadgeCatalog.byId(badgeId);
        if (definition == null) continue;
        events.add(
          BadgeUnlockUiEvent(
            badgeId: badgeId,
            title: definition.title,
            description: definition.description,
            icon: definition.icon,
          ),
        );
      }
      if (events.isNotEmpty) {
        ref.read(badgeUiEventQueueProvider.notifier).enqueueAll(events);
      }
    }
    final routeJustCompleted =
        result.isExam &&
        result.passed &&
        next.completedRouteIds.contains(result.routeId) &&
        !previousCompletedRoutes.contains(result.routeId);

    return LessonProgressUpdate(
      progress: next,
      routeJustCompleted: routeJustCompleted,
      newlyUnlockedBadgeIds: newlyUnlockedBadgeIds,
    );
  }

  Future<void> setUserName(String rawName) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    final cleaned = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      return _progressRepository.setUserName(userName: cleaned, routes: routes);
    });
  }

  Future<void> resetAllProgress() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      return _progressRepository.resetAll(routes: routes);
    });
  }
}

class LessonProgressUpdate {
  const LessonProgressUpdate({
    required this.progress,
    required this.routeJustCompleted,
    required this.newlyUnlockedBadgeIds,
  });

  final LearningProgressState progress;
  final bool routeJustCompleted;
  final List<String> newlyUnlockedBadgeIds;
}

class BadgeUnlockUiEvent {
  const BadgeUnlockUiEvent({
    required this.badgeId,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String badgeId;
  final String title;
  final String description;
  final IconData icon;
}

class BadgeUiEventQueueNotifier extends Notifier<List<BadgeUnlockUiEvent>> {
  @override
  List<BadgeUnlockUiEvent> build() => const <BadgeUnlockUiEvent>[];

  void enqueueAll(List<BadgeUnlockUiEvent> events) {
    if (events.isEmpty) return;
    state = [...state, ...events];
  }

  BadgeUnlockUiEvent? consumeFirst() {
    if (state.isEmpty) return null;
    final first = state.first;
    state = state.sublist(1);
    return first;
  }
}

final badgeUiEventQueueProvider =
    NotifierProvider<BadgeUiEventQueueNotifier, List<BadgeUnlockUiEvent>>(
      BadgeUiEventQueueNotifier.new,
    );
