import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/deck_fonts.dart';

void main() {
  setUpAll(loadDeckFonts);

  Future<void> pumpSlide(WidgetTester tester, FlutterDeckSlideWidget slide) async {
    tester.view.physicalSize = const Size(2560, 1440);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      FlutterDeckApp(
        configuration: const FlutterDeckConfiguration(
          slideSize: DeckCanvas.slideSize,
        ),
        darkTheme: PresentationTheme.darkTheme,
        lightTheme: PresentationTheme.darkTheme,
        slides: [slide],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Updated Slides Smoke Tests', () {
    testWidgets('PureFlutterWidgetsSlide renders Hybrid Flame Engine + Flutter HUD Architecture', (tester) async {
      const slide = PureFlutterWidgetsSlide();
      expect(slide.configuration?.route, '/pure-flutter-widgets');

      await pumpSlide(tester, slide);

      expect(
        find.text(
          isTurkishDeck
              ? 'Flame sahnesi + Flutter arayüzü: hibrit mimari'
              : 'Hybrid Flame Engine + Flutter HUD Architecture',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('BaristaFlameGame'), findsWidgets);
      expect(find.textContaining(isTurkishDeck ? '2x2 tezgah' : '2x2 Counter Grid'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SaltSugarMechanicSlide renders Web NFC Stage Trigger and CafeReview schema', (tester) async {
      const slide = SaltSugarMechanicSlide();
      expect(slide.configuration?.route, '/salt-sugar-mechanic');

      await pumpSlide(tester, slide);

      expect(find.textContaining('Web NFC'), findsWidgets);
      expect(find.textContaining('NDEFReader'), findsWidgets);
      expect(find.textContaining('nfcController.startScanning'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ArchitectureRecapSlide includes BaristaFlameGame 60fps and NfcTagController', (tester) async {
      const slide = ArchitectureRecapSlide();
      expect(slide.configuration?.route, '/architecture-recap');

      await pumpSlide(tester, slide);

      expect(
        find.textContaining(isTurkishDeck ? 'BaristaFlameGame 60fps 3 şerit' : 'BaristaFlameGame 60fps 3-Lane'),
        findsOneWidget,
      );
      expect(find.textContaining('NfcTagController (NDEFReader)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
