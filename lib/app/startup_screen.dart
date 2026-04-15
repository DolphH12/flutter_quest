import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/fq_page_container.dart';
import '../core/widgets/fq_state_views.dart';
import '../features/learning/state/app_state_providers.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final progress = ref.watch(appProgressNotifierProvider);
    if (preferences.isLoading || progress.isLoading) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (preferences.hasError || progress.hasError) {
      final l10n = AppLocalizations.of(context)!;
      return FQPageContainer(
        child: Center(
          child: FQErrorState(
            title: l10n.initializationErrorTitle,
            message: '${preferences.error ?? ''} ${progress.error ?? ''}'
                .trim(),
            primaryActionLabel: l10n.retryButton,
            onPrimaryAction: () {
              ref.invalidate(appPreferencesProvider);
              ref.read(appProgressNotifierProvider.notifier).loadProgress();
            },
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingDone =
          preferences.valueOrNull?.hasCompletedOnboarding ?? false;
      if (onboardingDone) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });

    return const FQPageContainer(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
