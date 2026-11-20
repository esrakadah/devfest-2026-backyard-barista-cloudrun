import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/deck_fonts.dart';

void main() {
  setUpAll(loadDeckFonts);

  const halfSlideWidth = 860.0;
  const codeCardHeight = 420.0;

  Future<void> pumpBlock(WidgetTester tester, Widget block) async {
    tester.view.physicalSize = const Size(DeckCanvas.width, DeckCanvas.height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: DeckColors.navy,
          body: Center(child: SizedBox(width: halfSlideWidth, child: block)),
        ),
      ),
    );
  }

  testWidgets('a code card lights exactly the one line to point at', (tester) async {
    await pumpBlock(
      tester,
      const SizedBox(
        height: codeCardHeight,
        child: LessonCodeCard(
          label: 'ÖNCE',
          filePathLabel: 'cafe_review.dart',
          lines: [
            CodeLine.comment('// eksik alan'),
            CodeLine('final stars = json["ratingStars"];'),
            CodeLine.pointAt('return stars ?? maxCafeRatingStars;'),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('code-line-point-at')), findsOneWidget);
    expect(find.text('return stars ?? maxCafeRatingStars;'), findsOneWidget);
    expect(find.text('ÖNCE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a code line longer than the card is scaled down instead of overflowing', (tester) async {
    await pumpBlock(
      tester,
      SizedBox(
        height: codeCardHeight,
        child: LessonCodeCard(
          label: 'SONRA',
          filePathLabel: 'cafe_judge_service.dart',
          lines: [CodeLine('x' * 200)],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the new word, proof and advanced blocks render their text', (tester) async {
    await pumpBlock(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NewWordCard(word: 'Enum', definition: 'İzin verilen değerlerin kapalı listesi.'),
          ProofStrip(testName: 'a reply with no fields does not score', outcome: 'kırmızı → yeşil'),
          AdvancedNote('exhaustive switch'),
        ],
      ),
    );

    expect(find.text('YENİ KELİME'), findsOneWidget);
    expect(find.text('Enum'), findsOneWidget);
    expect(find.text('a reply with no fields does not score'), findsOneWidget);
    expect(find.text('İleri seviye: exhaustive switch'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
