import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class HybridAssetPipelineSlide extends FlutterDeckSlideWidget {
  const HybridAssetPipelineSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/hybrid-asset-pipeline',
            title: isTurkishDeck
                ? '12. Hibrit görseller: 14 hazır PNG + anında üretilen AI vektörleri'
                : '12. Hybrid Asset Pipeline: 14 Studio PNGs + On-the-Fly AI SVGs',
            speakerNotes: isTurkishDeck
                ? "BEAT  [22:30 - 25:00] Hibrit görseller: 14 hazır stüdyo PNG'si + turda üretilen AI vektörleri.\n"
                    'SAY   "Atölyede en çok vakit görsel aramaya gider. Biz bunu ikiye böldük. Hazır kısım: birinci tur için 12 görsel, yani 3 içecek, 3 tatlı, 3 şaka malzemesi ve 3 müşteri yüzü. İkinci tur için 2 özel görsel daha. Toplam 14 PNG, hepsi repoda hazır. Üretilen kısım: ikinci turda herkes kendi imza tatlısını ve şaka malzemesini AI Studio ya da Antigravity\'ye çizdiriyor. Resim dosyası olarak değil, CustomPaint koduyla. Yüklenecek dosya olmayınca yükleme hatası da olmuyor."\n'
                    "HOLD  Solda hazır PNG'ler, sağda kodla çizilen iki örnek. [Olgu (flutter_client/assets/): assets/base/ içinde 14 PNG (12 + 2), assets/animations/ içinde 5 Lottie JSON, assets/audio/ içinde 10 WAV + Web Audio API].\n"
                    'NEXT  "Şimdi bilgisayarları ve telefonları açıyoruz: 3 turluk canlı yapım başlıyor!"'
                : 'BEAT  [22:30 - 25:00] Hibrit Görsel Boru Hattı: 14 Hazır Stüdyo PNG + Yolda Üretilen AI Vektörleri.\n'
                    'SAY   "Bir oyun atölyesinde en çok vakit kaybettiren şey görsel bulmak ve yüklemektir. Biz bunu hibrit bir boru hattıyla çözdük: 3 içecek, 3 tatlı, 3 şaka malzemesi ve 3 müşteri tepkisinden oluşan toplam 12 adet yüksek çözünürlüklü 1. Tur PNG görselini ve 2 adet 2. Tur özel PNG görselini doğrudan GitHub repomuzun içinde hazır veriyoruz. Ardından 2. Turda herkes kendi özel imza tatlısını ve kendi şaka malzemesini Google AI Studio veya Antigravity ile anında CustomPaint vektör kodu olarak üretiyor. Sıfır dosya yükleme hatası, anında görsel sonuç!"\n'
                    'HOLD  Soldaki hazır PNG vitrinini ve sağdaki yolda üretilen CustomPaint vektör akışını göster. [Fact (flutter_client/assets/): 14 PNGs in assets/base/ (12 Round-1 + 2 Round-2), 5 Lottie JSONs in assets/animations/, 10 audio WAVs + Web Audio API synth in assets/audio/].\n'
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
          eyebrow:
              isTurkishDeck ? 'HİBRİT GÖRSELLER (YÜKLEME HATASI YOK)' : 'HYBRID ASSET PIPELINE (ZERO UPLOAD FAILURES)',
          title: isTurkishDeck
              ? "14 hazır stüdyo PNG'si + anında üretilen AI vektör tatlılar"
              : '14 Pre-Generated Studio PNGs + On-the-Fly AI Vector Dishes',
          act: StoryAct.underTheHood,
          subtitle: isTurkishDeck
              ? "GitHub'dan gelen hazır görseller ile 2. turdaki canlı üretimi birleştiriyoruz"
              : 'Combining instant visual polish from GitHub with live generative creativity in Round 2',
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
                            badgeText: isTurkishDeck ? 'İçecek (1/3)' : 'Drinks (1/3)',
                            badgeColor: DeckColors.halftoneBlue,
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'menengic_coffee.png',
                            label: 'Menengiç',
                            badgeText: isTurkishDeck ? 'İçecek (3/3)' : 'Drinks (3/3)',
                            badgeColor: DeckColors.halftoneBlue,
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'croissant.png',
                            label: isTurkishDeck ? 'Kruvasan' : 'Croissant',
                            badgeText: isTurkishDeck ? 'Yiyecek (1/3)' : 'Foods (1/3)',
                            badgeColor: DeckColors.halftoneBlue,
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
                            badgeText: isTurkishDeck ? 'Yiyecek (2/3)' : 'Foods (2/3)',
                            badgeColor: DeckColors.halftoneBlue,
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'chili_sauce.png',
                            label: 'Acı Sos',
                            badgeText: isTurkishDeck ? 'Şaka (3/3)' : 'Pranks (3/3)',
                            badgeColor: DeckColors.halftoneBlue,
                            imageSize: 92,
                          ),
                        ),
                        SizedBox(width: _gridGap),
                        Expanded(
                          child: CafeAssetThumb(
                            assetFileName: 'customer_happy.png',
                            label: isTurkishDeck ? '5 yıldızlı müşteri' : '5-Star Guest',
                            badgeText: isTurkishDeck ? 'Müşteri (1/3)' : 'Customers (1/3)',
                            badgeColor: DeckColors.halftoneBlue,
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
                        badge: isTurkishDeck ? '2. TUR · CANLI ÜRETİM' : 'ROUND 2 · LIVE GENERATIVE EXTENSION',
                        badgeIcon: Icons.auto_awesome,
                        title: isTurkishDeck
                            ? '300 kişilik salonda hibrit görsel neden kazanır?'
                            : 'Why Hybrid Assets Win in a 300-Seat Hall',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            "1. kısım (GitHub'da 14 PNG): flutter_client/assets/base/ içinde 12 + 2 PNG, yanında 5 Lottie JSON ve 10 WAV + Web Audio API kafe sesi."
                          else
                            'Part 1 (14 Studio PNGs in GitHub): 12 Round-1 base PNGs + 2 Round-2 custom PNGs in flutter_client/assets/base/ alongside 5 Lottie JSONs and 10 Web Audio API + WAV cafe sounds.',
                          if (isTurkishDeck)
                            "2. kısım (anında AI kodu): herkes AI Studio ya da Antigravity'ye kendi imza tatlısını CustomVectorIngredientGraphic koduyla çizdirir."
                          else
                            'Part 2 (On-the-Fly AI Codegen): Builders prompt AI Studio or Antigravity to generate custom signature dishes as CustomVectorIngredientGraphic code.',
                          if (isTurkishDeck)
                            'Her şey pakette: bütün görseller flutter_client/ içinde, gcloud run deploy --source . hepsini birlikte yayınlar.'
                          else
                            'Self-Contained Cloud Run Build: All assets live inside flutter_client/ so gcloud run deploy --source . bundles everything cleanly.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kanıt: flutter_client/lib/data/custom_svg_items.dart'
                            : 'Evidence: flutter_client/lib/data/custom_svg_items.dart',
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
