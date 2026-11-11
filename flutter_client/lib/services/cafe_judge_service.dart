import 'dart:convert';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const int _httpOkStatus = 200;
const int _sweetBonusTipAmount = 40;
const Duration _geminiRequestTimeout = Duration(seconds: 8);
const Duration _offlineBundleLoadTimeout = Duration(milliseconds: 250);

/// One verdict is ~115 output tokens; a warm gemma4:12b-it-qat on an M3 Pro writes ~15 tok/s with thinking
/// off, so ~9 s end to end (measured 11 Nov 2026).
const Duration _localJudgeRequestTimeout = Duration(seconds: 15);

const Map<String, dynamic> _localJudgeJsonSchema = <String, dynamic>{
  'type': 'object',
  'properties': <String, dynamic>{
    'ratingStars': <String, dynamic>{'type': 'integer', 'minimum': minCafeRatingStars, 'maximum': maxCafeRatingStars},
    'tasteVerdict': <String, dynamic>{
      'type': 'string',
      'enum': <String>['sweet_perfection', 'salty_sabotage', 'spicy_chaos'],
    },
    'customerFace': <String, dynamic>{
      'type': 'string',
      'enum': <String>['happy', 'shocked', 'salty_disgusted'],
    },
    'headline': <String, dynamic>{'type': 'string'},
    'customerReaction': <String, dynamic>{'type': 'string'},
    'cityBonusTip': <String, dynamic>{'type': 'integer'},
  },
  'required': <String>['ratingStars', 'tasteVerdict', 'customerFace', 'headline', 'customerReaction', 'cityBonusTip'],
};

