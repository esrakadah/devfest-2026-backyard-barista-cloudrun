import 'package:backyard_barista_deck/leaderboard/hall_board_views.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The hall's live leaderboard, shown while the game still runs. One click forward closes the
/// round: the board freezes and stays as it is until the podium at the end of the talk.
class HallLeaderboardSlide extends FlutterDeckSlideWidget {
  const HallLeaderboardSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/hall-leaderboard',
            title: '7. Skor tablosu: kim önde?',
            steps: _stepCount,
            speakerNotes: 'BEAT  [07:00 - 07:30] Canlı skor tablosu. Bir tık ileri: süre doldu, tablo donar.\n'
                'SAY   "Bakalım kim önde. Puanı Gemini değil kod veriyor, o yüzden tablo adil. Süre doldu: tablo dondu. İlk üçü kapanışta kullanıcı adıyla sahneye çağıracağım: birinciye Dash, ikinciye Google Cloud gözlük, üçüncüye sticker seti. Telefonları kilitleyip cebinize koyun. Rozetiniz aklınızda kalsın; birazdan soracağım."\n'
                'HOLD  Slayt açıldığında tablo canlıdır. "Süre doldu" derken ileri tuşuna bir kez bas: başlık "SÜRE DOLDU" olur ve tablo donar. Geri tuşu tabloyu yeniden canlıya alır. Tablo boşsa ya da "BAĞLANTI BEKLENİYOR" yazıyorsa bekleme: "Tabloyu kapanışta göstereceğim" de ve geç. Uygunsuz bir isim *** olarak görünür; sahneye çağırmadan önce adı kendin oku.\n'
                'NEXT  "Peki bu oyun nasıl yazıldı?"',
          ),
        );

  static const int _stepCount = 2;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'CANLI SKOR TABLOSU',
          title: 'Kim önde?',
          act: StoryAct.tools,
          accentColor: DeckColors.googleGreen,
          child: FlutterDeckSlideStepsBuilder(
            builder: (context, stepNumber) => HallBoardView(isFrozen: stepNumber >= _stepCount),
          ),
        );
      },
    );
  }
}
