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

  DateTime fixedClock() => DateTime.utc(2026, 11, 20, 18);

  const geminiProxyPath = '/api/gemini/generate';
  const localJudgeUrl = 'http://localhost:11434/api/chat';
  const rateLimitedStatus = 429;
  const absurdTip = 999999;
  final gaziantepEdition = CityEditionController(remoteConfigCityCode: 'gaziantep').activeEdition;
  final sweetTray = <CafeIngredient>[
    IngredientsCatalog.findById('espresso')!,
    IngredientsCatalog.findById('baklava')!,
    IngredientsCatalog.findById('sugar_jar')!,
  ];
  final saltyTray = <CafeIngredient>[
    IngredientsCatalog.findById('espresso')!,
    IngredientsCatalog.findById('baklava')!,
    IngredientsCatalog.findById('salt_shaker')!,
  ];

  Map<String, dynamic> sweetReply() => <String, dynamic>{
        'ratingStars': maxCafeRatingStars,
        'tasteVerdict': TasteVerdict.sweetPerfection.jsonValue,
        'customerFace': CustomerFaceState.happy.jsonValue,
        'headline': 'Live praise',
        'customerReaction': 'Ellerine sağlık!',
        'cityBonusTip': 40,
      };

  Map<String, dynamic> saltyReply() => <String, dynamic>{
        'ratingStars': minCafeRatingStars,
        'tasteVerdict': TasteVerdict.saltySabotage.jsonValue,
        'customerFace': CustomerFaceState.saltyDisgusted.jsonValue,
        'headline': 'Live roast',
        'customerReaction': 'Baklavaya tuz mu?',
        'cityBonusTip': 0,
      };

  http.Response utf8JsonResponse(String body) => http.Response.bytes(
        utf8.encode(body),
        200,
        headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
      );

  Future<CafeReview> judgeWithGeminiReply(Map<String, dynamic> reply, List<CafeIngredient> tray) {
    final geminiBody = jsonEncode(<String, dynamic>{
      'candidates': <Map<String, dynamic>>[
        <String, dynamic>{
          'content': <String, dynamic>{
            'parts': <Map<String, dynamic>>[
              <String, dynamic>{'text': jsonEncode(reply)},
            ],
          },
        },
      ],
    });
    final judgeService = CafeJudgeService(
      clock: fixedClock,
      httpClient: MockClient((request) async => utf8JsonResponse(geminiBody)),
      geminiProxyPath: geminiProxyPath,
    );
    return judgeService.evaluateOrder(selectedIngredients: tray, cityEdition: gaziantepEdition);
  }

  group('a complete reply that agrees with the tray', () {
    test('is shown as the live Gemini verdict for a sweet tray', () async {
      final review = await judgeWithGeminiReply(sweetReply(), sweetTray);

      expect(review.source, JudgeSource.liveGemini);
      expect(review.headline, 'Live praise');
      expect(review.ratingStars, maxCafeRatingStars);
    });

    test('is shown as the live Gemini verdict for a salt tray', () async {
      final review = await judgeWithGeminiReply(saltyReply(), saltyTray);

      expect(review.source, JudgeSource.liveGemini);
      expect(review.headline, 'Live roast');
    });
  });

  group('a reply with holes is not a verdict', () {
    test('a Gemini reply with no fields does not score a sweet tray', () async {
      final review = await judgeWithGeminiReply(<String, dynamic>{}, sweetTray);

      expect(review.source, JudgeSource.offlineBundle);
    });

    for (final missingField in sweetReply().keys) {
      test('a sweet reply without $missingField falls back to the bundle', () async {
        final review = await judgeWithGeminiReply(sweetReply()..remove(missingField), sweetTray);

        expect(review.source, JudgeSource.offlineBundle);
      });
    }

    test('stars sent as text are not read as 5 stars', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['ratingStars'] = 'five', sweetTray);

      expect(review.source, JudgeSource.offlineBundle);
    });

    test('stars outside 1 to 5 are rejected instead of rounded into range', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['ratingStars'] = 9, sweetTray);

      expect(review.source, JudgeSource.offlineBundle);
    });

    test('an empty reaction text is rejected', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['customerReaction'] = '  ', sweetTray);

      expect(review.source, JudgeSource.offlineBundle);
    });

    test('a local Gemma reply with no fields does not score a sweet tray either', () async {
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        httpClient: MockClient((request) async {
          if (request.url.path == geminiProxyPath) {
            return http.Response('Too Many Requests', rateLimitedStatus);
          }
          return utf8JsonResponse(
            jsonEncode(<String, dynamic>{
              'message': <String, dynamic>{'role': 'assistant', 'content': '{}'},
            }),
          );
        }),
        geminiProxyPath: geminiProxyPath,
        localJudgeUrl: localJudgeUrl,
      );

      final review = await judgeService.evaluateOrder(selectedIngredients: sweetTray, cityEdition: gaziantepEdition);

      expect(review.source, JudgeSource.offlineBundle);
    });
  });

  group('stars must agree with the verdict', () {
    test('a salt verdict that still awards 5 stars is rejected', () async {
      final review = await judgeWithGeminiReply(saltyReply()..['ratingStars'] = maxCafeRatingStars, saltyTray);

      expect(review.source, JudgeSource.offlineBundle);
      expect(review.ratingStars, minCafeRatingStars);
    });

    test('a sweet verdict with 1 star is rejected', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['ratingStars'] = minCafeRatingStars, sweetTray);

      expect(review.source, JudgeSource.offlineBundle);
      expect(review.ratingStars, maxCafeRatingStars);
    });
  });

  group('the tip a model invents is bounded', () {
    test('an absurd tip is capped at the largest tip the game pays', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['cityBonusTip'] = absurdTip, sweetTray);

      expect(review.source, JudgeSource.liveGemini);
      expect(review.cityBonusTip, maxCityBonusTip);
    });

    test('a negative tip takes nothing out of the jar', () async {
      final review = await judgeWithGeminiReply(sweetReply()..['cityBonusTip'] = -absurdTip, sweetTray);

      expect(review.source, JudgeSource.liveGemini);
      expect(review.cityBonusTip, 0);
    });
  });
}
