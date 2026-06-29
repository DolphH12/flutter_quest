import 'package:flutter/material.dart';
import 'package:lite_code_editor/lite_code_editor.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/state/lesson_session_provider.dart';
import 'quest_code_editor.dart';

class ActivityRendererCallbacks {
  const ActivityRendererCallbacks({
    required this.onSelectOption,
    required this.onCodeChanged,
    required this.onSelectWrongLine,
    required this.onReorderBlocks,
    required this.onSetConceptMatch,
  });

  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<int> onSelectWrongLine;
  final void Function(int oldIndex, int newIndex) onReorderBlocks;
  final void Function(String left, String right) onSetConceptMatch;
}

class LessonActivityRenderer extends StatelessWidget {
  const LessonActivityRenderer({
    super.key,
    required this.activity,
    required this.session,
    required this.codeController,
    required this.callbacks,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final CodeEditorController codeController;
  final ActivityRendererCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return switch (activity.type) {
      ActivityType.multipleChoice => _MultipleChoiceActivity(
        activity: activity,
        session: session,
        onSelectOption: callbacks.onSelectOption,
      ),
      ActivityType.fillInTheCode ||
      ActivityType.fixTheBug ||
      ActivityType.completeSnippet => _CodeInputActivity(
        activity: activity,
        session: session,
        controller: codeController,
        onChanged: callbacks.onCodeChanged,
        fileName: 'practice.dart',
      ),
      ActivityType.orderCodeBlocks => _OrderCodeBlocksActivity(
        activity: activity,
        session: session,
        onReorderBlocks: callbacks.onReorderBlocks,
      ),
      ActivityType.findTheWrongLine => _FindWrongLineActivity(
        activity: activity,
        session: session,
        onSelectWrongLine: callbacks.onSelectWrongLine,
      ),
      ActivityType.matchConcept => _MatchConceptActivity(
        activity: activity,
        session: session,
        onSetConceptMatch: callbacks.onSetConceptMatch,
      ),
      ActivityType.predictOutput => _PredictOutputActivity(
        activity: activity,
        session: session,
        controller: codeController,
        onSelectOption: callbacks.onSelectOption,
        onChanged: callbacks.onCodeChanged,
      ),
      ActivityType.guidedWriting => _GuidedWritingActivity(
        activity: activity,
        session: session,
        controller: codeController,
        onChanged: callbacks.onCodeChanged,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class LessonFeedbackCard extends StatelessWidget {
  const LessonFeedbackCard({
    super.key,
    required this.isCorrect,
    required this.title,
    required this.message,
  });

  final bool isCorrect;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.medium,
      color: isCorrect ? const Color(0xFFDFF7E8) : const Color(0xFFFFE5E5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect
                    ? const Color(0xFF1D8D4A)
                    : const Color(0xFFC23737),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MultipleChoiceActivity extends StatelessWidget {
  const _MultipleChoiceActivity({
    required this.activity,
    required this.session,
    required this.onSelectOption,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final ValueChanged<int> onSelectOption;

  @override
  Widget build(BuildContext context) {
    final options = _displayOptions();
    final correct = activity.correctAnswer;

    return Column(
      children: [
        for (int i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: FQRadius.medium,
              onTap: session.submitted ? null : () => onSelectOption(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  borderRadius: FQRadius.medium,
                  color: _optionBackground(
                    option: options[i],
                    selected: session.selectedOptionIndex == i,
                    submitted: session.submitted,
                    correctAnswer: correct,
                  ),
                  border: Border.all(
                    color: _optionBorder(
                      option: options[i],
                      selected: session.selectedOptionIndex == i,
                      submitted: session.submitted,
                      correctAnswer: correct,
                    ),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[i],
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontSize: 17),
                      ),
                    ),
                    if (session.submitted && options[i] == correct)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1D8D4A),
                      ),
                    if (session.submitted &&
                        session.selectedOptionIndex == i &&
                        options[i] != correct)
                      const Icon(
                        Icons.cancel_rounded,
                        color: Color(0xFFC23737),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<String> _displayOptions() {
    final options = activity.options ?? const <String>[];
    if (options.isEmpty) return const <String>[];
    final order = session.optionOrder;
    if (order.length != options.length) return options;
    return order.map((index) => options[index]).toList();
  }

  Color _optionBackground({
    required String option,
    required bool selected,
    required bool submitted,
    required String? correctAnswer,
  }) {
    if (!submitted) {
      return selected
          ? FQColors.primary.withValues(alpha: 0.14)
          : FQColors.surfaceHigh.withValues(alpha: 0.58);
    }
    if (option == correctAnswer) return const Color(0xFFDFF7E8);
    if (selected) return const Color(0xFFFFE5E5);
    return FQColors.surfaceHigh.withValues(alpha: 0.58);
  }

  Color _optionBorder({
    required String option,
    required bool selected,
    required bool submitted,
    required String? correctAnswer,
  }) {
    if (!submitted) {
      return selected
          ? FQColors.primary.withValues(alpha: 0.45)
          : Colors.transparent;
    }
    if (option == correctAnswer) return const Color(0xFF1D8D4A);
    if (selected) return const Color(0xFFC23737);
    return Colors.transparent;
  }
}

class _CodeInputActivity extends StatelessWidget {
  const _CodeInputActivity({
    required this.activity,
    required this.session,
    required this.controller,
    required this.onChanged,
    required this.fileName,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final CodeEditorController controller;
  final ValueChanged<String> onChanged;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestCodeEditor(
          controller: controller,
          onChanged: onChanged,
          fileName: fileName,
          readOnly: session.submitted,
          hintText: activity.initialCode ?? 'Escribe tu solucion aqui',
          customKeywords: _editorKeywordsFor(activity),
        ),
        if (activity.hint != null) ...[
          const SizedBox(height: 8),
          Text(
            'Hint: ${activity.hint!}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.primary,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderCodeBlocksActivity extends StatelessWidget {
  const _OrderCodeBlocksActivity({
    required this.activity,
    required this.session,
    required this.onReorderBlocks,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final void Function(int oldIndex, int newIndex) onReorderBlocks;

  @override
  Widget build(BuildContext context) {
    final blocks = activity.blocks ?? const <String>[];
    final order = session.blockOrder;
    final highlighter = DartHighlighter();

    if (blocks.isEmpty) {
      return const Text('Esta actividad no tiene bloques configurados.');
    }

    final itemHeight = 62.0;
    final listHeight = (order.length * itemHeight) + 16;
    final maxHeight = listHeight > 360 ? 360.0 : listHeight;

    return FQSurfaceCard(
      radius: FQRadius.large,
      color: const Color(0xFF081629),
      useHighlightOverlay: false,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ideDot(const Color(0xFFFF6B6B)),
              const SizedBox(width: 6),
              _ideDot(const Color(0xFFFDC003)),
              const SizedBox(width: 6),
              _ideDot(const Color(0xFF50D5C3)),
              const SizedBox(width: 10),
              Text(
                'ORDER MODE · drag & drop',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: FQRadius.medium,
              color: const Color(0xFF0B1C33),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: maxHeight,
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                physics: const BouncingScrollPhysics(),
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    child: child,
                    builder: (context, proxyChild) {
                      final curved = Curves.easeOutCubic.transform(
                        animation.value,
                      );
                      return Transform.scale(
                        scale: 1 + (curved * 0.02),
                        child: Material(
                          type: MaterialType.transparency,
                          shadowColor: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: FQRadius.medium,
                              color: const Color(0xFF0E2342),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.24),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: proxyChild,
                          ),
                        ),
                      );
                    },
                  );
                },
                itemCount: order.length,
                onReorderItem: (oldIndex, newIndex) {
                  if (session.submitted) return;
                  onReorderBlocks(oldIndex, newIndex);
                },
                itemBuilder: (context, position) {
                  final blockIndex = order[position];
                  final block = blocks[blockIndex];
                  final isLocked = session.submitted;
                  return Container(
                    key: ValueKey('code_block_$blockIndex'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: FQRadius.medium,
                      color: const Color(0xFF0E2342),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '${position + 1}',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Color(0xFFEAF2FF),
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.35,
                            ),
                            child: RichText(
                              text: highlighter.highlight(block),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Opacity(
                          opacity: isLocked ? 0.35 : 0.95,
                          child: ReorderableDragStartListener(
                            index: position,
                            enabled: !isLocked,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: FQRadius.small,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ideDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FindWrongLineActivity extends StatelessWidget {
  const _FindWrongLineActivity({
    required this.activity,
    required this.session,
    required this.onSelectWrongLine,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final ValueChanged<int> onSelectWrongLine;

  @override
  Widget build(BuildContext context) {
    final lines = activity.codeLines ?? const <String>[];
    return QuestCodeLineSelector(
      lines: lines,
      selectedLineIndex: session.selectedWrongLineIndex,
      maxHeight: 300,
      fileName: 'bug_hunt.dart',
      onLineSelected: session.submitted ? (_) {} : onSelectWrongLine,
    );
  }
}

class _MatchConceptActivity extends StatelessWidget {
  const _MatchConceptActivity({
    required this.activity,
    required this.session,
    required this.onSetConceptMatch,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final void Function(String left, String right) onSetConceptMatch;

  @override
  Widget build(BuildContext context) {
    final pairs = activity.pairs ?? const <MatchConceptPair>[];
    final leftItems = pairs.map((item) => item.left).toList();
    final rightItems = session.matchRightOptions.isNotEmpty
        ? session.matchRightOptions
        : pairs.map((item) => item.right).toList();

    return Column(
      children: [
        for (final left in leftItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  left,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  menuMaxHeight: 280,
                  initialValue: session.conceptMatches[left],
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: rightItems
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: session.submitted
                      ? null
                      : (value) {
                          if (value == null) return;
                          onSetConceptMatch(left, value);
                        },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PredictOutputActivity extends StatelessWidget {
  const _PredictOutputActivity({
    required this.activity,
    required this.session,
    required this.controller,
    required this.onSelectOption,
    required this.onChanged,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final CodeEditorController controller;
  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = activity.options ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.isNotEmpty)
          _MultipleChoiceActivity(
            activity: activity,
            session: session,
            onSelectOption: onSelectOption,
          )
        else
          QuestCodeEditor(
            controller: controller,
            onChanged: onChanged,
            fileName: 'output.txt',
            hintText: 'Escribe la salida esperada',
            readOnly: session.submitted,
            minLines: 4,
            maxHeight: 180,
            language: CodeLanguage.plainText,
            customKeywords: _editorKeywordsFor(activity),
          ),
      ],
    );
  }
}

class _GuidedWritingActivity extends StatelessWidget {
  const _GuidedWritingActivity({
    required this.activity,
    required this.session,
    required this.controller,
    required this.onChanged,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final CodeEditorController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((activity.instructions ?? '').isNotEmpty)
          Text(
            activity.instructions!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              color: FQColors.onSurface.withValues(alpha: 0.84),
            ),
          ),
        if ((activity.instructions ?? '').isNotEmpty)
          const SizedBox(height: 10),
        QuestCodeEditor(
          controller: controller,
          onChanged: onChanged,
          fileName: 'guided_practice.dart',
          readOnly: session.submitted,
          hintText:
              activity.starterCode ??
              activity.initialCode ??
              'Escribe tu solucion aqui',
          customKeywords: _editorKeywordsFor(activity),
        ),
        if (activity.hint != null) ...[
          const SizedBox(height: 8),
          Text(
            'Hint: ${activity.hint!}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FQColors.primary,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}

List<String> _editorKeywordsFor(LessonActivity activity) {
  final keywords = <String>{...(activity.customKeywords ?? const <String>[])};

  void addSingle(String? value) {
    final candidate = (value ?? '').trim();
    if (candidate.isEmpty) return;
    if (candidate.contains('\n')) return;
    if (candidate.length > 48) return;
    keywords.add(candidate);
  }

  void addMany(List<String>? values) {
    for (final value in values ?? const <String>[]) {
      addSingle(value);
    }
  }

  addSingle(activity.expectedAnswer);
  addSingle(activity.suggestedName);
  addMany(activity.acceptedAnswers);
  addMany(activity.requiredTokens);
  addMany(activity.expectedFragments);
  _extractCodeSuggestions(activity.expectedAnswer).forEach(addSingle);
  _extractCodeSuggestions(activity.initialCode).forEach(addSingle);
  _extractCodeSuggestions(activity.starterCode).forEach(addSingle);

  return keywords.toList()..sort();
}

Iterable<String> _extractCodeSuggestions(String? source) sync* {
  final raw = (source ?? '').trim();
  if (raw.isEmpty) return;

  final regex = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
  final emitted = <String>{};
  for (final match in regex.allMatches(raw)) {
    final token = match.group(0);
    if (token == null || token.length < 2) continue;
    if (emitted.add(token)) yield token;

    final end = match.end;
    if (end + 1 < raw.length && raw.substring(end, end + 2) == '()') {
      final callable = '$token()';
      if (emitted.add(callable)) yield callable;
    }
  }
}
