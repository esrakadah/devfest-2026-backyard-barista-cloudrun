import 'dart:async';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  DateTime fixedClock() => DateTime.utc(2026, 11, 20, 18);

  const rateLimitedStatus = 429;
  const reviewCardFadeOut = Duration(milliseconds: 400);
  final serveButton = find.byKey(const Key('serve_order_button'));
  final serveSpinner = find.descendant(of: serveButton, matching: find.byType(CircularProgressIndicator));
  final reviewCard = find.byKey(const Key('customer_review_card'));

  Future<void> pumpCounter(WidgetTester tester, http.Client httpClient) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      BackyardBaristaApp(
        cityController: CityEditionController(remoteConfigCityCode: 'gaziantep'),
        judgeService: CafeJudgeService(
          clock: fixedClock,
          httpClient: httpClient,
          geminiProxyPath: '/api/gemini/generate',
        ),
      ),
    );
  }

  Future<void> buildSweetTray(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('ingredient_card_espresso')));
    await tester.tap(find.byKey(const Key('ingredient_card_baklava')));
    final sugarJar = find.byKey(const Key('ingredient_card_sugar_jar'));
    await tester.ensureVisible(sugarJar);
    await tester.pumpAndSettle();
    await tester.tap(sugarJar);
    await tester.pumpAndSettle();
    await tester.ensureVisible(serveButton);
    await tester.pumpAndSettle();
  }

  testWidgets('a verdict that arrives after Next Customer is dropped', (tester) async {
    final pendingGeminiReply = Completer<http.Response>();
    await pumpCounter(tester, MockClient((request) => pendingGeminiReply.future));
    await buildSweetTray(tester);

    await tester.tap(serveButton);
    await tester.pump();
    expect(serveSpinner, findsOneWidget);

    final nextCustomerButton = find.byKey(const Key('next_customer_button'));
    await tester.ensureVisible(nextCustomerButton);
    await tester.pump();
    await tester.tap(nextCustomerButton);
    await tester.pump();

    pendingGeminiReply.complete(http.Response('Too Many Requests', rateLimitedStatus));
    await tester.pumpAndSettle();

    expect(reviewCard, findsNothing);
    expect(find.text('Lv.1 Barista'), findsOneWidget);
  });

  testWidgets('Clear tray stops the serve spinner at once, before the late reply arrives', (tester) async {
    final pendingGeminiReply = Completer<http.Response>();
    await pumpCounter(tester, MockClient((request) => pendingGeminiReply.future));
    await buildSweetTray(tester);

    await tester.tap(serveButton);
    await tester.pump();
    expect(serveSpinner, findsOneWidget);

    final clearButton = find.byKey(const Key('clear_tray_button'));
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    await tester.pump();
    final spinnersRightAfterClear = serveSpinner.evaluate().length;

    pendingGeminiReply.complete(http.Response('Too Many Requests', rateLimitedStatus));
    await tester.pumpAndSettle();

    expect(spinnersRightAfterClear, 0);
    expect(reviewCard, findsNothing);
  });

  testWidgets('a second tap on Serve while the jury is thinking sends no second request', (tester) async {
    final pendingGeminiReply = Completer<http.Response>();
    var geminiRequestCount = 0;
    await pumpCounter(
      tester,
      MockClient((request) {
        geminiRequestCount++;
        return pendingGeminiReply.future;
      }),
    );
    await buildSweetTray(tester);

    await tester.tap(serveButton);
    await tester.pump();
    await tester.tap(serveButton, warnIfMissed: false);
    await tester.pump();

    pendingGeminiReply.complete(http.Response('Too Many Requests', rateLimitedStatus));
    await tester.pumpAndSettle();

    expect(geminiRequestCount, 1);
    expect(reviewCard, findsOneWidget);
  });

  testWidgets('serving again hides the previous review while the jury is thinking', (tester) async {
    var pendingGeminiReply = Completer<http.Response>();
    await pumpCounter(tester, MockClient((request) => pendingGeminiReply.future));
    await buildSweetTray(tester);

    await tester.tap(serveButton);
    await tester.pump();
    pendingGeminiReply.complete(http.Response('Too Many Requests', rateLimitedStatus));
    await tester.pumpAndSettle();
    expect(reviewCard, findsOneWidget);

    pendingGeminiReply = Completer<http.Response>();
    await tester.ensureVisible(serveButton);
    await tester.pumpAndSettle();
    await tester.tap(serveButton);
    await tester.pump();
    await tester.pump(reviewCardFadeOut);
    final cardsWhileEvaluating = reviewCard.evaluate().length;

    pendingGeminiReply.complete(http.Response('Too Many Requests', rateLimitedStatus));
    await tester.pumpAndSettle();

    expect(cardsWhileEvaluating, 0);
    expect(reviewCard, findsOneWidget);
  });
}
