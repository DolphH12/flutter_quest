import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/flutter_quest_theme.dart';
import 'app_router.dart';
import 'global_badge_overlay.dart';

class FlutterQuestApp extends ConsumerWidget {
  const FlutterQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Quest',
      theme: FlutterQuestTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return GlobalBadgeOverlayHost(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
