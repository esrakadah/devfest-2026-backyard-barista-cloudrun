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
                ? 'BEAT  [12:45 - 14:00] Oyun mekaniği, şemalı JSON ve konuşmanın ana dersi: kararı kod doğrular.\n'
                    'SAY   "Mekanik çok sade: tezgahta şeker kavanozunun yanında ikizi gibi duran bir tuzluk var. Android Chrome\'da gerçek bir Web NFC okuyucusu da bağladık: telefonu NFC etiketine dokundurduğunuzda tuzluk doğrudan tepsiye düşüyor. Servis Et\'e bastığınızda Gemini\'nin cevabı CafeReview JSON şemasına bağlı geliyor. Ama şema bir istektir, garanti değil. Model tuzu kaçırabilir; boş bir yanıt bile \'tatlı, 5 yıldız\' diye okunabilir. O yüzden sağdaki fonksiyon var: _verdictMatchesPranks. Modelin kararı Dart\'taki bayraklarla uyuşmuyorsa ekrana hiç çıkmıyor, hazır yanıta düşüyoruz. Bunu iki test sabitliyor."\n'
                    'HOLD  Solda baklava, şeker, tuzluk ve 1 yıldızlı müşteriyi göster. Sağda önce şema satırlarını, sonra _verdictMatchesPranks gövdesini işaret et ve bir saniye dur. Süre 13:30 altındaysa Stage Navigator ile 18. slayta (/generate-vs-decide, 45 sn) uğra; değilse devam et.\n'
                    'NEXT  "Sırada görseller var: kırık URL ve yükleme hatası olmadan nasıl paketliyoruz?"'
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
// ${isTurkishDeck ? '1. Şema bir istektir (cafe_judge_service.dart, sadeleştirildi)' : '1. The schema is a request (cafe_judge_service.dart, simplified)'}
'responseMimeType': 'application/json',
'responseSchema': {
  'tasteVerdict': {'type': 'STRING'}, // ${isTurkishDeck ? '+ 5 alan, hepsi zorunlu' : '+ 5 fields, all required'}
},

// ${isTurkishDeck ? '2. Kararı kod doğrular (cafe_judge_service.dart:370)' : '2. Code verifies the verdict (cafe_judge_service.dart:370)'}
bool _verdictMatchesPranks(
  CafeReview review, {
  required bool containsSaltPrank,
  required bool containsChiliPrank,
}) {
  if (!containsSaltPrank && !containsChiliPrank) {
    return review.tasteVerdict == 'sweet_perfection';
  }
  return (containsSaltPrank &&
          review.tasteVerdict == 'salty_sabotage') ||
      (containsChiliPrank &&
          review.tasteVerdict == 'spicy_chaos');
}''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'OYUN MEKANİĞİ · WEB NFC (NDEFREADER) VE JSON ŞEMASI'
              : 'GAME MECHANIC · WEB NFC (NDEFREADER) & STRUCTURED JSON SCHEMA',
          title: isTurkishDeck
              ? 'Tatlı mı tuzlu mu? Şema istektir, kararı kod doğrular'
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
                  filePathLabel: 'cafe_judge_service.dart',
                  code: _schemaSnippet,
                  accentColor: DeckColors.googleYellow,
                  badgeLabel: isTurkishDeck ? 'ŞEMA + KORUYUCU' : 'SCHEMA + GUARD',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
