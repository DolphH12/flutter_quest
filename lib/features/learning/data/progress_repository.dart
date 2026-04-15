import '../models/learning_models.dart';
import 'local_progress_store.dart';

class ProgressRepository {
  ProgressRepository(this._store);

  final LocalProgressStore _store;

  Future<LearningProgressState> loadAndInitialize(DartRouteContent route) {
    return _store.ensureRouteInitialized(route);
  }

  Future<LearningProgressState> loadAndInitializeAll(
    List<DartRouteContent> routes,
  ) {
    return _store.ensureRoutesInitialized(routes);
  }

  Future<LearningProgressState> applyLessonResult({
    required LessonAttemptResult result,
    required DartRouteContent route,
  }) {
    return _store.applyLessonResult(result: result, route: route);
  }

  Future<LearningProgressState> setUserName({
    required String userName,
    required List<DartRouteContent> routes,
  }) {
    return _store.setUserName(userName: userName, routes: routes);
  }

  Future<LearningProgressState> resetAll({
    required List<DartRouteContent> routes,
  }) {
    return _store.resetAll(routes: routes);
  }

  Future<LearningProgressState> importProgress({
    required LearningProgressState imported,
    required List<DartRouteContent> routes,
  }) {
    return _store.importProgress(imported: imported, routes: routes);
  }
}
