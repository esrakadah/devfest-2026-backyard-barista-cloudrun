import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 2, first code slide: two hand-typed schemas become one enum that feeds both.
class EnumFeedsSchemaSlide extends FlutterDeckSlideWidget {
  const EnumFeedsSchemaSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/enum-feeds-schema',
            title: '9. Kural 2, kod: liste şemayı besliyor',
            speakerNotes: 'BEAT  [11:45 - 13:15] Kural 2, kod. İki ayrı liste tek listeye iniyor.\n'
                'SAY   "Solda eski hali. Sarı satır Gemini\'ye giden şema: karar bir metin olsun, o kadar. Hangi metin? Söylemiyoruz. Altında ikinci bir şema var, yerel model için; orada liste elle yazılmış. İki liste, iki ayrı yer: biri değişir, öbürü unutulur. Sağda yeni hali. Yukarıda enum: üç karar, tek yerde. Sarı satır iki şemada da aynı: listeyi enum\'dan al. Alttaki test, iki şemanın da tam bu listeyi gönderdiğini kontrol ediyor."\n'
                'HOLD  Sol sarı satır, sonra sağdaki enum, sonra sağ sarı satır. Test adını göster, okuma.\n'
                'NEXT  "Liste tamam. Peki model hiçbir şey göndermezse?"',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 2 / 5 · KOD',
          title: 'İki elle yazılmış liste yerine tek enum',
          act: StoryAct.realNumbers,
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: 'ÖNCE · İKİ ŞEMA, İKİ AYRI LİSTE',
              filePathLabel: 'cafe_judge_service.dart · sadeleştirildi',
              accentColor: DeckColors.googleRed,
              lines: [
                CodeLine.comment("// Gemini'ye giden şema"),
                CodeLine.pointAt("'tasteVerdict': {'type': 'STRING'},"),
                CodeLine(''),
                CodeLine.comment('// yerel modele giden şema'),
                CodeLine("'tasteVerdict': {'type': 'string',"),
                CodeLine("  'enum': ['sweet_perfection',"),
                CodeLine("    'salty_sabotage', 'spicy_chaos']},"),
              ],
            ),
            right: LessonCodeCard(
              label: 'SONRA · TEK LİSTE',
              filePathLabel: 'cafe_review.dart + cafe_judge_service.dart · sadeleştirildi',
              accentColor: DeckColors.googleGreen,
              lines: [
                CodeLine('enum TasteVerdict {'),
                CodeLine("  sweetPerfection('sweet_perfection'),"),
                CodeLine("  saltySabotage('salty_sabotage'),"),
                CodeLine("  spicyChaos('spicy_chaos'), ..."),
                CodeLine('}'),
                CodeLine.comment('// iki şemada da aynı satır'),
                CodeLine.pointAt("'enum': TasteVerdict.modelJsonValues,"),
              ],
            ),
            proof: ProofStrip(
              testName: 'the Gemini and the local Gemma schema both allow exactly the model verdicts',
              outcome: 'yeşil',
            ),
          ),
        );
      },
    );
  }
}
