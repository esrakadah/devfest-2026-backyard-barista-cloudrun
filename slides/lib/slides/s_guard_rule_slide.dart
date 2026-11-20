import 'package:backyard_barista_deck/widgets/deck_cards.dart';
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
            title: '6. Kural 1: model önerir, kararı kod verir',
            speakerNotes: 'BEAT  [07:30 - 08:45] Kural 1. Salona sor, sonra yeni kelime: guard.\n'
                'SAY   "Kim tuz attı? Hepiniz bir yıldız aldınız. Peki o bir yıldızı kim verdi? Çoğunuz Gemini diyeceksiniz. Aslında kod verdi. Yeni kelimemiz guard, Türkçesiyle koruyucu: modelin cevabı ekrana çıkmadan önce onu kontrol eden kod. Hikaye şöyle: 12 Kasım\'a kadar Gemini\'nin cevabı kontrolsüz ekrana çıkıyordu. Model tuzu kaçırırsa tuzlu tepsi beş yıldız alabiliyordu. Tepside tuz var mı, bunu artık Dart biliyor; modelin kararı buna uymuyorsa cevabı atıyoruz."\n'
                'HOLD  "Kim verdi?" sorusundan sonra 2 saniye bekle. Sonra üç kutuyu soldan sağa göster. Alttaki satırı okuma.\n'
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
          child: LessonRuleBody(
            word: 'Guard',
            definition: 'Koruyucu: modelin cevabı ekrana çıkmadan önce onu kontrol eden kod.',
            whatHappened: LessonTile(
              title: 'Modele güvendik',
              lines: ["Gemini'nin cevabı kontrolsüz ekrana çıkıyordu.", 'Tuzlu tepsi 5 yıldız alabiliyordu.'],
              footer: "12 Kasım 2026'ya kadar",
            ),
            whatWeDid: LessonTile(
              title: 'Kararı koda aldık',
              lines: ['Tuz var mı? Buna Dart bakıyor.', 'Modelin kararı uymuyorsa cevabı atıyoruz.'],
              footer: 'cafe_judge_service.dart',
            ),
            proof: LessonTile(
              title: 'Kontrolü sil, testler kızarsın',
              lines: ['Kontrol silinirse 4 test kırmızı.', 'Kontrol artık yıldıza da bakıyor.'],
              footer: 'cafe_judge_service_test.dart · model_reply_validation_test.dart',
            ),
            advanced: 'kontrol önce yalnızca tasteVerdict alanına bakıyordu; '
                '"tuzlu" deyip 5 yıldız veren cevap 20 Kasım\'a kadar geçiyordu',
          ),
        );
      },
    );
  }
}
