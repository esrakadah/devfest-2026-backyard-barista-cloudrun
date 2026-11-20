import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The whole tool tour on one slide, ending on the frame of the talk: it works, its tests were
/// green, and it still had five bugs.
class HowItWasBuiltSlide extends FlutterDeckSlideWidget {
  const HowItWasBuiltSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/how-it-was-built',
            title: '4. Bu oyun nasıl yazıldı',
            speakerNotes: 'BEAT  [06:00 - 07:00] Dört araç tek slaytta, ardından konuşmanın çerçevesi: çalışıyor, ama beş hata.\n'
                'SAY   "Bu oyunu dört araçla yaptım. Google AI Studio: tarayıcıda isteğini yazıyorsun, çalışan uygulamayı alıyorsun. Antigravity: tek istekle birçok dosyayı değiştiren bir AI editör. Oyun sahnesi Flame ile, raflar ve tepsi Flutter widget\'larıyla. Hepsi Cloud Run\'da; Cloud Run, uygulamanızı internette çalıştıran Google servisi. Sonuç: çalışan bir oyun ve 32 test, hepsi yeşil. 20 Kasım\'da aynı kodda beş hata buldum. Çalışıyor olması ve testlerin yeşil olması, doğru olduğu anlamına gelmiyor."\n'
                'HOLD  Dört kartı soldan sağa göster, okuma. Alttaki cümlede dur ve salona bak.\n'
                'NEXT  "Bu beş hatadan beş kural çıktı."',
          ),
        );

  static const double _gap = 18;
  static const double _toolTitleSize = 34;
  static const double _toolLineSize = 30;
  static const double _bannerPaddingHorizontal = 30;
  static const double _bannerPaddingVertical = 22;
  static const double _bannerTextSize = 40;
  static const double _bannerRadius = 18;
  static const double _bannerBorderOpacity = 0.7;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'BU OYUN NASIL YAZILDI',
          title: 'Dört araç, çalışan bir oyun',
          act: StoryAct.tools,
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'AI STUDIO',
                        title: 'İsteğini yaz, uygulamayı al',
                        talkTitleFontSize: _toolTitleSize,
                        talkBulletFontSize: _toolLineSize,
                        bullets: ['Tarayıcıda, kurulum yok.', 'İstek metni (prompt) repoda.'],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ANTIGRAVITY',
                        title: 'Bir istek, birçok dosya',
                        talkTitleFontSize: _toolTitleSize,
                        talkBulletFontSize: _toolLineSize,
                        accentColor: DeckColors.googleYellow,
                        bullets: ['AI destekli kod editörü.', 'Kodu yazar, testleri çalıştırır.'],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'FLAME + FLUTTER',
                        title: 'Sahne Flame, tezgah Flutter',
                        talkTitleFontSize: _toolTitleSize,
                        talkBulletFontSize: _toolLineSize,
                        accentColor: DeckColors.googleGreen,
                        bullets: ['Flame: Flutter için oyun motoru.', 'Raflar ve tepsi: widget.'],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'CLOUD RUN',
                        title: 'İnternette canlı adres',
                        talkTitleFontSize: _toolTitleSize,
                        talkBulletFontSize: _toolLineSize,
                        accentColor: DeckColors.googleRed,
                        bullets: ['Uygulamayı internette çalıştırır.', 'Az önce oynadığınız yer.'],
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
                  border: Border.all(
                    color: DeckColors.googleYellow.withValues(alpha: _bannerBorderOpacity),
                    width: 2,
                  ),
                ),
                child: const Text(
                  "Çalışıyor. 32 test yeşil. 20 Kasım'da içinde 5 hata buldum.",
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