/// Evaluates an assembled 2-player cafe tray using Gemini (`gemini-3.5-flash-lite`) structured JSON output,
/// then a local Gemma 4 through Ollama when [localJudgeUrl] is set, and finally
/// `assets/offline_fallback/mock_responses.json` when conference Wi-Fi drops.
///
/// When [geminiProxyPath] is set (the Cloud Run image sets `/api/gemini/generate`), requests go to that
/// same-origin nginx route, which adds the API key server-side, so the web build never contains the key.
///
/// [localJudgeUrl] (for example `http://localhost:11434/api/chat`) is meant for the stage laptop: Ollama
/// accepts browser calls from a `localhost` origin and rejects the Cloud Run origin.
class CafeJudgeService {
  CafeJudgeService({
    required DateTime Function() clock,
    http.Client? httpClient,
    this.geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY'),
    this.geminiModel = const String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: 'gemini-3.5-flash-lite',
    ),
    this.geminiProxyPath = const String.fromEnvironment('GEMINI_PROXY_PATH'),
    this.forceOfflineMode = const bool.fromEnvironment('OFFLINE_MODE'),
    this.localJudgeUrl = const String.fromEnvironment('LOCAL_JUDGE_URL'),
    this.localJudgeModel = const String.fromEnvironment(
      'LOCAL_JUDGE_MODEL',
      defaultValue: 'gemma4:12b-it-qat',
    ),
  })  : _clock = clock,
        _httpClient = httpClient;

  final DateTime Function() _clock;
  final http.Client? _httpClient;
  final String geminiApiKey;
  final String geminiModel;
  final String geminiProxyPath;

  /// Skips the cloud call only; the local judge still runs, which is the Wi-Fi-off stage case.
  final bool forceOfflineMode;
  final String localJudgeUrl;
  final String localJudgeModel;

  bool get _usesServerSideProxy => geminiProxyPath.trim().isNotEmpty;

  static Map<String, dynamic>? _cachedReviewsByCity;

  /// Evaluates the selected tray ingredients for the active [cityEdition].
  /// Enforces prank detection first (`salty_sabotage` / `spicy_chaos`), then verifies
  /// that all 3 cafe stations (Drink + Pastry + Sweet Sugar) are represented on the tray.
  Future<CafeReview> evaluateOrder({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    AssetBundle? bundle,
  }) async {
    final containsSaltPrank = selectedIngredients.any((item) => item.prankKind == 'salt');
    final containsChiliPrank = selectedIngredients.any((item) => item.prankKind == 'chili');
    final hasDrinkCourse = selectedIngredients.any((item) => item.category == IngredientCategory.drink);
    final hasFoodCourse = selectedIngredients.any((item) => item.category == IngredientCategory.food);
    final hasSweetCondiment = selectedIngredients.any(
      (item) => item.category == IngredientCategory.toppingOrPrank && !item.isPrankItem,
    );
    final isCompleteThreeCourseTray = hasDrinkCourse && hasFoodCourse && hasSweetCondiment;

    if (!containsSaltPrank && !containsChiliPrank && !isCompleteThreeCourseTray) {
      final isEnglish = cityEdition.defaultLanguage == 'en';
      final drinkCourseLabel = isEnglish ? 'Coffee/Drink' : 'Kahve/İçecek';
      final foodCourseLabel = isEnglish ? 'Pastry' : 'Tatlı';
      final sweetCondimentLabel = isEnglish ? 'Sweet Sugar' : 'Tatlı Şeker';
      final missingStations = <String>[
        if (!hasDrinkCourse) drinkCourseLabel,
        if (!hasFoodCourse) foodCourseLabel,
        if (!hasSweetCondiment) sweetCondimentLabel,
      ].join(' + ');

      return CafeReview(
        ratingStars: 3,
        tasteVerdict: 'incomplete_tray',
        customerFace: CustomerFaceState.shocked,
        headline:
            isEnglish ? '${cityEdition.cityName}: Incomplete Tray!' : '${cityEdition.cityName}: Tepside Eksik Var!',
        customerReaction: isEnglish
            ? 'Wait a second! You forgot ($missingStations) on the tray. Plate all 3 stations for 5 stars!'
            : 'Usta tepside ($missingStations) eksik kalmış! 5 yıldız için içecek, tatlı ve şekeri birlikte dizin!',
        cityBonusTip: 0,
        evaluatedAt: _clock(),
        source: JudgeSource.offlineBundle,
      );
    }

    if (!forceOfflineMode && (_usesServerSideProxy || geminiApiKey.trim().isNotEmpty)) {
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

    if (localJudgeUrl.trim().isNotEmpty) {
      final localReview = await _tryCallLocalGemma(
        selectedIngredients: selectedIngredients,
        cityEdition: cityEdition,
        containsSaltPrank: containsSaltPrank,
        containsChiliPrank: containsChiliPrank,
      );
      if (localReview != null &&
          _verdictMatchesPranks(
            localReview,
            containsSaltPrank: containsSaltPrank,
            containsChiliPrank: containsChiliPrank,
          )) {
        return localReview;
      }
    }

    return _evaluateFromOfflineFallback(
      cityEdition: cityEdition,
      containsSaltPrank: containsSaltPrank,
      containsChiliPrank: containsChiliPrank,
      bundle: bundle,
    );
  }

  /// The prank flags are decided in Dart and stated as rules, so the model only writes the roast.
  String _buildJudgePrompt({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    required bool containsSaltPrank,
    required bool containsChiliPrank,
  }) {
    final itemDescriptions =
        selectedIngredients.map((item) => '${item.id} (${item.titleEn} / prank=${item.prankKind})').join(', ');

    return '''
You are the witty food & coffee critic at ${cityEdition.eventTitle} (${cityEdition.cafeSubtitle}).
The 2-player barista team just served a tray with: [$itemDescriptions].
Active city: ${cityEdition.cityName} (${cityEdition.flagEmoji}).
Contains salt prank: $containsSaltPrank. Contains chili prank: $containsChiliPrank.
If a salt or chili prank item is present in a sweet order, you MUST return ratingStars=1, tasteVerdict="salty_sabotage" (or "spicy_chaos"), customerFace="salty_disgusted" (or "shocked"), and a hilarious roast in language "${cityEdition.defaultLanguage}" referencing ${cityEdition.cityName}.
Otherwise return ratingStars=5, tasteVerdict="sweet_perfection", customerFace="happy", and a warm local compliment.
''';
  }

  Future<CafeReview?> _tryCallGeminiStructuredJson({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    required bool containsSaltPrank,
    required bool containsChiliPrank,
  }) async {
    final endpointUri = _usesServerSideProxy
        ? Uri.base.resolve(geminiProxyPath.trim())
        : Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent',
          );
    final promptText = _buildJudgePrompt(
      selectedIngredients: selectedIngredients,
      cityEdition: cityEdition,
      containsSaltPrank: containsSaltPrank,
      containsChiliPrank: containsChiliPrank,
    );

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

    final shouldCloseClient = _httpClient == null;
    final client = _httpClient ?? http.Client();
    try {
      final response = await client
          .post(
            endpointUri,
            // The key travels in a header when calling Gemini directly, and is injected server-side in proxy mode.
            headers: <String, String>{
              'Content-Type': 'application/json',
              if (!_usesServerSideProxy && geminiApiKey.trim().isNotEmpty) 'x-goog-api-key': geminiApiKey,
            },
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
        source: JudgeSource.liveGemini,
      );
    } on Object {
      return null;
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// Ollama `/api/chat` with a JSON schema in `format`; thinking off keeps a verdict near 9 s instead of a minute.
  Future<CafeReview?> _tryCallLocalGemma({
    required List<CafeIngredient> selectedIngredients,
    required CityEditionConfig cityEdition,
    required bool containsSaltPrank,
    required bool containsChiliPrank,
  }) async {
    final requestBody = <String, dynamic>{
      'model': localJudgeModel,
      'stream': false,
      'think': false,
      'format': _localJudgeJsonSchema,
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{
          'role': 'user',
          'content': _buildJudgePrompt(
            selectedIngredients: selectedIngredients,
            cityEdition: cityEdition,
            containsSaltPrank: containsSaltPrank,
            containsChiliPrank: containsChiliPrank,
          ),
        },
      ],
    };

    final shouldCloseClient = _httpClient == null;
    final client = _httpClient ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(localJudgeUrl.trim()),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_localJudgeRequestTimeout);

      if (response.statusCode != _httpOkStatus) {
        return null;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final messageNode = payload['message'];
      if (messageNode is! Map<String, dynamic>) {
        return null;
      }
      final rawJsonText = messageNode['content'] as String?;
      if (rawJsonText == null || rawJsonText.isEmpty) {
        return null;
      }
      final reviewJson = jsonDecode(rawJsonText) as Map<String, dynamic>;
      return CafeReview.fromJson(
        reviewJson,
        evaluatedAt: _clock(),
        source: JudgeSource.localGemma,
      );
    } on Object {
      return null;
    } finally {
      if (shouldCloseClient) {
        client.close();
      }
    }
  }

  /// A small local model can miss the prank even when the prompt states it, so its verdict must agree
  /// with the flags decided in Dart before it reaches the screen.
  bool _verdictMatchesPranks(
    CafeReview review, {
    required bool containsSaltPrank,
    required bool containsChiliPrank,
  }) {
    if (!containsSaltPrank && !containsChiliPrank) {
      return review.tasteVerdict == 'sweet_perfection';
    }
    return (containsSaltPrank && review.tasteVerdict == 'salty_sabotage') ||
        (containsChiliPrank && review.tasteVerdict == 'spicy_chaos');
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
            .timeout(_offlineBundleLoadTimeout);
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
              source: JudgeSource.offlineBundle,
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
        headline: '${cityEdition.cityName}: Salt Prank Caught!',
        customerReaction: cityEdition.saltPrankRoast,
        cityBonusTip: 0,
        evaluatedAt: _clock(),
        source: JudgeSource.offlineBundle,
      );
    }

    if (containsChiliPrank) {
      return CafeReview(
        ratingStars: minCafeRatingStars,
        tasteVerdict: 'spicy_chaos',
        customerFace: CustomerFaceState.shocked,
        headline: '${cityEdition.cityName}: Chili Prank Caught!',
        customerReaction: cityEdition.chiliPrankRoast,
        cityBonusTip: 0,
        evaluatedAt: _clock(),
        source: JudgeSource.offlineBundle,
      );
    }

    return CafeReview(
      ratingStars: maxCafeRatingStars,
      tasteVerdict: 'sweet_perfection',
      customerFace: CustomerFaceState.happy,
      headline: '${cityEdition.cityName}: 5-Star Sweet Perfection!',
      customerReaction: cityEdition.sweetCompliment,
      cityBonusTip: _sweetBonusTipAmount,
      evaluatedAt: _clock(),
      source: JudgeSource.offlineBundle,
    );
  }
}
