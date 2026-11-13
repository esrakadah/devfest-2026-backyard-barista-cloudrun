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
            title: "11. Today's Game Mechanic: Tatlı mı Tuzlu mu? + Web NFC",
            speakerNotes:
                'BEAT  [20:30 - 22:30] Oyun Mekaniği ("Tatlı mı Tuzlu mu?"), Web NFC Sahne Tetikleyicisi ve Yapılandırılmış JSON Şeması (CafeReview).\n'
                'SAY   "Oyunumuzun kalbinde çok eğlenceli bir mekanik var: iki oyuncu tezgahtaki içecek ve tatlılara tıklayarak 3 yuvalı ahşap tepsiyi hazırlıyor. Ancak Şeker kavanozunun yanında ikizi gibi duran Tuzluk var! Üstelik dart:js_interop ve Chrome Android NDEFReader ile gerçek bir NfcTagController ekledik: sahnede fiziksel bir NFC etikete dokunduğunuzda salt_shaker doğrudan tepsiye düşüyor; masaüstü ve iOS\'ta Tuzluk kartına dokunmak aynı işi yapıyor. Servis Et butonuna bastığınızda Gemini, CafeReview JSON şemamız üzerinden siparişi denetliyor ve tatlıya tuz atıldıysa ratingStars: 1, tasteVerdict: salty_sabotage döndürüyor."\n'
                'HOLD  Sol taraftaki görselleri (Baklava, Şeker, Web NFC Tuzluk, 1 Yıldızlı Müşteri) ve sağdaki NfcTagController + CafeReview JSON kodunu göster.\n'
                'NEWS  [Yalnız Konya, isteğe bağlı] Bu slayttan sonra Stage Navigator ile 17. slayta (/generate-vs-decide) geç: aynı jüri, üretmek mi karar vermek mi. 60 sn, sonra akışa dön.\n'
                'NEXT  "Peki bu yüksek kaliteli 9D görselleri 300 kişinin bilgisayarında sıfır yükleme hatasıyla nasıl birleştiriyoruz?"',
          ),
        );

  static const double _columnGap = 24;
  static const double _thumbGap = 14;

  static const String _schemaSnippet = '''
// 1. Web NFC Stage Trigger (nfc_tag_controller.dart + nfc_platform_web.dart)
// dart:js_interop + Chrome Android NDEFReader
nfcController.onIngredientTapped = placeIngredientFromTag;
await nfcController.startScanning(); // a salt_shaker tag lands on the tray
// Desktop / iOS: tap the salt card, same tray, same judge

// 2. Structured Verdict Schema (cafe_judge_service.dart)
'generationConfig': {
  'responseMimeType': 'application/json',
  'responseSchema': {
    'type': 'OBJECT',
    'properties': {
      'ratingStars': {'type': 'INTEGER'},       // 1 (Sabotage!) | 3 (Incomplete) | 5 (Sweet!)
      'tasteVerdict': {'type': 'STRING'},       // "salty_sabotage" | "incomplete_tray" | "sweet_perfection"
      'customerFace': {'type': 'STRING'},       // "salty_disgusted" | "shocked" | "happy"
      'headline': {'type': 'STRING'},           // City-branded review headline
      'customerReaction': {'type': 'STRING'},   // Witty Turkish/English roast!
      'cityBonusTip': {'type': 'INTEGER'},      // 0 on sabotage/partial, +40 on 5-star order
    },
  },
}''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'GAME MECHANIC · WEB NFC (NDEFREADER) & STRUCTURED JSON SCHEMA',
          title: 'Tatlı mı Tuzlu mu? Web NFC Stage Pranks Meet Structured JSON',
          act: StoryAct.underTheHood,
          subtitle:
              'Physical NFC sticker tap (NfcTagController, card tap on desktop and iOS) drops salt_shaker onto the 3-slot tray',
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
                            label: 'Tuz (Web NFC Tap!)',
                            badgeText: 'NDEFReader + card tap',
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
                  filePathLabel: 'nfc_tag_controller.dart + cafe_judge_service.dart',
                  code: _schemaSnippet,
                  accentColor: DeckColors.googleYellow,
                  badgeLabel: 'WEB NFC + CAFEREVIEW',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
