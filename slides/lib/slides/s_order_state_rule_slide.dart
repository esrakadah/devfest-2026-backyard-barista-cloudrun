import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 3, rule slide: make the state that must not exist impossible to write.
class OrderStateRuleSlide extends FlutterDeckSlideWidget {
  const OrderStateRuleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/order-state-rule',
            title: '15. Kural 3: olmaması gereken durum, yazılamasın',
            steps: _stepCount,
            speakerNotes:
                'BEAT  [15:30 - 16:45] Kural 3. Üçüncü görevi salona sor, sonra yeni kelime: sealed class. SAY, canlı oyunun düzeltilmiş sürüm olduğunu varsayar; değilse HOLD satırındaki cümleleri kullan.\n'
                'SAY   "Üçüncü kural. Kim Servis Et\'e basıp hemen Sıradaki Müşteri\'ye bastı? Garip bir şey görmediniz, çünkü düzelttim. 20 Kasım\'daki sürümde aynı hamle şunu yapıyordu: yeni müşteri gelmiş, tepsi boş, ama ekranda beş yıldızlı bir kart ve elli puan. Önceki siparişin cevabı yeni müşteriye yazılıyordu. Yeni kelime sealed class: bir şeyin alabileceği halleri tek tek sayan bir kalıp. Sipariş ya boşta, ya jüride, ya servis edildi. Dördüncü hal yok. Kod yazmanıza izin vermiyorsa, yanlışlıkla da yapamazsınız."\n'
                'HOLD  CANLI OYUN ESKİ SÜRÜMSE üçüncü ve dördüncü cümlenin ("Garip bir şey görmediniz..." ve "20 Kasım\'daki sürümde...") yerine şunu söyle: "Yeterince hızlı olanlar şunu gördü: yeni müşteri gelmiş, tepsi boş, ama ekranda beş yıldızlı bir kart ve elli puan. Görmediyseniz cevap parmağınızdan hızlıydı. Bu hata şu an canlıda duruyor; düzeltmesi yazıldı, testi yeşil." El kalkmazsa: "Normal, cevap sizden hızlıydı." Bekleme, devam et. İlk açılışta beş satır nötrdür; ilk tıkta iki saçma durum kırmızı yanar, ikinci tıkta üstleri çizilir ve sağda üç OrderState hali açılır.\n'
                'NEXT  "Hata tek bir unutulmuş satırdı."',
          ),
        );

  static const int _stepCount = 3;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'KURAL 3 / 5',
          title: 'Olmaması gereken durum, yazılamasın',
          act: StoryAct.underTheHood,
          child: FlutterDeckSlideStepsBuilder(
            builder: (context, stepNumber) => LessonPictureBody(
              word: 'Sealed class',
              definition: '"Sipariş ya boşta, ya jüride, ya servis edildi" diyen tip. Dördüncü hal yok.',
              picture: OrderStateDiagram(step: OrderStateStep.fromStepNumber(stepNumber)),
              advanced: 'geç gelen cevap identical() ile reddediliyor; '
                  'enum yetmez, çünkü 1. siparişi 2. siparişten ayıramaz',
            ),
          ),
        );
      },
    );
  }
}
