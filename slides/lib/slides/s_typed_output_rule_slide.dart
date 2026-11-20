import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
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
            title: '9. Kural 2: serbest metin yerine kapalı liste',
            speakerNotes: 'BEAT  [11:00 - 12:00] Kural 2. Yeni kelime: enum. Şemayı da burada tanımla.\n'
                'SAY   "İkinci kural. Yeni kelime enum: izin verilen değerlerin kapalı listesi. Oyunda modelin verebileceği üç karar var: tatlı, tuzlu, acı. Bunlar kodda düz metindi; karar metinleri 21 ayrı yerde elle yazılıydı. Bir harfi yanlış yazarsanız kimse fark etmiyor. Bir de şema var: modele \'cevabı şu kalıpta ver\' dediğimiz tarif. Daha kötüsü, Gemini\'ye giden şemada bu liste hiç yoktu. Şimdi liste tek bir yerde duruyor; şema da kod da oradan okuyor."\n'
                'HOLD  Önce üç yüz, sonra tablo: üç yeşil satır, iki kırmızı satır. "Yine geçti" sütununda dur; "21 ayrı yerde" derken sağ üstteki etiketi göster.\n'
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
          child: LessonPictureBody(
            word: 'Enum',
            definition: 'İzin verilen değerlerin kapalı listesi. Listede olmayan değer kabul edilmez.',
            picture: ClosedListDiagram(),
            advanced: "Dart 3 exhaustive switch: listeye yeni değer eklenince derleyici eksik case'i gösterir, "
                'default dalı kalmadı',
          ),
        );
      },
    );
  }
}
