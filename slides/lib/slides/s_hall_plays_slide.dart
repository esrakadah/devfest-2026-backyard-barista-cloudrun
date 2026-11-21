import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The hall plays the live game right after the poll, with three things to try. Each one is picked
/// up again by a lesson later in the talk.
class HallPlaysSlide extends FlutterDeckSlideWidget {
  const HallPlaysSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/hall-plays',
            title: '6. Salon oynuyor: QR ve üç görev',
            speakerNotes:
                'BEAT  [03:15 - 07:00] Canlı oyun. Önce kendi iki tepsin (canlı sekmede, 75 sn), sonra bu slayt ve salon (2,5 dk).\n'
                'SAY   "Canlı oyundayız, Cloud Run\'da çalışıyor. Doğru bir tepsi: kahve, tatlı, şeker. Servis Et: beş yıldız. Kartın altında Jüri: Canlı Gemini yazıyorsa, bu esprili yorumu Gemini yazdı. Şimdi şeker yerine tuz: bir yıldız. Sıra sizde. Önce telefonun sesini kısın, sonra QR kodu okutun ve bir kullanıcı adı yazın. Puanınız sahnedeki tabloya düşecek; tabloyu iki buçuk dakika sonra donduracağım. Birinciye Dash, ikinciye Google Cloud gözlük, üçüncüye sticker seti; kazananları kapanışta o kullanıcı adıyla sahneye çağıracağım. Üç de göreviniz var. Bir: tatlı siparişe gizlice tuz atın. İki: gelen kartın altındaki jüri rozetini okuyun, ne yazdığını aklınızda tutun. Üç, hızlı olanlar için: Servis Et\'e basın ve hemen Sıradaki Müşteri\'ye basın."\n'
                'HOLD  1) Canlı Cloud Run sekmesi: tatlı tepsi 5 yıldız, tuzlu tepsi 1 yıldız. Rozete bak: "Canlı Gemini" yazmıyorsa Gemini cümlesini atla ve "Bu kez hazır yanıt geldi; nedenini birazdan anlatacağım" de. 2) "Sıra sizde" derken bu slaytı aç; önce tam ekran QR sekmesini 30 saniye göster, sonra bu slayta dön. "Okutamayan yanındakinin telefonundan oynasın" de. 3) Sayaç 05:00: "Açabilenler el kaldırsın." Yarıdan azsa "Yanınızdakinin ekranına bakın" de ve 06:00\'da bitir. 4) Salon oynarken sus; 06:45\'te "Son on beş saniye" de. Oyun sende açılmazsa Stage Navigator ile "Demo aksadı" slaytına geç.\n'
                'NEXT  "Bakalım kim önde."',
          ),
        );

  static const double _gap = 22;
  static const double _qrSize = 500;
  static const double _taskTitleSize = 36;
  static const double _taskLineSize = 28;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'CANLI OYUN · TELEFONUNUZLA KATILIN',
          title: 'Sıra sizde: QR kodu okutun',
          act: StoryAct.tools,
          accentColor: DeckColors.googleGreen,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'GÖREV 1',
                        title: 'Tatlı siparişe gizlice tuz atın',
                        talkTitleFontSize: _taskTitleSize,
                        talkBulletFontSize: _taskLineSize,
                        accentColor: DeckColors.googleYellow,
                        bullets: ['Kahve + tatlı + tuzluk, sonra Servis Et.'],
                      ),
                    ),
                    SizedBox(height: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'GÖREV 2',
                        title: 'Kartın altındaki jüri rozetini okuyun',
                        talkTitleFontSize: _taskTitleSize,
                        talkBulletFontSize: _taskLineSize,
                        bullets: ['"Jüri:" yazısından sonra ne geliyor? Aklınızda tutun.'],
                      ),
                    ),
                    SizedBox(height: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'GÖREV 3',
                        title: 'Hızlıysanız: Servis Et, hemen ardından Sıradaki Müşteri',
                        talkTitleFontSize: _taskTitleSize,
                        talkBulletFontSize: _taskLineSize,
                        accentColor: DeckColors.googleGreen,
                        bullets: ['Jüri düşünürken yetişebildiniz mi?'],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: _gap),
              Center(
                child: QrCodeCard(
                  assetPath: isIzmirDeck
                      ? 'assets/images/backyard_barista_cloudrun_qr.png'
                      : 'assets/images/backyard_barista_konya_qr.png',
                  caption: isIzmirDeck ? 'Canlı kafeyi oyna' : 'Konya kafesini oyna',
                  size: _qrSize,
                  accentColor: DeckColors.googleGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
