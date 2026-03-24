import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dart_route_asset_source.dart';
import '../data/local_progress_store.dart';
import '../data/progress_repository.dart';
import '../data/route_content_repository.dart';
import '../models/learning_models.dart';
import '../models/progress_view_models.dart';

final dartRouteAssetSourceProvider = Provider<DartRouteAssetSource>((ref) {
  return const DartRouteAssetSource();
});

final routeContentRepositoryProvider = Provider<RouteContentRepository>((ref) {
  return RouteContentRepository(ref.watch(dartRouteAssetSourceProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(LocalProgressStore());
});

final activeRouteIdProvider = Provider<String>((ref) => 'dart_route');

final routeContentProvider = FutureProvider<DartRouteContent>((ref) async {
  final repository = ref.watch(routeContentRepositoryProvider);
  return repository.loadDartRoute();
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

final currentNodeProvider = Provider.family<CurrentNodeInfo, String>((
  ref,
  routeId,
) {
  final content = ref.watch(routeContentProvider).valueOrNull;
  final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (content == null || progress == null) {
    return const CurrentNodeInfo(
      nodeId: null,
      nodeTitle: 'Aun no has comenzado',
      hasStarted: false,
    );
  }

  final nodeId = progress.activeNodeId;
  if (nodeId == null) {
    return const CurrentNodeInfo(
      nodeId: null,
      nodeTitle: 'Aun no has comenzado',
      hasStarted: false,
    );
  }

  for (final node in content.nodes) {
    if (node.id == nodeId) {
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
  final route = ref.watch(routeContentProvider).valueOrNull;
  final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
  if (route == null || progress == null) return null;
  final currentNode = ref.watch(currentNodeProvider(route.routeId));
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
    routeProgress: progress.routeProgress(route.routeId),
    examCompleted: progress.completedNodeIds.contains(route.examNodeId),
  );
});

class AppProgressNotifier extends AsyncNotifier<LearningProgressState> {
  ProgressRepository get _progressRepository =>
      ref.read(progressRepositoryProvider);

  @override
  Future<LearningProgressState> build() async {
    final route = await ref.watch(routeContentProvider.future);
    return _progressRepository.loadAndInitialize(route);
  }

  Future<void> loadProgress() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final route = await ref.read(routeContentProvider.future);
      return _progressRepository.loadAndInitialize(route);
    });
  }

  Future<LearningProgressState?> completeLesson(
    LessonAttemptResult result,
  ) async {
    final previous = state.valueOrNull;
    if (previous == null) return null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final route = await ref.read(routeContentProvider.future);
      return _progressRepository.applyLessonResult(
        result: result,
        route: route,
      );
    });
    return state.valueOrNull;
  }

  Future<void> setUserName(String rawName) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    final cleaned = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final route = await ref.read(routeContentProvider.future);
      return _progressRepository.setUserName(userName: cleaned, route: route);
    });
  }

  Future<void> resetAllProgress() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final route = await ref.read(routeContentProvider.future);
      return _progressRepository.resetAll(route: route);
    });
  }
}
