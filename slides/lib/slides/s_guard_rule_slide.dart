import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 1, rule slide: the model proposes, code decides.
class GuardRuleSlide extends FlutterDeckSlideWidget {
  const GuardRuleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/guard-rule',
            title: '10. Kural 1: model önerir, kararı kod verir',
            speakerNotes: 'BEAT  [09:00 - 10:15] Kural 1. Salona sor, sonra yeni kelime: guard.\n'
                'SAY   "Kim tuz attı? Kaç yıldız aldınız? Bir. Peki o yıldızı kim verdi? Öneri jüriden geldi; son sözü kod söyledi: tepside tuz varsa kod bir yıldızdan fazlasına izin vermiyor. Yeni kelimemiz guard, Türkçesiyle koruyucu: modelin cevabı ekrana çıkmadan önce onu kontrol eden kod. Hikaye şöyle: 12 Kasım\'a kadar Gemini\'nin cevabı kontrolsüz ekrana çıkıyordu. Model tuzu kaçırırsa tuzlu tepsi beş yıldız alabiliyordu. Tepside tuz var mı, bunu artık kodumuz biliyor; modelin kararı buna uymuyorsa cevabı atıyoruz."\n'
                'HOLD  "Kim verdi?" sorusundan sonra 2 saniye bekle; "Gemini" diyeni de "kod" diyeni de duy, sonra cevabı ver. "Kim tuz attı?" sorusuna el kalkmazsa: "Ben attım, gördünüz: bir yıldız." Sonra üst şeridi (ÖNCE), ardından alt şeridi (SONRA) soldan sağa göster; Guard kutusunda dur. Alttaki satırı okuma.\n'
                'NEXT  "Kodda bu tek bir satır."',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 1 / 5',
          title: 'Model önerir, kararı kod verir',
          act: StoryAct.realNumbers,
          child: LessonPictureBody(
            word: 'Guard',
            definition: 'Koruyucu: modelin cevabı ekrana çıkmadan önce onu kontrol eden kod.',
            picture: GuardFlowDiagram(),
            advanced: 'kontrol önce yalnızca tasteVerdict alanına bakıyordu; '
                '"tuzlu" deyip 5 yıldız veren cevap 20 Kasım\'a kadar geçiyordu',
          ),
        );
      },
    );
  }
}
