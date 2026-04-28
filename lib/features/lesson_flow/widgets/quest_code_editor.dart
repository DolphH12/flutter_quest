import 'package:flutter/material.dart';
import 'package:lite_code_editor/lite_code_editor.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_surface_card.dart';

class QuestCodeEditor extends StatelessWidget {
  const QuestCodeEditor({
    super.key,
    required this.controller,
    required this.onChanged,
    this.fileName = 'practice.dart',
    this.hintText,
    this.readOnly = false,
    this.minLines = 8,
    this.maxHeight = 260,
    this.language = CodeLanguage.dart,
    this.customKeywords = const <String>[],
  });

  final CodeEditorController controller;
  final ValueChanged<String> onChanged;
  final String fileName;
  final String? hintText;
  final bool readOnly;
  final int minLines;
  final double maxHeight;
  final CodeLanguage language;
  final List<String> customKeywords;

  @override
  Widget build(BuildContext context) {
    controller.language = language;
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.deepQuest,
      useHighlightOverlay: false,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _EditorTopBar(
              fileName: fileName,
              languageTag: language == CodeLanguage.plainText ? 'TEXT' : 'DART',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: maxHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: FQRadius.large.bottomLeft,
                bottomRight: FQRadius.large.bottomRight,
              ),
              child: CodeEditor(
                controller: controller,
                readOnly: readOnly,
                theme: _editorTheme(),
                customKeywords: customKeywords,
                onChanged: onChanged,
              ),
            ),
          ),
          if (!readOnly &&
              hintText != null &&
              hintText!.trim().isNotEmpty &&
              controller.code.trim().isEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                hintText!,
                style: _codeStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 13,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class QuestCodePreview extends StatefulWidget {
  const QuestCodePreview({
    super.key,
    required this.content,
    this.fileName = 'example.dart',
    this.minLines = 7,
    this.maxHeight = 260,
    this.language = CodeLanguage.dart,
  });

  final String content;
  final String fileName;
  final int minLines;
  final double maxHeight;
  final CodeLanguage language;

  @override
  State<QuestCodePreview> createState() => _QuestCodePreviewState();
}

class _QuestCodePreviewState extends State<QuestCodePreview> {
  late final CodeEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeEditorController(
      initialCode: widget.content,
      language: widget.language,
    );
  }

  @override
  void didUpdateWidget(covariant QuestCodePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.code = widget.content;
    }
    if (oldWidget.language != widget.language) {
      _controller.language = widget.language;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineCount = '\n'.allMatches(widget.content).length + 1;
    final targetLines = lineCount < widget.minLines ? widget.minLines : lineCount;
    final minHeight = (targetLines * 22.0) + 20;
    final editorHeight = minHeight > widget.maxHeight ? widget.maxHeight : minHeight;

    return QuestCodeEditor(
      controller: _controller,
      onChanged: (_) {},
      fileName: widget.fileName,
      readOnly: true,
      minLines: widget.minLines,
      maxHeight: editorHeight,
      language: widget.language,
    );
  }
}

class QuestCodeLineSelector extends StatefulWidget {
  const QuestCodeLineSelector({
    super.key,
    required this.lines,
    required this.onLineSelected,
    this.selectedLineIndex,
    this.fileName = 'bug.dart',
    this.maxHeight = 320,
  });

  final List<String> lines;
  final int? selectedLineIndex;
  final ValueChanged<int> onLineSelected;
  final String fileName;
  final double maxHeight;

  @override
  State<QuestCodeLineSelector> createState() => _QuestCodeLineSelectorState();
}

class _QuestCodeLineSelectorState extends State<QuestCodeLineSelector> {
  late final CodeEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeEditorController(
      initialCode: widget.lines.join('\n'),
      language: CodeLanguage.dart,
    );
    _controller.selectLine(widget.selectedLineIndex);
  }

  @override
  void didUpdateWidget(covariant QuestCodeLineSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameLines(oldWidget.lines, widget.lines)) {
      _controller.code = widget.lines.join('\n');
    }
    if (oldWidget.selectedLineIndex != widget.selectedLineIndex) {
      _controller.selectLine(widget.selectedLineIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.deepQuest,
      useHighlightOverlay: false,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _EditorTopBar(fileName: widget.fileName, languageTag: 'SELECT'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: widget.maxHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: FQRadius.large.bottomLeft,
                bottomRight: FQRadius.large.bottomRight,
              ),
              child: CodeEditor(
                controller: _controller,
                readOnly: true,
                selectionMode: true,
                theme: _editorTheme(),
                onLineSelected: (index, _) => widget.onLineSelected(index),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  bool _sameLines(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _EditorTopBar extends StatelessWidget {
  const _EditorTopBar({required this.fileName, required this.languageTag});

  final String fileName;
  final String languageTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(const Color(0xFFFF6B6B)),
        const SizedBox(width: 6),
        _dot(const Color(0xFFFDC003)),
        const SizedBox(width: 6),
        _dot(const Color(0xFF50D5C3)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: FQRadius.small,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Text(
            languageTag,
            style: _codeStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              weight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Text(
          fileName,
          style: _codeStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

EditorTheme _editorTheme() {
  return EditorTheme(
    background: const Color(0xFF0E2342),
    gutterBackground: const Color(0xFF0C203D),
    gutterBorder: Colors.white.withValues(alpha: 0.08),
    textColor: Colors.white.withValues(alpha: 0.94),
    gutterTextColor: Colors.white.withValues(alpha: 0.38),
    gutterTextColorActive: Colors.white.withValues(alpha: 0.78),
    lineSelectedBackground: const Color(0xFF2A4D7A),
    lineHighlightBackground: Colors.white.withValues(alpha: 0.06),
    cursorColor: FQColors.primaryBright,
    selectionColor: const Color(0x665CADFE),
    fontFamily: 'monospace',
    fontSize: 14.5,
    lineHeight: 1.5,
  );
}

Widget _dot(Color color) {
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

TextStyle _codeStyle({
  Color? color,
  double fontSize = 14,
  FontWeight weight = FontWeight.w500,
}) {
  return TextStyle(
    fontFamily: 'monospace',
    fontSize: fontSize,
    fontWeight: weight,
    color: color ?? Colors.white.withValues(alpha: 0.93),
    height: 1.4,
  );
}
