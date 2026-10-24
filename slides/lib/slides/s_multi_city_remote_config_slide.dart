import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class MultiCityRemoteConfigSlide extends FlutterDeckSlideWidget {
  const MultiCityRemoteConfigSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/multi-city-remote-config',
            title: '9. Multi-City Architecture with Firebase Remote Config',
            speakerNotes:
                'BEAT  [18:30 - 20:30] Firebase Remote Config ile 4 Şehir (Berlin, Gaziantep, Adana, İstanbul) Mimarisi.\n'
                'SAY   "Bu oyunu 14 Kasım\'da Berlin\'de, 15 Kasım\'da Gaziantep\'te, 11 Aralık\'ta Adana\'da ve 19 Aralık\'ta İstanbul\'da sahneye taşıyoruz. Her şehir için ayrı bir uygulama derlemek yerine CityEditionController içinde 3 katmanlı bir öncelik mimarisi kurduk: birinci öncelik uygulama içi Ayarlar çekmecesi (_manualOverrideCityId), ikinci öncelik Firebase Remote Config veya dart-define üzerindeki active_city_id parametresi (_remoteConfigCityId), üçüncü öncelik ise çevrimdışı çalışan city_editions.json dosyamız (_fallbackCityId). Böylece sahnede tek bir Remote Config anahtarını değiştirerek tüm salonun menüsünü ve şaka yanıtlarını Gaziantep Baklavası ve Menengiç Kahvesi moduna geçirebiliyoruz!"\n'
                'HOLD  Sağdaki activeCityId / activeEdition getter kodunu (city_edition_controller.dart:147-168) ve 3 öncelik katmanını göster.\n'
                'NEXT  "Şimdi oyunun en eğlenceli kısmına, yani Tatlı mı Tuzlu mu şaka mekaniğine bakalım!"',
          ),
        );

  static const double _columnGap = 24;

  static const String _cityControllerSnippet = '''
// flutter_client/lib/config/city_edition_controller.dart (Lines 147-168)
Map<CityEditionId, CityEditionConfig> _editionsByCity = _builtInDefaults;
CityEditionId _fallbackCityId = CityEditionId.gaziantep;
CityEditionId? _remoteConfigCityId;
CityEditionId? _manualOverrideCityId;

/// Priority 1: In-App Settings Switcher (_manualOverrideCityId)
/// Priority 2: Firebase Remote Config / --dart-define (_remoteConfigCityId)
/// Priority 3: Local city_editions.json Fallback (_fallbackCityId)
CityEditionId get activeCityId =>
    _manualOverrideCityId ?? _remoteConfigCityId ?? _fallbackCityId;

CityEditionConfig get activeEdition =>
    _editionsByCity[activeCityId] ?? _defaultGaziantepConfig;''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 9 · FIREBASE REMOTE CONFIG (firebase/monitoring/remote-config)',
          title: 'One Codebase, Four DevFest Cities via Remote Config',
          subtitle: '3-Layer resolution in CityEditionController: UI Override -> Remote Config -> Local JSON',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: '1 · UI Override',
                      label: '_manualOverrideCityId',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: '2 · Remote Config',
                      label: '_remoteConfigCityId',
                      accentColor: DeckColors.halftoneBlue,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: '3 · Local JSON',
                      label: '_fallbackCityId (Gaziantep)',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DeckFeatureCard(
                        badge: '4 CITY EDITIONS IN 1 REPO',
                        badgeIcon: Icons.public,
                        title: 'Live City Switching Without Redeploying',
                        accentColor: DeckColors.halftoneBlue,
                        bullets: [
                          'DE · Berlin (14 Nov): Kreuzberg Späti & Kiez Roasters · Berliner Pfannkuchen & Späti Club-Mate.',
                          'TR · Gaziantep (15 Nov): Şehitkamil Baklava & Menengiç Kahvesi · "Şehitkamil\'den sınır dışı ederler!"',
                          'TR · Adana (11 Dec): Gar Kahvesi & Bici Bici Durağı · Bici Bici & Gar Kahvesi ("Şalgam suyu mu sandın?").',
                          'TR · Istanbul (19 Dec): Galata & Vapur Kafe · Galata San Sebastian & Vapur Çayı.',
                        ],
                        footerText: 'Template: flutter_client/remote_config_template.json',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/config/city_edition_controller.dart',
                        code: _cityControllerSnippet,
                        badgeLabel: '3-TIER CASCADE',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
