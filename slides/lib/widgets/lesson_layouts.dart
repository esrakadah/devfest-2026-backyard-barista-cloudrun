import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:flutter/material.dart';

/// The two slide bodies every lesson of the Turkish talk is built from: the rule slide (new word,
/// what happened, what we did, the proof) and the code slide (two code cards and the proving test).

/// One of the three boxes on a rule slide.
@immutable
class LessonTile {
  const LessonTile({required this.title, required this.lines, this.footer});

  final String title;
  final List<String> lines;
  final String? footer;
}

/// Opens a lesson: the one new word, then three boxes read left to right, then the quiet advanced line.
class LessonRuleBody extends StatelessWidget {
  const LessonRuleBody({
    required this.word,
    required this.definition,
    required this.whatHappened,
    required this.whatWeDid,
    required this.proof,
    required this.advanced,
    this.whatHappenedLabel = 'NE OLDU',
    this.whatWeDidLabel = 'NE YAPTIK',
    this.proofLabel = 'KANIT',
    super.key,
  });

  static const double _gap = 18;
  static const double _tileTitleSize = 34;
  static const double _tileLineSize = 32;

  final String word;
  final String definition;
  final LessonTile whatHappened;
  final LessonTile whatWeDid;
  final LessonTile proof;
  final String advanced;
  final String whatHappenedLabel;
  final String whatWeDidLabel;
  final String proofLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NewWordCard(word: word, definition: definition),
        const SizedBox(height: _gap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _tile(whatHappenedLabel, whatHappened, DeckColors.googleRed)),
              const SizedBox(width: _gap),
              Expanded(child: _tile(whatWeDidLabel, whatWeDid, DeckColors.googleBlue)),
              const SizedBox(width: _gap),
              Expanded(child: _tile(proofLabel, proof, DeckColors.googleGreen)),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        AdvancedNote(advanced),
      ],
    );
  }

  Widget _tile(String label, LessonTile tile, Color accentColor) {
    return DeckFeatureCard(
      badge: label,
      title: tile.title,
      bullets: tile.lines,
      accentColor: accentColor,
      footerText: tile.footer,
      talkTitleFontSize: _tileTitleSize,
      talkBulletFontSize: _tileLineSize,
    );
  }
}

/// Two panels side by side (usually code before and after), the proving test under them, and
/// optionally the quiet advanced line.
class LessonCodeBody extends StatelessWidget {
  const LessonCodeBody({required this.left, required this.right, this.proof, this.advanced, super.key});

  static const double _gap = 18;

  final Widget left;
  final Widget right;
  final ProofStrip? proof;
  final String? advanced;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: _gap),
              Expanded(child: right),
            ],
          ),
        ),
        if (proof != null) ...[const SizedBox(height: _gap), proof!],
        if (advanced != null) ...[const SizedBox(height: _gap), AdvancedNote(advanced!)],
      ],
    );
  }
}
