import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 4, proof slide: the hall was the load test, and the judge badge says who answered.
class HallLoadTestSlide extends FlutterDeckSlideWidget {
  const HallLoadTestSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/hall-load-test',
            title: '15. Kural 4, kanıt: yük testini salon yaptı',
            speakerNotes: 'BEAT  [20:45 - 22:30] Kural 4, kanıt. İkinci görevi salona sor: rozetinizde ne yazıyordu?\n'
                'SAY   "Rozetinde Canlı Gemini yazanlar el kaldırsın. Yerel JSON Şeması yazanlar? İkinci grup: sizde bir şey bozulmadı, C planı çalıştı. Sunucumuz saniyede on isteğe izin veriyor; fazlasına HTTP 429 diyor, yani çok fazla istek geldi, yavaşla. Solda küçük bir hikaye daha: rozet eskiden bir evet-hayır değişkeniydi, Gemini\'den mi geldi? Üçüncü jüri gelince evet-hayır yetmedi. Sarı satır yeni hali: üç jüri, üç isim. Eve götüreceğiniz cümle: yapay zeka çağıran her özelliğin bir B planı olsun."\n'
                'HOLD  İki oylamada da elleri görmek için 3 saniye bekle. Sonra soldaki kod, sonra sağdaki kart.\n'
                'NEXT  "Son kural para ve güvenlikle ilgili."',
          ),
        );

  static const double _tileTitleSize = 36;
  static const double _tileLineSize = 30;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 4 / 5 · KANIT',
          title: 'Az önce yük testini siz yaptınız',
          act: StoryAct.underTheHood,
          subtitle: 'HTTP 429: sunucunun "çok fazla istek geldi, yavaşla" demesi',
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: 'KİM CEVAPLADI? · ÖNCE VE SONRA',
              filePathLabel: 'cafe_review.dart',
              lines: [
                CodeLine.comment("// 11 Kasım'a kadar: evet ya da hayır"),
                CodeLine('final bool isFromLiveGemini;'),
                CodeLine(''),
                CodeLine.comment('// üçüncü jüri gelince: üç isim'),
                CodeLine.pointAt('enum JudgeSource {'),
                CodeLine('  liveGemini,'),
                CodeLine('  localGemma,'),
                CodeLine('  offlineBundle,'),
                CodeLine('}'),
              ],
            ),
            right: DeckFeatureCard(
              badge: 'ROZETİNİZDE NE YAZIYORDU?',
              title: 'Rozet, cevabın nereden geldiğini söyler',
              talkTitleFontSize: _tileTitleSize,
              talkBulletFontSize: _tileLineSize,
              accentColor: DeckColors.googleGreen,
              bullets: [
                '"Canlı Gemini": cevap modelden geldi.',
                '"Yerel JSON Şeması": C planı çalıştı.',
                'Sunucu saniyede 10 isteğe izin veriyor.',
              ],
              footerText: 'nginx limit_req 10 r/s + burst 20 · tek ortak kova: harcamayı sınırlar, kötüye kullanımı değil',
            ),
            proof: ProofStrip(
              testName: 'Proxy errors such as a 429 rate limit fall back to the offline roast',
              outcome: 'yeşil',
            ),
          ),
        );
      },
    );
  }
}
