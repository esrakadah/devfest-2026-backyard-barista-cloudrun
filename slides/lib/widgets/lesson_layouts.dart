import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:flutter/material.dart';

/// The two slide bodies every lesson of the Turkish talk is built from: the rule slide (new word and
/// one picture to point at) and the code slide (two code cards and the proving test).

/// Opens a lesson: the one new word, the picture that tells the rule, then the quiet advanced line.
class LessonPictureBody extends StatelessWidget {
  const LessonPictureBody({
    required this.word,
    required this.definition,
    required this.picture,
    required this.advanced,
    super.key,
  });

  static const double _gap = 18;

  final String word;
  final String definition;
  final Widget picture;
  final String advanced;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NewWordCard(word: word, definition: definition),
        const SizedBox(height: _gap),
        Expanded(child: picture),
        const SizedBox(height: _gap),
        AdvancedNote(advanced),
      ],
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
