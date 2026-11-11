import 'dart:convert';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime fixedClock() => DateTime.utc(2026, 11, 15, 14);

  final saltyTray = <CafeIngredient>[
    IngredientsCatalog.findById('baklava')!,
    IngredientsCatalog.findById('salt_shaker')!,
  ];
  final gaziantepEdition = CityEditionController(
    remoteConfigCityCode: 'gaziantep',
  ).activeEdition;

  String geminiResponseBody() => jsonEncode(<String, dynamic>{
        'candidates': <Map<String, dynamic>>[
          <String, dynamic>{
            'content': <String, dynamic>{
              'parts': <Map<String, dynamic>>[
                <String, dynamic>{
                  'text': jsonEncode(<String, dynamic>{
                    'ratingStars': 1,
                    'tasteVerdict': 'salty_sabotage',
                    'customerFace': 'salty_disgusted',
                    'headline': 'Live Gemini roast',
                    'customerReaction': 'Baklavaya tuz mu?',
                    'cityBonusTip': 0,
                  }),
                },
              ],
            },
          },
        ],
      });

  test(
    'Proxy mode posts to the same-origin route without an API key, even when no key is compiled in',
    () async {
      late http.Request capturedRequest;
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(geminiResponseBody(), 200);
        }),
        geminiProxyPath: '/api/gemini/generate',
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(capturedRequest.url.path, '/api/gemini/generate');
      expect(capturedRequest.url.queryParameters.containsKey('key'), isFalse);
      expect(review.source, JudgeSource.liveGemini);
      expect(review.headline, 'Live Gemini roast');
    },
  );

  test(
    'Proxy errors such as a 429 rate limit fall back to the offline roast',
    () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient(
          (request) async => http.Response('Too Many Requests', 429),
        ),
        geminiProxyPath: '/api/gemini/generate',
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(review.source, JudgeSource.offlineBundle);
      expect(review.tasteVerdict, 'salty_sabotage');
    },
  );

  group('Local Gemma judge', () {
    const localJudgeUrl = 'http://localhost:11434/api/chat';

    String ollamaResponseBody({required String tasteVerdict}) => jsonEncode(<String, dynamic>{
          'model': 'gemma4:12b-it-qat',
          'message': <String, dynamic>{
            'role': 'assistant',
            'content': jsonEncode(<String, dynamic>{
              'ratingStars': tasteVerdict == 'sweet_perfection' ? 5 : 1,
              'tasteVerdict': tasteVerdict,
              'customerFace': tasteVerdict == 'sweet_perfection' ? 'happy' : 'salty_disgusted',
              'headline': 'Local Gemma roast',
              'customerReaction': 'Baklavaya tuz, Antep ağlar!',
              'cityBonusTip': 0,
            }),
          },
          'done': true,
        });

    http.Response ollamaResponse(String tasteVerdict) => http.Response(
          ollamaResponseBody(tasteVerdict: tasteVerdict),
          200,
          headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
        );

    MockClient geminiDownLocalAnswers(String tasteVerdict, {List<http.Request>? localRequests}) {
      return MockClient((request) async {
        if (request.url.host == 'localhost') {
          localRequests?.add(request);
          return ollamaResponse(tasteVerdict);
        }
        return http.Response('Too Many Requests', 429);
      });
    }

    test('answers when Gemini fails and the verdict matches the salt prank', () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: geminiDownLocalAnswers('salty_sabotage'),
        geminiProxyPath: '/api/gemini/generate',
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(review.source, JudgeSource.localGemma);
      expect(review.tasteVerdict, 'salty_sabotage');
      expect(review.headline, 'Local Gemma roast');
    });

    test('runs in OFFLINE_MODE, which only skips the cloud call', () async {
      final requestedHosts = <String>[];
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          requestedHosts.add(request.url.host);
          return ollamaResponse('salty_sabotage');
        }),
        geminiApiKey: 'test-key',
        forceOfflineMode: true,
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(requestedHosts, <String>['localhost']);
      expect(review.source, JudgeSource.localGemma);
    });

    test('a verdict that misses the salt prank falls back to the offline bundle', () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: geminiDownLocalAnswers('sweet_perfection'),
        geminiProxyPath: '/api/gemini/generate',
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(review.source, JudgeSource.offlineBundle);
      expect(review.tasteVerdict, 'salty_sabotage');
    });

    test('an unreachable Ollama falls back to the offline bundle', () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          throw http.ClientException('Connection refused', request.url);
        }),
        geminiProxyPath: '/api/gemini/generate',
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(review.source, JudgeSource.offlineBundle);
    });

    test('without LOCAL_JUDGE_URL no request reaches localhost', () async {
      final localRequests = <http.Request>[];
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: geminiDownLocalAnswers('salty_sabotage', localRequests: localRequests),
        geminiProxyPath: '/api/gemini/generate',
      );

      final review = await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      expect(localRequests, isEmpty);
      expect(review.source, JudgeSource.offlineBundle);
    });

    test('sends thinking off, no streaming and the verdict schema', () async {
      final localRequests = <http.Request>[];
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: geminiDownLocalAnswers('salty_sabotage', localRequests: localRequests),
        geminiProxyPath: '/api/gemini/generate',
        localJudgeUrl: localJudgeUrl,
      );

      await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      final sentBody = jsonDecode(localRequests.single.body) as Map<String, dynamic>;
      final schema = sentBody['format'] as Map<String, dynamic>;
      final verdictProperty = (schema['properties'] as Map<String, dynamic>)['tasteVerdict'] as Map<String, dynamic>;
      expect(localRequests.single.url.toString(), localJudgeUrl);
      expect(sentBody['model'], 'gemma4:12b-it-qat');
      expect(sentBody['think'], isFalse);
      expect(sentBody['stream'], isFalse);
      expect(verdictProperty['enum'], contains('salty_sabotage'));
    });

    test('names the language instead of sending a bare code', () async {
      final localRequests = <http.Request>[];
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: geminiDownLocalAnswers('salty_sabotage', localRequests: localRequests),
        geminiProxyPath: '/api/gemini/generate',
        localJudgeUrl: localJudgeUrl,
      );

      await judgeService.evaluateOrder(
        selectedIngredients: saltyTray,
        cityEdition: gaziantepEdition,
      );

      final sentBody = jsonDecode(localRequests.single.body) as Map<String, dynamic>;
      final prompt = ((sentBody['messages'] as List<dynamic>).single as Map<String, dynamic>)['content'] as String;
      expect(prompt, contains('Write headline and customerReaction in Turkish (Türkçe) only.'));
    });
  });
}
