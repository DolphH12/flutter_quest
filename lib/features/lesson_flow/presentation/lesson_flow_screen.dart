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
import '../../learning/state/app_state_providers.dart';
import '../../learning/state/lesson_session_provider.dart';
import '../widgets/activity_renderers.dart';
import '../widgets/quest_code_editor.dart';

class LessonFlowScreen extends ConsumerStatefulWidget {
  const LessonFlowScreen({
    super.key,
    required this.lesson,
    required this.onBack,
  });

  final LessonContent lesson;
  final VoidCallback onBack;

  @override
  ConsumerState<LessonFlowScreen> createState() => _LessonFlowScreenState();
}

class _LessonFlowScreenState extends ConsumerState<LessonFlowScreen> {
  final TextEditingController _codeController = TextEditingController();

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
          title: widget.lesson.nodeTitle,
          progress: session.stage == LessonSessionStage.intro
              ? 0
              : session.progress,
          xpReward: widget.lesson.maxXp,
          onBack: widget.onBack,
          isExam: widget.lesson.isExam,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: session.stage == LessonSessionStage.intro
              ? _LessonIntroStep(lesson: widget.lesson)
              : SingleChildScrollView(
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
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
                                  )
                                  .selectOption(value);
                            },
                            onCodeChanged: (value) {
                              ref
                                  .read(
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
                                  )
                                  .updateCodeInput(value);
                            },
                            onSelectWrongLine: (value) {
                              ref
                                  .read(
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
                                  )
                                  .selectWrongLine(value);
                            },
                            onMoveBlockUp: (value) {
                              ref
                                  .read(
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
                                  )
                                  .moveBlockUp(value);
                            },
                            onMoveBlockDown: (value) {
                              ref
                                  .read(
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
                                  )
                                  .moveBlockDown(value);
                            },
                            onSetConceptMatch: (left, right) {
                              ref
                                  .read(
                                    lessonSessionProvider(
                                      widget.lesson,
                                    ).notifier,
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
      await _showResultModal();
    }
  }

  Future<void> _showResultModal() async {
    final result = ref
        .read(lessonSessionProvider(widget.lesson).notifier)
        .buildResult();
    final total = result.totalAnswers;
    final safeTotal = total == 0 ? 1 : total;
    final rate = result.correctAnswers / safeTotal;
    final mood = rate >= 0.9
        ? _ResultMood.excellent
        : (rate >= 0.6 ? _ResultMood.good : _ResultMood.reinforce);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _LessonResultModal(
          mood: mood,
          correctCount: result.correctAnswers,
          total: total,
          xpEarned: result.xpEarned,
          passed: result.passed,
          isExam: result.isExam,
          requiredScore: result.requiredScore,
          onRepeat: () {
            Navigator.of(bottomSheetContext).pop();
            _codeController.clear();
            ref.read(lessonSessionProvider(widget.lesson).notifier).reset();
          },
          onContinue: () async {
            if (bottomSheetContext.mounted) {
              Navigator.of(bottomSheetContext).pop();
            }
            if (!mounted) return;

            final updated = await ref
                .read(appProgressNotifierProvider.notifier)
                .completeLesson(result);
            final showRouteCelebration =
                result.isExam &&
                result.passed &&
                (updated?.completedRouteIds.contains(result.routeId) ?? false);

            if (!mounted) return;
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
              await showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return _RouteCompletionDialog(routeTitle: routeTitle);
                },
              );
            }

            if (!mounted) return;
            widget.onBack();
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
  final VoidCallback onBack;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
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

class _LessonIntroStep extends StatelessWidget {
  const _LessonIntroStep({required this.lesson});

  final LessonContent lesson;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FQSurfaceCard(
        radius: FQRadius.xLarge,
        gradient: lesson.isExam
            ? FQGradients.heroBlue
            : FQGradients.subtlePanel,
        useHighlightOverlay: !lesson.isExam,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.introTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: lesson.isExam ? Colors.white : FQColors.deepNavy,
                fontSize: 34,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lesson.introBody,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.45,
                color: lesson.isExam
                    ? Colors.white.withValues(alpha: 0.9)
                    : FQColors.onSurface,
              ),
            ),
            if (lesson.isExam) ...[
              const SizedBox(height: 12),
              FQPill(
                label: 'Reto final de la ruta Dart',
                icon: Icons.flag_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                textColor: Colors.white,
              ),
            ],
            if (lesson.introExample != null) ...[
              const SizedBox(height: 14),
              QuestCodePreview(
                content: lesson.introExample!,
                fileName: lesson.isExam
                    ? 'exam_context.dart'
                    : 'lesson_intro.dart',
                minLines: 6,
                maxHeight: 320,
              ),
            ],
          ],
        ),
      ),
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

