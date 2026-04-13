import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quest/l10n/app_localizations.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_buttons.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_progress_bar.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/data/badge_catalog.dart';
import '../../learning/state/app_state_providers.dart';
import '../../learning/state/lesson_session_provider.dart';
import '../widgets/activity_renderers.dart';
import '../widgets/quest_code_editor.dart';

class LessonFlowScreen extends ConsumerStatefulWidget {
  const LessonFlowScreen({
    super.key,
    required this.lesson,
    required this.onBack,
    this.onRouteCompleted,
  });

  final LessonContent lesson;
  final VoidCallback onBack;
  final ValueChanged<RouteCompletionResultData>? onRouteCompleted;

  @override
  ConsumerState<LessonFlowScreen> createState() => _LessonFlowScreenState();
}

class _LessonFlowScreenState extends ConsumerState<LessonFlowScreen> {
  final TextEditingController _codeController = TextEditingController();
  _LessonResultViewData? _resultData;
  bool _savingResult = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(lessonSessionProvider(widget.lesson));
    final activity = session.currentActivity;

    if (activity != null && _usesTextController(activity)) {
      if (_codeController.text != session.codeInput) {
        _codeController.value = TextEditingValue(
          text: session.codeInput,
          selection: TextSelection.collapsed(offset: session.codeInput.length),
        );
      }
    }

