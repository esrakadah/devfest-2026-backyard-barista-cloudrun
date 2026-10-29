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

  group('Updated Slides & GDE Artifacts Tour Smoke Tests', () {
    testWidgets('PureFlutterWidgetsSlide renders Hybrid Flame Engine + Flutter HUD Architecture', (tester) async {
      const slide = PureFlutterWidgetsSlide();
      expect(slide.configuration?.route, '/pure-flutter-widgets');

      await pumpSlide(tester, slide);

      expect(find.text('Hybrid Flame Engine + Flutter HUD Architecture'), findsOneWidget);
      expect(find.textContaining('BaristaFlameGame'), findsWidgets);
      expect(find.textContaining('2x2 Counter Grid'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SaltSugarMechanicSlide renders Web NFC Stage Trigger and CafeReview schema', (tester) async {
      const slide = SaltSugarMechanicSlide();
      expect(slide.configuration?.route, '/salt-sugar-mechanic');

      await pumpSlide(tester, slide);

      expect(find.textContaining('Web NFC'), findsWidgets);
      expect(find.textContaining('NDEFReader'), findsWidgets);
      expect(find.textContaining('simulateTap'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ArchitectureRecapSlide includes BaristaFlameGame 60fps and WebNfcService', (tester) async {
      const slide = ArchitectureRecapSlide();
      expect(slide.configuration?.route, '/architecture-recap');

      await pumpSlide(tester, slide);

      expect(find.textContaining('BaristaFlameGame 60fps 3-Lane'), findsOneWidget);
      expect(find.textContaining('WebNfcService (NDEFReader)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GdeArtifactsTourSlide renders all 6 Claude Artifacts and 8 Autumn 2026 Tour stops', (tester) async {
      const slide = GdeArtifactsTourSlide();
      expect(slide.configuration?.route, '/gde-artifacts-tour');

      await pumpSlide(tester, slide);

      expect(find.text('GDE Speaking Autumn 2026: Artifacts & Tour Roadmap'), findsOneWidget);
      expect(find.textContaining('GDE Speaking Autumn 2026'), findsWidgets);
      expect(find.textContaining('Phase 3 Speaker Notes'), findsWidgets);
      expect(find.textContaining('Live AI Demo Risks & Fallbacks'), findsWidgets);
      expect(find.textContaining('SoundStage Capability Ledger'), findsWidgets);
      expect(find.textContaining('modemoiselle x BlocSignal'), findsWidgets);
      expect(find.textContaining('DevFest Adana Firebase AI + Genkit'), findsWidgets);

      for (final stop in const [
        'Stockholm 22 Oct',
        'Gaziantep 8 Nov',
        'Berlin 14 Nov',
        'Adana 21 Nov',
        'Hatay 28 Nov',
        'Atyrau 29 Nov',
        'Karlsruhe 5 Dec',
        'Istanbul 6 Dec',
      ]) {
        expect(find.text(stop), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
