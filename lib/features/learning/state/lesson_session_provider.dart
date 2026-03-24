import 'dart:math';
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
    required this.optionOrder,
    required this.matchRightOptions,
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
  final List<int> optionOrder;
  final List<String> matchRightOptions;
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
    List<int>? optionOrder,
    List<String>? matchRightOptions,
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
      optionOrder: optionOrder ?? this.optionOrder,
      matchRightOptions: matchRightOptions ?? this.matchRightOptions,
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
      optionOrder: const <int>[],
      matchRightOptions: const <String>[],
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
    final optionOrder = _seedOptionOrder(activity);
    final matchRightOptions = _seedMatchRightOptions(activity);
    final codeInput = _seedCodeForActivity(activity);

    state = state.copyWith(
      activityIndex: index,
      clearSelectedOption: true,
      clearSelectedWrongLine: true,
      codeInput: codeInput,
      blockOrder: blockOrder,
      optionOrder: optionOrder,
      matchRightOptions: matchRightOptions,
      clearConceptMatches: true,
    );
  }

  List<int> _seedBlockOrder(LessonActivity? activity) {
    if (activity == null || activity.type != ActivityType.orderCodeBlocks) {
      return const <int>[];
    }
    final blocks = activity.blocks ?? const <String>[];
    if (blocks.isEmpty) return const <int>[];
    final seeded = List<int>.generate(blocks.length, (index) => index);
    if (activity.shuffle) {
      seeded.shuffle(Random());
    }
    return seeded;
  }

  List<int> _seedOptionOrder(LessonActivity? activity) {
    if (activity == null) return const <int>[];
    if (activity.type != ActivityType.multipleChoice &&
        activity.type != ActivityType.predictOutput) {
      return const <int>[];
    }
    final options = activity.options ?? const <String>[];
    if (options.isEmpty) return const <int>[];
    final seeded = List<int>.generate(options.length, (index) => index);
    if (activity.shuffle) {
      seeded.shuffle(Random());
    }
    return seeded;
  }

  List<String> _seedMatchRightOptions(LessonActivity? activity) {
    if (activity == null || activity.type != ActivityType.matchConcept) {
      return const <String>[];
    }
    final pairs = activity.pairs ?? const <MatchConceptPair>[];
    if (pairs.isEmpty) return const <String>[];
    final right = pairs.map((item) => item.right).toList();
    if (activity.shuffle) {
      right.shuffle(Random());
    }
    return right;
  }

  String _seedCodeForActivity(LessonActivity? activity) {
    if (activity == null) return '';
    return switch (activity.type) {
      ActivityType.multipleChoice => '',
      ActivityType.orderCodeBlocks => '',
      ActivityType.findTheWrongLine => '',
      ActivityType.matchConcept => '',
      ActivityType.predictOutput => '',
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
    final displayOptions = _displayOptions(activity);
    if (state.selectedOptionIndex! < 0 ||
        state.selectedOptionIndex! >= displayOptions.length) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'Esa opción no es válida.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    final selected = displayOptions[state.selectedOptionIndex!];
    final correct = (activity.correctAnswer ?? '').trim();
    final isCorrect =
        _normalize(selected).toLowerCase() == _normalize(correct).toLowerCase();
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

    final normalizedAnswer = _normalize(answer);
    final normalizedExpected = _normalize(expected);

    bool isCorrect = false;
    final placeholder = RegExp(r'_{3,}');
    if (placeholder.hasMatch(initial)) {
      final expectedFull = initial.replaceFirst(placeholder, expected);
      isCorrect =
          normalizedAnswer == _normalize(expectedFull) ||
          normalizedAnswer == normalizedExpected;
    } else {
      isCorrect = normalizedAnswer == normalizedExpected;
      if (!isCorrect && initial.trim().isNotEmpty) {
        final normalizedInitial = _normalize(initial);
        if (normalizedAnswer == normalizedInitial &&
            normalizedInitial.contains(normalizedExpected)) {
          isCorrect = true;
        }
      }
      if (!isCorrect &&
          normalizedExpected.length <= 20 &&
          normalizedExpected.split(' ').length <= 3 &&
          normalizedAnswer.contains(normalizedExpected)) {
        isCorrect = true;
      }
    }

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

    final expected = activity.correctOrder ?? const <String>[];
    if (expected.length != blocks.length) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'No hay una respuesta correcta válida en esta actividad.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }
    final userOrder = state.blockOrder.map((index) => blocks[index]).toList();
    final isCorrect = _normalizedListEquals(userOrder, expected);
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
    final pairs = activity.pairs ?? const <MatchConceptPair>[];
    if (pairs.isEmpty) {
      return const _ValidationResult(
        isCorrect: false,
        error: 'No hay pares de concepto configurados en esta actividad.',
        feedbackTitle: null,
        feedbackMessage: null,
      );
    }

    for (final pair in pairs) {
      if ((state.conceptMatches[pair.left] ?? '').trim().isEmpty) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Relaciona todos los conceptos antes de verificar.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
    }

    final isCorrect = pairs.every((pair) {
      final selected = _normalize(state.conceptMatches[pair.left] ?? '')
          .toLowerCase();
      final expectedValue = _normalize(pair.right).toLowerCase();
      return selected == expectedValue;
    });
    final feedback = _feedbackFor(activity: activity, isCorrect: isCorrect);
    return _ValidationResult(
      isCorrect: isCorrect,
      error: null,
      feedbackTitle: feedback.$1,
      feedbackMessage: feedback.$2,
    );
  }

  _ValidationResult _validatePredictOutput(LessonActivity activity) {
    final options = activity.options ?? const <String>[];
    bool isCorrect = false;
    if (options.isNotEmpty) {
      if (state.selectedOptionIndex == null) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Elige la salida que esperas del código.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      final displayOptions = _displayOptions(activity);
      if (state.selectedOptionIndex! < 0 ||
          state.selectedOptionIndex! >= displayOptions.length) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'La opción seleccionada no es válida.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      final selected = _normalize(displayOptions[state.selectedOptionIndex!])
          .toLowerCase();
      final answerFromJson = (activity.correctAnswer ?? '').trim();
      if (answerFromJson.isNotEmpty) {
        isCorrect = selected == _normalize(answerFromJson).toLowerCase();
      }
    } else {
      final expected = (activity.expectedAnswer ?? '').trim();
      if (expected.isEmpty) {
        final feedback = _feedbackFor(activity: activity, isCorrect: false);
        return _ValidationResult(
          isCorrect: false,
          error: null,
          feedbackTitle: feedback.$1,
          feedbackMessage: feedback.$2,
        );
      }
      final answer = state.codeInput.trim();
      if (answer.isEmpty) {
        return const _ValidationResult(
          isCorrect: false,
          error: 'Escribe tu predicción de salida antes de verificar.',
          feedbackTitle: null,
          feedbackMessage: null,
        );
      }
      isCorrect =
          _normalize(answer).toLowerCase() ==
          _normalize(expected).toLowerCase();
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

  bool _normalizedListEquals(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (int i = 0; i < left.length; i++) {
      if (_normalize(left[i]).toLowerCase() != _normalize(right[i]).toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  List<String> _displayOptions(LessonActivity activity) {
    final options = activity.options ?? const <String>[];
    if (options.isEmpty) return const <String>[];
    final order = state.optionOrder;
    if (order.length != options.length) return options;
    return order.map((index) => options[index]).toList();
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
