import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/flutter_quest_app.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await AppEnv.initializeSupabaseIfConfigured();
  runApp(const ProviderScope(child: FlutterQuestApp()));
}