enum _ResultMood { excellent, good, reinforce }

class _LessonResultModal extends StatelessWidget {
  const _LessonResultModal({
    required this.mood,
    required this.correctCount,
    required this.total,
    required this.xpEarned,
    required this.passed,
    required this.isExam,
    required this.requiredScore,
    required this.onContinue,
    required this.onRepeat,
  });

  final _ResultMood mood;
  final int correctCount;
  final int total;
  final int xpEarned;
  final bool passed;
  final bool isExam;
  final double requiredScore;
  final VoidCallback onContinue;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final (title, message, icon, color) = switch (mood) {
      _ResultMood.excellent => (
        isExam ? 'Examen dominado' : 'Excelente',
        isExam
            ? 'Cerraste el examen con autoridad. Flutter Quest te respeta.'
            : 'Dominaste esta leccion con precision.',
        Icons.emoji_events_rounded,
        const Color(0xFF1D8D4A),
      ),
      _ResultMood.good => (
        isExam ? 'Examen aprobado' : 'Buen resultado',
        isExam
            ? 'Aprobaste el examen final. Base solida de Dart desbloqueada.'
            : 'Vas bien, sigue practicando para consolidar.',
        Icons.thumb_up_alt_rounded,
        const Color(0xFF2D79D8),
      ),
      _ResultMood.reinforce => (
        isExam ? 'Examen con refuerzo' : 'Necesita refuerzo',
        isExam
            ? 'Casi. Repite el examen y termina la ruta con confianza.'
            : 'Repite la leccion para reforzar conceptos clave.',
        Icons.school_rounded,
        const Color(0xFFC23737),
      ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: FQSurfaceCard(
          radius: FQRadius.xLarge,
          gradient: isExam ? FQGradients.heroBlue : FQGradients.subtlePanel,
          useHighlightOverlay: !isExam,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: isExam ? Colors.white : color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isExam ? Colors.white : FQColors.deepNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isExam
                      ? Colors.white.withValues(alpha: 0.9)
                      : FQColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Correctas: $correctCount / $total',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isExam ? Colors.white : FQColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Resultado: ${passed ? 'Aprobado' : 'No aprobado'} · requisito ${(requiredScore * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isExam
                      ? Colors.white.withValues(alpha: 0.9)
                      : (passed
                            ? const Color(0xFF1D8D4A)
                            : const Color(0xFFC23737)),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'XP ganada: +$xpEarned',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isExam ? Colors.white : FQColors.onSurface,
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 4),
                Text(
                  isExam
                      ? 'El examen final no se aprueba aun. Repite para cerrar la ruta.'
                      : 'Esta leccion no se marcara como completada hasta aprobar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isExam
                        ? Colors.white.withValues(alpha: 0.86)
                        : FQColors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FQPrimaryButton(
                  label: 'Volver a la ruta',
                  icon: Icons.arrow_back_rounded,
                  onPressed: onContinue,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FQSecondaryButton(label: 'Repetir', onPressed: onRepeat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteCompletionDialog extends StatelessWidget {
  const _RouteCompletionDialog({required this.routeTitle});

  final String routeTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: FQSurfaceCard(
        radius: FQRadius.xLarge,
        gradient: FQGradients.heroBlue,
        useHighlightOverlay: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Ruta completada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Completaste $routeTitle de principio a fin. Ya no improvisas: ahora construyes con criterio.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FQPill(
                  label: 'Badge desbloqueado',
                  icon: Icons.emoji_events_rounded,
                  color: Color(0x33FFFFFF),
                  textColor: Colors.white,
                ),
                FQPill(
                  label: '$routeTitle complete',
                  icon: Icons.check_circle_rounded,
                  color: Color(0x33FFFFFF),
                  textColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FQPrimaryButton(
                label: 'Seguir explorando',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
