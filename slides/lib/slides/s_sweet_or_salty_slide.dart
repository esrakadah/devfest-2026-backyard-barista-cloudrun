import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The cold open: an audience poll on two near-identical jars, which is the whole game in one picture.
class SweetOrSaltySlide extends FlutterDeckSlideWidget {
  const SweetOrSaltySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/sweet-or-salty',
            title: '2. Cold Open: Hangisi şeker?',
            speakerNotes:
                'BEAT  [02:00 - 03:30] Soğuk açılış ve salon oylaması. Oyunun tüm fikrini tek bir resimle ver; henüz hiçbir teknoloji adı söyleme.\n'
                'SAY   "Başlamadan önce küçük bir oylama. Ekrandaki iki kavanozdan biri şeker, biri tuz. A şeker diyenler el kaldırsın. Şimdi B diyenler. Salon ikiye bölündü, değil mi? Doğru cevap: A şeker, B tuz. İşte bugünkü oyunun bütün fikri bu: iki kavanoz neredeyse aynı ve arayüz hiçbir uyarı vermiyor. Peki tatlıya tuz atıldığını kim fark edecek? Gemini. Sipariş servis edildiği anda yapılandırılmış bir JSON kararı dönüyor: ya beş yıldız ya da şehre özel, bir yıldızlı bir laf sokma. Bu oturumun sonunda sizin kafenizin jürisi de bunu her seferinde bilecek."\n'
                'HOLD  Her oylamadan sonra elleri saymak için 3 saniye bekle. Cevabı söylerken sağdaki iki müşteri yüzünü işaret et (yanlış kavanoz 1 yıldız, doğru kavanoz 5 yıldız).\n'
                'NEXT  "Bu oyunu bugün bu salondaki herkes kuracak. Kurallarımız ve ödüllerimiz şöyle."',
          ),
        );

  static const double _gap = 28;
  static const double _jarSize = 440;
  static const double _faceSize = 150;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'AUDIENCE POLL · HANDS UP',
          title: 'Hangisi şeker? Which jar is the sugar?',
          act: StoryAct.hook,
          subtitle: 'One of them is salt. The screen will not warn you. Gemini will.',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PollJar(letter: 'A', assetFileName: 'sugar_jar.png', size: _jarSize),
              SizedBox(width: _gap),
              _PollJar(letter: 'B', assetFileName: 'salt_shaker.png', size: _jarSize),
              SizedBox(width: _gap * 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Outcome(
                      assetFileName: 'customer_salty_disgusted.png',
                      size: _faceSize,
                      stars: 1,
                      headline: 'Salt in the baklava',
                      verdict: 'tasteVerdict: "salty_sabotage"',
                      color: DeckColors.googleRed,
                    ),
                    SizedBox(height: _gap),
                    _Outcome(
                      assetFileName: 'customer_happy.png',
                      size: _faceSize,
                      stars: 5,
                      headline: 'Sugar, as ordered',
                      verdict: 'tasteVerdict: "sweet_perfection"',
                      color: DeckColors.googleGreen,
                    ),
                    Spacer(),
                    Text(
                      'One tray. One JSON verdict.',
                      style: TextStyle(
                        fontFamily: DeckFonts.sans,
                        fontSize: DeckTypeScale.title,
                        fontWeight: FontWeight.w700,
                        color: DeckColors.googleYellow,
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

class _PollJar extends StatelessWidget {
  const _PollJar({required this.letter, required this.assetFileName, required this.size});

  static const double _letterBadgeSize = 84;

  final String letter;
  final String assetFileName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: DeckColors.surfaceElevated,
      borderColor: DeckColors.outlineLight,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/cafe/$assetFileName', width: size, height: size * 1.2, fit: BoxFit.cover),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: _letterBadgeSize,
              height: _letterBadgeSize,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: DeckColors.navy, shape: BoxShape.circle),
              child: Text(
                letter,
                style: const TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: DeckTypeScale.header,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.googleYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.assetFileName,
    required this.size,
    required this.stars,
    required this.headline,
    required this.verdict,
    required this.color,
  });

  static const int _maxStars = 5;

  final String assetFileName;
  final double size;
  final int stars;
  final String headline;
  final String verdict;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/cafe/$assetFileName', width: size, height: size, fit: BoxFit.cover),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var index = 0; index < _maxStars; index++)
                      Icon(
                        index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: index < stars ? DeckColors.googleYellow : DeckColors.outlineLight,
                        size: 40,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  headline,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: DeckTypeScale.subtitle,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  verdict,
                  style: TextStyle(fontFamily: DeckFonts.mono, fontSize: DeckTypeScale.code, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
