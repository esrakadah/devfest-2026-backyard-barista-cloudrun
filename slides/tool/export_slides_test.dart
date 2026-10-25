// Renders every slide to build/slides/NN_route.png with the real bundled fonts and images.
//
// Run from slides/:  flutter test tool/export_slides_test.dart
// Then (optional):   python3 tool/pngs_to_pdf.py   -> build/slides/backyard_barista_deck.pdf
//
// The PNGs and the PDF are the offline backup of the deck: if the stage laptop cannot run
// Flutter, present the PDF from any machine.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers/deck_fonts.dart';

const Size _slideSize = Size(2560, 1440);
const String _outputDirectory = 'build/slides';

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
            configuration: const FlutterDeckConfiguration(
              slideSize: DeckCanvas.slideSize,
              background: FlutterDeckBackgroundConfiguration(
                light: FlutterDeckBackground.solid(DeckColors.navy),
                dark: FlutterDeckBackground.solid(DeckColors.navy),
              ),
              controls: FlutterDeckControlsConfiguration(presenterToolbarVisible: false),
              footer: FlutterDeckFooterConfiguration(showSocialHandle: true),
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
