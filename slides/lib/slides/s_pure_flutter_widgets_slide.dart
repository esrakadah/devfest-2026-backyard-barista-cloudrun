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
            title: '6. Hybrid Flame Engine + Flutter HUD Architecture',
            speakerNotes:
                'BEAT  [09:30 - 11:30] Mimari Karar: BaristaFlameGame 60fps 3-Koridorlu Sahne + Reaktif Flutter HUD.\n'
                'SAY   "Bir kafe oyunu yaparken sahne atmosferi için Flame motorunun 60fps gücünü, sipariş tezgahı için ise Flutter\'ın reaktif widget ağacını birleştirdik. Arka planda BaristaFlameGame, sıcak ceviz paleti (#1E130C ve #F4E4CE) ve Hogsmeade sahne dekoruyla 3 koridorlu 60fps arcade sahnesini çiziyor. Ön planda ise Flutter Overlay HUD kartlarımız (2x2 tezgah ızgarası ve 3 yuvalı ahşap tepsi) hem 360 piksel mobilde hem masaüstünde sıfır taşmayla çalışıyor."\n'
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
          eyebrow: 'ARCHITECTURAL DECISION (flutter/one-codebase · package:flame)',
          title: 'Hybrid Flame Engine + Flutter HUD Architecture',
          act: StoryAct.tools,
          subtitle:
              'BaristaFlameGame 60fps 3-lane arcade stage (#1E130C / #F4E4CE) paired with reactive 2x2 Flutter HUD cards',
          accentColor: DeckColors.googleGreen,
          child: Row(
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'STAGE · BARISTAFLAMEGAME (60FPS)',
                  title: 'FlameGame 3-Lane Arcade Stage + Hogsmeade Backdrop',
                  accentColor: DeckColors.googleYellow,
                  bullets: [
                    '60fps 3-Lane Arcade Stage: BaristaFlameGame renders Beverage, Sweet, and Prank lanes with smooth animations.',
                    'Warm Walnut Palette (#1E130C / #F4E4CE): Rich timber stage paired with the Hogsmeade cafe backdrop.',
                    'Reactive Stage Avatars: Barista and customer sprites react live to tray drops, steam particles, and verdicts.',
                    'Deterministic Layout: Scene coordinates stay locked to the 3-lane stage while UI controls live in Flutter.',
                  ],
                  footerText: 'flutter_client/lib/game/barista_flame_game.dart (commit e5d905e)',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'HUD · REACTIVE FLUTTER OVERLAY WIDGETS',
                  title: '2x2 Counter Grid + 3-Slot Wooden Tray HUD',
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    '2x2 Counter HUD Grid: Beverages, Sweet Treats, Prank Shelf, and 3-Slot Wooden Tray in clean Flutter cards.',
                    'Responsive Out of the Box: LayoutBuilder scales the 2x2 counter cleanly from 360x780 mobile to 1280x900 desktop.',
                    '100% LLM Codegen Reliability: Gemini & Antigravity generate rock-solid Row, Column, Wrap, and Stack HUDs.',
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
