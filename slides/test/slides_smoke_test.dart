import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
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

  group('the lesson slides of the Turkish talk', () {
    const ruleSentences = <String, FlutterDeckSlideWidget>{
      'Model önerir, kararı kod verir': GuardRuleSlide(),
      'Serbest metin yerine kapalı liste': TypedOutputRuleSlide(),
      'Olmaması gereken durum, yazılamasın': OrderStateRuleSlide(),
      'Model susarsa oyun susmaz': FallbackRuleSlide(),
      'Anahtar sunucuda kalır': KeyRuleSlide(),
    };

    for (final MapEntry(key: ruleSentence, value: slide) in ruleSentences.entries) {
      testWidgets('"$ruleSentence" is the title of its rule slide and defines one new word', (tester) async {
        await pumpSlide(tester, slide);

        expect(find.text(ruleSentence), findsOneWidget);
        expect(find.byType(NewWordCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    const codeSlides = <FlutterDeckSlideWidget>[
      GuardBeforeAfterSlide(),
      EnumFeedsSchemaSlide(),
      EmptyReplySlide(),
      ForgottenLineSlide(),
      SealedOrderSlide(),
      HallLoadTestSlide(),
      KeyRuleSlide(),
    ];

    for (final slide in codeSlides) {
      testWidgets('${slide.runtimeType} lights one line to point at in each code card that has one', (tester) async {
        await pumpSlide(tester, slide);

        final codeCards = tester.widgetList<LessonCodeCard>(find.byType(LessonCodeCard)).toList();
        expect(codeCards, isNotEmpty);
        for (final card in codeCards) {
          final pointedLines = card.lines.where((line) => line.kind == CodeLineKind.pointAt);
          expect(pointedLines.length, lessThanOrEqualTo(1), reason: '${card.label} points at more than one line');
        }
        expect(find.byKey(const ValueKey<String>('code-line-point-at')), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'OrderStateRuleSlide steps from neutral combinations to red invalid rows to crossed-out sealed states at 2560x1440',
      (tester) async {
        const slide = OrderStateRuleSlide();
        expect(slide.configuration?.steps, 3);

        await pumpSlide(tester, slide);

        // Step 1: all 5 combinations neutral, right panel waiting.
        expect(find.text('5 KOMBİNASYON'), findsOneWidget);
        expect(find.text('BİRAZDAN'), findsOneWidget);
        expect(find.textContaining('Hangileri gerçekte olmamalı?'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
        expect(find.byIcon(Icons.error_rounded), findsNothing);
        expect(find.byIcon(Icons.block_rounded), findsNothing);
        expect(find.text('OrderIdle'), findsNothing);
        expect(find.text('YAZILAMAZ'), findsNothing);
        expect(tester.takeException(), isNull);

        // Step 2: valid rows turn green, 2 invalid rows light up red, right panel stays dimmed.
        tester.element(find.byType(OrderStateDiagram)).flutterDeck.next();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('2 SAÇMA DURUM YAZILABİLİYORDU'), findsOneWidget);
        expect(find.text('BİRAZDAN'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
        expect(find.byIcon(Icons.error_rounded), findsNWidgets(2));
        expect(find.text('Jüride ama kart ekranda?'), findsOneWidget);
        expect(find.text('Boş tepsiye 5 yıldız!'), findsOneWidget);
        expect(find.textContaining('bir unutulan sıfırlama satırı yetiyor.'), findsOneWidget);
        expect(find.text('OrderIdle'), findsNothing);
        expect(tester.takeException(), isNull);

        // Step 3: invalid rows are crossed out as YAZILAMAZ and the 3 sealed subtypes appear.
        tester.element(find.byType(OrderStateDiagram)).flutterDeck.next();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('SEALED İLE 2 SAÇMA DURUM YAZILAMAZ'), findsOneWidget);
        expect(find.text('3 HAL'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
        expect(find.byIcon(Icons.block_rounded), findsNWidgets(2));
        expect(find.text('YAZILAMAZ'), findsNWidgets(2));
        expect(find.text('OrderIdle'), findsOneWidget);
        expect(find.text('OrderEvaluating'), findsOneWidget);
        expect(find.text('OrderServed + kart'), findsOneWidget);
        expect(find.text('Dördüncü hal yok: yazmaya kalkarsan derlenmez.'), findsOneWidget);
        final crossedOutTexts = tester
            .widgetList<Text>(find.byType(Text))
            .where((text) => text.style?.decoration == TextDecoration.lineThrough)
            .toList();
        expect(crossedOutTexts, hasLength(2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('standalone OrderStateDiagram defaults to sealedStates cleanly at 2560x1440', (tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: DeckColors.navy,
            body: SizedBox(width: 1760, height: 620, child: OrderStateDiagram()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SEALED İLE 2 SAÇMA DURUM YAZILAMAZ'), findsOneWidget);
      expect(find.text('OrderIdle'), findsOneWidget);
      expect(find.text('YAZILAMAZ'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('Updated Slides Smoke Tests', () {
    testWidgets('PureFlutterWidgetsSlide renders Hybrid Flame Engine + Flutter HUD Architecture', (tester) async {
      const slide = PureFlutterWidgetsSlide();
      expect(slide.configuration?.route, '/pure-flutter-widgets');

      await pumpSlide(tester, slide);

      expect(
        find.text(
          isTurkishDeck ? 'Oyun sahnesi Flame, butonlar Flutter' : 'Hybrid Flame Engine + Flutter HUD Architecture',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('BaristaFlameGame'), findsWidgets);
      expect(find.textContaining(isTurkishDeck ? 'raflar ve tepsi' : '2x2 Counter Grid'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SaltSugarMechanicSlide renders the CafeReview schema and the verdict guard', (tester) async {
      const slide = SaltSugarMechanicSlide();
      expect(slide.configuration?.route, '/salt-sugar-mechanic');

      await pumpSlide(tester, slide);

      expect(find.textContaining('Web NFC'), findsWidgets);
      expect(find.textContaining('NDEFReader'), findsWidgets);
      expect(find.textContaining('_verdictMatchesPranks'), findsWidgets);
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
