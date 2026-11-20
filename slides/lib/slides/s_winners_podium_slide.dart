import 'package:backyard_barista_deck/leaderboard/hall_board_views.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The prize moment before the closing slide: each click forward reveals one place, third first.
class WinnersPodiumSlide extends FlutterDeckSlideWidget {
  const WinnersPodiumSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/winners-podium',
            title: '20. Podyum: ilk üç sahneye',
            steps: _stepCount,
            speakerNotes: 'BEAT  [26:00 - 27:30] Ödül anı. Üç tık: üçüncü, ikinci, birinci.\n'
                'SAY   "Söz verdiğim gibi: podyum. Üçüncümüz sticker setini alıyor. İkincimiz Google Cloud gözlüğü. Ve birincimiz, Dash\'in yeni sahibi. Üçünüzü de sahneye bekliyorum."\n'
                'HOLD  Slayt üç soru işaretiyle açılır. Her ödülden önce ileri tuşuna bir kez bas, ekrandaki kullanıcı adını yüksek sesle oku ve salonun alkışını bekle. İsim *** görünüyorsa okuma, "üçüncümüz kendini biliyor" de. Kutu "Henüz kimse yok" diyorsa o ödülü fuayede vereceğini söyle. Üçü sahneye gelince ödülleri ver, tek bir fotoğraf çektir.\n'
                'NEXT  "Ve son olarak: bana nasıl ulaşırsınız?"',
          ),
        );

  /// The empty podium, then one step for each of the three places.
  static const int _stepCount = 4;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'ÖDÜL ANI',
          title: 'Podyum: en hızlı üç barista',
          act: StoryAct.buildAndShip,
          child: FlutterDeckSlideStepsBuilder(
            builder: (context, stepNumber) => WinnersPodiumView(revealedPlaces: stepNumber - 1),
          ),
        );
      },
    );
  }
}
