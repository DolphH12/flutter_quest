import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';

import '../core/theme/flutter_quest_theme.dart';
import '../features/notifications/state/habit_notifications_provider.dart';
import '../features/learning/models/learning_models.dart';
import '../features/learning/state/app_state_providers.dart';
import 'app_router.dart';
import 'global_badge_overlay.dart';

class FlutterQuestApp extends ConsumerWidget {
  const FlutterQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    ref.watch(habitNotificationsProvider);

    ref.listen<AsyncValue<LearningProgressState>>(appProgressNotifierProvider, (
      _,
      next,
    ) {
      final progress = next.valueOrNull;
      if (progress == null) return;
      final languageCode = ref.read(effectiveLanguageCodeProvider);
      ref
          .read(habitNotificationsProvider.notifier)
          .syncWithProgress(progress: progress, languageCode: languageCode);
    });

    ref.listen<String>(effectiveLanguageCodeProvider, (_, languageCode) {
      final progress = ref.read(appProgressNotifierProvider).valueOrNull;
      if (progress == null) return;
      ref
          .read(habitNotificationsProvider.notifier)
          .syncWithProgress(progress: progress, languageCode: languageCode);
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Flutter Quest',
      theme: FlutterQuestTheme.light(),
      routerConfig: router,
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return GlobalBadgeOverlayHost(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
