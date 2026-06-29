import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'habit_reminder_message_bank.dart';

class LocalNotificationsService {
  LocalNotificationsService();

  static const int habitReminderId = 7001;
  static const String _habitChannelId = 'fq_habit_daily';
  static const String _habitChannelName = 'Flutter Quest Habit';
  static const String _habitChannelDescription =
      'Daily reminders to maintain your learning streak.';
  static const String _habitPayload = 'habit_daily';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Keep default timezone configuration when platform lookup fails.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (_) {},
      onDidReceiveBackgroundNotificationResponse: _noopBackgroundCallback,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _habitChannelId,
        _habitChannelName,
        description: _habitChannelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermissionsIfNeeded() async {
    if (kIsWeb) return false;
    await initialize();

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final iosGranted =
        await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final macGranted =
        await macImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final androidGranted = await androidImplementation
        ?.requestNotificationsPermission();

    return iosGranted && macGranted && (androidGranted ?? true);
  }

  Future<void> scheduleHabitReminder({
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: habitReminderId);

    final firstDate = _nextInstanceOfTime(hour, minute);
    final reminder = HabitReminderMessageBank.pickForLanguage(languageCode);

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _habitChannelId,
        _habitChannelName,
        channelDescription: _habitChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: habitReminderId,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: firstDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _habitPayload,
    );
  }

  Future<void> cancelHabitReminder() async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: habitReminderId);
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    if (kIsWeb) return const [];
    await initialize();
    return _plugin.pendingNotificationRequests();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

@pragma('vm:entry-point')
void _noopBackgroundCallback(NotificationResponse _) {}
