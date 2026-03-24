import 'package:flutter/material.dart';

import '../core/theme/flutter_quest_theme.dart';
import 'quest_shell.dart';

class FlutterQuestApp extends StatelessWidget {
  const FlutterQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Quest',
      theme: FlutterQuestTheme.light(),
      home: const QuestShell(),
    );
  }
}
