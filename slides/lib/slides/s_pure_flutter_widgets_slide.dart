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
                ? "BEAT  [09:30 - 11:30] Mimari karar: sahne Flame ile, tezgah Flutter widget'larıyla.\n"
                    'SAY   "Oyunun sahnesini bir oyun motoru çiziyor, tezgahını Flutter. Flame, Flutter için yazılmış bir oyun motoru. Arkadaki 3 şeritli sahneyi BaristaFlameGame çiziyor. Öndeki tezgah ise bildiğimiz Flutter widget\'ları: 2x2 kartlar ve 3 gözlü ahşap tepsi. Oyunlarda bu arayüz katmanına HUD deniyor. Aynı ekran 360 piksel telefonda da masaüstünde de taşmadan çalışıyor."\n'
                    'HOLD  Soldaki kart sahne (Flame), sağdaki kart tezgah (Flutter): ikisini elinle ayır. "60fps" bugün salonda ölçülmedi, [HEDEF]: "hedefimiz saniyede 60 kare" de.\n'
                    'NEXT  "Şimdi söz verdiğimiz bölüm: gerçek rakamlar. Gecikme, soğuk başlangıç ve maliyet ne durumda?"'
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
              ? 'MİMARİ KARAR (flutter/one-codebase · package:flame)'
              : 'ARCHITECTURAL DECISION (flutter/one-codebase · package:flame)',
          title: isTurkishDeck
              ? 'Flame sahnesi + Flutter arayüzü: hibrit mimari'
              : 'Hybrid Flame Engine + Flutter HUD Architecture',
          act: StoryAct.tools,
          subtitle: isTurkishDeck
              ? 'BaristaFlameGame 3 şeritli sahneyi çizer (#1E130C / #F4E4CE), tezgah 2x2 Flutter kartlarıyla çalışır'
              : 'BaristaFlameGame 60fps 3-lane arcade stage (#1E130C / #F4E4CE) paired with reactive 2x2 Flutter HUD cards',
          accentColor: DeckColors.googleGreen,
          child: Row(
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: isTurkishDeck ? 'SAHNE · BARISTAFLAMEGAME (60FPS HEDEFİ)' : 'STAGE · BARISTAFLAMEGAME (60FPS)',
                  title: isTurkishDeck
                      ? 'FlameGame: 3 şeritli sahne + gece kafesi dekoru'
                      : 'FlameGame 3-Lane Arcade Stage + Night-Cafe Backdrop',
                  accentColor: DeckColors.googleYellow,
                  bullets: [
                    if (isTurkishDeck)
                      '3 şeritli sahne, 60fps hedefi: BaristaFlameGame içecek, tatlı ve şaka şeritlerini akıcı animasyonla çizer.'
                    else
                      '60fps 3-Lane Arcade Stage: BaristaFlameGame renders Beverage, Sweet, and Prank lanes with smooth animations.',
                    if (isTurkishDeck)
                      'Sıcak ceviz paleti (#1E130C / #F4E4CE): boyalı gece kafesi dekorunun önünde ahşap sahne.'
                    else
                      'Warm Walnut Palette (#1E130C / #F4E4CE): Rich timber stage over a painted night-cafe backdrop.',
                    if (isTurkishDeck)
                      'Canlı karakterler: barista ve müşteri tepsiye, buhara ve karara tepki verir.'
                    else
                      'Reactive Stage Avatars: Barista and customer sprites react live to tray drops, steam particles, and verdicts.',
                    if (isTurkishDeck)
                      "Sabit yerleşim: sahne koordinatları 3 şeride kilitli, butonlar Flutter'da kalır."
                    else
                      'Deterministic Layout: Scene coordinates stay locked to the 3-lane stage while UI controls live in Flutter.',
                  ],
                  footerText: 'flutter_client/lib/ui/barista_flame_game.dart',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                child: DeckFeatureCard(
                  badge:
                      isTurkishDeck ? "ARAYÜZ (HUD) · FLUTTER WIDGET'LARI" : 'HUD · REACTIVE FLUTTER OVERLAY WIDGETS',
                  title:
                      isTurkishDeck ? '2x2 tezgah + 3 gözlü ahşap tepsi' : '2x2 Counter Grid + 3-Slot Wooden Tray HUD',
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    if (isTurkishDeck)
                      '2x2 tezgah: içecekler, tatlılar, şaka rafı ve 3 gözlü tepsi sade Flutter kartlarında.'
                    else
                      '2x2 Counter HUD Grid: Beverages, Sweet Treats, Prank Shelf, and 3-Slot Wooden Tray in clean Flutter cards.',
                    if (isTurkishDeck)
                      'Her ekrana uyar: LayoutBuilder tezgahı 360x780 telefondan 1280x900 masaüstüne ölçekler.'
                    else
                      'Responsive Out of the Box: LayoutBuilder scales the 2x2 counter cleanly from 360x780 mobile to 1280x900 desktop.',
                    if (isTurkishDeck)
                      'AI için kolay hedef: Gemini ve Antigravity Row, Column, Wrap ve Stack ile sağlam arayüz üretir.'
                    else
                      '100% LLM Codegen Reliability: Gemini & Antigravity generate rock-solid Row, Column, Wrap, and Stack HUDs.',
                    if (isTurkishDeck)
                      'Erişilebilirlik ve test hazır: standart Semantics ve WidgetTester (cafe_counter_test.dart).'
                    else
                      'Built-in Accessibility & Testing: Standard Semantics and WidgetTester finders (cafe_counter_test.dart).',
                  ],
                  footerText: 'flutter_client/lib/ui/cafe_counter_screen.dart',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