    return Column(
      children: [
        if (_resultData != null)
          Expanded(
            child: _LessonResultScreen(
              data: _resultData!,
              saving: _savingResult,
              onRepeat: () {
                _codeController.clear();
                ref.read(lessonSessionProvider(widget.lesson).notifier).reset();
                setState(() {
                  _resultData = null;
                });
              },
              onContinue: _onContinueFromResult,
            ),
          )
        else ...[
          _LessonTopBar(
            title: widget.lesson.nodeTitle,
            progress: session.progress,
            xpReward: widget.lesson.maxXp,
            onBack: widget.onBack,
            isExam: widget.lesson.isExam,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: activity == null
                  ? const SizedBox.shrink()
                  : _ActivityStep(
                      activity: activity,
                      session: session,
                      codeController: _codeController,
                      callbacks: ActivityRendererCallbacks(
                        onSelectOption: (value) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .selectOption(value);
                        },
                        onCodeChanged: (value) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .updateCodeInput(value);
                        },
                        onSelectWrongLine: (value) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .selectWrongLine(value);
                        },
                        onMoveBlockUp: (value) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .moveBlockUp(value);
                        },
                        onMoveBlockDown: (value) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .moveBlockDown(value);
                        },
                        onSetConceptMatch: (left, right) {
                          ref
                              .read(
                                lessonSessionProvider(widget.lesson).notifier,
                              )
                              .setConceptMatch(left: left, right: right);
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FQPrimaryButton(
              label: _primaryLabelFor(session, l10n),
              icon: Icons.arrow_forward_rounded,
              onPressed: _onPrimaryPressed,
            ),
          ),
        ],
      ],
    );
  }

  bool _usesTextController(LessonActivity activity) {
    return switch (activity.type) {
      ActivityType.multipleChoice => false,
      ActivityType.orderCodeBlocks => false,
      ActivityType.findTheWrongLine => false,
      ActivityType.matchConcept => false,
      ActivityType.predictOutput => !(activity.options?.isNotEmpty ?? false),
      ActivityType.intro => false,
      _ => true,
    };
  }

  Future<void> _onPrimaryPressed() async {
    final action = ref
        .read(lessonSessionProvider(widget.lesson).notifier)
        .onPrimaryPressed();
    if (action.message != null) {
      _showMessage(action.message!);
      return;
    }
    if (action.openResult) {
      _openResultScreen();
    }
  }

  void _openResultScreen() {
    final result = ref
        .read(lessonSessionProvider(widget.lesson).notifier)
        .buildResult();
    final total = result.totalAnswers;
    final safeTotal = total == 0 ? 1 : total;
    final rate = result.correctAnswers / safeTotal;
    final mood = rate >= 0.9
        ? _ResultMood.excellent
        : (rate >= 0.6 ? _ResultMood.good : _ResultMood.reinforce);
    setState(() {
      _resultData = _LessonResultViewData(mood: mood, result: result);
    });
  }

  Future<void> _onContinueFromResult() async {
    final resultData = _resultData;
    if (resultData == null || _savingResult) return;
    setState(() {
      _savingResult = true;
    });
    final result = resultData.result;
    final l10n = AppLocalizations.of(context)!;
    final update = await ref
        .read(appProgressNotifierProvider.notifier)
        .completeLesson(result);
    if (!mounted) return;
    final showRouteCelebration = update?.routeJustCompleted ?? false;

    if (showRouteCelebration) {
      final routes = ref.read(allRoutesProvider).valueOrNull;
      String routeTitle = l10n.routeCompleted;
      if (routes != null) {
        for (final route in routes) {
          if (route.routeId == result.routeId) {
            routeTitle = route.title;
            break;
          }
        }
      }
      widget.onRouteCompleted?.call(
        RouteCompletionResultData(
          routeId: result.routeId,
          routeTitle: routeTitle,
          xpEarned: result.xpEarned,
          correctCount: result.correctAnswers,
          totalAnswers: result.totalAnswers,
          unlockedBadgeIds: update?.newlyUnlockedBadgeIds ?? const [],
        ),
      );
      return;
    }

    widget.onBack();
  }

  void _showMessage(String message) {
    final l10n = AppLocalizations.of(context)!;
    final mappedMessage = switch (message) {
      'Selecciona una opción para verificar.' => l10n.quizSelectOptionError,
      'Selecciona la línea que consideras incorrecta.' =>
        l10n.quizSelectWrongLineError,
      'Elige la salida que esperas del código.' => l10n.quizSelectOutputError,
      'Escribe una respuesta antes de verificar.' => l10n.quizFixInputError,
      _ => message,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mappedMessage)));
  }

  String _primaryLabelFor(LessonSessionState session, AppLocalizations l10n) {
    final current = session.currentActivity;
    if (current == null) return l10n.finishButton;
    if (current.type == ActivityType.intro) {
      if (session.activityIndex == session.lesson.activities.length - 1) {
        return l10n.finishButton;
      }
      return l10n.continueButton;
    }
    if (!session.submitted) return l10n.verifyButton;
    if (session.activityIndex == session.lesson.activities.length - 1) {
      return l10n.finishButton;
    }
    return l10n.nextActivityButton;
  }
}

class RouteCompletionResultData {
  const RouteCompletionResultData({
    required this.routeId,
    required this.routeTitle,
    required this.xpEarned,
    required this.correctCount,
    required this.totalAnswers,
    required this.unlockedBadgeIds,
  });

  final String routeId;
  final String routeTitle;
  final int xpEarned;
  final int correctCount;
  final int totalAnswers;
  final List<String> unlockedBadgeIds;

  BadgeDefinition? get primaryBadge {
    for (final id in unlockedBadgeIds) {
      final badge = BadgeCatalog.byId(id);
      if (badge != null) return badge;
    }
    return null;
  }
}

class _LessonTopBar extends StatelessWidget {
  const _LessonTopBar({
    required this.title,
    required this.progress,
    required this.xpReward,
    required this.onBack,
    required this.isExam,
  });

