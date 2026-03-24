import '../models/learning_models.dart';
import 'local_progress_store.dart';

class ProgressRepository {
  ProgressRepository(this._store);

  final LocalProgressStore _store;

  Future<LearningProgressState> loadAndInitialize(DartRouteContent route) {
    return _store.ensureRouteInitialized(route);
  }

  Future<LearningProgressState> applyLessonResult({
    required LessonAttemptResult result,
    required DartRouteContent route,
  }) {
    return _store.applyLessonResult(result: result, route: route);
  }

  Future<LearningProgressState> setUserName({
    required String userName,
    required DartRouteContent route,
  }) {
    return _store.setUserName(userName: userName, route: route);
  }

  Future<LearningProgressState> resetAll({required DartRouteContent route}) {
    return _store.resetAll(route: route);
  }
}
