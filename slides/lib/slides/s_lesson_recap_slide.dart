import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The five rules in two columns, read once and not explained again, with the repo QR.
class LessonRecapSlide extends FlutterDeckSlideWidget {
  const LessonRecapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/lesson-recap',
            title: '22. Özet: beş kural, iki sütun',
            speakerNotes:
                'BEAT  [25:15 - 26:30] Özet. İki sütunu oku, yeniden anlatma. Açılıştaki soruyu salona geri sor.\n'
                'SAY   "Beş kural, iki sütun. Modelin cevabı: model önerir, kararı kod verir. Serbest metin yerine kapalı liste; boş cevap başarı değildir. Uygulamanın kendisi: olmaması gereken durum yazılamasın. Model susarsa oyun susmaz. Anahtar sunucuda kalır, model boşuna çağrılmaz. Kodun hepsi, testleriyle birlikte, sağdaki QR kodda. Başta bir soru sormuştum: tuzu kim yakalayacak, yapay zeka mı, kod mu?"\n'
                'HOLD  Sütunları oku, açıklama ekleme. Soruyu sorduktan sonra 3 saniye bekle; sessizlikse cevabı kendin söyle.\n'
                'NEXT  "Cevap: kod."',
          ),
        );

  static const double _gap = 20;
  static const double _columnTitleSize = 36;
  static const double _ruleSize = 38;
  static const double _qrSize = 400;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'ÖZET · KOD VE TESTLER AÇIK KAYNAK',
          title: 'Beş kural, iki sütun',
          act: StoryAct.buildAndShip,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'MODELİN CEVABI',
                  title: 'Modele güvenme, kontrol et',
                  talkTitleFontSize: _columnTitleSize,
                  talkBulletFontSize: _ruleSize,
                  accentColor: DeckColors.googleRed,
                  bullets: [
                    '1. Model önerir, kararı kod verir.',
                    '2. Serbest metin yerine kapalı liste; boş cevap başarı değildir.',
                  ],
                ),
              ),
              SizedBox(width: _gap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'UYGULAMANIN KENDİSİ',
                  title: 'Hatayı yazılamaz yap',
                  talkTitleFontSize: _columnTitleSize,
                  talkBulletFontSize: _ruleSize,
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    '3. Olmaması gereken durum, yazılamasın.',
                    '4. Model susarsa oyun susmaz.',
                    '5. Anahtar sunucuda kalır, model boşuna çağrılmaz.',
                  ],
                ),
              ),
              SizedBox(width: _gap),
              Center(
                child: QrCodeCard(
                  assetPath: 'assets/images/starter_repo_qr.png',
                  caption: 'Kod, testler ve slaytlar',
                  url: 'github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                  size: _qrSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
