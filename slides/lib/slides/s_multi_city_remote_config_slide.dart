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
                'SAY   "Bu oyunu 14 Kasım\'da Berlin\'de, 15 Kasım\'da Gaziantep\'te, 11 Aralık\'ta Adana\'da ve 19 Aralık\'ta İstanbul\'da sahneye taşıyoruz. Her şehir için ayrı bir uygulama derlemek yerine CityEditionController içinde 3 katmanlı bir öncelik mimarisi kurduk. ✅ fact (city_edition_controller.dart:119-135): Birinci öncelik uygulama içi Ayarlar çekmecesi (uiOverrideCityCode), ikinci öncelik Firebase Remote Config üzerindeki active_city_id parametresi, üçüncü öncelik ise çevrimdışı çalışan city_editions.json dosyamız. Böylece sahnede tek bir Remote Config anahtarını değiştirerek tüm salonun menüsünü ve şaka yanıtlarını Gaziantep Baklavası ve Menengiç Kahvesi moduna geçirebiliyoruz!"\n'
                'HOLD  Sağdaki activeEdition getter kodunu ve 3 öncelik katmanını göster.\n'
                'NEXT  "Şimdi oyunun en eğlenceli kısmına, yani Tatlı mı Tuzlu mu şaka mekaniğine bakalım!"',
          ),
        );

  static const double _columnGap = 28;

  static const String _cityControllerSnippet = '''
// flutter_client/lib/config/city_edition_controller.dart (Lines 119-135)
/// Priority 1: In-App Settings Switcher Override (uiOverrideCityCode)
/// Priority 2: Firebase Remote Config (active_city_id / remoteConfigCityCode)
/// Priority 3: Local city_editions.json Fallback (CityEditionId.gaziantep)
CityEditionConfig get activeEdition {
  if (_uiOverrideCityCode != null) {
    final overrideEdition = _editionsById[CityEditionId.fromCode(_uiOverrideCityCode)];
    if (overrideEdition != null) return overrideEdition;
  }
  final remoteEdition = _editionsById[CityEditionId.fromCode(_remoteConfigCityCode)];
  if (remoteEdition != null) return remoteEdition;

  return _editionsById[CityEditionId.gaziantep] ?? CityEditionConfig.fallbackGaziantep;
}''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 9 · FIREBASE REMOTE CONFIG (firebase/monitoring/remote-config)',
          title: 'One Codebase, Four DevFest Cities via Remote Config',
          subtitle: '3-Layer resolution in CityEditionController: UI Override -> Remote Config -> Local JSON',
          accentColor: DeckColors.halftoneBlue,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: DeckFeatureCard(
                  badge: '4 CITY EDITIONS IN 1 REPO',
                  title: 'Live City Switching Without Redeploying',
                  accentColor: DeckColors.halftoneBlue,
                  bullets: [
                    '🇩🇪 Berlin (14 Nov): Spree Side Roastery · Franzbrötchen & Pretzel Salt roast.',
                    '🇹🇷 Gaziantep (15 Nov): Şehitkamil Baklava & Menengiç Kahvesi · "Şehitkamil\'den sınır dışı ederler!"',
                    '🇹🇷 Adana (11 Dec): Çukurova Cezve & Tatlı Durağı · Acı Şalgam & İsot Biberi roast.',
                    '🇹🇷 Istanbul (19 Dec): Bosphorus Ferry Roastery · Karaköy Poğaçası & Vapuru kaçırtan tuz şakası.',
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
