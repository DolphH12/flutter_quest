import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/state/app_state_providers.dart';
import '../../notifications/state/habit_notifications_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _stepIndex = 0;
  bool _saving = false;
  String? _selectedLanguage;
  final bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final preferred = ref.read(preferredLanguageCodeProvider);
    _selectedLanguage = preferred;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const totalSteps = 6;
    final isLast = _stepIndex == totalSteps - 1;
    final canSkip = _stepIndex > 0 && !isLast;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_stepIndex + 1) / totalSteps,
                      borderRadius: FQRadius.pill,
                      minHeight: 8,
                      backgroundColor: FQColors.surfaceHigh,
                      color: FQColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_stepIndex + 1}/$totalSteps',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (canSkip)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _saving ? null : _finishOnboarding,
                    child: Text(l10n.onboardingSkipButton),
                  ),
                )
              else
                const SizedBox(height: 40),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    setState(() {
                      _stepIndex = value;
                    });
                  },
                  children: [
                    _WelcomeSetupStep(
                      nameController: _nameController,
                      selectedLanguage: _selectedLanguage,
                      onLanguageChanged: _handleLanguageChanged,
                    ),
                    _ImageInfoStep(
                      imageAsset: 'assets/images/route.png',
                      title: l10n.onboardingRoutesTitle,
                      body: l10n.onboardingRoutesBodyGeneral,
                    ),
                    _NodesDemoStep(
                      title: l10n.onboardingNodesTitle,
                      body: l10n.onboardingNodesBody,
                      completedLabel: l10n.onboardingNodeCompletedLabel,
                      nextLabel: l10n.onboardingNodeNextLabel,
                    ),
                    _ImageInfoStep(
                      imageAsset: 'assets/images/exp.png',
                      title: l10n.onboardingRewardsTitle,
                      body: l10n.onboardingRewardsBody,
                    ),
                    _ImageInfoStep(
                      imageAsset: 'assets/images/racha.png',
                      title: l10n.onboardingStreakTitle,
                      body: l10n.onboardingStreakBody,
                    ),
                    _FinalReadyStep(
                      imageAsset: 'assets/images/LOGO_FC.png',
                      title: l10n.onboardingAllSetTitle,
                      body: l10n.onboardingAllSetBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_stepIndex > 0)
                    Expanded(
                      child: FQSecondaryButton(
                        label: l10n.onboardingBackButton,
                        onPressed: _saving ? null : _goBack,
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FQPrimaryButton(
                      label: _saving
                          ? l10n.saveInProgress
                          : (isLast ? l10n.startButton : l10n.continueButton),
                      icon: isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _saving ? null : _onPrimaryPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimaryPressed() async {
    if (_stepIndex == 0) {
      await _saveInitialSetupAndContinue();
      return;
    }
    if (_stepIndex == 5) {
      await _finishOnboarding();
      return;
    }
    _goNext();
  }

  void _goNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_saving) return;
    setState(() => _saving = true);
    final progress = ref.read(appProgressNotifierProvider).valueOrNull;
    if (progress == null) {
      setState(() => _saving = false);
      return;
    }

    final cleanName = _nameController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (cleanName.isNotEmpty) {
      await ref
          .read(appProgressNotifierProvider.notifier)
          .setUserName(cleanName);
    }

    await ref
        .read(appProgressNotifierProvider.notifier)
        .setPreferredLanguage(_selectedLanguage);

    await ref
        .read(habitNotificationsProvider.notifier)
        .setEnabled(
          enabled: _notificationsEnabled,
          progress:
              ref.read(appProgressNotifierProvider).valueOrNull ?? progress,
          languageCode: ref.read(effectiveLanguageCodeProvider),
        );
    await ref.read(appPreferencesProvider.notifier).completeOnboarding();

    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _saveInitialSetupAndContinue() async {
    final l10n = AppLocalizations.of(context)!;
    final cleanName = _nameController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (cleanName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.nameRequiredError)));
      return;
    }

    final progress = ref.read(appProgressNotifierProvider).valueOrNull;
    if (progress == null) return;

    setState(() => _saving = true);
    await ref.read(appProgressNotifierProvider.notifier).setUserName(cleanName);
    if (!mounted) return;
    setState(() => _saving = false);
    _goNext();
  }

  Future<void> _handleLanguageChanged(String? value) async {
    if (_selectedLanguage == value) return;
    setState(() => _selectedLanguage = value);
    await ref
        .read(appProgressNotifierProvider.notifier)
        .setPreferredLanguage(value);
  }
}

