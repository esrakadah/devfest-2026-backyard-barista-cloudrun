import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 1, code slide: the call site before and after the guard.
class GuardBeforeAfterSlide extends FlutterDeckSlideWidget {
  const GuardBeforeAfterSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/guard-before-after',
            title: '7. Kural 1, kod: önce ve sonra',
            speakerNotes: 'BEAT  [08:45 - 10:45] Kural 1, kod. Yalnızca iki sarı satır ve test adı.\n'
                'SAY   "Solda eski hali. Sarı satıra bakın: cevap geldiyse göster. Modelin ne dediğine bakan yok. Sağda yeni hali: cevap geldiyse ve tepsideki şakayla uyuşuyorsa göster. Uyuşmuyorsa cevap çöpe gidiyor, yerine hazır yanıt geliyor. Bunu nereden biliyoruz? Alttaki test. Sağdaki sarı satırı silerseniz bu test kırmızıya dönüyor. 20 Kasım\'da bir şey daha buldum: kontrol sadece kelimeye bakıyordu. Model tuzlu deyip beş yıldız verirse geçiyordu; artık yıldıza da bakıyor. Eve götüreceğiniz cümle: modelin cevabı bir öneridir, karar değil."\n'
                'HOLD  Önce soldaki sarı satır, sonra sağdaki sarı satır, en son alttaki test adı. Kodun geri kalanını okuma.\n'
                'NEXT  "Peki model yanlış değil de eksik cevap verirse?"',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 1 / 5 · KOD',
          title: 'Önce: cevap geldiyse göster. Sonra: uyuşuyorsa göster',
          act: StoryAct.realNumbers,
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: "ÖNCE · 12 KASIM'A KADAR",
              filePathLabel: 'cafe_judge_service.dart · sadeleştirildi',
              accentColor: DeckColors.googleRed,
              lines: [
                CodeLine('final liveReview ='),
                CodeLine('    await _tryCallGemini(...);'),
                CodeLine(''),
                CodeLine.pointAt('if (liveReview != null) {'),
                CodeLine('  return liveReview;'),
                CodeLine('}'),
                CodeLine.comment('// model ne derse ekranda o'),
              ],
            ),
            right: LessonCodeCard(
              label: 'SONRA',
              filePathLabel: 'cafe_judge_service.dart · sadeleştirildi',
              accentColor: DeckColors.googleGreen,
              lines: [
                CodeLine('if (liveReview != null &&'),
                CodeLine.pointAt('    _verdictMatchesPranks(liveReview,'),
                CodeLine('        containsSaltPrank: ...,'),
                CodeLine('        containsChiliPrank: ...)) {'),
                CodeLine('  return liveReview;'),
                CodeLine('}'),
                CodeLine.comment('// uymuyorsa: sıradaki jüri, sonra hazır yanıt'),
              ],
            ),
            proof: ProofStrip(
              testName: 'a Gemini verdict that misses the salt prank falls back to the offline roast',
              outcome: 'kontrolü sil: kırmızı',
            ),
          ),
        );
      },
    );
  }
}
