import 'dart:convert';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime fixedClock() => DateTime.utc(2026, 11, 20, 18);

  const geminiProxyPath = '/api/gemini/generate';
  const localJudgeUrl = 'http://localhost:11434/api/chat';
  const rateLimitedStatus = 429;
  final gaziantepEdition = CityEditionController(remoteConfigCityCode: 'gaziantep').activeEdition;
  final sweetTray = <CafeIngredient>[
    IngredientsCatalog.findById('espresso')!,
    IngredientsCatalog.findById('baklava')!,
    IngredientsCatalog.findById('sugar_jar')!,
  ];

  String geminiBody(Map<String, dynamic> review) => jsonEncode(<String, dynamic>{
        'candidates': <Map<String, dynamic>>[
          <String, dynamic>{
            'content': <String, dynamic>{
              'parts': <Map<String, dynamic>>[
                <String, dynamic>{'text': jsonEncode(review)},
              ],
            },
          },
        ],
      });

  group('TasteVerdict', () {
    test('parses every value it can write', () {
      for (final verdict in TasteVerdict.values) {
        expect(TasteVerdict.tryParse(verdict.jsonValue), verdict);
      }
    });

    test('returns null for a typo instead of guessing a verdict', () {
      expect(TasteVerdict.tryParse('sweet_perfction'), isNull);
      expect(TasteVerdict.tryParse(null), isNull);
      expect(TasteVerdict.tryParse(5), isNull);
    });

    test('keeps the verdict that Dart decides out of the list a model may answer with', () {
      expect(TasteVerdict.modelVerdicts, isNot(contains(TasteVerdict.incompleteTray)));
    });
  });

  group('the verdict list cannot drift', () {
    test('the Gemini and the local Gemma schema both allow exactly the model verdicts', () async {
      final sentRequests = <http.Request>[];
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          sentRequests.add(request);
          return http.Response('Too Many Requests', rateLimitedStatus);
        }),
        geminiProxyPath: geminiProxyPath,
        localJudgeUrl: localJudgeUrl,
      );

      await judgeService.evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition);

      final geminiRequest = jsonDecode(sentRequests.first.body) as Map<String, dynamic>;
      final geminiSchema =
          (geminiRequest['generationConfig'] as Map<String, dynamic>)['responseSchema'] as Map<String, dynamic>;
      final geminiVerdict =
          (geminiSchema['properties'] as Map<String, dynamic>)['tasteVerdict'] as Map<String, dynamic>;
      final gemmaRequest = jsonDecode(sentRequests.last.body) as Map<String, dynamic>;
      final gemmaSchema = gemmaRequest['format'] as Map<String, dynamic>;
      final gemmaVerdict = (gemmaSchema['properties'] as Map<String, dynamic>)['tasteVerdict'] as Map<String, dynamic>;

      expect(sentRequests, hasLength(2));
      expect(geminiVerdict['enum'], TasteVerdict.modelJsonValues);
      expect(gemmaVerdict['enum'], TasteVerdict.modelJsonValues);
    });

    test('every city in the bundle has an answer for every model verdict', () async {
      final rawBundle = await rootBundle.loadString('assets/offline_fallback/mock_responses.json');
      final reviewsByCity = (jsonDecode(rawBundle) as Map<String, dynamic>)['reviewsByCity'] as Map<String, dynamic>;

      for (final city in CityEditionId.values) {
        final cityReviews = reviewsByCity[city.code] as Map<String, dynamic>;
        for (final verdict in TasteVerdict.modelVerdicts) {
          final review = CafeReview.tryParse(
            cityReviews[verdict.jsonValue] as Map<String, dynamic>,
            evaluatedAt: fixedClock(),
            source: JudgeSource.offlineBundle,
          );
          expect(review?.tasteVerdict, verdict, reason: '${city.code} ${verdict.jsonValue}');
        }
      }
    });
  });

  group('a verdict outside the list', () {
    test('from Gemini is not shown; the bundled answer is', () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient(
          (request) async => http.Response(
            geminiBody(<String, dynamic>{
              'ratingStars': 5,
              'tasteVerdict': 'sweet_perfction',
              'customerFace': 'happy',
              'headline': 'Typo',
              'customerReaction': 'Harika!',
              'cityBonusTip': 40,
            }),
            200,
          ),
        ),
        geminiProxyPath: geminiProxyPath,
      );

      final review = await judgeService.evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition);

      expect(review.source, JudgeSource.offlineBundle);
      expect(review.tasteVerdict, TasteVerdict.sweetPerfection);
    });
  });
}
