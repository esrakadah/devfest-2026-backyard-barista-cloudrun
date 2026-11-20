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

  static List<String> get jsonValues => <String>[for (final face in CustomerFaceState.values) face.jsonValue];

  static CustomerFaceState fromJsonValue(String? rawValue) {
    for (final candidate in CustomerFaceState.values) {
      if (candidate.jsonValue == rawValue) {
        return candidate;
      }
    }
    return CustomerFaceState.happy;
  }
}

/// The closed list of verdicts a [CafeReview] can carry.
enum TasteVerdict {
  sweetPerfection('sweet_perfection'),
  saltySabotage('salty_sabotage'),
  spicyChaos('spicy_chaos'),

  /// Decided in Dart for a tray with a missing station and never by a model, so it is not in [modelVerdicts].
  incompleteTray('incomplete_tray');

  const TasteVerdict(this.jsonValue);

  final String jsonValue;

  /// The verdicts a model may answer with. Both response schemas are built from this list.
  static const List<TasteVerdict> modelVerdicts = <TasteVerdict>[sweetPerfection, saltySabotage, spicyChaos];

  static List<String> get modelJsonValues => <String>[for (final verdict in modelVerdicts) verdict.jsonValue];

  /// Returns null for a value outside the list, such as a typo, instead of guessing a verdict.
  static TasteVerdict? tryParse(Object? rawValue) {
    for (final candidate in TasteVerdict.values) {
      if (candidate.jsonValue == rawValue) {
        return candidate;
      }
    }
    return null;
  }
}

/// Which judge produced a [CafeReview], shown as the judge badge under the verdict.
enum JudgeSource { liveGemini, localGemma, offlineBundle }

/// Structured JSON verdict from Gemini (`gemini-3.5-flash-lite`), a local Gemma, or the offline bundle.
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

  /// Returns null when the verdict is not one of [TasteVerdict.values].
  static CafeReview? tryParse(
    Map<String, dynamic> jsonMap, {
    required DateTime evaluatedAt,
    required JudgeSource source,
  }) {
    final rawVerdict = jsonMap['tasteVerdict'];
    final tasteVerdict = rawVerdict == null ? TasteVerdict.sweetPerfection : TasteVerdict.tryParse(rawVerdict);
    if (tasteVerdict == null) {
      return null;
    }
    final rawStars = jsonMap['ratingStars'];
    final parsedStars = rawStars is num ? rawStars.toInt() : maxCafeRatingStars;
    final clampedStars = parsedStars.clamp(minCafeRatingStars, maxCafeRatingStars);
    final rawTip = jsonMap['cityBonusTip'];
    final parsedTip = rawTip is num ? rawTip.toInt() : 0;

    return CafeReview(
      ratingStars: clampedStars,
      tasteVerdict: tasteVerdict,
      customerFace: CustomerFaceState.fromJsonValue(jsonMap['customerFace'] as String?),
      headline: (jsonMap['headline'] as String?) ?? 'Cafe Verdict',
      customerReaction: (jsonMap['customerReaction'] as String?) ?? '',
      cityBonusTip: parsedTip,
      evaluatedAt: evaluatedAt,
      source: source,
    );
  }

  final int ratingStars;
  final TasteVerdict tasteVerdict;
  final CustomerFaceState customerFace;
  final String headline;
  final String customerReaction;
  final int cityBonusTip;
  final DateTime evaluatedAt;
  final JudgeSource source;

  bool get isPrankCaught =>
      tasteVerdict == TasteVerdict.saltySabotage ||
      tasteVerdict == TasteVerdict.spicyChaos ||
      ratingStars == minCafeRatingStars;

  bool get isIncompleteTray => tasteVerdict == TasteVerdict.incompleteTray;

  /// Human-friendly badge label replacing raw snake_case enum tokens (`sweet_perfection` -> `Tatlı Mükemmellik ✨`).
  String localizedVerdictLabel(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (tasteVerdict) {
      case TasteVerdict.saltySabotage:
        return isEnglish ? 'Salty Sabotage 🧂' : 'Tuzlu Sabotaj 🧂';
      case TasteVerdict.spicyChaos:
        return isEnglish ? 'Spicy Chaos 🌶️' : 'Acı Biber Şoku 🌶️';
      case TasteVerdict.incompleteTray:
        return isEnglish ? 'Incomplete Tray 🧩' : 'Eksik Tepsi 🧩';
      case TasteVerdict.sweetPerfection:
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
      'tasteVerdict': tasteVerdict.jsonValue,
      'customerFace': customerFace.jsonValue,
      'headline': headline,
      'customerReaction': customerReaction,
      'cityBonusTip': cityBonusTip,
    };
  }
}
