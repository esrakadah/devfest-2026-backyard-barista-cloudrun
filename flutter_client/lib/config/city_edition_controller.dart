import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Supported DevFest 2026 City Edition identifiers.
enum CityEditionId {
  berlin('berlin'),
  gaziantep('gaziantep'),
  adana('adana'),
  istanbul('istanbul');

  const CityEditionId(this.code);

  final String code;

  static CityEditionId fromCode(String? rawCode) {
    final normalizedCode = rawCode?.trim().toLowerCase();
    for (final candidate in CityEditionId.values) {
      if (candidate.code == normalizedCode) {
        return candidate;
      }
    }
    return CityEditionId.gaziantep;
  }
}

/// Immutable configuration for a single DevFest City Edition (`Berlin`, `Gaziantep`, `Adana`, `Istanbul`).
@immutable
class CityEditionConfig {
  const CityEditionConfig({
    required this.editionId,
    required this.cityName,
    required this.flagEmoji,
    required this.eventTitle,
    required this.cafeSubtitle,
    required this.defaultLanguage,
    required this.signatureSpecialty,
    required this.saltPrankRoast,
    required this.chiliPrankRoast,
    required this.sweetCompliment,
  });

  factory CityEditionConfig.fromJson(Map<String, dynamic> jsonMap) {
    final editionId = CityEditionId.fromCode(jsonMap['id'] as String?);
    return CityEditionConfig(
      editionId: editionId,
      cityName: (jsonMap['cityName'] as String?) ?? editionId.code,
      flagEmoji: (jsonMap['flagEmoji'] as String?) ?? '🇹🇷',
      eventTitle: (jsonMap['eventTitle'] as String?) ?? 'DevFest 2026 Edition',
      cafeSubtitle: (jsonMap['cafeSubtitle'] as String?) ?? 'Backyard Barista on Cloud Run',
      defaultLanguage: (jsonMap['defaultLanguage'] as String?) ?? 'tr',
      signatureSpecialty: (jsonMap['signatureSpecialty'] as String?) ?? 'Baklava & Espresso',
      saltPrankRoast: (jsonMap['saltPrankRoast'] as String?) ?? 'Salt in a sweet order?! 1 Star!',
      chiliPrankRoast: (jsonMap['chiliPrankRoast'] as String?) ?? 'Hot chili in my coffee?! 1 Star!',
      sweetCompliment: (jsonMap['sweetCompliment'] as String?) ?? 'Delicious coffee and pastry! 5 Stars!',
    );
  }

  final CityEditionId editionId;
  final String cityName;
  final String flagEmoji;
  final String eventTitle;
  final String cafeSubtitle;
  final String defaultLanguage;
  final String signatureSpecialty;
  final String saltPrankRoast;
  final String chiliPrankRoast;
  final String sweetCompliment;
}

/// Source layer that determined the currently active City Edition.
enum CityConfigSourceLayer {
  manualUiOverride('Priority 1: In-App Settings Switcher Override'),
  firebaseRemoteConfig('Priority 2: Firebase Remote Config (active_city_id)'),
  bundledLocalFallback('Priority 3: Local city_editions.json Fallback');

  const CityConfigSourceLayer(this.displayLabel);

  final String displayLabel;
}

/// 3-Layer City Edition Controller:
/// 1. Priority 1: In-App Settings Switcher Override (`selectManualOverride`)
/// 2. Priority 2: Firebase Remote Config (`active_city_id` / `--dart-define=DEFAULT_CITY`)
/// 3. Priority 3: Bundled `assets/editions/city_editions.json` Fallback
class CityEditionController extends ChangeNotifier {
  CityEditionController({
    String? remoteConfigCityCode,
  }) : _remoteConfigCityId = remoteConfigCityCode != null && remoteConfigCityCode.trim().isNotEmpty
            ? CityEditionId.fromCode(remoteConfigCityCode)
            : null;

  static const CityEditionConfig _defaultGaziantepConfig = CityEditionConfig(
    editionId: CityEditionId.gaziantep,
    cityName: 'Gaziantep',
    flagEmoji: '🇹🇷',
    eventTitle: 'DevFest Gaziantep 2026 Edition',
    cafeSubtitle: 'Şehitkamil Baklava & Menengiç Kahve Evi',
    defaultLanguage: 'tr',
    signatureSpecialty: 'Fıstıklı Baklava & Menengiç Kahvesi',
    saltPrankRoast: "Baklavaya ve kahveye tuz atanı Şehitkamil'den sınır dışı ederler! 1 Yıldız!",
    chiliPrankRoast: 'Tatlı tabağına acı sos ve isot basmışsın, ağzımızdan ateş çıkıyor! 1 Yıldız!',
    sweetCompliment: 'Ellerine sağlık usta! Fıstığı bol, şerbeti tam kıvamında, 5 Yıldız!',
  );

