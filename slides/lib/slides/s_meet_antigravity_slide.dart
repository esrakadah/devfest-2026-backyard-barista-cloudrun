import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class MeetAntigravitySlide extends FlutterDeckSlideWidget {
  const MeetAntigravitySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/meet-antigravity',
            title: '4. Meet Google Antigravity',
            speakerNotes:
                'BEAT  [07:30 - 09:30] Google Antigravity ile çoklu dosya düzenleme ve yerinde vektör/widget üretimi.\n'
                'SAY   "Tarayıcıda prototiplemek harika; peki gerçek bir Flutter projesinde aynı anda hem veri kataloğunu, hem özel çizim sınıfını, hem de JSON şemasını nasıl güncelliyoruz? İşte burada Google Antigravity devreye giriyor. Antigravity içinde Cmd+I veya Agent Mode kullanarak kafemize yeni bir imza tatlısı ekle dediğimizde, dışarıdan kırık bir resim dosyası aramak yerine doğrudan CustomVectorIngredientGraphic çizim kodunu üretip ingredients_catalog.dart içindeki roundTwoCustomItems listesine bağlıyor."\n'
                'HOLD  Sağ taraftaki roundTwoCustomItems (custom_katmer_roll ve custom_isot_pepper) ve CustomVectorArtworkKind kod kutusunu işaret et.\n'
                'NEXT  "Burada çok önemli bir mimari kararımız var: neden bu oyunda Flame oyun motoru yerine saf Flutter widget\'ları kullandık?"',
          ),
        );

  static const double _columnGap = 28;

  static const String _antigravitySnippet = '''
// flutter_client/lib/data/ingredients_catalog.dart (Lines 183-208)
static const List<CafeIngredient> roundTwoCustomItems = <CafeIngredient>[
  CafeIngredient(
    id: 'custom_katmer_roll',
    titleEn: 'AI Custom: Katmer Roll',
    titleTr: 'AI Özel: Fıstıklı Katmer Sarma',
    subtitleEn: 'Crispy Phyllo · Kaymak & Pistachio',
    subtitleTr: 'Çıtır Yufka · Kaymak & Boz Fıstık',
    category: IngredientCategory.food,
    isPrankItem: false,
    prankKind: 'none',
    assetPath: 'assets/base/foods/katmer_roll.png',
    customVectorKind: CustomVectorArtworkKind.pistachioKatmerRoll,
  ),
  CafeIngredient(
    id: 'custom_isot_pepper',
    titleEn: 'AI Flakes: İsot Pepper',
    titleTr: 'AI Özel: İsot Biberi',
    subtitleEn: 'Smoky Urfa Chili Flakes',
    subtitleTr: 'İsli Urfa & Antep İsotu',
    category: IngredientCategory.toppingOrPrank,
    isPrankItem: true,
    prankKind: 'chili',
    assetPath: 'assets/base/toppings_pranks/isot_pepper.png',
    customVectorKind: CustomVectorArtworkKind.isotPepperShaker,
  ),
];''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 4 · AI-FIRST AGENTIC IDE (ai/ai-dev-tools/antigravity)',
          title: 'Meet Google Antigravity: Multi-File Flutter Velocity',
          subtitle: 'Generating zero-upload vector dishes and wiring Gemini JSON across files',
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: DeckFeatureCard(
                  badge: 'LANE B SUPERPOWER',
                  title: 'How We Use Antigravity in Round 2',
                  accentColor: DeckColors.googleYellow,
                  bullets: [
                    'Tab & Cmd+I: Inline completions and instant widget refactoring inside cafe_counter_screen.dart.',
                    'Agent Mode: Updates ingredients_catalog.dart, custom_svg_items.dart, and cafe_judge_service.dart in one pass.',
                    'Zero Asset-Hosting Failures: Generates CustomPainter / SVG code directly in Dart so 300 laptops never fail on image uploads.',
                    'Cross-Platform Ready: Runs on Windows 10/11 (x64 & ARM64), macOS, and Linux.',
                  ],
                  footerText: 'Tip: Pre-install before the workshop; use Lane A on conference Wi-Fi!',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                flex: 6,
                child: DeckCodeCard(
                  filePathLabel: 'flutter_client/lib/data/ingredients_catalog.dart',
                  code: _antigravitySnippet,
                  accentColor: DeckColors.googleYellow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
