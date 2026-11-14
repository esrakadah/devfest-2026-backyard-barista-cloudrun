// Writes the speaker notes of every slide to one readable Markdown page, next to the PNG backup.
//
// Run from slides/:  flutter test tool/export_notes_test.dart
// Turkish deck:      flutter test tool/export_notes_test.dart --dart-define=DECK_LANG=tr
//
// Output: build/slides/speaker_notes.md, in the language the deck was run in.
import 'dart:io';

import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:flutter_test/flutter_test.dart';

const String _outputDirectory = 'build/slides';
const List<String> _cueLabels = ['BEAT', 'SAY', 'HOLD', 'NEXT'];

/// Splits one note line such as `SAY   "Hangisi şeker?"` into its cue label and its text.
(String, String) _cueAndText(String line) {
  for (final label in _cueLabels) {
    if (line.startsWith(label)) return (label, line.substring(label.length).trim());
  }
  return ('', line.trim());
}

void main() {
  test('export speaker notes', () {
    final page = StringBuffer()
      ..writeln(isTurkishDeck ? '# Konuşmacı notları' : '# Speaker notes')
      ..writeln();

    for (final (index, slide) in deckSlides.indexed) {
      final configuration = slide.configuration!;
      page
        ..writeln('## ${index + 1}. `${configuration.route}`')
        ..writeln();
      for (final line in configuration.speakerNotes.split('\n')) {
        if (line.trim().isEmpty) continue;
        final (label, text) = _cueAndText(line);
        page
          ..writeln(label.isEmpty ? text : '**$label** $text')
          ..writeln();
      }
    }

    Directory(_outputDirectory).createSync(recursive: true);
    File('$_outputDirectory/speaker_notes.md').writeAsStringSync(page.toString());
  });
}