  final String title;
  final double progress;
  final int xpReward;
  final VoidCallback? onBack;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            else
              const SizedBox(width: 48),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: FQColors.deepNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FQPill(
              label: '+$xpReward XP',
              icon: isExam ? Icons.military_tech_rounded : Icons.bolt_rounded,
              color: isExam
                  ? FQColors.tertiary.withValues(alpha: 0.36)
                  : FQColors.tertiary.withValues(alpha: 0.24),
              textColor: FQColors.tertiaryDark,
            ),
          ],
        ),
        const SizedBox(height: 8),
        FQProgressBar(value: progress),
      ],
    );
  }
}

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.activity,
    required this.session,
    required this.codeController,
    required this.callbacks,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final TextEditingController codeController;
  final ActivityRendererCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final isDesktop = FQBreakpoints.isDesktop(context);
    if (activity.type == ActivityType.intro) {
      return _IntroActivityStep(
        activity: activity,
        isExam: session.lesson.isExam,
        isDesktop: isDesktop,
      );
    }

    final title = switch (activity.type) {
      ActivityType.multipleChoice => activity.question ?? activity.prompt ?? '',
      ActivityType.predictOutput =>
        activity.question ?? activity.prompt ?? 'Predice la salida',
      ActivityType.matchConcept => activity.prompt ?? 'Relaciona los conceptos',
      ActivityType.orderCodeBlocks => activity.prompt ?? 'Ordena los bloques',
      ActivityType.findTheWrongLine =>
        activity.prompt ?? 'Encuentra la linea incorrecta',
      ActivityType.guidedWriting => activity.prompt ?? 'Escritura guiada',
      _ => activity.prompt ?? 'Completa el codigo',
    };
    final inlineCodeQuestion = _resolveInlineCodeQuestion(activity, title);

    if (isDesktop) {
      return FQSurfaceCard(
        radius: FQRadius.large,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: FQColors.deepNavy,
                      fontSize: 24,
                    ),
                  ),
                  if (inlineCodeQuestion != null) ...[
                    const SizedBox(height: 12),
                    QuestCodePreview(
                      content: inlineCodeQuestion,
                      fileName: 'question.dart',
                      minLines: 7,
                      maxHeight: 340,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonActivityRenderer(
                    activity: activity,
                    session: session,
                    codeController: codeController,
                    callbacks: callbacks,
                  ),
                  if (session.submitted) ...[
                    const SizedBox(height: 12),
                    LessonFeedbackCard(
                      isCorrect: session.lastValidationCorrect ?? false,
                      title: session.feedbackTitle ?? 'Feedback',
                      message:
                          session.feedbackMessage ??
                          'Revisa tu respuesta e intenta de nuevo.',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return FQSurfaceCard(
      radius: FQRadius.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.deepNavy,
              fontSize: 24,
            ),
          ),
          if (inlineCodeQuestion != null) ...[
            const SizedBox(height: 10),
            QuestCodePreview(
              content: inlineCodeQuestion,
              fileName: 'question.dart',
              minLines: 5,
              maxHeight: 240,
            ),
          ],
          const SizedBox(height: 12),
          LessonActivityRenderer(
            activity: activity,
            session: session,
            codeController: codeController,
            callbacks: callbacks,
          ),
          if (session.submitted) ...[
            const SizedBox(height: 12),
            LessonFeedbackCard(
              isCorrect: session.lastValidationCorrect ?? false,
              title: session.feedbackTitle ?? 'Feedback',
              message:
                  session.feedbackMessage ??
                  'Revisa tu respuesta e intenta de nuevo.',
            ),
          ],
        ],
      ),
    );
  }

  String? _resolveInlineCodeQuestion(LessonActivity activity, String title) {
    final codeSnippet = activity.codeSnippet?.trim();
    if (codeSnippet != null && codeSnippet.isNotEmpty) {
      return codeSnippet;
    }

    final candidate = (activity.question ?? activity.prompt ?? '').trim();
    if (!_looksLikeCode(candidate)) return null;
    if (_normalize(candidate) == _normalize(title)) return candidate;
    return candidate;
  }

  bool _looksLikeCode(String value) {
    if (!value.contains('\n')) return false;
    final markers = ['{', '}', ';', '=>', 'if (', 'for (', 'class ', 'void '];
    for (final marker in markers) {
      if (value.contains(marker)) return true;
    }
    return false;
  }

  String _normalize(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _IntroActivityStep extends StatelessWidget {
  const _IntroActivityStep({
    required this.activity,
    required this.isExam,
    required this.isDesktop,
  });

  final LessonActivity activity;
  final bool isExam;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final title = (activity.title ?? '').trim().isEmpty
        ? 'Introducción'
        : activity.title!.trim();
    final body = (activity.body ?? '').trim();
    final example = (activity.example ?? '').trim();
    if (isDesktop && example.isNotEmpty) {
      return FQSurfaceCard(
        radius: FQRadius.xLarge,
        gradient: isExam ? FQGradients.heroBlue : FQGradients.subtlePanel,
        useHighlightOverlay: !isExam,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isExam ? Colors.white : FQColors.deepNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 1.46,
                        color: isExam
                            ? Colors.white.withValues(alpha: 0.9)
                            : FQColors.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 6,
              child: QuestCodePreview(
                content: example,
                fileName: isExam ? 'exam_intro.dart' : 'lesson_intro.dart',
                minLines: 9,
                maxHeight: 420,
              ),
            ),
          ],
        ),
      );
    }
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: isExam ? FQGradients.heroBlue : FQGradients.subtlePanel,
      useHighlightOverlay: !isExam,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isExam ? Colors.white : FQColors.deepNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                height: 1.46,
                color: isExam
                    ? Colors.white.withValues(alpha: 0.9)
                    : FQColors.onSurface,
              ),
            ),
          ],
          if (example.isNotEmpty) ...[
            const SizedBox(height: 14),
            QuestCodePreview(
              content: example,
              fileName: isExam ? 'exam_intro.dart' : 'lesson_intro.dart',
              minLines: 6,
              maxHeight: 320,
            ),
          ],
        ],
      ),
    );
  }
}