  static const Map<CityEditionId, CityEditionConfig> _builtInDefaults = <CityEditionId, CityEditionConfig>{
    CityEditionId.berlin: CityEditionConfig(
      editionId: CityEditionId.berlin,
      cityName: 'Berlin',
      flagEmoji: '🇩🇪',
      eventTitle: 'DevFest Berlin 2026 Edition',
      cafeSubtitle: 'Kreuzberg Späti & Kiez Roasters',
      defaultLanguage: 'en',
      signatureSpecialty: 'Berliner Pfannkuchen & Späti Club-Mate',
      saltPrankRoast: 'Das ist Salz, kein Zucker! Tougher than the Berghain bouncer: 1 Star!',
      chiliPrankRoast: 'Curry-Chili in my cappuccino?! Not even at Kotti at 4 AM: 1 Star!',
      sweetCompliment: 'Wunderbar! Crispy pastry, silky crema, and real sugar: 5 Stars in Berlin!',
    ),
    CityEditionId.gaziantep: _defaultGaziantepConfig,
    CityEditionId.adana: CityEditionConfig(
      editionId: CityEditionId.adana,
      cityName: 'Adana',
      flagEmoji: '🇹🇷',
      eventTitle: 'DevFest Adana 2026 Edition',
      cafeSubtitle: 'Gar Kahvesi & Bici Bici Durağı',
      defaultLanguage: 'tr',
      signatureSpecialty: 'Bici Bici & Gar Kahvesi',
      saltPrankRoast: 'Şalgam suyu mu sandın bunu? Tatlıya tuz basmışsın, 1 Yıldız!',
      chiliPrankRoast: 'Adana sıcağı yetmedi bir de kahveye acı sos dökmüşsün, 1 Yıldız!',
      sweetCompliment: 'Buz gibi ferah, tam Adana usulü tatlı keyfi, 5 Yıldız!',
    ),
    CityEditionId.istanbul: CityEditionConfig(
      editionId: CityEditionId.istanbul,
      cityName: 'Istanbul',
      flagEmoji: '🇹🇷',
      eventTitle: 'DevFest Istanbul 2026 Edition',
      cafeSubtitle: 'Galata & Vapur Kafe',
      defaultLanguage: 'tr',
      signatureSpecialty: 'Galata San Sebastian & Vapur Çayı',
      saltPrankRoast: "Galata Kulesi'nde turist kazıklar gibi kahveye tuz basmışsınız, 1 Yıldız!",
      chiliPrankRoast: "San Sebastian'ın üstüne çilek sosu diye acı sos dökmüşsünüz, martılar bile yemez! 1 Yıldız!",
      sweetCompliment: 'Boğaz havasında bundan güzel kahve ve tatlı ikilisi olamaz, 5 Yıldız!',
    ),
  };

  Map<CityEditionId, CityEditionConfig> _editionsByCity = _builtInDefaults;
  CityEditionId _fallbackCityId = CityEditionId.gaziantep;
  CityEditionId? _remoteConfigCityId;
  CityEditionId? _manualOverrideCityId;

  /// Resolves the active City Edition using the 3-layer priority hierarchy.
  CityEditionId get activeCityId => _manualOverrideCityId ?? _remoteConfigCityId ?? _fallbackCityId;

  /// Returns which of the 3 configuration layers currently drives the UI.
  CityConfigSourceLayer get activeSourceLayer {
    if (_manualOverrideCityId != null) {
      return CityConfigSourceLayer.manualUiOverride;
    }
    if (_remoteConfigCityId != null) {
      return CityConfigSourceLayer.firebaseRemoteConfig;
    }
    return CityConfigSourceLayer.bundledLocalFallback;
  }

  /// Active city configuration object.
  CityEditionConfig get activeEdition => _editionsByCity[activeCityId] ?? _defaultGaziantepConfig;

  /// All available City Editions in display order.
  List<CityEditionConfig> get allEditions =>
      CityEditionId.values.map((cityId) => _editionsByCity[cityId] ?? _defaultGaziantepConfig).toList();

  /// Loads `assets/editions/city_editions.json` into Layer 3 fallback storage.
  Future<void> loadBundledEditions({AssetBundle? bundle}) async {
    final effectiveBundle = bundle ?? rootBundle;
    try {
      final rawJsonString = await effectiveBundle.loadString('assets/editions/city_editions.json');
      final decodedMap = jsonDecode(rawJsonString) as Map<String, dynamic>;
      final defaultCityCode = decodedMap['defaultCityId'] as String?;
      if (defaultCityCode != null) {
        _fallbackCityId = CityEditionId.fromCode(defaultCityCode);
      }
      final editionsNode = decodedMap['editions'];
      if (editionsNode is Map<String, dynamic>) {
        final parsedEditions = <CityEditionId, CityEditionConfig>{..._builtInDefaults};
        for (final entry in editionsNode.entries) {
          final cityValue = entry.value;
          if (cityValue is Map<String, dynamic>) {
            final config = CityEditionConfig.fromJson(cityValue);
            parsedEditions[config.editionId] = config;
          }
        }
        _editionsByCity = parsedEditions;
      }
      notifyListeners();
    } on Object {
      // Keep built-in defaults if asset bundle is unavailable.
    }
  }

  /// Priority 1: Sets a manual UI override from the top-bar Settings drawer.
  void selectManualOverride(CityEditionId cityId) {
    _manualOverrideCityId = cityId;
    notifyListeners();
  }

  /// Clears the Priority 1 manual UI override so Priority 2 (Firebase Remote Config) takes over.
  void clearManualOverride() {
    _manualOverrideCityId = null;
    notifyListeners();
  }

  /// Priority 2: Applies a live `active_city_id` update from Firebase Remote Config.
  void applyRemoteConfigCity(CityEditionId cityId) {
    _remoteConfigCityId = cityId;
    notifyListeners();
  }
}
