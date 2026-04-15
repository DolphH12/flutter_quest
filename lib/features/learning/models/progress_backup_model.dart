import 'learning_models.dart';

class ProgressBackupModel {
  const ProgressBackupModel({
    required this.schemaVersion,
    required this.exportedAt,
    required this.progress,
    required this.preferredLanguageCode,
    required this.notificationsEnabled,
    required this.notificationHour,
    required this.notificationMinute,
  });

  final int schemaVersion;
  final String exportedAt;
  final LearningProgressState progress;
  final String? preferredLanguageCode;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;

  static const int currentSchemaVersion = 1;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt,
      'progress': progress.toJson(),
      'settings': {
        'preferredLanguageCode': preferredLanguageCode,
        'notifications': {
          'enabled': notificationsEnabled,
          'hour': notificationHour,
          'minute': notificationMinute,
        },
      },
    };
  }

  factory ProgressBackupModel.fromJson(Map<String, dynamic> json) {
    final schemaVersion = (json['schemaVersion'] as num?)?.toInt() ?? 0;
    if (schemaVersion <= 0 || schemaVersion > currentSchemaVersion) {
      throw FormatException('Unsupported backup schemaVersion: $schemaVersion');
    }
    final progressJson = json['progress'];
    if (progressJson is! Map<String, dynamic>) {
      throw const FormatException('Backup progress payload is missing');
    }
    final settings = json['settings'];
    final settingsMap = settings is Map<String, dynamic>
        ? settings
        : const <String, dynamic>{};
    final notifications = settingsMap['notifications'];
    final notificationsMap = notifications is Map<String, dynamic>
        ? notifications
        : const <String, dynamic>{};

    return ProgressBackupModel(
      schemaVersion: schemaVersion,
      exportedAt:
          (json['exportedAt'] as String?) ?? DateTime.now().toIso8601String(),
      progress: LearningProgressState.fromJson(progressJson),
      preferredLanguageCode: settingsMap['preferredLanguageCode'] as String?,
      notificationsEnabled: notificationsMap['enabled'] as bool? ?? false,
      notificationHour: (notificationsMap['hour'] as num?)?.toInt() ?? 10,
      notificationMinute: (notificationsMap['minute'] as num?)?.toInt() ?? 0,
    );
  }
}
