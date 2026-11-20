import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 2, rule slide: a closed list instead of free text.
class TypedOutputRuleSlide extends FlutterDeckSlideWidget {
  const TypedOutputRuleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/typed-output-rule',
            title: '8. Kural 2: serbest metin yerine kapalı liste',
            speakerNotes: 'BEAT  [10:30 - 11:30] Kural 2. Yeni kelime: enum. Şemayı da burada tanımla.\n'
                'SAY   "İkinci kural. Yeni kelime enum: izin verilen değerlerin kapalı listesi. Oyunda modelin verebileceği üç karar var: tatlı, tuzlu, acı. Bunlar kodda düz metindi; karar metinleri 21 ayrı yerde elle yazılıydı. Bir harfi yanlış yazarsanız kimse fark etmiyor. Bir de şema var: modele \'cevabı şu kalıpta ver\' dediğimiz tarif. Daha kötüsü, Gemini\'ye giden şemada bu liste hiç yoktu. Şimdi liste tek bir yerde duruyor; şema da kod da oradan okuyor."\n'
                'HOLD  Üç kutu, soldan sağa. "21 ayrı yerde" derken dur.\n'
                'NEXT  "Kodda nasıl görünüyor?"',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 2 / 5',
          title: 'Serbest metin yerine kapalı liste',
          act: StoryAct.realNumbers,
          child: LessonRuleBody(
            word: 'Enum',
            definition: 'İzin verilen değerlerin kapalı listesi. Listede olmayan değer kabul edilmez.',
            whatHappened: LessonTile(
              title: 'Karar düz metindi',
              lines: ['Karar metinleri kodda 21 yerde elle yazılıydı.', "Gemini'ye giden şemada liste yoktu."],
              footer: "'sweet_perfection' · 'salty_sabotage' · 'spicy_chaos'",
            ),
            whatWeDid: LessonTile(
              title: 'Tek liste: enum',
              lines: ['İki şema ve istek metni bu listeden üretiliyor.', 'Listede olmayan karar reddediliyor.'],
              footer: 'enum TasteVerdict · cafe_review.dart',
            ),
            proof: LessonTile(
              title: 'Yazım hatası artık yakalanıyor',
              lines: ['"sweet_perfction" reddediliyor.', 'İki şema da aynı listeyi gönderiyor.'],
              footer: 'taste_verdict_test.dart',
            ),
            advanced: "Dart 3 exhaustive switch: listeye yeni değer eklenince derleyici eksik case'i gösterir, "
                'default dalı kalmadı',
          ),
        );
      },
    );
  }
}
