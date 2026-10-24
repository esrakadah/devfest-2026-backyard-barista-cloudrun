import 'package:backyard_barista_deck/main.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme Coverage', () {
    test('PresentationTheme darkTheme generates valid configuration', () {
      final theme = PresentationTheme.darkTheme;
      expect(theme.materialTheme.brightness, Brightness.dark);
      expect(theme.splitSlideTheme, isNotNull);
      expect(theme.headerTheme, isNotNull);
      expect(theme.footerTheme, isNotNull);
      expect(theme.codeHighlightTheme, isNotNull);
    });
  });

  group('Slides Rendering at 2560x1440', () {
    testWidgets('BackyardBaristaDeckApp widget builds cleanly', (tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const BackyardBaristaDeckApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FlutterDeckApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final slide in deckSlides) {
      testWidgets('Slide ${slide.runtimeType} renders without errors at 2560x1440', (tester) async {
        tester.view.physicalSize = const Size(2560, 1440);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          FlutterDeckApp(
            configuration: const FlutterDeckConfiguration(
              slideSize: FlutterDeckSlideSize.custom(width: 2560, height: 1440),
            ),
            darkTheme: PresentationTheme.darkTheme,
            lightTheme: PresentationTheme.darkTheme,
            slides: [slide],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(slide.runtimeType), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
