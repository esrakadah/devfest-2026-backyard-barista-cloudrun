import 'dart:convert';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
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
      expect(review.isFromLiveGemini, isTrue);
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

      expect(review.isFromLiveGemini, isFalse);
      expect(review.tasteVerdict, 'salty_sabotage');
    },
  );
}
