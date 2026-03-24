import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_models.dart';

enum LessonSessionStage { intro, activity }

class LessonSessionState {
  const LessonSessionState({
    required this.lesson,
    required this.stage,
    required this.activityIndex,
    required this.correctCount,
    required this.potentialXp,
    required this.selectedOptionIndex,
    required this.selectedWrongLineIndex,
    required this.codeInput,
    required this.blockOrder,
    required this.conceptMatches,
    required this.submitted,
    required this.lastValidationCorrect,
    required this.feedbackTitle,
    required this.feedbackMessage,
    required this.completed,
  });

  final LessonContent lesson;
  final LessonSessionStage stage;
  final int activityIndex;
  final int correctCount;
  final int potentialXp;

  final int? selectedOptionIndex;
  final int? selectedWrongLineIndex;
  final String codeInput;
  final List<int> blockOrder;
  final Map<String, String> conceptMatches;

  final bool submitted;
  final bool? lastValidationCorrect;
  final String? feedbackTitle;
  final String? feedbackMessage;
  final bool completed;

  LessonActivity? get currentActivity {
    if (lesson.activities.isEmpty) return null;
    if (activityIndex < 0 || activityIndex >= lesson.activities.length) {
      return null;
    }
    return lesson.activities[activityIndex];
  }

  double get progress {
    if (lesson.activities.isEmpty) return 1;
    return (activityIndex + 1) / lesson.activities.length;
  }

  String get primaryLabel {
    if (stage == LessonSessionStage.intro) {
      return lesson.isExam ? 'Comenzar examen' : 'Comenzar actividad';
    }
    if (!submitted) return 'Verificar';
    if (activityIndex == lesson.activities.length - 1) return 'Finalizar';
    return 'Siguiente actividad';
  }

  LessonSessionState copyWith({
    LessonSessionStage? stage,
    int? activityIndex,
    int? correctCount,
    int? potentialXp,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    int? selectedWrongLineIndex,
    bool clearSelectedWrongLine = false,
    String? codeInput,
    List<int>? blockOrder,
    Map<String, String>? conceptMatches,
    bool clearConceptMatches = false,
    bool? submitted,
    bool? lastValidationCorrect,
    bool clearLastValidation = false,
    String? feedbackTitle,
    bool clearFeedbackTitle = false,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
    bool? completed,
  }) {
    return LessonSessionState(
      lesson: lesson,
      stage: stage ?? this.stage,
      activityIndex: activityIndex ?? this.activityIndex,
      correctCount: correctCount ?? this.correctCount,
      potentialXp: potentialXp ?? this.potentialXp,
      selectedOptionIndex: clearSelectedOption
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      selectedWrongLineIndex: clearSelectedWrongLine
          ? null
          : (selectedWrongLineIndex ?? this.selectedWrongLineIndex),
      codeInput: codeInput ?? this.codeInput,
      blockOrder: blockOrder ?? this.blockOrder,
      conceptMatches: clearConceptMatches
          ? <String, String>{}
          : (conceptMatches ?? this.conceptMatches),
      submitted: submitted ?? this.submitted,
      lastValidationCorrect: clearLastValidation
          ? null
          : (lastValidationCorrect ?? this.lastValidationCorrect),
      feedbackTitle: clearFeedbackTitle
          ? null
          : (feedbackTitle ?? this.feedbackTitle),
      feedbackMessage: clearFeedbackMessage
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      completed: completed ?? this.completed,
    );
  }

  factory LessonSessionState.initial(LessonContent lesson) {
    return LessonSessionState(
      lesson: lesson,
      stage: LessonSessionStage.intro,
      activityIndex: 0,
      correctCount: 0,
      potentialXp: 0,
      selectedOptionIndex: null,
      selectedWrongLineIndex: null,
      codeInput: '',
      blockOrder: const <int>[],
      conceptMatches: const <String, String>{},
      submitted: false,
      lastValidationCorrect: null,
      feedbackTitle: null,
      feedbackMessage: null,
      completed: false,
    );
  }
}

class LessonPrimaryActionResult {
  const LessonPrimaryActionResult({this.message, this.openResult = false});

  final String? message;
  final bool openResult;
}

final lessonSessionProvider =
    AutoDisposeNotifierProviderFamily<
      LessonSessionNotifier,
      LessonSessionState,
      LessonContent
    >(LessonSessionNotifier.new);

