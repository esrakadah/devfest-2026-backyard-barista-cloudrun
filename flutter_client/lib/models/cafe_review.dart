import 'package:flutter/foundation.dart';

/// Minimum and maximum rating star bounds returned by the Gemini cafe judge.
const int minCafeRatingStars = 1;
const int maxCafeRatingStars = 5;

/// The largest tip a single review pays into the jar. No prompt or schema limits the number a model writes,
/// so the parser does. The bundled answers pay 0 to 50.
const int maxCityBonusTip = 50;

/// Deterministic customer face state mapped to `assets/base/customers/*.png`.
enum CustomerFaceState {
  happy('happy', 'assets/base/customers/customer_happy.png'),
  shocked('shocked', 'assets/base/customers/customer_shocked.png'),
  saltyDisgusted('salty_disgusted', 'assets/base/customers/customer_salty_disgusted.png');

  const CustomerFaceState(this.jsonValue, this.assetPath);

  final String jsonValue;
  final String assetPath;

  static List<String> get jsonValues => <String>[for (final face in CustomerFaceState.values) face.jsonValue];

  /// Returns null for a missing or unknown value instead of defaulting to a happy customer.
  static CustomerFaceState? tryParse(Object? rawValue) {
    for (final candidate in CustomerFaceState.values) {
      if (candidate.jsonValue == rawValue) {
        return candidate;
      }
    }
    return null;
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

  /// Returns null unless every field is present with the right type and in range. A reply with holes is not a
  /// verdict: no missing field may be read as 5 stars or as a sweet tray.
  static CafeReview? tryParse(
    Map<String, dynamic> jsonMap, {
    required DateTime evaluatedAt,
    required JudgeSource source,
  }) {
    final tasteVerdict = TasteVerdict.tryParse(jsonMap['tasteVerdict']);
    final customerFace = CustomerFaceState.tryParse(jsonMap['customerFace']);
    final ratingStars = jsonMap['ratingStars'];
    final headline = jsonMap['headline'];
    final customerReaction = jsonMap['customerReaction'];
    final cityBonusTip = jsonMap['cityBonusTip'];

    if (tasteVerdict == null ||
        customerFace == null ||
        ratingStars is! int ||
        ratingStars < minCafeRatingStars ||
        ratingStars > maxCafeRatingStars ||
        headline is! String ||
        headline.trim().isEmpty ||
        customerReaction is! String ||
        customerReaction.trim().isEmpty ||
        cityBonusTip is! int) {
      return null;
    }

    return CafeReview(
      ratingStars: ratingStars,
      tasteVerdict: tasteVerdict,
      customerFace: customerFace,
      headline: headline,
      customerReaction: customerReaction,
      cityBonusTip: cityBonusTip.clamp(0, maxCityBonusTip),
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
