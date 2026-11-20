import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 4, rule slide: when the model is silent the game is not. Limits are shown as limits and
/// measurements carry their date.
class FallbackRuleSlide extends FlutterDeckSlideWidget {
  const FallbackRuleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/fallback-rule',
            title: '14. Kural 4: model susarsa oyun susmaz',
            speakerNotes: 'BEAT  [18:15 - 19:30] Kural 4. Yeni kelime: timeout. Üç plan; sınır ile ölçümü ayır.\n'
                'SAY   "Dördüncü kural. Yeni kelime timeout, zaman aşımı: en fazla şu kadar beklerim sınırı. Oyunda üç plan var. A planı canlı Gemini: en fazla sekiz saniye bekliyoruz. B planı bu laptoptaki Gemma: sınır on beş saniye; o yalnızca benim laptopumda var, sizin telefonunuzda yok. C planı pakete koyduğumuz hazır yanıtlar: model gerekmez. Ekrandaki sekiz ve on beş ölçüm değil, sınır. Ölçümler kartların ikinci satırında; 11 Kasım\'da 12 tepsiyle ölçtüm."\n'
                'HOLD  Soldan sağa A, B, C. "Ölçüm değil, sınır" derken kart başlıklarını, sonra ikinci satırları göster.\n'
                'NEXT  "C planını belki az önce siz test ettiniz."',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 4 / 5',
          title: 'Model susarsa oyun susmaz',
          act: StoryAct.underTheHood,
          child: LessonRuleBody(
            word: 'Timeout',
            definition: 'Zaman aşımı: "en fazla şu kadar beklerim" sınırı. Süre dolunca sıradaki plana geçilir.',
            whatHappenedLabel: 'PLAN A',
            whatWeDidLabel: 'PLAN B',
            proofLabel: 'PLAN C',
            whatHappened: LessonTile(
              title: 'Canlı Gemini · sınır 8 sn',
              lines: ['Süre dolarsa ya da hata gelirse B planı.', 'Ölçüm: 1,0 ile 1,8 sn arası.'],
              footer: 'ölçüm: 12 tepsi · 11 Kas 2026',
            ),
            whatWeDid: LessonTile(
              title: 'Yerel Gemma · sınır 15 sn',
              lines: ['Yalnızca sahnedeki laptopta; telefonunuzda yok.', 'Ölçüm: 5,0 ile 8,4 sn arası.'],
              footer: 'ölçüm: 12 tepsi · 11 Kas 2026',
            ),
            proof: LessonTile(
              title: 'Hazır yanıtlar · pakette',
              lines: ['Model gerekmez.', 'Her şehir ve her karar için bir yanıt.'],
              footer: 'yükleme sınırı 250 ms · mock_responses.json',
            ),
            advanced: 'her katman CafeReview? döndürüyor: null; 429, zaman aşımı ve bozuk JSON birbirinden ayrılmıyor, '
                'neden düştüğü kayboluyor',
          ),
        );
      },
    );
  }
}
