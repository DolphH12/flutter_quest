sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.debugDetails});

  final String message;
  final String? debugDetails;

  @override
  String toString() {
    if (debugDetails == null || debugDetails!.isEmpty) return message;
    return '$message | $debugDetails';
  }
}

class ContentFailure extends AppFailure {
  const ContentFailure(super.message, {super.debugDetails});
}

class PersistenceFailure extends AppFailure {
  const PersistenceFailure(super.message, {super.debugDetails});
}

class NotificationFailure extends AppFailure {
  const NotificationFailure(super.message, {super.debugDetails});
}

class BackupFailure extends AppFailure {
  const BackupFailure(super.message, {super.debugDetails});
}
