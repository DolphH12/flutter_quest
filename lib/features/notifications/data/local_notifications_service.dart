import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

    await _plugin.initialize(settings: initSettings);

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
    final androidGranted =
        await androidImplementation?.requestNotificationsPermission() ?? true;

    return iosGranted && macGranted && androidGranted;
  }

  Future<bool> _canScheduleExactAlarms() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation == null) return false;
    try {
      final dynamic impl = androidImplementation;
      final bool? allowed = await impl.canScheduleExactNotifications();
      return allowed ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _requestExactAlarmsPermissionIfNeeded() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation == null) return;
    try {
      final dynamic impl = androidImplementation;
      await impl.requestExactAlarmsPermission();
    } catch (_) {
      // Unsupported on some Android versions/devices.
    }
  }

  Future<void> scheduleHabitReminder({
    required bool studiedToday,
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: habitReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var firstDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (studiedToday || !firstDate.isAfter(now)) {
      firstDate = firstDate.add(const Duration(days: 1));
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _habitChannelId,
        _habitChannelName,
        channelDescription: _habitChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    final isSpanish = languageCode.toLowerCase().startsWith('es');
    final title = isSpanish
        ? 'Tu racha te está esperando 🔥'
        : 'Your streak is waiting 🔥';
    final body = isSpanish
        ? 'Hoy toca un pasito más en Flutter Quest.'
        : 'Time for one more step in Flutter Quest today.';

    var scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    var canExact = await _canScheduleExactAlarms();
    if (!canExact) {
      await _requestExactAlarmsPermissionIfNeeded();
      canExact = await _canScheduleExactAlarms();
    }
    if (canExact) {
      scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }

    await _plugin.zonedSchedule(
      id: habitReminderId,
      title: title,
      body: body,
      scheduledDate: firstDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _habitPayload,
    );
  }

  Future<void> cancelHabitReminder() async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: habitReminderId);
  }
}
