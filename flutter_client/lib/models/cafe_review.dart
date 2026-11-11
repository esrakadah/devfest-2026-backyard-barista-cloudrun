import 'package:flutter/foundation.dart';

/// Minimum and maximum rating star bounds returned by the Gemini cafe judge.
const int minCafeRatingStars = 1;
const int maxCafeRatingStars = 5;

/// Deterministic customer face state mapped to `assets/base/customers/*.png`.
enum CustomerFaceState {
  happy('happy', 'assets/base/customers/customer_happy.png'),
  shocked('shocked', 'assets/base/customers/customer_shocked.png'),
  saltyDisgusted('salty_disgusted', 'assets/base/customers/customer_salty_disgusted.png');

  const CustomerFaceState(this.jsonValue, this.assetPath);

  final String jsonValue;
  final String assetPath;

  static CustomerFaceState fromJsonValue(String? rawValue) {
    for (final candidate in CustomerFaceState.values) {
      if (candidate.jsonValue == rawValue) {
        return candidate;
      }
    }
    return CustomerFaceState.happy;
  }
}

/// Which judge produced a [CafeReview], shown as the judge badge under the verdict.
enum JudgeSource { liveGemini, localGemma, offlineBundle }

/// Structured JSON verdict returned by Gemini (`gemini-3.5-flash-lite`) or the offline fallback.
@immutable
class CafeReview {
  const CafeReview({
    required this.ratingStars,
    required this.tasteVerdict,
    required this.customerFace,
    required this.headline,
    required this.customerReaction,
    required this.cityBonusTip,
    required this.evaluatedAt,
    required this.source,
  });

  factory CafeReview.fromJson(
    Map<String, dynamic> jsonMap, {
    required DateTime evaluatedAt,
    required JudgeSource source,
  }) {
    final rawStars = jsonMap['ratingStars'];
    final parsedStars = rawStars is num ? rawStars.toInt() : maxCafeRatingStars;
    final clampedStars = parsedStars.clamp(minCafeRatingStars, maxCafeRatingStars);
    final rawTip = jsonMap['cityBonusTip'];
    final parsedTip = rawTip is num ? rawTip.toInt() : 0;

    return CafeReview(
      ratingStars: clampedStars,
      tasteVerdict: (jsonMap['tasteVerdict'] as String?) ?? 'sweet_perfection',
      customerFace: CustomerFaceState.fromJsonValue(jsonMap['customerFace'] as String?),
      headline: (jsonMap['headline'] as String?) ?? 'Cafe Verdict',
      customerReaction: (jsonMap['customerReaction'] as String?) ?? '',
      cityBonusTip: parsedTip,
      evaluatedAt: evaluatedAt,
      source: source,
    );
  }

  final int ratingStars;
  final String tasteVerdict;
  final CustomerFaceState customerFace;
  final String headline;
  final String customerReaction;
  final int cityBonusTip;
  final DateTime evaluatedAt;
  final JudgeSource source;

  bool get isPrankCaught =>
      tasteVerdict == 'salty_sabotage' || tasteVerdict == 'spicy_chaos' || ratingStars == minCafeRatingStars;

  bool get isIncompleteTray => tasteVerdict == 'incomplete_tray';

  /// Human-friendly badge label replacing raw snake_case enum tokens (`sweet_perfection` -> `Tatlı Mükemmellik ✨`).
  String localizedVerdictLabel(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (tasteVerdict) {
      case 'salty_sabotage':
        return isEnglish ? 'Salty Sabotage 🧂' : 'Tuzlu Sabotaj 🧂';
      case 'spicy_chaos':
        return isEnglish ? 'Spicy Chaos 🌶️' : 'Acı Biber Şoku 🌶️';
      case 'incomplete_tray':
        return isEnglish ? 'Incomplete Tray 🧩' : 'Eksik Tepsi 🧩';
      case 'sweet_perfection':
      default:
        return isEnglish ? 'Sweet Perfection ✨' : 'Tatlı Mükemmellik ✨';
    }
  }

  String localizedJudgeLabel(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (source) {
      case JudgeSource.liveGemini:
        return isEnglish ? 'Live Gemini 3.5 Flash-Lite' : 'Canlı Gemini 3.5 Flash-Lite';
      case JudgeSource.localGemma:
        return isEnglish ? 'Local Gemma 4 (offline)' : 'Yerel Gemma 4 (çevrimdışı)';
      case JudgeSource.offlineBundle:
        return isEnglish ? 'Offline JSON Schema' : 'Yerel JSON Şeması';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ratingStars': ratingStars,
      'tasteVerdict': tasteVerdict,
      'customerFace': customerFace.jsonValue,
      'headline': headline,
      'customerReaction': customerReaction,
      'cityBonusTip': cityBonusTip,
    };
  }
}
