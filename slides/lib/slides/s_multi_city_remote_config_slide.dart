import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class MultiCityRemoteConfigSlide extends FlutterDeckSlideWidget {
  const MultiCityRemoteConfigSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/multi-city-remote-config',
            title: isTurkishDeck
                ? '10. Firebase Remote Config ile çok şehirli mimari'
                : '10. Multi-City Architecture with Firebase Remote Config',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [18:30 - 20:30] Firebase Remote Config ile şehir sürümleri: Berlin, Gaziantep, Adana, İstanbul.\n'
                    'SAY   "Tek kod, dört şehir. Bu oyunun Berlin, Gaziantep, Adana ve İstanbul sürümleri var ve her şehir için ayrı uygulama derlemiyoruz. Remote Config, uygulamayı yeniden yayınlamadan ayar değiştirmemizi sağlayan bir Firebase servisi. CityEditionController üç yere sırayla bakıyor. Bir: uygulamadaki Ayarlar menüsü. İki: Remote Config ya da dart-define ile gelen active_city_id. Üç: uygulamanın içindeki city_editions.json dosyası. Yani tek bir ayarla menüyü Gaziantep baklavası ve menengiç kahvesi moduna geçirebiliyoruz."\n'
                    "HOLD  Sağdaki kodda activeCityId satırını göster (city_edition_controller.dart:147-168): üç öncelik tek satırda, ?? ile. Kodda yedek şehir Gaziantep, bunu gülümseyerek söyle. Not: kodda 13 Kasım'dan beri 5. sürüm de var (Konya); slayt 4 şehir gösteriyor, sorulursa söyle.\n"
                    'NEXT  "Şimdi oyunun en eğlenceli kısmı: Tatlı mı, tuzlu mu?"'
                : 'BEAT  [18:30 - 20:30] Firebase Remote Config ile 4 Şehir (Berlin, Gaziantep, Adana, İstanbul) Mimarisi.\n'
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
          eyebrow: 'FIREBASE REMOTE CONFIG (firebase/monitoring/remote-config)',
          title: isTurkishDeck
              ? 'Tek kod, dört DevFest şehri: Remote Config'
              : 'One Codebase, Four DevFest Cities via Remote Config',
          act: StoryAct.underTheHood,
          subtitle: isTurkishDeck
              ? 'CityEditionController 3 yere sırayla bakar: uygulama içi seçim -> Remote Config -> yerel JSON'
              : '3-Layer resolution in CityEditionController: UI Override -> Remote Config -> Local JSON',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '1 · Uygulama içi seçim' : '1 · UI Override',
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
                      value: isTurkishDeck ? '3 · Yerel JSON' : '3 · Local JSON',
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
                        badge: isTurkishDeck ? 'TEK REPODA 4 ŞEHİR SÜRÜMÜ' : '4 CITY EDITIONS IN 1 REPO',
                        badgeIcon: Icons.public,
                        title: isTurkishDeck
                            ? 'Yeniden yayınlamadan şehir değiştirme'
                            : 'Live City Switching Without Redeploying',
                        accentColor: DeckColors.halftoneBlue,
                        bullets: [
                          if (isTurkishDeck)
                            'DE · Berlin: Kreuzberg Späti & Kiez Roasters · Berliner Pfannkuchen & Späti Club-Mate.'
                          else
                            'DE · Berlin (14 Nov): Kreuzberg Späti & Kiez Roasters · Berliner Pfannkuchen & Späti Club-Mate.',
                          if (isTurkishDeck)
                            'TR · Gaziantep (bugün): Şehitkamil Baklava & Menengiç Kahvesi · "Şehitkamil\'den sınır dışı ederler!"'
                          else
                            'TR · Gaziantep (15 Nov): Şehitkamil Baklava & Menengiç Kahvesi · "Şehitkamil\'den sınır dışı ederler!"',
                          if (isTurkishDeck)
                            'TR · Adana: Gar Kahvesi & Bici Bici Durağı · Bici Bici & Gar Kahvesi ("Şalgam suyu mu sandın?").'
                          else
                            'TR · Adana (11 Dec): Gar Kahvesi & Bici Bici Durağı · Bici Bici & Gar Kahvesi ("Şalgam suyu mu sandın?").',
                          if (isTurkishDeck)
                            'TR · İstanbul: Galata & Vapur Kafe · Galata San Sebastian & Vapur Çayı.'
                          else
                            'TR · Istanbul (19 Dec): Galata & Vapur Kafe · Galata San Sebastian & Vapur Çayı.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Şablon: flutter_client/remote_config_template.json'
                            : 'Template: flutter_client/remote_config_template.json',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/config/city_edition_controller.dart',
                        code: _cityControllerSnippet,
                        badgeLabel: isTurkishDeck ? '3 KATMANLI ÖNCELİK' : '3-TIER CASCADE',
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
