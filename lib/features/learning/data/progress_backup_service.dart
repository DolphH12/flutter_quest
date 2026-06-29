import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/progress_backup_model.dart';

class ProgressBackupService {
  Future<void> exportBackup(
    ProgressBackupModel backup, {
    Rect? sharePositionOrigin,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'flutter_quest_backup_$timestamp.json';
    final file = File('${tempDir.path}/$fileName');
    final payload = const JsonEncoder.withIndent('  ').convert(backup.toJson());
    await file.writeAsString(payload, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Flutter Quest backup',
        subject: 'Flutter Quest backup',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<ProgressBackupModel?> pickAndParseBackup() async {
    const typeGroup = XTypeGroup(
      label: 'JSON backup',
      extensions: <String>['json'],
      mimeTypes: <String>['application/json'],
      uniformTypeIdentifiers: <String>['public.json'],
    );
    final picked = await openFile(acceptedTypeGroups: const <XTypeGroup>[typeGroup]);
    if (picked == null) return null;
    final raw = await picked.readAsString();
    if (raw.trim().isEmpty) {
      throw const FormatException('Backup file is empty.');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup JSON.');
    }
    return ProgressBackupModel.fromJson(decoded);
  }
}
