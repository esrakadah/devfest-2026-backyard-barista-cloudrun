import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class PureFlutterWidgetsSlide extends FlutterDeckSlideWidget {
  const PureFlutterWidgetsSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/pure-flutter-widgets',
            title: isTurkishDeck
                ? '6. Flame sahnesi + Flutter arayüzü'
                : '6. Hybrid Flame Engine + Flutter HUD Architecture',
            speakerNotes: isTurkishDeck
                ? "BEAT  [05:45 - 07:00] Mimari karar: sahne Flame ile, tezgah Flutter widget'larıyla.\n"
                    'SAY   "Bir oyun yazarken her şeyi oyun motorunun içine koymak zorunda değiliz. Arka plandaki 3 şeritli kafe sahnesini ve karakter animasyonlarını Flame çiziyor; Flame, Flutter için bir oyun motoru. Ön plandaki üç raf ve 3 gözlü ahşap tepsi ise bildiğimiz deklaratif Flutter widget\'ları. Neden? Çünkü büyük dil modelleri koordinat matematiğinde yanılabiliyor. Row, Column ve LayoutBuilder ile ise ilk denemede taşmayan, 360 piksellik telefonda da masaüstünde de çalışan, WidgetTester ile test edebildiğimiz bir arayüz çıkarıyorlar."\n'
                    'HOLD  Soldaki sahne (Flame) ve sağdaki arayüz (Flutter) kartlarını elinle ayır. "60fps" tasarım hedefi, ölçüm diye sunma.\n'
                    'NEXT  "Açılışta söz verdiğim bölüme geldik: gerçek rakamlar. Gecikme, soğuk başlangıç ve maliyet ne durumda?"'
                : 'BEAT  [09:30 - 11:30] Mimari Karar: BaristaFlameGame 60fps 3-Koridorlu Sahne + Reaktif Flutter HUD.\n'
                    'SAY   "Bir kafe oyunu yaparken sahne atmosferi için Flame motorunun 60fps gücünü, sipariş tezgahı için ise Flutter\'ın reaktif widget ağacını birleştirdik. Arka planda BaristaFlameGame, sıcak ceviz paleti (#1E130C ve #F4E4CE) ve boyalı gece kafesi dekoruyla 3 koridorlu 60fps arcade sahnesini çiziyor. Ön planda ise Flutter Overlay HUD kartlarımız (2x2 tezgah ızgarası ve 3 yuvalı ahşap tepsi) hem 360 piksel mobilde hem masaüstünde sıfır taşmayla çalışıyor."\n'
                    'HOLD  Sol karttaki BaristaFlameGame 60fps 3-koridorlu arcade sahnesini ve sağ karttaki 2x2 Flutter Overlay HUD mimarisini karşılaştır.\n'
                    'NEXT  "Şimdi söz verdiğimiz en kritik bölüme geliyoruz: Gerçek Rakamlar! Prodüksiyonda gecikme, soğuk başlangıç ve maliyet ne durumda?"',
          ),
        );

  static const double _columnGap = 28;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'MİMARİ KARAR'
              : 'ARCHITECTURAL DECISION (flutter/one-codebase · package:flame)',
          title: isTurkishDeck
              ? 'Oyun sahnesi Flame, butonlar Flutter'
              : 'Hybrid Flame Engine + Flutter HUD Architecture',
          act: StoryAct.tools,
          subtitle: isTurkishDeck
              ? "Her işi en iyi yapan araca verdik: animasyon oyun motorunda, arayüz widget'larda"
              : 'BaristaFlameGame 60fps 3-lane arcade stage (#1E130C / #F4E4CE) paired with reactive 2x2 Flutter HUD cards',
          accentColor: DeckColors.googleGreen,
          child: Row(
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: isTurkishDeck ? 'SAHNE · FLAME (OYUN MOTORU)' : 'STAGE · BARISTAFLAMEGAME (60FPS)',
                  title: isTurkishDeck
                      ? 'Arkada: hareketli kafe sahnesi'
                      : 'FlameGame 3-Lane Arcade Stage + Night-Cafe Backdrop',
                  accentColor: DeckColors.googleYellow,
                  bullets: [
                    if (isTurkishDeck)
                      'Üç şerit: içecek, tatlı, şaka.'
                    else
                      '60fps 3-Lane Arcade Stage: BaristaFlameGame renders Beverage, Sweet, and Prank lanes with smooth animations.',
                    if (!isTurkishDeck)
                      'Warm Walnut Palette (#1E130C / #F4E4CE): Rich timber stage over a painted night-cafe backdrop.',
                    if (isTurkishDeck)
                      'Barista ve müşteri olanlara tepki verir.'
                    else
                      'Reactive Stage Avatars: Barista and customer sprites react live to tray drops, steam particles, and verdicts.',
                    if (!isTurkishDeck)
                      'Deterministic Layout: Scene coordinates stay locked to the 3-lane stage while UI controls live in Flutter.',
                  ],
                  footerText: isTurkishDeck
                      ? 'İleri seviye: BaristaFlameGame, 60fps hedefi · barista_flame_game.dart'
                      : 'flutter_client/lib/ui/barista_flame_game.dart',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                child: DeckFeatureCard(
                  badge:
                      isTurkishDeck ? "ARAYÜZ · FLUTTER WIDGET'LARI" : 'HUD · REACTIVE FLUTTER OVERLAY WIDGETS',
                  title:
                      isTurkishDeck ? 'Önde: raflar ve tepsi' : '2x2 Counter Grid + 3-Slot Wooden Tray HUD',
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    if (isTurkishDeck)
                      'Telefonda da masaüstünde de düzgün görünür.'
                    else
                      '2x2 Counter HUD Grid: Beverages, Sweet Treats, Prank Shelf, and 3-Slot Wooden Tray in clean Flutter cards.',
                    if (!isTurkishDeck)
                      'Responsive Out of the Box: LayoutBuilder scales the 2x2 counter cleanly from 360x780 mobile to 1280x900 desktop.',
                    if (isTurkishDeck)
                      'AI, Row ve Column ile sağlam arayüz yazar.'
                    else
                      '100% LLM Codegen Reliability: Gemini & Antigravity generate rock-solid Row, Column, Wrap, and Stack HUDs.',
                    if (!isTurkishDeck)
                      'Built-in Accessibility & Testing: Standard Semantics and WidgetTester finders (cafe_counter_test.dart).',
                  ],
                  footerText: isTurkishDeck
                      ? 'İleri seviye: LayoutBuilder 360 px - 1280 px, WidgetTester · cafe_counter_screen.dart'
                      : 'flutter_client/lib/ui/cafe_counter_screen.dart',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
