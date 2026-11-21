import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
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
            title: '18. Kural 4: model susarsa oyun susmaz',
            speakerNotes: 'BEAT  [19:30 - 20:45] Kural 4. Yeni kelime: timeout. Üç plan; sınır ile ölçümü ayır.\n'
                'SAY   "Dördüncü kural. Yeni kelime timeout, zaman aşımı: en fazla şu kadar beklerim sınırı. Oyunda üç plan var. A planı canlı Gemini: en fazla sekiz saniye bekliyoruz. B planı Gemma, bu laptopta çalışan küçük bir model: sınır on beş saniye; o yalnızca benim laptopumda var, sizin telefonunuzda yok. C planı pakete koyduğumuz hazır yanıtlar: model gerekmez. Ekrandaki sekiz ve on beş ölçüm değil, sınır. Çerçeve sınırı, dolu kısım ölçümü gösteriyor; 12 tepsiyle ölçtüm."\n'
                'HOLD  Yukarıdan aşağı A, B, C. "Ölçüm değil, sınır" derken çerçeveyi, sonra dolu kısmı göster. C çubuğunun ne kadar kısa olduğunu göster.\n'
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
          child: LessonPictureBody(
            word: 'Timeout',
            definition: 'Zaman aşımı: "en fazla şu kadar beklerim" sınırı. Süre dolunca sıradaki plana geçilir.',
            picture: FallbackTimelineDiagram(),
            advanced: 'her katman CafeReview? döndürüyor: null; 429, zaman aşımı ve bozuk JSON birbirinden ayrılmıyor, '
                'neden düştüğü kayboluyor',
          ),
        );
      },
    );
  }
}
