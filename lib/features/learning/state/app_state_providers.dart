import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/badge_catalog.dart';
import '../data/app_preferences_repository.dart';
import '../data/local_progress_store.dart';
import '../data/progress_repository.dart';
import '../data/progress_backup_service.dart';
import '../data/route_asset_source.dart';
import '../data/route_content_repository.dart';
import '../data/route_progress_mapper.dart';
import '../models/app_preferences.dart';
import '../models/learning_models.dart';
import '../models/progress_backup_model.dart';
import '../models/progress_view_models.dart';
import '../../notifications/state/habit_notifications_provider.dart';
import '../../notifications/models/habit_notification_settings.dart';

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

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>((
  ref,
) {
  return AppPreferencesRepository();
});

final progressBackupServiceProvider = Provider<ProgressBackupService>((ref) {
  return ProgressBackupService();
});

final systemLanguageCodeProvider = Provider<String>((ref) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  return locale.languageCode.toLowerCase();
});

final languagePreferenceProvider =
    AsyncNotifierProvider<LanguagePreferenceNotifier, String?>(
      LanguagePreferenceNotifier.new,
    );

final preferredLanguageCodeProvider = Provider<String?>((ref) {
  return ref.watch(languagePreferenceProvider).valueOrNull;
});

final effectiveLanguageCodeProvider = Provider<String>((ref) {
  final preferred = ref.watch(preferredLanguageCodeProvider);
  if (preferred != null && preferred.isNotEmpty) return preferred;
  return ref.watch(systemLanguageCodeProvider);
});

final appLocaleProvider = Provider<Locale?>((ref) {
  final preferred = ref.watch(preferredLanguageCodeProvider);
  if (preferred == null || preferred.isEmpty) return null;
  return Locale(preferred);
});

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferences>(
      AppPreferencesNotifier.new,
    );

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref
          .watch(appPreferencesProvider)
          .valueOrNull
          ?.hasCompletedOnboarding ??
      false;
});

