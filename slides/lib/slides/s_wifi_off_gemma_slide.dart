import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Backup: the Wi-Fi off step with the local Gemma judge, shown only if time allows or someone asks.
class WifiOffGemmaSlide extends FlutterDeckSlideWidget {
  const WifiOffGemmaSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/wifi-off-gemma',
            title: 'Yedek: Wi-Fi kapalı, jüri bu laptopta',
            speakerNotes: 'BEAT  [YEDEK] B planının canlı gösterimi. Yalnızca süre kalırsa ya da sorulursa.\n'
                'SAY   "B planını canlı görelim. Wi-Fi\'ı kapatıyorum ve aynı tuzlu tepsiyi gönderiyorum; bu kez bulut yok. Kararı bu laptoptaki Gemma 4 veriyor. Beş ile sekiz saniye sürebiliyor; on beş saniyelik sınır bunun için. O da yetişmezse paketteki hazır yanıt gelir."\n'
                'HOLD  Yerel oyun sekmesine geç (sahneden önce açtığın sekme). Sahnede komut çalıştırma. Gemma düşünürken sus ve bekle. Bitince Stage Navigator ile kaldığın slayta dön.\n'
                'NEXT  "Kaldığımız yerden devam edelim."',
          ),
        );

  static const double _gap = 20;
  static const double _stepTitleSize = 34;
  static const double _stepLineSize = 30;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'YEDEK · B PLANI CANLI',
          title: 'Wi-Fi kapalı: jüri bu laptopta',
          act: StoryAct.underTheHood,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 1',
                  title: "Wi-Fi'ı kapat",
                  talkTitleFontSize: _stepTitleSize,
                  talkBulletFontSize: _stepLineSize,
                  accentColor: DeckColors.googleRed,
                  bullets: ['Canlı Gemini artık ulaşılamaz.', 'Oyun aynı, kod aynı.'],
                ),
              ),
              SizedBox(width: _gap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 2',
                  title: 'Tuzlu tepsiyi servis et',
                  talkTitleFontSize: _stepTitleSize,
                  talkBulletFontSize: _stepLineSize,
                  accentColor: DeckColors.googleYellow,
                  bullets: ['Kararı laptoptaki Gemma 4 verir.', 'Sınır 15 saniye.'],
                  footerText: 'ölçüm: 5,0 ile 8,4 sn arası · 12 tepsi · 11 Kas 2026',
                ),
              ),
              SizedBox(width: _gap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 3',
                  title: 'Rozeti oku',
                  talkTitleFontSize: _stepTitleSize,
                  talkBulletFontSize: _stepLineSize,
                  accentColor: DeckColors.googleGreen,
                  bullets: ['"Yerel Gemma 4": B planı.', '"Yerel JSON Şeması": C planı.'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
