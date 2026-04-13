import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning/models/learning_models.dart';
import '../data/local_notifications_service.dart';
import '../data/notification_preferences_repository.dart';
import '../models/habit_notification_settings.dart';

enum NotificationToggleResult { enabled, disabled, permissionDenied }

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((
  ref,
) {
  return LocalNotificationsService();
});

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      return NotificationPreferencesRepository();
    });

final habitNotificationsProvider =
    AsyncNotifierProvider<
      HabitNotificationsNotifier,
      HabitNotificationSettings
    >(HabitNotificationsNotifier.new);

class HabitNotificationsNotifier
    extends AsyncNotifier<HabitNotificationSettings> {
  NotificationPreferencesRepository get _preferences =>
      ref.read(notificationPreferencesRepositoryProvider);
  LocalNotificationsService get _notifications =>
      ref.read(localNotificationsServiceProvider);
  bool _bootstrapped = false;

  @override
  Future<HabitNotificationSettings> build() async {
    await _notifications.initialize();
    final settings = await _preferences.load();
    return settings.copyWith(
      hour: settings.hour <= 0
          ? HabitNotificationSettings.defaults.hour
          : settings.hour,
      minute: settings.minute < 0
          ? HabitNotificationSettings.defaults.minute
          : settings.minute,
    );
  }

  Future<void> bootstrapOnFirstAppOpen({
    required LearningProgressState progress,
    required String languageCode,
  }) async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final current = state.valueOrNull ?? await _preferences.load();
    final alreadyRequested = await _preferences.hasRequestedInitialPermission();

    if (!alreadyRequested) {
      final granted = await _notifications.requestPermissionsIfNeeded();
      await _preferences.markInitialPermissionRequested();
      final next = current.copyWith(enabled: granted);
      await _preferences.save(next);
      state = AsyncData(next);
      if (granted) {
        await _notifications.scheduleHabitReminder(
          studiedToday: _studiedToday(progress.lastStudyDate),
          hour: next.hour,
          minute: next.minute,
          languageCode: languageCode,
        );
      } else {
        await _notifications.cancelHabitReminder();
      }
      return;
    }

    if (current.enabled) {
      await _notifications.scheduleHabitReminder(
        studiedToday: _studiedToday(progress.lastStudyDate),
        hour: current.hour,
        minute: current.minute,
        languageCode: languageCode,
      );
    }
  }

  Future<NotificationToggleResult> setEnabled({
    required bool enabled,
    required LearningProgressState progress,
    required String languageCode,
  }) async {
    final current = state.valueOrNull ?? HabitNotificationSettings.defaults;
    state = const AsyncLoading();

    if (!enabled) {
      final next = current.copyWith(enabled: false);
      await _notifications.cancelHabitReminder();
      await _preferences.save(next);
      state = AsyncData(next);
      return NotificationToggleResult.disabled;
    }

    final granted = await _notifications.requestPermissionsIfNeeded();
    if (!granted) {
      final next = current.copyWith(enabled: false);
      await _notifications.cancelHabitReminder();
      await _preferences.save(next);
      state = AsyncData(next);
      return NotificationToggleResult.permissionDenied;
    }

    final next = current.copyWith(enabled: true);
    final studiedToday = _studiedToday(progress.lastStudyDate);
    await _notifications.scheduleHabitReminder(
      studiedToday: studiedToday,
      hour: next.hour,
      minute: next.minute,
      languageCode: languageCode,
    );
    await _preferences.save(next);
    state = AsyncData(next);
    return NotificationToggleResult.enabled;
  }

  Future<void> syncWithProgress({
    required LearningProgressState progress,
    required String languageCode,
  }) async {
    final current = state.valueOrNull;
    if (current == null || !current.enabled) return;
    await _notifications.scheduleHabitReminder(
      studiedToday: _studiedToday(progress.lastStudyDate),
      hour: current.hour,
      minute: current.minute,
      languageCode: languageCode,
    );
  }

  Future<void> clearAll() async {
    await _notifications.cancelHabitReminder();
    await _preferences.clear();
    state = const AsyncData(HabitNotificationSettings.defaults);
  }

  bool _studiedToday(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return false;
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return false;
    final now = DateTime.now();
    return parsed.year == now.year &&
        parsed.month == now.month &&
        parsed.day == now.day;
  }
}
