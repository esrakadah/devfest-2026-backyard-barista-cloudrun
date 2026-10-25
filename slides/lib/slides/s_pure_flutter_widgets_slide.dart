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
            title: '6. Why Pure Flutter Widgets Beat Flame Here',
            speakerNotes: 'BEAT  [09:30 - 11:30] Mimari Karar: Neden Flame değil de saf Flutter widget ağacı?\n'
                'SAY   "Bir oyun yapıyoruz dediğimizde akla ilk Flame motoru gelebilir. Ama 40 dakikalık bir atölyede, tezgaha tıklayarak kahve ve tatlı hazırladığımız bir oyunda Flame kullanmak büyük bir tuzak olurdu. Neden? Çünkü dil modelleri Flame içinde Vector2 koordinatlarını sık sık yanlış hesaplıyor ve ekran dışına taşırıyor. Oysa saf Flutter widget\'ları, yani Stack, AnimatedScale, AnimatedSwitcher ve LayoutBuilder kullandığımızda hem 360 piksel mobil ekranda hem masaüstünde sıfır taşmayla çalışıyor, hem de AI Studio\'nun ürettiği web arayüzüyle birebir aynı mantığı paylaşıyor."\n'
                'HOLD  Sol karttaki yeşil avantajları ve sağ karttaki kırmızı riskleri karşılaştır.\n'
                'NEXT  "Şimdi söz verdiğimiz en kritik bölüme geliyoruz: Gerçek Rakamlar! Prodüksiyonda gecikme, soğuk başlangıç ve maliyet ne durumda?"',
          ),
        );

  static const double _columnGap = 28;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'ARCHITECTURAL DECISION (flutter/one-codebase)',
          title: 'Why Pure Flutter Declarative Widgets Beat Flame Here',
          act: StoryAct.tools,
          subtitle: 'Designing for 40-minute beginner ergonomics and LLM code-generation accuracy',
          accentColor: DeckColors.googleGreen,
          child: Row(
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'CHOSEN · PURE FLUTTER WIDGETS',
                  title: 'Stack + AnimatedScale + AnimatedSwitcher',
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    '100% LLM Codegen Reliability: Gemini & Antigravity generate rock-solid Row, Column, Wrap, and Stack layouts on the first try.',
                    'Responsive out of the box: LayoutBuilder scales our cafe counter cleanly from 360x780 mobile phones to 1280x1200 desktops.',
                    '1:1 Parity with Lane A: Matches the declarative component mental model of AI Studio Build mode.',
                    'Built-in Accessibility & Testing: Standard Semantics and WidgetTester finders (7/7 tests passing in cafe_counter_test.dart).',
                  ],
                  footerText: 'flutter_client/lib/ui/cafe_counter_screen.dart',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'REJECTED FOR THIS SLOT · PACKAGE:FLAME',
                  title: 'Why a 2D Physics Loop Hurts a 40-Min Cafe Game',
                  accentColor: DeckColors.googleRed,
                  bullets: [
                    'Vector2 Coordinate Hallucinations: LLMs frequently misplace absolute canvas coordinates across different aspect ratios.',
                    'Cognitive Overhead: Teaching FlameGame, PositionComponent, and sprite asset loaders eats 25 of our 40 build minutes.',
                    'Zero Physics Needed: Backyard Barista is a turn-based, tap-to-assemble tray game judged by structured JSON.',
                    'Harder Web/DOM Parity: Diverges from the HTML/React output that Lane A builders see in AI Studio.',
                  ],
                  footerText: 'Rule: Pick the simplest architecture that ships in 40 minutes.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
