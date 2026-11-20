import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';

/// Building blocks for the lesson slides of the Turkish talk: one new word with its definition,
/// short code with the single line the speaker points at, the test that proves the lesson, and a
/// quiet line for the experienced part of the hall. Every block draws its own dark plate, so the
/// text keeps its contrast on the navy decks and on the konya parchment alike.

/// One line of code on a lesson slide.
@immutable
class CodeLine {
  const CodeLine(this.text) : kind = CodeLineKind.plain;

  /// The one line the speaker points at. A code card has at most one.
  const CodeLine.pointAt(this.text) : kind = CodeLineKind.pointAt;

  /// A comment, drawn dimmer than code.
  const CodeLine.comment(this.text) : kind = CodeLineKind.comment;

  final String text;
  final CodeLineKind kind;
}

enum CodeLineKind { plain, pointAt, comment }

/// The new word of a lesson with its one-sentence definition.
class NewWordCard extends StatelessWidget {
  const NewWordCard({required this.word, required this.definition, this.label = 'YENİ KELİME', super.key});

  static const double _horizontalPadding = 26;
  static const double _verticalPadding = 18;
  static const double _labelSize = 15;
  static const double _wordSize = 34;
  static const double _definitionSize = 32;
  static const double _gap = 22;
  static const double _cornerRadius = 18;
  static const double _borderOpacity = 0.6;

  final String word;
  final String definition;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.googleYellow.withValues(alpha: _borderOpacity), width: 1.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: _labelSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: DeckColors.mutedText,
                ),
              ),
              Text(
                word,
                style: const TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: _wordSize,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.googleYellow,
                ),
              ),
            ],
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Text(
              definition,
              style: const TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _definitionSize,
                height: 1.25,
                color: DeckColors.offWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A short piece of code on a dark plate, with the one line to point at lit and marked.
class LessonCodeCard extends StatelessWidget {
  const LessonCodeCard({
    required this.label,
    required this.filePathLabel,
    required this.lines,
    this.accentColor = DeckColors.halftoneBlue,
    this.fontSize = defaultFontSize,
    super.key,
  });

  /// Read from the back row of a 850 seat hall; a card holds about nine lines at this size.
  static const double defaultFontSize = 26;
  static const double _cornerRadius = 18;
  static const double _headerHorizontalPadding = 20;
  static const double _headerVerticalPadding = 12;
  static const double _labelSize = 17;
  static const double _filePathSize = 16;
  static const double _bodyPadding = 18;
  static const double _lineHorizontalPadding = 12;
  static const double _lineVerticalPadding = 3;
  static const double _markerWidth = 6;
  static const double _lineHeight = 1.38;
  static const double _borderOpacity = 0.5;
  static const double _pointAtFillOpacity = 0.2;

  final String label;
  final String filePathLabel;
  final List<CodeLine> lines;
  final Color accentColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: accentColor.withValues(alpha: _borderOpacity), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: _headerHorizontalPadding, vertical: _headerVerticalPadding),
            decoration: const BoxDecoration(
              color: DeckColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(_cornerRadius - 2)),
              border: Border(bottom: BorderSide(color: DeckColors.outline)),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _labelSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Text(
                  filePathLabel,
                  style: const TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: _filePathSize,
                    color: DeckColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(_bodyPadding),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final line in lines) _buildLine(line)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(CodeLine line) {
    final isPointAt = line.kind == CodeLineKind.pointAt;
    final textColor = switch (line.kind) {
      CodeLineKind.plain => DeckColors.offWhite,
      CodeLineKind.pointAt => DeckColors.googleYellow,
      CodeLineKind.comment => DeckColors.mutedText,
    };
    return Container(
      key: isPointAt ? const ValueKey<String>('code-line-point-at') : null,
      padding: const EdgeInsets.symmetric(horizontal: _lineHorizontalPadding, vertical: _lineVerticalPadding),
      decoration: isPointAt
          ? BoxDecoration(
              color: DeckColors.googleYellow.withValues(alpha: _pointAtFillOpacity),
              border: const Border(left: BorderSide(color: DeckColors.googleYellow, width: _markerWidth)),
            )
          : null,
      child: Text(
        line.text.isEmpty ? ' ' : line.text,
        softWrap: false,
        style: TextStyle(
          fontFamily: DeckFonts.mono,
          fontSize: fontSize,
          height: _lineHeight,
          fontWeight: isPointAt ? FontWeight.w700 : FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}

/// The test that proves a lesson: its name as it stands in the repo, and what it showed.
class ProofStrip extends StatelessWidget {
  const ProofStrip({required this.testName, required this.outcome, this.label = 'TEST', super.key});

  static const double _horizontalPadding = 22;
  static const double _verticalPadding = 14;
  static const double _labelSize = 16;
  static const double _nameSize = 23;
  static const double _outcomeSize = 23;
  static const double _gap = 16;
  static const double _iconSize = 30;
  static const double _cornerRadius = 14;
  static const double _borderOpacity = 0.55;

  final String label;
  final String testName;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.googleGreen.withValues(alpha: _borderOpacity), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, size: _iconSize, color: DeckColors.googleGreen),
          const SizedBox(width: _gap),
          Text(
            label,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _labelSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: DeckColors.googleGreen,
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Text(
              testName,
              style: const TextStyle(fontFamily: DeckFonts.mono, fontSize: _nameSize, color: DeckColors.offWhite),
            ),
          ),
          const SizedBox(width: _gap),
          Text(
            outcome,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _outcomeSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.googleGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// The quiet line for the experienced part of the hall. Never read aloud.
class AdvancedNote extends StatelessWidget {
  const AdvancedNote(this.text, {super.key});

  static const String _prefix = 'İleri seviye: ';
  static const double _horizontalPadding = 18;
  static const double _verticalPadding = 10;
  static const double _fontSize = 19;
  static const double _cornerRadius = 12;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.outline),
      ),
      child: Text(
        '$_prefix$text',
        style: const TextStyle(fontFamily: DeckFonts.mono, fontSize: _fontSize, color: DeckColors.googleYellow),
      ),
    );
  }
}
