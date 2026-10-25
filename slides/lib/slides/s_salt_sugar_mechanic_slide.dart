import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class SaltSugarMechanicSlide extends FlutterDeckSlideWidget {
  const SaltSugarMechanicSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/salt-sugar-mechanic',
            title: "11. Today's Game Mechanic: Tatlı mı Tuzlu mu?",
            speakerNotes:
                'BEAT  [20:30 - 22:30] Oyun Mekaniği ("Tatlı mı Tuzlu mu?") ve Yapılandırılmış JSON Şeması (CafeReview).\n'
                'SAY   "Oyunumuzun kalbinde çok basit ama çok komik bir mekanik var: iki oyuncu tezgahtaki içecek ve tatlılara tıklayarak sipariş tepsisini hazırlıyor. Ancak tezgahta Şeker kavanozunun hemen yanında ikizi gibi duran Tuzluk ve Acı Sos var! Üstelik arayüzde kırmızı bir ŞAKA uyarısı göstermiyoruz; sadece tepsiye gizlice tuz eklendiğinde küçük bir göz kırpma ikonu beliriyor. Servis Et butonuna bastığınızda Gemini yapılandırılmış JSON şemamız üzerinden siparişi denetliyor ve tatlıya tuz atıldıysa ratingStars: 1, tasteVerdict: salty_sabotage ve şehre özel komik bir müşteri tepkisi döndürüyor."\n'
                'HOLD  Sol taraftaki gerçek görselleri (Baklava, Şeker, Tuz, 1 Yıldızlı Müşteri) ve sağdaki JSON şemasını göster.\n'
                'NEXT  "Peki bu yüksek kaliteli 9D görselleri 300 kişinin bilgisayarında sıfır yükleme hatasıyla nasıl birleştiriyoruz?"',
          ),
        );

  static const double _columnGap = 24;
  static const double _thumbGap = 14;

  static const String _schemaSnippet = '''
// flutter_client/lib/services/cafe_judge_service.dart (Lines 95-116)
'generationConfig': {
  'responseMimeType': 'application/json',
  'responseSchema': {
    'type': 'OBJECT',
    'properties': {
      'ratingStars': {'type': 'INTEGER'},       // 1 (Sabotage!) to 5 (Sweet!)
      'tasteVerdict': {'type': 'STRING'},       // "salty_sabotage" | "spicy_chaos" | "sweet_perfection"
      'customerFace': {'type': 'STRING'},       // "salty_disgusted" | "shocked" | "happy"
      'headline': {'type': 'STRING'},           // City-branded review headline
      'customerReaction': {'type': 'STRING'},   // Witty Turkish/English roast!
      'cityBonusTip': {'type': 'INTEGER'},      // 0 on sabotage, +40 on 5-star order
    },
  },
}''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'GAME MECHANIC & STRUCTURED JSON SCHEMA',
          title: 'Tatlı mı Tuzlu mu? Stealth Pranks Meets Structured JSON',
          act: StoryAct.underTheHood,
          subtitle: 'Sneaking Salt (Tuz) next to Sugar (Şeker) triggers a deterministic 1-star Gemini roast',
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'baklava.png',
                            label: 'Fıstıklı Baklava',
                            badgeText: 'Sweet Food',
                            borderColor: DeckColors.googleGreen,
                          ),
                        ),
                        SizedBox(width: _thumbGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'sugar_jar.png',
                            label: 'Şeker (Sugar)',
                            badgeText: '5-Star Twin',
                            borderColor: DeckColors.halftoneBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _thumbGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'salt_shaker.png',
                            label: 'Tuz (Salt Prank!)',
                            badgeText: 'Stealth Twin (Wink)',
                            borderColor: DeckColors.googleYellow,
                          ),
                        ),
                        SizedBox(width: _thumbGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'customer_salty_disgusted.png',
                            label: '1-Star Verdict!',
                            badgeText: 'salty_sabotage',
                            borderColor: DeckColors.googleRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                flex: 6,
                child: DeckCodeCard(
                  filePathLabel: 'flutter_client/lib/services/cafe_judge_service.dart',
                  code: _schemaSnippet,
                  accentColor: DeckColors.googleYellow,
                  badgeLabel: 'CAFEREVIEW SCHEMA',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
