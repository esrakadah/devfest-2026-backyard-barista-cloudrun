import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 5, second slide: explains what a token actually is for junior developers and how the
/// game avoids spending tokens when code alone already knows the answer.
class CostHonestSlide extends FlutterDeckSlideWidget {
  const CostHonestSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/cost-honest',
            title: '21. Kural 5, maliyet: token nedir, model ne zaman çağrılır?',
            speakerNotes: 'BEAT  [24:00 - 25:15] Kural 5, maliyet. Önce token nedir açıkla, sonra üç kartı göster.\n'
                'SAY   "Peki fatura neye göre yazılıyor? Yeni kelime token: modelin okuduğu, işlediği ve ürettiği en küçük metin birimi. Bazen kısa bir kelime, bazen kelimenin yarısı, bazen tek bir noktalama işareti; kabaca dört harf bir token eder. Modelin taksimetresi token sayar: hem sizin gönderdiğiniz soruyu hem kendi yazdığı cevabı toplar. O yüzden en ucuz token, hiç harcamadığınız tokendır. Tepsiyi dizerken, değiştirirken, temizlerken modele hiç gitmiyoruz: sıfır token. Eksik tepside de gitmiyoruz; cevabı Dart kodu veriyor. Yalnızca Servis Et\'e bastığınızda, tüm geçmişi değil sadece o tepsinin kısa özetini gönderiyoruz."\n'
                'HOLD  Önce üstteki Token tanımını göster ("kabaca dört harf = bir token"). Sonra soldan sağa üç kartı işaret et: 0 token, 0 token, 1 kısa istek.\n'
                'NEXT  "Beş kuralı tek ekranda toparlayalım."',
          ),
        );

  static const double _gap = 18;

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 5 / 5 · MALİYET',
          title: 'Model boşuna çağrılmaz',
          act: StoryAct.underTheHood,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NewWordCard(
                word: 'Token',
                definition:
                    'Modelin okuduğu ve ürettiği en küçük veri birimi (kelime, hece ya da noktalama; yaklaşık 4 harf / 0,75 kelime). Fatura toplam token sayısına göre kesilir.',
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _CountTile(
                        value: '0',
                        unit: 'token',
                        caption: 'Tepsiyi dizerken, ürün değiştirirken ya da tepsiyi temizlerken modele hiç gidilmez.',
                        tag: 'TEPSİYİ DİZERKEN · TEST VAR',
                        color: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _CountTile(
                        value: '0',
                        unit: 'token',
                        caption: 'Eksik tepside (tuz ve acı yoksa) cevabı doğrudan Dart kodu verir; model çağrılmaz.',
                        tag: 'KOD BİLİYORSA · TEST VAR',
                        color: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _CountTile(
                        value: '1',
                        unit: 'kısa istek',
                        caption:
                            'Yalnızca Servis Et anında: uzun sohbet geçmişi değil, tek tepsinin özeti + JSON şeması gider.',
                        tag: 'SERVİS ANINDA · TEST VAR',
                        color: DeckColors.googleYellow,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              ProofStrip(
                testName: 'building, changing and clearing a tray sends no request; serving it sends one',
                outcome: 'yeşil',
              ),
              SizedBox(height: _gap),
              AdvancedNote(
                'İngilizcede 1 token yaklaşık 4 karakterdir; Türkçede ekler nedeniyle aynı cümle biraz daha fazla token tutar, kısa istek iki kat kazandırır',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.value,
    required this.unit,
    required this.caption,
    required this.tag,
    required this.color,
  });

  static const double _valueSize = 84;
  static const double _unitSize = 32;
  static const double _captionSize = 27;
  static const double _tagGap = 12;

  final String value;
  final String unit;
  final String caption;
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      borderColor: color.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeckBadge(label: tag, color: color),
          const SizedBox(height: _tagGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: _valueSize,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _unitSize,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _tagGap),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 480,
                child: Text(
                  caption,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _captionSize,
                    height: 1.28,
                    color: DeckColors.offWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
