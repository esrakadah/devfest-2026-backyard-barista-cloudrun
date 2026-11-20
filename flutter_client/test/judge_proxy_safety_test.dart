import 'dart:async';
import 'dart:io';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime fixedClock() => DateTime.utc(2026, 11, 20, 18);

  const geminiProxyPath = '/api/gemini/generate';
  const localJudgeUrl = 'http://localhost:11434/api/chat';
  const rateLimitedStatus = 429;
  const justUnderGeminiLimit = Duration(seconds: 7);
  const restOfGeminiLimit = Duration(seconds: 2);
  const justUnderLocalJudgeLimit = Duration(seconds: 14);
  const restOfLocalJudgeLimit = Duration(seconds: 2);
  const bundleLoadLimit = Duration(milliseconds: 250);
  final gaziantepEdition = CityEditionController(remoteConfigCityCode: 'gaziantep').activeEdition;
  final sweetTray = <CafeIngredient>[
    IngredientsCatalog.findById('espresso')!,
    IngredientsCatalog.findById('baklava')!,
    IngredientsCatalog.findById('sugar_jar')!,
  ];

  group('the key stays on the server', () {
    test('proxy mode sends no API key in a header, the address or the body, even when a key is compiled in', () async {
      const compiledInKey = 'not-a-real-key-only-for-this-test';
      late http.Request sentRequest;
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          sentRequest = request;
          return http.Response('Too Many Requests', rateLimitedStatus);
        }),
        geminiApiKey: compiledInKey,
        geminiProxyPath: geminiProxyPath,
      );

      await judgeService.evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition);

      final headerNames = sentRequest.headers.keys.map((name) => name.toLowerCase());
      expect(sentRequest.url.path, geminiProxyPath);
      expect(headerNames, isNot(contains('x-goog-api-key')));
      expect(sentRequest.headers.values, isNot(contains(compiledInKey)));
      expect(sentRequest.url.toString(), isNot(contains(compiledInKey)));
      expect(sentRequest.body, isNot(contains(compiledInKey)));
    });

    test('the Cloud Run image is built without the key and nginx adds it per request', () {
      final dockerfile = File('Dockerfile').readAsStringSync();
      final nginxTemplate = File('nginx/default.conf.template').readAsStringSync();

      expect(dockerfile, contains('--dart-define=GEMINI_PROXY_PATH=$geminiProxyPath'));
      expect(dockerfile, isNot(contains('GEMINI_API_KEY')));
      expect(nginxTemplate, contains('location = $geminiProxyPath'));
      expect(nginxTemplate, contains(r'proxy_set_header x-goog-api-key "${GEMINI_API_KEY}";'));
    });
  });

  group('the model is called once per serve and never earlier', () {
    testWidgets('building, changing and clearing a tray sends no request; serving it sends one', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var modelRequestCount = 0;
      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'gaziantep'),
          judgeService: CafeJudgeService(
            clock: fixedClock,
            httpClient: MockClient((request) async {
              modelRequestCount++;
              return http.Response('Too Many Requests', rateLimitedStatus);
            }),
            geminiProxyPath: geminiProxyPath,
          ),
        ),
      );

      Future<void> tapIngredient(String ingredientId) async {
        final card = find.byKey(Key('ingredient_card_$ingredientId'));
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
      }

      await tapIngredient('espresso');
      await tapIngredient('baklava');
      await tapIngredient('salt_shaker');
      await tapIngredient('sugar_jar');
      final clearButton = find.byKey(const Key('clear_tray_button'));
      await tester.ensureVisible(clearButton);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
      await tapIngredient('espresso');
      await tapIngredient('baklava');
      await tapIngredient('sugar_jar');
      expect(modelRequestCount, 0);

      final serveButton = find.byKey(const Key('serve_order_button'));
      await tester.ensureVisible(serveButton);
      await tester.pumpAndSettle();
      await tester.tap(serveButton);
      await tester.pumpAndSettle();
      expect(modelRequestCount, 1);
    });

    test('a tray with a missing station is answered in Dart without a request', () async {
      var modelRequestCount = 0;
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          modelRequestCount++;
          return http.Response('Too Many Requests', rateLimitedStatus);
        }),
        geminiProxyPath: geminiProxyPath,
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: <CafeIngredient>[IngredientsCatalog.findById('espresso')!],
        cityEdition: gaziantepEdition,
      );

      expect(modelRequestCount, 0);
      expect(review.isIncompleteTray, isTrue);
    });
  });

  group('a judge that never answers does not hold the game', () {
    testWidgets('Gemini is given 8 seconds, then the bundled answer is served', (tester) async {
      final geminiNeverAnswers = Completer<http.Response>();
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) => geminiNeverAnswers.future),
        geminiProxyPath: geminiProxyPath,
      );

      CafeReview? review;
      unawaited(
        judgeService
            .evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition)
            .then((answer) => review = answer),
      );

      await tester.pump(justUnderGeminiLimit);
      expect(review, isNull);

      await tester.pump(restOfGeminiLimit);
      await tester.pump(bundleLoadLimit);
      expect(review?.source, JudgeSource.offlineBundle);
    });

    testWidgets('the local judge is given 15 seconds, then the bundled answer is served', (tester) async {
      final localJudgeNeverAnswers = Completer<http.Response>();
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) {
          if (request.url.path == geminiProxyPath) {
            return Future<http.Response>.value(http.Response('Too Many Requests', rateLimitedStatus));
          }
          return localJudgeNeverAnswers.future;
        }),
        geminiProxyPath: geminiProxyPath,
        localJudgeUrl: localJudgeUrl,
      );

      CafeReview? review;
      unawaited(
        judgeService
            .evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition)
            .then((answer) => review = answer),
      );

      await tester.pump(justUnderLocalJudgeLimit);
      expect(review, isNull);

      await tester.pump(restOfLocalJudgeLimit);
      await tester.pump(bundleLoadLimit);
      expect(review?.source, JudgeSource.offlineBundle);
    });
  });
}