class _WelcomeSetupStep extends StatelessWidget {
  const _WelcomeSetupStep({
    required this.nameController,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final TextEditingController nameController;
  final String? selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepFrame(
      gradient: FQGradients.subtlePanel,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              children: [
                const Spacer(),
                Image.asset('assets/images/hola_FC.png', height: 216),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: FQColors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.78),
                  ),
                ),
                const Spacer(),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(
                    labelText: l10n.nameInputLabel,
                    hintText: l10n.nameInputHint,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _LanguageIconMenu(
              selectedLanguage: selectedLanguage,
              onChanged: onLanguageChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageInfoStep extends StatelessWidget {
  const _ImageInfoStep({
    required this.imageAsset,
    required this.title,
    required this.body,
  });

  final String imageAsset;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      gradient: FQGradients.subtlePanel,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(imageAsset, height: 278),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _NodesDemoStep extends StatelessWidget {
  const _NodesDemoStep({
    required this.title,
    required this.body,
    required this.completedLabel,
    required this.nextLabel,
  });

  final String title;
  final String body;
  final String completedLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      gradient: FQGradients.subtlePanel,
      child: Column(
        children: [
          const Spacer(),
          _OnboardingNodePreview(
            completedLabel: completedLabel,
            nextLabel: nextLabel,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _OnboardingNodePreview extends StatelessWidget {
  const _OnboardingNodePreview({
    required this.completedLabel,
    required this.nextLabel,
  });

  final String completedLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DemoRouteNode(
            icon: Icons.check_rounded,
            outer: Color(0xFF0E6AA8),
            inner: Color(0xFF66BAFF),
            label: completedLabel,
          ),
          const SizedBox(width: 18),
          const SizedBox(
            width: 42,
            child: Divider(
              thickness: 6,
              color: Color(0xFFBFD2F2),
              endIndent: 4,
              indent: 4,
            ),
          ),
          const SizedBox(width: 18),
          _DemoRouteNode(
            icon: Icons.play_arrow_rounded,
            outer: Color(0xFF8D7D00),
            inner: Color(0xFFF4C900),
            label: nextLabel,
          ),
        ],
      ),
    );
  }
}

class _DemoRouteNode extends StatelessWidget {
  const _DemoRouteNode({
    required this.icon,
    required this.outer,
    required this.inner,
    required this.label,
  });

  final IconData icon;
  final Color outer;
  final Color inner;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 102,
          height: 102,
          decoration: BoxDecoration(shape: BoxShape.circle, color: outer),
          child: Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(shape: BoxShape.circle, color: inner),
              child: Icon(icon, color: FQColors.deepNavy, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _FinalReadyStep extends StatelessWidget {
  const _FinalReadyStep({
    required this.imageAsset,
    required this.title,
    required this.body,
  });

  final String imageAsset;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      gradient: FQGradients.subtlePanel,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(imageAsset, height: 220),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({required this.child, this.gradient});

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: SizedBox.expand(
        child: FQSurfaceCard(
          radius: FQRadius.xLarge,
          gradient: gradient,
          child: child,
        ),
      ),
    );
  }
}

class _LanguageIconMenu extends StatelessWidget {
  const _LanguageIconMenu({
    required this.selectedLanguage,
    required this.onChanged,
  });

  final String? selectedLanguage;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = selectedLanguage ?? 'auto';
    return PopupMenuButton<String>(
      tooltip: l10n.onboardingLanguageTitle,
      onSelected: (value) => onChanged(value == 'auto' ? null : value),
      shape: RoundedRectangleBorder(borderRadius: FQRadius.medium),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'auto',
          child: Text('${l10n.languageAuto}${current == 'auto' ? ' ✓' : ''}'),
        ),
        PopupMenuItem<String>(
          value: 'es',
          child: Text('${l10n.languageSpanish}${current == 'es' ? ' ✓' : ''}'),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Text('${l10n.languageEnglish}${current == 'en' ? ' ✓' : ''}'),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FQColors.primary.withValues(alpha: 0.12),
        ),
        child: const Icon(Icons.language_rounded, color: FQColors.primary),
      ),
    );
  }
}
