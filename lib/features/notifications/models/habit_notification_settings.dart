class HabitNotificationSettings {
  const HabitNotificationSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  static const HabitNotificationSettings defaults = HabitNotificationSettings(
    enabled: false,
    hour: 10,
    minute: 0,
  );

  HabitNotificationSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return HabitNotificationSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