class LessonSessionNotifier
    extends AutoDisposeFamilyNotifier<LessonSessionState, LessonContent> {
  @override
  LessonSessionState build(LessonContent arg) {
    return LessonSessionState.initial(arg);
  }

  void selectOption(int index) {
    if (state.submitted) return;
    state = state.copyWith(selectedOptionIndex: index);
  }

  void selectWrongLine(int index) {
    if (state.submitted) return;
    state = state.copyWith(selectedWrongLineIndex: index);
  }

  void updateCodeInput(String value) {
    if (state.submitted) return;
    state = state.copyWith(codeInput: value);
  }

  void moveBlockUp(int position) {
    if (state.submitted) return;
    if (position <= 0 || position >= state.blockOrder.length) return;
    final next = [...state.blockOrder];
    final current = next[position];
    next[position] = next[position - 1];
    next[position - 1] = current;
    state = state.copyWith(blockOrder: next);
  }

  void moveBlockDown(int position) {
    if (state.submitted) return;
    if (position < 0 || position >= state.blockOrder.length - 1) return;
    final next = [...state.blockOrder];
    final current = next[position];
    next[position] = next[position + 1];
    next[position + 1] = current;
    state = state.copyWith(blockOrder: next);
  }

  void setConceptMatch({required String left, required String right}) {
    if (state.submitted) return;
    final matches = {...state.conceptMatches, left: right};
    state = state.copyWith(conceptMatches: matches);
  }

  void reset() {
    state = LessonSessionState.initial(state.lesson);
  }

  LessonPrimaryActionResult onPrimaryPressed() {
    if (state.stage == LessonSessionStage.intro) {
      if (state.lesson.activities.isEmpty) {
        state = state.copyWith(completed: true);
        return const LessonPrimaryActionResult(openResult: true);
      }
      _prepareActivityState(0);
      state = state.copyWith(stage: LessonSessionStage.activity);
      return const LessonPrimaryActionResult();
    }

    if (!state.submitted) {
      final validation = _validateCurrent();
      if (validation.error != null) {
        return LessonPrimaryActionResult(message: validation.error);
      }
      state = state.copyWith(
        submitted: true,
        lastValidationCorrect: validation.isCorrect,
        feedbackTitle: validation.feedbackTitle,
        feedbackMessage: validation.feedbackMessage,
        correctCount: validation.isCorrect
            ? state.correctCount + 1
            : state.correctCount,
        potentialXp: validation.isCorrect
            ? state.potentialXp + (state.currentActivity?.xpReward ?? 0)
            : state.potentialXp,
      );
      return const LessonPrimaryActionResult();
    }

    if (state.activityIndex == state.lesson.activities.length - 1) {
      state = state.copyWith(completed: true);
      return const LessonPrimaryActionResult(openResult: true);
    }

    final nextIndex = state.activityIndex + 1;
    _prepareActivityState(nextIndex);
    state = state.copyWith(
      activityIndex: nextIndex,
      submitted: false,
      clearLastValidation: true,
      clearFeedbackTitle: true,
      clearFeedbackMessage: true,
    );
    return const LessonPrimaryActionResult();
  }

  LessonAttemptResult buildResult() {
    final total = state.lesson.activities.length;
    final safeTotal = total == 0 ? 1 : total;
    final score = state.correctCount / safeTotal;
    final required = state.lesson.passThreshold;
    final passed = score >= required;
    final awardedXp = passed ? state.potentialXp : 0;
    return LessonAttemptResult(
      lessonId: state.lesson.id,
      routeId: state.lesson.routeId,
      nodeId: state.lesson.nodeId,
      correctAnswers: state.correctCount,
      totalAnswers: total,
      xpEarned: awardedXp,
      completedAt: DateTime.now(),
      passed: passed,
      isExam: state.lesson.isExam,
      requiredScore: required,
    );
  }

  void _prepareActivityState(int index) {
    final activity = (index >= 0 && index < state.lesson.activities.length)
        ? state.lesson.activities[index]
        : null;
    final blockOrder = _seedBlockOrder(activity);
    final codeInput = _seedCodeForActivity(activity);

    state = state.copyWith(
      activityIndex: index,
      clearSelectedOption: true,
      clearSelectedWrongLine: true,
      codeInput: codeInput,
      blockOrder: blockOrder,
      clearConceptMatches: true,
    );
  }

  List<int> _seedBlockOrder(LessonActivity? activity) {
    if (activity == null || activity.type != ActivityType.orderCodeBlocks) {
      return const <int>[];
    }
    final blocks = activity.blocks ?? const <String>[];
    if (blocks.isEmpty) return const <int>[];
    return List<int>.generate(
      blocks.length,
      (index) => blocks.length - 1 - index,
    );
  }

  String _seedCodeForActivity(LessonActivity? activity) {
    if (activity == null) return '';
    return switch (activity.type) {
      ActivityType.multipleChoice => '',
      ActivityType.orderCodeBlocks => '',
      ActivityType.findTheWrongLine => '',
      ActivityType.matchConcept => '',
      ActivityType.predictOutput =>
        (activity.options?.isNotEmpty ?? false)
            ? ''
            : (activity.initialCode ?? activity.codeSnippet ?? ''),
      ActivityType.guidedWriting =>
        activity.starterCode ?? activity.initialCode ?? '',
      _ => activity.initialCode ?? '',
    };
  }

  _ValidationResult _validateCurrent() {
    final activity = state.currentActivity;
    if (activity == null) {
      return const _ValidationResult(
        isCorrect: false,
        error: null,
        feedbackTitle: 'Sin actividad',
        feedbackMessage: 'No encontramos una actividad para validar.',
      );
    }

    switch (activity.type) {
      case ActivityType.multipleChoice:
        return _validateMultipleChoice(activity);
      case ActivityType.fillInTheCode:
      case ActivityType.fixTheBug:
      case ActivityType.completeSnippet:
        return _validateCodeByExpectedAnswer(activity);
      case ActivityType.orderCodeBlocks:
        return _validateOrderBlocks(activity);
      case ActivityType.findTheWrongLine:
        return _validateWrongLine(activity);
      case ActivityType.matchConcept:
        return _validateMatchConcept(activity);
      case ActivityType.predictOutput:
        return _validatePredictOutput(activity);
      case ActivityType.guidedWriting:
        return _validateGuidedWriting(activity);
      case ActivityType.intro:
      case ActivityType.unknown:
        return const _ValidationResult(
          isCorrect: true,
          error: null,
          feedbackTitle: 'Seguimos',
          feedbackMessage: 'Paso de teoría completado.',
        );
    }
  }

  _ValidationResult _validateMultipleChoice(LessonActivity activity) {
    if (state.selectedOptionIndex == null) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Selecciona una opción para verificar.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }
    final options = activity.options ?? const <String>[];
    if (state.selectedOptionIndex! < 0 ||
        state.selectedOptionIndex! >= options.length) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Esa opción no es válida.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    final selected = options[state.selectedOptionIndex!];
    final correct = (activity.correctAnswer ?? '').trim();
    final isCorrect = selected.trim() == correct;
    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validateCodeByExpectedAnswer(LessonActivity activity) {
    final answer = state.codeInput.trim();
    if (answer.isEmpty) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Completa el código antes de verificar.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    final expected = (activity.expectedAnswer ?? '').trim();
    final initial = activity.initialCode ?? '';

    if (expected.isEmpty) {
      final feedback = _feedbackFor(activity: activity, isCorrect: false);
      return _ValidationResult(
        isCorrect: false,
        error: null,
        feedbackTitle: feedback.$1,
        feedbackMessage: feedback.$2,
      );
    }

    final isCorrect = initial.contains('_____')
        ? (() {
            final expectedFull = initial.replaceFirst('_____', expected);
            return _normalize(answer) == _normalize(expectedFull) ||
                _normalize(answer) == _normalize(expected);
          })()
        : _normalize(answer) == _normalize(expected);

    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validateOrderBlocks(LessonActivity activity) {
    final blocks = activity.blocks ?? const <String>[];
    if (blocks.isEmpty) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'No hay bloques para ordenar en esta actividad.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }
    if (state.blockOrder.length != blocks.length) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Organiza todos los bloques antes de verificar.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    final expected =
        activity.correctOrder ??
        List<int>.generate(blocks.length, (index) => index);
    final isCorrect = _listEquals(state.blockOrder, expected);
    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validateWrongLine(LessonActivity activity) {
    if (state.selectedWrongLineIndex == null) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Selecciona la línea que consideras incorrecta.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }
    final expected = activity.wrongLineIndex;
    final isCorrect =
        expected != null && expected == state.selectedWrongLineIndex;
    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validateMatchConcept(LessonActivity activity) {
    final left = activity.matchLeft ?? const <String>[];
    final expected = activity.correctMatches ?? const <String, String>{};

    if (left.isEmpty || expected.isEmpty) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'No hay pares de concepto configurados en esta actividad.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    for (final key in left) {
      if ((state.conceptMatches[key] ?? '').trim().isEmpty) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Relaciona todos los conceptos antes de verificar.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
    }

    final isCorrect = left.every(
      (key) =>
          (state.conceptMatches[key] ?? '').trim() ==
          (expected[key] ?? '').trim(),
    );
    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validatePredictOutput(LessonActivity activity) {
    final expected = (activity.expectedOutput ?? activity.expectedAnswer ?? '')
        .trim();
    if (expected.isEmpty) {
      final feedback = _feedbackFor(activity: activity, isCorrect: false);
      return _ValidationResult(
        isCorrect: false,
        error: null,
        feedbackTitle: feedback.$1,
        feedbackMessage: feedback.$2,
      );
    }

    final options = activity.options ?? const <String>[];
    late final bool isCorrect;
    if (options.isNotEmpty) {
      if (state.selectedOptionIndex == null) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Elige la salida que esperas del código.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      if (state.selectedOptionIndex! < 0 ||
          state.selectedOptionIndex! >= options.length) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'La opción seleccionada no es válida.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      isCorrect =
          _normalize(options[state.selectedOptionIndex!]) ==
          _normalize(expected);
    } else {
      final answer = state.codeInput.trim();
      if (answer.isEmpty) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Escribe tu predicción de salida antes de verificar.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      isCorrect = _normalize(answer) == _normalize(expected);
    }

    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validateGuidedWriting(LessonActivity activity) {
    final answer = state.codeInput.trim();
    if (answer.isEmpty) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Escribe tu solución antes de verificar.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    final fragments = activity.expectedFragments ?? const <String>[];
    final expected = (activity.expectedAnswer ?? '').trim();

    final normalizedAnswer = answer.toLowerCase();
    final fragmentsPass =
        fragments.isNotEmpty &&
        fragments.every(
          (part) => normalizedAnswer.contains(part.toLowerCase().trim()),
        );
    final exactPass =
        expected.isNotEmpty && _normalize(answer) == _normalize(expected);
    final isCorrect = fragmentsPass || exactPass;

    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  (String, String) _feedbackFor({
    required LessonActivity activity,
    required bool isCorrect,
  }) {
    final title = isCorrect
        ? _positiveTitle(activity.type)
        : _negativeTitle(activity.type);

    final explanation = isCorrect
        ? (activity.correctExplanation ??
              'Bien jugado. Ese concepto quedó claro.')
        : (activity.incorrectExplanation ??
              'Casi, pero aquí Dart te puso una zancadilla. Revisa la pista y vuelve a intentar.');

    final didacticTail = isCorrect
        ? 'Sigue así, ya estás pensando como dev.'
        : 'Lee la explicación, ajusta y vuelve a verificar.';

    return (title, '$explanation\n\n$didacticTail');
  }

  String _positiveTitle(ActivityType type) {
    return switch (type) {
      ActivityType.multipleChoice => 'Bien jugado',
      ActivityType.fillInTheCode => 'Código en orden',
      ActivityType.fixTheBug => 'Ese bug ya no te asusta',
      ActivityType.completeSnippet => 'Snippet completo',
      ActivityType.orderCodeBlocks => 'Secuencia impecable',
      ActivityType.findTheWrongLine => 'Ojo clínico activado',
      ActivityType.matchConcept => 'Conceptos conectados',
      ActivityType.predictOutput => 'Predicción precisa',
      ActivityType.guidedWriting => 'Escritura sólida',
      _ => 'Excelente',
    };
  }

  String _negativeTitle(ActivityType type) {
    return switch (type) {
      ActivityType.multipleChoice => 'Casi, pero venía con trampa',
      ActivityType.fillInTheCode => 'Te faltó una pieza',
      ActivityType.fixTheBug => 'Aquí fue donde Dart te puso la zancadilla',
      ActivityType.completeSnippet => 'Snippet incompleto',
      ActivityType.orderCodeBlocks => 'El orden manda',
      ActivityType.findTheWrongLine => 'No era esa línea',
      ActivityType.matchConcept => 'Cruce incorrecto',
      ActivityType.predictOutput => 'Salida inesperada',
      ActivityType.guidedWriting => 'Necesita un ajuste más',
      _ => 'Todavía no',
    };
  }

  String _normalize(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _ValidationResult {
  const _ValidationResult({
    required this.isCorrect,
    required this.error,
    required this.feedbackTitle,
    required this.feedbackMessage,
  });

  final bool isCorrect;
  final String? error;
  final String? feedbackTitle;
  final String? feedbackMessage;
}
