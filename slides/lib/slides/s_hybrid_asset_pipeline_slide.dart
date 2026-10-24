import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class HybridAssetPipelineSlide extends FlutterDeckSlideWidget {
  const HybridAssetPipelineSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/hybrid-asset-pipeline',
            title: '11. Hybrid Asset Pipeline: 20 Studio PNGs + On-the-Fly AI SVGs',
            speakerNotes:
                'BEAT  [22:30 - 25:00] Hibrit Görsel Boru Hattı: 20 Hazır Stüdyo PNG + Yolda Üretilen AI Vektörleri.\n'
                'SAY   "Bir oyun atölyesinde en çok vakit kaybettiren şey görsel bulmak ve yüklemektir. Biz bunu hibrit bir boru hattıyla çözdük: 3 içecek, 3 tatlı, 3 şaka malzemesi ve 3 müşteri tepkisinden oluşan toplam 12 adet yüksek çözünürlüklü 1. Tur PNG görselini, 2 adet 2. Tur özel PNG görselini ve 6 adet 3D karakter portresini doğrudan GitHub repomuzun içinde hazır veriyoruz. Ardından 2. Turda herkes kendi özel imza tatlısını ve kendi şaka malzemesini Google AI Studio veya Antigravity ile anında CustomPaint vektör kodu olarak üretiyor. Sıfır dosya yükleme hatası, anında görsel sonuç!"\n'
                'HOLD  Soldaki hazır PNG vitrinini ve sağdaki yolda üretilen CustomPaint vektör akışını göster. [Fact (flutter_client/assets/): 20 PNGs in assets/base/ (12 Round-1 + 2 Round-2 + 6 3D characters), 5 Lottie JSONs in assets/animations/, 10 audio WAVs + Web Audio API synth in assets/audio/].\n'
                'NEXT  "Şimdi bilgisayarlarımızı ve telefonlarımızı açıyoruz: 3 turluk canlı inşa maratonumuz başlıyor!"',
          ),
        );

  static const double _columnGap = 24;
  static const double _gridGap = 12;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 11 · HYBRID ASSET PIPELINE (ZERO UPLOAD FAILURES)',
          title: '20 Pre-Generated Studio PNGs + On-the-Fly AI Vector Dishes',
          subtitle: 'Combining instant visual polish from GitHub with live generative creativity in Round 2',
          accentColor: DeckColors.googleBlue,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'espresso.png',
                            label: 'Espresso',
                            badgeText: 'Drinks (1/3)',
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'menengic_coffee.png',
                            label: 'Menengiç',
                            badgeText: 'Drinks (3/3)',
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'croissant.png',
                            label: 'Croissant',
                            badgeText: 'Foods (1/3)',
                            imageSize: 92,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _gridGap),
                    Row(
                      children: [
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'san_sebastian.png',
                            label: 'San Sebastian',
                            badgeText: 'Foods (2/3)',
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'chili_sauce.png',
                            label: 'Acı Sos',
                            badgeText: 'Pranks (3/3)',
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'customer_happy.png',
                            label: '5-Star Guest',
                            badgeText: 'Customers (1/3)',
                            imageSize: 92,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    RoundTwoVectorPreviewCard(),
                    SizedBox(height: 14),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ROUND 2 · LIVE GENERATIVE EXTENSION',
                        badgeIcon: Icons.auto_awesome,
                        title: 'Why Hybrid Assets Win in a 300-Seat Hall',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'Part 1 (20 Studio PNGs in GitHub): 12 Round-1 base PNGs + 2 Round-2 custom PNGs + 6 3D characters in flutter_client/assets/base/ alongside 5 Lottie JSONs and 10 Web Audio API + WAV cafe sounds.',
                          'Part 2 (On-the-Fly AI Codegen): Builders prompt AI Studio or Antigravity to generate custom signature dishes as CustomVectorIngredientGraphic code.',
                          'Self-Contained Cloud Run Build: All assets live inside flutter_client/ so gcloud run deploy --source . bundles everything cleanly.',
                        ],
                        footerText: 'Evidence: flutter_client/lib/data/custom_svg_items.dart',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
