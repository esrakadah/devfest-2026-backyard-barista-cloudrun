import 'dart:convert';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const int _httpOkStatus = 200;
const int _sweetBonusTipAmount = 40;
const Duration _geminiRequestTimeout = Duration(seconds: 8);

/// Evaluates an assembled 2-player cafe tray using Gemini (`gemini-3.5-flash-lite`) structured JSON output,
/// with automatic fallback to `assets/offline_fallback/mock_responses.json` when conference Wi-Fi drops.
class CafeJudgeService {
  CafeJudgeService({
    required DateTime Function() clock,
    http.Client? httpClient,
    this.geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY'),
    this.geminiModel = const String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: 'gemini-3.5-flash-lite',
    ),
    this.forceOfflineMode = const bool.fromEnvironment('OFFLINE_MODE'),
  })  : _clock = clock,
        _httpClient = httpClient;

  final DateTime Function() _clock;
  final http.Client? _httpClient;
  final String geminiApiKey;
  final String geminiModel;
  final bool forceOfflineMode;

  static Map<String, dynamic>? _cachedReviewsByCity;

  /// Evaluates the selected tray ingredients for the active [cityEdition].
  Future<CafeReview> evaluateOrder({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    AssetBundle? bundle,
  }) async {
    final containsSaltPrank = selectedIngredients.any((item) => item.prankKind == 'salt');
    final containsChiliPrank = selectedIngredients.any((item) => item.prankKind == 'chili');

    if (!forceOfflineMode && geminiApiKey.trim().isNotEmpty) {
      final liveReview = await _tryCallGeminiStructuredJson(
        selectedIngredients: selectedIngredients,
        cityEdition: cityEdition,
        containsSaltPrank: containsSaltPrank,
        containsChiliPrank: containsChiliPrank,
      );
      if (liveReview != null) {
        return liveReview;
      }
    }

    return _evaluateFromOfflineFallback(
      cityEdition: cityEdition,
      containsSaltPrank: containsSaltPrank,
      containsChiliPrank: containsChiliPrank,
      bundle: bundle,
    );
  }

  Future<CafeReview?> _tryCallGeminiStructuredJson({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    required bool containsSaltPrank,
    required bool containsChiliPrank,
  }) async {
    final endpointUri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
    );
    final itemDescriptions =
        selectedIngredients.map((item) => '${item.id} (${item.titleEn} / prank=${item.prankKind})').join(', ');

    final promptText = '''
You are the witty food & coffee critic at ${cityEdition.eventTitle} (${cityEdition.cafeSubtitle}).
The 2-player barista team just served a tray with: [$itemDescriptions].
Active city: ${cityEdition.cityName} (${cityEdition.flagEmoji}).
Contains salt prank: $containsSaltPrank. Contains chili prank: $containsChiliPrank.
If a salt or chili prank item is present in a sweet order, you MUST return ratingStars=1, tasteVerdict="salty_sabotage" (or "spicy_chaos"), customerFace="salty_disgusted" (or "shocked"), and a hilarious roast in language "${cityEdition.defaultLanguage}" referencing ${cityEdition.cityName}.
Otherwise return ratingStars=5, tasteVerdict="sweet_perfection", customerFace="happy", and a warm local compliment.
''';

    final requestBody = <String, dynamic>{
      'contents': <Map<String, dynamic>>[
        <String, dynamic>{
          'parts': <Map<String, dynamic>>[
            <String, dynamic>{'text': promptText},
          ],
        },
      ],
      'generationConfig': <String, dynamic>{
        'responseMimeType': 'application/json',
        'responseSchema': <String, dynamic>{
          'type': 'OBJECT',
          'properties': <String, dynamic>{
            'ratingStars': <String, dynamic>{'type': 'INTEGER'},
            'tasteVerdict': <String, dynamic>{'type': 'STRING'},
            'customerFace': <String, dynamic>{'type': 'STRING'},
            'headline': <String, dynamic>{'type': 'STRING'},
            'customerReaction': <String, dynamic>{'type': 'STRING'},
            'cityBonusTip': <String, dynamic>{'type': 'INTEGER'},
          },
          'required': <String>[
            'ratingStars',
            'tasteVerdict',
            'customerFace',
            'headline',
            'customerReaction',
            'cityBonusTip',
          ],
        },
      },
    };

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .post(
            endpointUri,
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_geminiRequestTimeout);

      if (response.statusCode != _httpOkStatus) {
        return null;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = payload['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        return null;
      }
      final firstCandidate = candidates.first;
      if (firstCandidate is! Map<String, dynamic>) {
        return null;
      }
      final contentNode = firstCandidate['content'];
      if (contentNode is! Map<String, dynamic>) {
        return null;
      }
      final partsNode = contentNode['parts'];
      if (partsNode is! List || partsNode.isEmpty) {
        return null;
      }
      final firstPart = partsNode.first;
      if (firstPart is! Map<String, dynamic>) {
        return null;
      }
      final rawJsonText = firstPart['text'] as String?;
      if (rawJsonText == null || rawJsonText.isEmpty) {
        return null;
      }
      final reviewJson = jsonDecode(rawJsonText) as Map<String, dynamic>;
      return CafeReview.fromJson(
        reviewJson,
        evaluatedAt: _clock(),
        isFromLiveGemini: true,
      );
    } on Object {
      return null;
    }
  }

  Future<CafeReview> _evaluateFromOfflineFallback({
    required CityEditionConfig cityEdition,
    required bool containsSaltPrank,
    required bool containsChiliPrank,
    AssetBundle? bundle,
  }) async {
    final verdictKey = containsSaltPrank
        ? 'salty_sabotage'
        : containsChiliPrank
            ? 'spicy_chaos'
            : 'sweet_perfection';

    final effectiveBundle = bundle ?? rootBundle;
    try {
      var reviewsByCity = _cachedReviewsByCity;
      if (reviewsByCity == null) {
        final rawMockString = await effectiveBundle
            .loadString('assets/offline_fallback/mock_responses.json')
            .timeout(const Duration(milliseconds: 250));
        final decodedRoot = jsonDecode(rawMockString) as Map<String, dynamic>;
        final parsedNode = decodedRoot['reviewsByCity'];
        if (parsedNode is Map<String, dynamic>) {
          reviewsByCity = parsedNode;
          _cachedReviewsByCity = parsedNode;
        }
      }
      if (reviewsByCity != null) {
        final cityNode = reviewsByCity[cityEdition.editionId.code];
        if (cityNode is Map<String, dynamic>) {
          final verdictNode = cityNode[verdictKey];
          if (verdictNode is Map<String, dynamic>) {
            return CafeReview.fromJson(
              verdictNode,
              evaluatedAt: _clock(),
              isFromLiveGemini: false,
            );
          }
        }
      }
    } on Object {
      // Fall through to deterministic in-memory review.
    }

    if (containsSaltPrank) {
      return CafeReview(
        ratingStars: minCafeRatingStars,
        tasteVerdict: 'salty_sabotage',
        customerFace: CustomerFaceState.saltyDisgusted,
        headline: '${cityEdition.flagEmoji} ${cityEdition.cityName}: Salt Prank Caught!',
        customerReaction: cityEdition.saltPrankRoast,
        cityBonusTip: 0,
        evaluatedAt: _clock(),
        isFromLiveGemini: false,
      );
    }

    if (containsChiliPrank) {
      return CafeReview(
        ratingStars: minCafeRatingStars,
        tasteVerdict: 'spicy_chaos',
        customerFace: CustomerFaceState.shocked,
        headline: '${cityEdition.flagEmoji} ${cityEdition.cityName}: Chili Prank Caught!',
        customerReaction: cityEdition.chiliPrankRoast,
        cityBonusTip: 0,
        evaluatedAt: _clock(),
        isFromLiveGemini: false,
      );
    }

    return CafeReview(
      ratingStars: maxCafeRatingStars,
      tasteVerdict: 'sweet_perfection',
      customerFace: CustomerFaceState.happy,
      headline: '${cityEdition.flagEmoji} ${cityEdition.cityName}: 5-Star Sweet Perfection!',
      customerReaction: cityEdition.sweetCompliment,
      cityBonusTip: _sweetBonusTipAmount,
      evaluatedAt: _clock(),
      isFromLiveGemini: false,
    );
  }
}
