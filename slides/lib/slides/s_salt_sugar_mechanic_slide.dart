import 'package:backyard_barista_deck/deck_language.dart';
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
            title: isTurkishDeck
                ? '11. Oyun mekaniği: tatlı mı tuzlu mu? + Web NFC'
                : "11. Today's Game Mechanic: Tatlı mı Tuzlu mu? + Web NFC",
            speakerNotes: isTurkishDeck
                ? 'BEAT  [12:45 - 14:00] Oyun mekaniği (Tatlı mı Tuzlu mu?), Web NFC sahne tetikleyicisi ve CafeReview JSON şeması.\n'
                    'SAY   "Oyunun mekaniği çok sade: tezgahta şeker kavanozunun yanında ikizi gibi duran tuzluk var. Üstelik dart:js_interop ve Android Chrome NDEFReader ile gerçek bir Web NFC okuyucusu bağladık: telefonu fiziksel bir NFC etiketine dokundurduğunuzda salt_shaker doğrudan tepsiye düşüyor; masaüstü ve iOS\'ta karta dokunmak aynı işi yapıyor. Servis Et\'e bastığınızda Gemini cevabı CafeReview JSON şemasına kilitli veriyor. Daha da önemlisi: model yanlışlıkla tuza 5 yıldız verse bile Dart tarafındaki _verdictMatchesPranks koruyucusu bunu yakalayıp deterministik yedeğe çekiyor."\n'
                    "HOLD  Solda baklava, şeker, tuzluk ve 1 yıldızlı müşteriyi; sağda NFC ve 'tasteVerdict' şema satırlarını göster. Süre 13:30 altındaysa Stage Navigator ile 18. slayta (/generate-vs-decide, 45 sn) uğrayıp dön; değilse doğrudan devam et.\n"
                    'NEXT  "Peki görselleri kırık URL ve yükleme hatası olmadan nasıl paketliyoruz?"'
                : 'BEAT  [20:30 - 22:30] Oyun Mekaniği ("Tatlı mı Tuzlu mu?"), Web NFC Sahne Tetikleyicisi ve Yapılandırılmış JSON Şeması (CafeReview).\n'
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
      // ...''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'OYUN MEKANİĞİ · WEB NFC (NDEFREADER) VE JSON ŞEMASI'
              : 'GAME MECHANIC · WEB NFC (NDEFREADER) & STRUCTURED JSON SCHEMA',
          title: isTurkishDeck
              ? 'Tatlı mı tuzlu mu? Web NFC şakası ve şemalı JSON kararı'
              : 'Tatlı mı Tuzlu mu? Web NFC Stage Pranks Meet Structured JSON',
          act: StoryAct.underTheHood,
          subtitle: isTurkishDeck
              ? "NFC etiketine dokununca (masaüstü ve iOS'ta karta dokununca) salt_shaker 3 gözlü tepsiye düşer"
              : 'Physical NFC sticker tap (NfcTagController, card tap on desktop and iOS) drops salt_shaker onto the 3-slot tray',
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
                            badgeText: isTurkishDeck ? 'Tatlı' : 'Sweet Food',
                            borderColor: DeckColors.googleGreen,
                          ),
                        ),
                        SizedBox(width: _thumbGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'sugar_jar.png',
                            label: isTurkishDeck ? 'Şeker' : 'Şeker (Sugar)',
                            badgeText: isTurkishDeck ? '5 yıldızlı ikiz' : '5-Star Twin',
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
                            label: isTurkishDeck ? 'Tuz (Web NFC!)' : 'Tuz (Web NFC Tap!)',
                            badgeText: isTurkishDeck ? 'NDEFReader + kart' : 'NDEFReader + card tap',
                            borderColor: DeckColors.googleYellow,
                          ),
                        ),
                        SizedBox(width: _thumbGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'customer_salty_disgusted.png',
                            label: isTurkishDeck ? '1 yıldız!' : '1-Star Verdict!',
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