final allRoutesProvider = FutureProvider<List<DartRouteContent>>((ref) async {
  final repository = ref.watch(routeContentRepositoryProvider);
  final manifests = ref.watch(routeManifestsProvider);
  final languageCode = ref.watch(effectiveLanguageCodeProvider);
  return repository.loadRoutes(
    manifests: manifests,
    languageCode: languageCode,
  );
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
  static const _streakLostToastDateKey = 'fq_streak_lost_toast_date';

  ProgressRepository get _progressRepository =>
      ref.read(progressRepositoryProvider);

  @override
  Future<LearningProgressState> build() async {
    final routes = await ref.watch(allRoutesProvider.future);
    final next = await _progressRepository.loadAndInitializeAll(routes);
    await _maybeEmitStreakLost(previous: null, next: next);
    return next;
  }

  Future<void> loadProgress() async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      final next = await _progressRepository.loadAndInitializeAll(routes);
      await _maybeEmitStreakLost(previous: previous, next: next);
      return next;
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

    await _maybeEmitStreakLost(previous: previous, next: next);

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

  Future<void> setPreferredLanguage(String? languageCode) async {
    await ref
        .read(languagePreferenceProvider.notifier)
        .setLanguage(languageCode);
  }

  Future<ProgressBackupModel?> buildBackupModel() async {
    final progress = state.valueOrNull;
    if (progress == null) return null;
    final languageCode = ref.read(preferredLanguageCodeProvider);
    final notificationPrefs = await ref
        .read(notificationPreferencesRepositoryProvider)
        .load();
    return ProgressBackupModel(
      schemaVersion: ProgressBackupModel.currentSchemaVersion,
      exportedAt: DateTime.now().toIso8601String(),
      progress: progress,
      preferredLanguageCode: languageCode,
      notificationsEnabled: notificationPrefs.enabled,
      notificationHour: notificationPrefs.hour,
      notificationMinute: notificationPrefs.minute,
    );
  }

  Future<void> exportBackup() async {
    final backup = await buildBackupModel();
    if (backup == null) return;
    await ref.read(progressBackupServiceProvider).exportBackup(backup);
  }

  Future<ProgressBackupModel?> pickBackupPreview() async {
    return ref.read(progressBackupServiceProvider).pickAndParseBackup();
  }

  Future<void> importBackup(ProgressBackupModel backup) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      final imported = await _progressRepository.importProgress(
        imported: backup.progress,
        routes: routes,
      );
      return imported;
    });

    await ref
        .read(languagePreferenceProvider.notifier)
        .setLanguage(backup.preferredLanguageCode);
    final importedNotificationSettings = HabitNotificationSettings(
      enabled: backup.notificationsEnabled,
      hour: backup.notificationHour,
      minute: backup.notificationMinute,
    );
    final currentProgress = state.valueOrNull;
    if (currentProgress != null) {
      await ref
          .read(habitNotificationsProvider.notifier)
          .applyImportedSettings(
            settings: importedNotificationSettings,
            progress: currentProgress,
            languageCode: ref.read(effectiveLanguageCodeProvider),
          );
    }

    ref.invalidate(allRoutesProvider);
  }

  Future<void> resetAllProgress() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final routes = await ref.read(allRoutesProvider.future);
      return _progressRepository.resetAll(routes: routes);
    });
    await ref.read(appPreferencesProvider.notifier).resetOnboarding();
    await ref.read(languagePreferenceProvider.notifier).setLanguage(null);
    await ref.read(habitNotificationsProvider.notifier).clearAll();
    ref.invalidate(allRoutesProvider);
  }

  Future<void> _maybeEmitStreakLost({
    required LearningProgressState? previous,
    required LearningProgressState next,
  }) async {
    final droppedNow =
        previous != null &&
        previous.currentStreak > 0 &&
        next.currentStreak == 0;
    final expiredAtStartup =
        previous == null &&
        next.bestStreak > 0 &&
        next.currentStreak == 0 &&
        _isStreakExpired(next.lastStudyDate);
    if (!droppedNow && !expiredAtStartup) return;

    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_streakLostToastDateKey) == todayKey) return;
    await prefs.setString(_streakLostToastDateKey, todayKey);

    ref
        .read(streakUiEventQueueProvider.notifier)
        .enqueue(const StreakLostUiEvent());
  }

  bool _isStreakExpired(String? lastStudyDateIso) {
    if (lastStudyDateIso == null || lastStudyDateIso.trim().isEmpty) {
      return false;
    }
    final last = DateTime.tryParse(lastStudyDateIso);
    if (last == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    return today.difference(lastDay).inDays > 1;
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

class StreakLostUiEvent {
  const StreakLostUiEvent();
}

class StreakUiEventQueueNotifier extends Notifier<List<StreakLostUiEvent>> {
  @override
  List<StreakLostUiEvent> build() => const <StreakLostUiEvent>[];

  void enqueue(StreakLostUiEvent event) {
    state = [...state, event];
  }

  StreakLostUiEvent? consumeFirst() {
    if (state.isEmpty) return null;
    final first = state.first;
    state = state.sublist(1);
    return first;
  }
}

final streakUiEventQueueProvider =
    NotifierProvider<StreakUiEventQueueNotifier, List<StreakLostUiEvent>>(
      StreakUiEventQueueNotifier.new,
    );

class AppPreferencesNotifier extends AsyncNotifier<AppPreferences> {
  AppPreferencesRepository get _repository =>
      ref.read(appPreferencesRepositoryProvider);

  @override
  Future<AppPreferences> build() async {
    return _repository.load();
  }

  Future<void> completeOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.setOnboardingCompleted(true),
    );
  }

  Future<void> resetOnboarding() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.setOnboardingCompleted(false),
    );
  }
}

class LanguagePreferenceNotifier extends AsyncNotifier<String?> {
  static const _key = 'preferred_language_code';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return null;
    return raw.trim().toLowerCase();
  }

  Future<void> setLanguage(String? code) async {
    // Prevent race with initial build() result overriding a just-selected language.
    await future;
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.trim().isEmpty) {
      await prefs.remove(_key);
      state = const AsyncData(null);
      return;
    }
    final normalized = code.trim().toLowerCase();
    await prefs.setString(_key, normalized);
    state = AsyncData(normalized);
  }
}
