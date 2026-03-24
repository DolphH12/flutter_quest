import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        _LessonTopBar(
          title: _resultData == null ? widget.lesson.nodeTitle : 'Resultado',
          progress: _resultData == null ? session.progress : 1,
          xpReward: widget.lesson.maxXp,
          onBack: _resultData == null ? widget.onBack : null,
          isExam: widget.lesson.isExam,
        ),
        const SizedBox(height: 12),
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
              label: session.primaryLabel,
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
      _resultData = _LessonResultViewData(
        mood: mood,
        result: result,
      );
    });
  }

  Future<void> _onContinueFromResult() async {
    final resultData = _resultData;
    if (resultData == null || _savingResult) return;
    setState(() {
      _savingResult = true;
    });
    final result = resultData.result;
    final update = await ref
        .read(appProgressNotifierProvider.notifier)
        .completeLesson(result);
    if (!mounted) return;
    final showRouteCelebration = update?.routeJustCompleted ?? false;

    if (showRouteCelebration) {
      final routes = ref.read(allRoutesProvider).valueOrNull;
      String routeTitle = 'Ruta';
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    if (activity.type == ActivityType.intro) {
      return _IntroActivityStep(activity: activity, isExam: session.lesson.isExam);
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
  const _IntroActivityStep({required this.activity, required this.isExam});

  final LessonActivity activity;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    final title = (activity.title ?? '').trim().isEmpty
        ? 'Introducción'
        : activity.title!.trim();
    final body = (activity.body ?? '').trim();
    final example = (activity.example ?? '').trim();
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
    final result = data.result;
    final (title, message, icon, color) = switch (data.mood) {
      _ResultMood.excellent => (
        result.isExam ? 'Examen dominado' : 'Excelente',
        result.isExam
            ? 'Cerraste el examen con autoridad. Flutter Quest te respeta.'
            : 'Dominaste esta leccion con precision.',
        Icons.emoji_events_rounded,
        const Color(0xFF1D8D4A),
      ),
      _ResultMood.good => (
        result.isExam ? 'Examen aprobado' : 'Buen resultado',
        result.isExam
            ? 'Aprobaste el examen final. Base solida de Dart desbloqueada.'
            : 'Vas bien, sigue practicando para consolidar.',
        Icons.thumb_up_alt_rounded,
        const Color(0xFF2D79D8),
      ),
      _ResultMood.reinforce => (
        result.isExam ? 'Examen con refuerzo' : 'Necesita refuerzo',
        result.isExam
            ? 'Casi. Repite el examen y termina la ruta con confianza.'
            : 'Repite la leccion para reforzar conceptos clave.',
        Icons.school_rounded,
        const Color(0xFFC23737),
      ),
    };

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: FQSurfaceCard(
              radius: FQRadius.xLarge,
              gradient: result.isExam
                  ? FQGradients.heroBlue
                  : FQGradients.subtlePanel,
              useHighlightOverlay: !result.isExam,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: result.isExam ? Colors.white : color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: result.isExam
                                    ? Colors.white
                                    : FQColors.deepNavy,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: result.isExam
                          ? Colors.white.withValues(alpha: 0.9)
                          : FQColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Correctas: ${result.correctAnswers} / ${result.totalAnswers}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: result.isExam ? Colors.white : FQColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Resultado: ${result.passed ? 'Aprobado' : 'No aprobado'} · requisito ${(result.requiredScore * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: result.isExam
                          ? Colors.white.withValues(alpha: 0.9)
                          : (result.passed
                                ? const Color(0xFF1D8D4A)
                                : const Color(0xFFC23737)),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'XP ganada: +${result.xpEarned}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: result.isExam ? Colors.white : FQColors.onSurface,
                    ),
                  ),
                  if (!result.passed) ...[
                    const SizedBox(height: 4),
                    Text(
                      result.isExam
                          ? 'El examen final no se aprueba aun. Repite para cerrar la ruta.'
                          : 'Esta leccion no se marcara como completada hasta aprobar.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: result.isExam
                            ? Colors.white.withValues(alpha: 0.86)
                            : FQColors.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FQPrimaryButton(
            label: saving ? 'Guardando...' : 'Volver a la ruta',
            icon: Icons.arrow_back_rounded,
            onPressed: saving ? null : onContinue,
          ),
        ),
        if (!data.result.passed) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FQSecondaryButton(
              label: 'Repetir',
              onPressed: saving ? null : onRepeat,
            ),
          ),
        ],
      ],
    );
  }
}
