import 'package:flutter/material.dart';

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
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String fileName;
  final String? hintText;
  final bool readOnly;
  final int minLines;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.deepQuest,
      useHighlightOverlay: false,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  'DART',
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
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LineNumbers(text: controller.text, minLines: minLines),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      readOnly: readOnly,
                      minLines: minLines,
                      maxLines: null,
                      cursorColor: FQColors.primaryBright,
                      style: _codeStyle(fontSize: 15),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: hintText,
                        hintStyle: _codeStyle(
                          color: Colors.white.withValues(alpha: 0.42),
                          fontSize: 14,
                        ),
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

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class QuestCodePreview extends StatelessWidget {
  const QuestCodePreview({
    super.key,
    required this.content,
    this.fileName = 'example.dart',
    this.minLines = 7,
    this.maxHeight = 260,
  });

  final String content;
  final String fileName;
  final int minLines;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.deepQuest,
      useHighlightOverlay: false,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _panelDot(const Color(0xFFFF6B6B)),
              const SizedBox(width: 6),
              _panelDot(const Color(0xFFFDC003)),
              const SizedBox(width: 6),
              _panelDot(const Color(0xFF50D5C3)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: FQRadius.small,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: Text(
                  'DART',
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
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LineNumbers(text: content, minLines: minLines),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      content,
                      style: _codeStyle(fontSize: 15),
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
}

class _LineNumbers extends StatelessWidget {
  const _LineNumbers({required this.text, required this.minLines});

  final String text;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final totalLines = '\n'.allMatches(text).length + 1;
    final lines = totalLines < minLines ? minLines : totalLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 1; i <= lines; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.6),
            child: Text(
              '$i',
              style: _codeStyle(
                color: Colors.white.withValues(alpha: 0.36),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

Widget _panelDot(Color color) {
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
