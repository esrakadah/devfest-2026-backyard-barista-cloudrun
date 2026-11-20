// Renders every slide to build/slides/NN_route.png with the real bundled fonts and images.
//
// Run from slides/:  flutter test tool/export_slides_test.dart
// Then (optional):   python3 tool/pngs_to_pdf.py   -> build/slides/backyard_barista_deck.pdf
//
// The PNGs and the PDF are the offline backup of the deck: if the stage laptop cannot run
// Flutter, present the PDF from any machine.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:backyard_barista_deck/leaderboard/hall_board.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers/deck_fonts.dart';

const Size _slideSize = Size(2560, 1440);
const String _outputDirectory = 'build/slides';

/// `--dart-define=BOARD_SAMPLE=true` fills the leaderboard slides with made-up players, to check the
/// layout. The backup PDF is exported without it: its board says that the table opens live on stage.
const bool _showsSampleBoard = bool.fromEnvironment('BOARD_SAMPLE');

final List<HallBoardEntry> _sampleBoard = <HallBoardEntry>[
  for (final (index, name) in const <String>[
    'tuzlu_kahve',
    'Mevlana42',
    'baklavacı',
    'flutter_kız',
    'dash_avcısı',
    'Etli Ekmek',
    'şekerpare',
    'gde_fan',
    'cloud_run',
    'konyalı',
    'son_sıra',
  ].indexed)
    HallBoardEntry(
      name: name,
      score: _sampleTopScore - index * _sampleScoreStep,
      rounds: _sampleTopRounds - index,
      updatedAt: DateTime.utc(2026, 11, 21, 11, 36, index),
    ),
];
const int _sampleTopScore = 1850;
const int _sampleScoreStep = 130;
const int _sampleTopRounds = 21;

Future<void> _precacheImages(WidgetTester tester) async {
  final elements = find.byType(Image).evaluate().toList();
  await tester.runAsync(() async {
    for (final element in elements) {
      final widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
  });
}

String _fileNameFor(int number, String route) {
  final slug = route.replaceAll('/', '').replaceAll('-', '_');
  return '${number.toString().padLeft(2, '0')}_$slug.png';
}

void main() {
  setUpAll(() async {
    await loadDeckFonts();
    if (_showsSampleBoard) {
      HallBoard.instance.showEntries(_sampleBoard);
    }
    Directory(_outputDirectory).createSync(recursive: true);
  });

  for (var index = 0; index < deckSlides.length; index++) {
    final slide = deckSlides[index];
    final route = slide.configuration!.route;

    testWidgets('export $route', (tester) async {
      tester.view.physicalSize = _slideSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: FlutterDeckApp(
            configuration: FlutterDeckConfiguration(
              slideSize: DeckCanvas.slideSize,
              progressIndicator: PresentationTheme.progressIndicator,
              background: const FlutterDeckBackgroundConfiguration(
                light: FlutterDeckBackground.custom(child: DeckBackdrop()),
                dark: FlutterDeckBackground.custom(child: DeckBackdrop()),
              ),
              controls: const FlutterDeckControlsConfiguration(presenterToolbarVisible: false),
              footer: const FlutterDeckFooterConfiguration(showSocialHandle: true),
            ),
            themeMode: ThemeMode.dark,
            darkTheme: PresentationTheme.darkTheme,
            lightTheme: PresentationTheme.darkTheme,
            speakerInfo: const FlutterDeckSpeakerInfo(
              name: 'Esra Kadah',
              description: 'Google Developer Expert, Flutter & Dart',
              socialHandle: '@esrakadah',
              imagePath: 'assets/images/esra.png',
            ),
            slides: [slide],
          ),
        ),
      );
      await tester.pump();
      await _precacheImages(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_outputDirectory/${_fileNameFor(index + 1, route)}').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    });
  }
}
