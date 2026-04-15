import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/progress_backup_model.dart';

class ProgressBackupService {
  Future<void> exportBackup(ProgressBackupModel backup) async {
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
      ),
    );
  }

  Future<ProgressBackupModel?> pickAndParseBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;
    String? raw;
    if (picked.bytes != null) {
      raw = utf8.decode(picked.bytes!);
    } else if (picked.path != null) {
      raw = await File(picked.path!).readAsString();
    }
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('Backup file is empty.');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup JSON.');
    }
    return ProgressBackupModel.fromJson(decoded);
  }
}