enum _ResultMood { excellent, good, reinforce }

class _LessonResultViewData {
  const _LessonResultViewData({required this.mood, required this.result});

  final _ResultMood mood;
  final LessonAttemptResult result;
}

class _LessonResultScreen extends StatelessWidget {
  const _LessonResultScreen({
    required this.data,
    required this.saving,
    required this.onContinue,
    required this.onRepeat,
  });

  final _LessonResultViewData data;
  final bool saving;
  final VoidCallback onContinue;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = data.result;
    final isSuccess = result.passed;
    final precision = result.totalAnswers == 0
        ? 100
        : ((result.correctAnswers / result.totalAnswers) * 100).round();
    final imageAsset = isSuccess
        ? 'assets/images/felicitaciones_FC.png'
        : 'assets/images/fallaste_FC.png';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageAsset,
              width: 250,
              //height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            isSuccess ? l10n.excellentWork : l10n.keepTrying,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: FQColors.deepNavy,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSuccess ? l10n.lessonSuccessSubtitle : l10n.lessonFailSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FQColors.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: '+${result.xpEarned} XP',
                  label: l10n.experiencePoints,
                  valueColor: FQColors.tertiaryDark,
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  value: '$precision%',
                  label: l10n.accuracyLabel,
                  valueColor: FQColors.deepNavy,
                  icon: Icons.timer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FQSurfaceCard(
            radius: FQRadius.xLarge,
            color: Colors.white.withValues(alpha: 0.9),
            child: Text(
              isSuccess ? l10n.resultQuoteSuccess : l10n.resultQuoteFail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: FQColors.deepNavy,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FQPrimaryButton(
              label: saving ? l10n.saveInProgress : l10n.continueButton,
              icon: Icons.arrow_forward_rounded,
              onPressed: saving ? null : onContinue,
            ),
          ),
          if (!data.result.passed) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FQSecondaryButton(
                label: l10n.repeatButton,
                onPressed: saving ? null : onRepeat,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.icon,
  });

  final String value;
  final String label;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      color: Colors.white.withValues(alpha: 0.92),
      child: SizedBox(
        height: 116,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: valueColor),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: FQColors.deepNavy.withValues(alpha: 0.9),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
