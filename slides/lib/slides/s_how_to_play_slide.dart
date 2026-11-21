import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The game in three steps, shown before the speaker plays two trays in the live tab.
class HowToPlaySlide extends FlutterDeckSlideWidget {
  const HowToPlaySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/how-to-play',
            title: '5. Oyun: üç adımda bir tepsi',
            speakerNotes: 'BEAT  [02:45 - 03:15] Oyunun kuralı, üç adım. Sonra canlı sekmeye geç.\n'
                'SAY   "Oyun üç adım. Bir: raftan ürün seçip tepsiyi diziyorsunuz; tatlı bir tepsi kahve, tatlı ve şeker demek. İki: Servis Et\'e basıyorsunuz, tepsi jüriye gidiyor; jürimiz Gemini. Üç: bir kart geliyor: yıldız, esprili bir yorum ve en altta cevabı kimin verdiğini söyleyen jüri rozeti. Doğru tepsi yüz puan."\n'
                'HOLD  Üç kartı soldan sağa göster, okuma. Bu slayttan sonra canlı Cloud Run sekmesine geç.\n'
                'NEXT  "Önce ben oynayacağım, sonra siz."',
          ),
        );

  static const double _gap = 20;
  static const double _bannerPaddingHorizontal = 30;
  static const double _bannerPaddingVertical = 20;
  static const double _bannerTextSize = 36;
  static const double _bannerRadius = 18;
  static const double _bannerBorderOpacity = 0.7;
  static const double _arrowSize = 56;
  static const double _starSize = 72;
  static const int _starCount = 5;
  static const double _judgeBadgeGap = 18;
  static const double _judgeBadgeSize = 26;
  static const double _serveIconSize = 150;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'OYUN NASIL OYNANIR',
          title: 'Üç adımda bir tepsi',
          act: StoryAct.tools,
          accentColor: DeckColors.googleGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      child: _StepCard(
                        step: 'ADIM 1',
                        title: 'Raftan ürün seçin',
                        line: 'Tatlı tepsi: kahve + tatlı + şeker.',
                        accentColor: DeckColors.googleYellow,
                        visual: _TrayVisual(),
                      ),
                    ),
                    const _StepArrow(),
                    const Expanded(
                      child: _StepCard(
                        step: 'ADIM 2',
                        title: "Servis Et'e basın",
                        line: 'Tepsi jüriye gider. Jüri: Gemini.',
                        accentColor: DeckColors.googleBlue,
                        visual: Icon(Icons.room_service, size: _serveIconSize, color: DeckColors.googleBlue),
                      ),
                    ),
                    const _StepArrow(),
                    Expanded(
                      child: _StepCard(
                        step: 'ADIM 3',
                        title: 'Jüri kartı gelir',
                        line: 'Yıldız, yorum ve jüri rozeti.',
                        accentColor: DeckColors.googleGreen,
                        visual: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var star = 0; star < _starCount; star++)
                                  const Icon(Icons.star_rounded, size: _starSize, color: DeckColors.googleYellow),
                              ],
                            ),
                            const SizedBox(height: _judgeBadgeGap),
                            const Text(
                              'Jüri: Canlı Gemini',
                              style: TextStyle(
                                fontFamily: DeckFonts.mono,
                                fontSize: _judgeBadgeSize,
                                fontWeight: FontWeight.w700,
                                color: DeckColors.googleGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _gap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _bannerPaddingHorizontal,
                  vertical: _bannerPaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: DeckColors.surfaceInset,
                  borderRadius: BorderRadius.circular(_bannerRadius),
                  border: Border.all(color: DeckColors.googleYellow.withValues(alpha: _bannerBorderOpacity), width: 2),
                ),
                child: const Text(
                  'Doğru tepsi 100 puan. Önce ben oynayacağım, sonra siz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _bannerTextSize,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.googleYellow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.line,
    required this.accentColor,
    required this.visual,
  });

  static const double _padding = 26;
  static const double _titleSize = 42;
  static const double _lineSize = 30;
  static const double _lineGap = 8;

  final String step;
  final String title;
  final String line;
  final Color accentColor;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(_padding),
      borderColor: accentColor.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeckBadge(label: step, color: accentColor),
          Expanded(child: Center(child: visual)),
          Text(
            title,
            style: const TextStyle(
              fontFamily: DeckFonts.cardDisplay,
              fontSize: _titleSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
          const SizedBox(height: _lineGap),
          Text(
            line,
            style: const TextStyle(fontFamily: DeckFonts.sans, fontSize: _lineSize, color: DeckColors.offWhite),
          ),
        ],
      ),
    );
  }
}

class _TrayVisual extends StatelessWidget {
  const _TrayVisual();

  static const double _itemSize = 140;
  static const double _itemGap = 14;
  static const double _itemRadius = 18;
  static const List<String> _items = ['espresso.png', 'baklava.png', 'sugar_jar.png'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, item) in _items.indexed) ...[
          if (index > 0) const SizedBox(width: _itemGap),
          ClipRRect(
            borderRadius: BorderRadius.circular(_itemRadius),
            child: Image.asset('assets/cafe/$item', width: _itemSize, height: _itemSize, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.arrow_forward_rounded, size: HowToPlaySlide._arrowSize, color: DeckColors.onGroundAccent),
    );
  }
}
