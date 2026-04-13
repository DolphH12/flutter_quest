import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit_notification_settings.dart';

class NotificationPreferencesRepository {
  static const _enabledKey = 'fq_habit_notifications_enabled';
  static const _hourKey = 'fq_habit_notifications_hour';
  static const _minuteKey = 'fq_habit_notifications_minute';
  static const _requestedPermissionKey =
      'fq_habit_notifications_permission_requested';

  Future<HabitNotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return HabitNotificationSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? HabitNotificationSettings.defaults.hour,
      minute:
          prefs.getInt(_minuteKey) ?? HabitNotificationSettings.defaults.minute,
    );
  }

  Future<void> save(HabitNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setInt(_hourKey, settings.hour);
    await prefs.setInt(_minuteKey, settings.minute);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_enabledKey);
    await prefs.remove(_hourKey);
    await prefs.remove(_minuteKey);
    await prefs.remove(_requestedPermissionKey);
  }

  Future<bool> hasRequestedInitialPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_requestedPermissionKey) ?? false;
  }

  Future<void> markInitialPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requestedPermissionKey, true);
  }
}
