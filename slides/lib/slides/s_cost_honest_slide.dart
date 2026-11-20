import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 5, second slide: cost as a decision. Counted numbers are tested; the one estimate is
/// labelled as an estimate.
class CostHonestSlide extends FlutterDeckSlideWidget {
  const CostHonestSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/cost-honest',
            title: '17. Kural 5, maliyet: model boşuna çağrılmaz',
            speakerNotes:
                'BEAT  [22:45 - 24:00] Kural 5, maliyet. Sayılan rakamlar ve tek tahmin; tahmini tahmin diye söyle.\n'
                'SAY   "Token, modelin okuduğu ve yazdığı kelime parçası; fatura token sayısına göre kesiliyor. O yüzden en ucuz çağrı, hiç yapmadığınız çağrı. Tepsiyi dizerken modele gitmiyoruz: sıfır çağrı. Eksik ve şakasız tepside de gitmiyoruz, cevabı kod veriyor. Tepsi servis edilince tek çağrı gidiyor. Bu üçünün testi var. Sağdaki rakama dikkat: servis başına yaklaşık 270 token. Bu bir tahmin; ölçmedim, o yüzden üstünde tahmin yazıyor. Ölçmediğiniz rakamı ölçmüş gibi göstermeyin."\n'
                'HOLD  Soldan sağa dört kutu. Son kutudaki "TAHMİN" etiketini göster ve bir saniye dur.\n'
                'NEXT  "Toparlayalım."',
          ),
        );

  static const double _gap = 18;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 5 / 5 · MALİYET',
          title: 'Model boşuna çağrılmaz',
          act: StoryAct.underTheHood,
          subtitle: 'Token: modelin okuduğu ve yazdığı kelime parçası. Fatura token sayısına göre kesilir',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _CountTile(
                        value: '0',
                        unit: 'çağrı',
                        caption: 'Tepsiyi dizerken, değiştirirken, temizlerken',
                        tag: 'TEST VAR',
                        color: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _CountTile(
                        value: '0',
                        unit: 'çağrı',
                        caption: 'Eksik ve şakasız tepside: cevabı kod veriyor',
                        tag: 'TEST VAR',
                        color: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _CountTile(
                        value: '1',
                        unit: 'çağrı',
                        caption: 'Servis edilen tepsi başına',
                        tag: 'TEST VAR',
                        color: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _CountTile(
                        value: '~270',
                        unit: 'token',
                        caption: 'Servis başına: yaklaşık 150 girdi, 120 çıktı',
                        tag: 'TAHMİN · ÖLÇMEDİM',
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
                '152 + 118 token, benchmark aracındaki sabitler; gerçek sayı cevaptaki usageMetadata alanında, henüz okunmadı',
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

  static const double _valueSize = 92;
  static const double _unitSize = 34;
  static const double _captionSize = 28;
  static const double _tagGap = 14;

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
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: _unitSize,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.offWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: _tagGap),
          Text(
            caption,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _captionSize,
              height: 1.25,
              color: DeckColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }
}
