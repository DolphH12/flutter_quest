import 'package:flutter/material.dart';

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
    required this.onMoveBlockUp,
    required this.onMoveBlockDown,
    required this.onSetConceptMatch,
  });

  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<int> onSelectWrongLine;
  final ValueChanged<int> onMoveBlockUp;
  final ValueChanged<int> onMoveBlockDown;
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
  final TextEditingController codeController;
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
        onMoveBlockUp: callbacks.onMoveBlockUp,
        onMoveBlockDown: callbacks.onMoveBlockDown,
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
  final TextEditingController controller;
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
    required this.onMoveBlockUp,
    required this.onMoveBlockDown,
  });

  final LessonActivity activity;
  final LessonSessionState session;
  final ValueChanged<int> onMoveBlockUp;
  final ValueChanged<int> onMoveBlockDown;

  @override
  Widget build(BuildContext context) {
    final blocks = activity.blocks ?? const <String>[];
    final order = session.blockOrder;

    if (blocks.isEmpty) {
      return const Text('Esta actividad no tiene bloques configurados.');
    }

    return Column(
      children: [
        for (int position = 0; position < order.length; position++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FQSurfaceCard(
              radius: FQRadius.medium,
              color: FQColors.surfaceHigh.withValues(alpha: 0.58),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${position + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: FQColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      blocks[order[position]],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: session.submitted
                            ? null
                            : () => onMoveBlockUp(position),
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      IconButton(
                        onPressed: session.submitted
                            ? null
                            : () => onMoveBlockDown(position),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
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
    final correctIndex = activity.wrongLineIndex;

    return FQSurfaceCard(
      radius: FQRadius.large,
      color: FQColors.deepNavy,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          for (int i = 0; i < lines.length; i++)
            InkWell(
              onTap: session.submitted ? null : () => onSelectWrongLine(i),
              borderRadius: FQRadius.small,
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: FQRadius.small,
                  color: _wrongLineBackground(
                    index: i,
                    selected: session.selectedWrongLineIndex,
                    correct: correctIndex,
                    submitted: session.submitted,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${i + 1}'.padLeft(2, '0'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lines[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _wrongLineBackground({
    required int index,
    required int? selected,
    required int? correct,
    required bool submitted,
  }) {
    if (!submitted) {
      return index == selected
          ? FQColors.primary.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.08);
    }
    if (index == correct) return const Color(0xFF1D8D4A);
    if (index == selected) return const Color(0xFFC23737);
    return Colors.white.withValues(alpha: 0.08);
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
  final TextEditingController controller;
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
  final TextEditingController controller;
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
