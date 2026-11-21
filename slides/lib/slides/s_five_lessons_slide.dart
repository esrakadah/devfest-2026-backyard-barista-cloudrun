import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The plan of the talk: five rules in two groups, and the five new words.
class FiveLessonsSlide extends FlutterDeckSlideWidget {
  const FiveLessonsSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/five-lessons',
            title: '9. Bugün: beş kural, beş kelime',
            speakerNotes: 'BEAT  [08:30 - 09:00] Yol haritası. Kuralları okuma, iki grubu ve beş kelimeyi göster.\n'
                'SAY   "Bugünün planı: beş kural. İlk ikisi modelin cevabıyla ilgili, son üçü uygulamanın kendisiyle. Her kuralla bir yeni kelime geliyor: guard, enum, sealed class, timeout ve proxy. Hepsini geldiği yerde açıklayacağım; şimdi bilmeniz gerekmiyor."\n'
                'HOLD  Sol sütun, sağ sütun, alttaki beş kelime. 30 saniyeyi geçme.\n'
                'NEXT  "Birinci kural, az önce tuz atanların gördüğü şey."',
          ),
        );

  static const double _gap = 20;
  static const double _ruleTitleSize = 36;
  static const double _ruleLineSize = 38;
  static const double _wordSize = 30;
  static const double _wordLabelSize = 25;
  static const double _wordPaddingHorizontal = 20;
  static const double _wordPaddingVertical = 16;
  static const double _wordRadius = 16;
  static const double _wordBorderOpacity = 0.6;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'BUGÜN NE GÖRECEĞİZ',
          title: 'Beş kural, beş yeni kelime',
          act: StoryAct.tools,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'MODELİN CEVABI',
                        title: 'Model yanlış ya da eksik cevap verirse',
                        talkTitleFontSize: _ruleTitleSize,
                        talkBulletFontSize: _ruleLineSize,
                        accentColor: DeckColors.googleRed,
                        bullets: ['1. Model önerir, kararı kod verir.', '2. Serbest metin yerine kapalı liste.'],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'UYGULAMANIN KENDİSİ',
                        title: 'Model doğru olsa bile bozulabilen yerler',
                        talkTitleFontSize: _ruleTitleSize,
                        talkBulletFontSize: _ruleLineSize,
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          '3. Olmaması gereken durum, yazılamasın.',
                          '4. Model susarsa oyun susmaz.',
                          '5. Anahtar sunucuda kalır, model boşuna çağrılmaz.',
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              Row(
                children: [
                  Expanded(child: _NewWordChip(word: 'guard', meaning: 'koruyucu kontrol')),
                  SizedBox(width: _gap),
                  Expanded(child: _NewWordChip(word: 'enum', meaning: 'kapalı liste')),
                  SizedBox(width: _gap),
                  Expanded(child: _NewWordChip(word: 'sealed class', meaning: 'kapalı durum listesi')),
                  SizedBox(width: _gap),
                  Expanded(child: _NewWordChip(word: 'timeout', meaning: 'zaman aşımı')),
                  SizedBox(width: _gap),
                  Expanded(child: _NewWordChip(word: 'proxy', meaning: 'aracı sunucu')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewWordChip extends StatelessWidget {
  const _NewWordChip({required this.word, required this.meaning});

  final String word;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FiveLessonsSlide._wordPaddingHorizontal,
        vertical: FiveLessonsSlide._wordPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(FiveLessonsSlide._wordRadius),
        border: Border.all(
          color: DeckColors.googleYellow.withValues(alpha: FiveLessonsSlide._wordBorderOpacity),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word,
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: FiveLessonsSlide._wordSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.googleYellow,
            ),
          ),
          Text(
            meaning,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: FiveLessonsSlide._wordLabelSize,
              color: DeckColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }
}
