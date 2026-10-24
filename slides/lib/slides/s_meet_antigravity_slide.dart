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
                'SAY   "Tarayıcıda prototiplemek harika; peki gerçek bir Flutter projesinde aynı anda hem veri kataloğunu, hem özel çizim sınıfını, hem de JSON şemasını nasıl güncelliyoruz? İşte burada Google Antigravity devreye giriyor. Antigravity içinde Cmd+I veya Agent Mode kullanarak kafemize yeni bir imza tatlısı ekle dediğimizde, dışarıdan kırık bir resim dosyası aramak yerine doğrudan CustomPainter veya inline SVG kodunu üretip ingredients_catalog.dart içine bağlıyor."\n'
                'HOLD  Sağ taraftaki CustomCupcakePainting ve ingredients_catalog.dart kod kutusunu işaret et.\n'
                'NEXT  "Burada çok önemli bir mimari kararımız var: neden bu oyunda Flame oyun motoru yerine saf Flutter widget\'ları kullandık?"',
          ),
        );

  static const double _columnGap = 28;

  static const String _antigravitySnippet = '''
// Generated in seconds with Google Antigravity Agent Mode:
// flutter_client/lib/data/ingredients_catalog.dart
CafeIngredient(
  id: 'custom_cupcake',
  titleEn: 'AI Studio Berry Cupcake',
  titleTr: 'AI Studio Orman Meyveli Cupcake',
  category: IngredientCategory.food,
  assetPath: null, // Rendered via on-the-fly CustomPainter / SVG!
  customGeneratedKind: 'cupcake',
  isSweet: true,
),
CafeIngredient(
  id: 'custom_garlic_prank',
  titleEn: 'Whipped Garlic Cream (Prank!)',
  titleTr: 'Sarımsaklı Krem Şanti (Şaka!)',
  category: IngredientCategory.toppingOrPrank,
  customGeneratedKind: 'garlic_sauce',
  prankKind: 'salt', // Triggers 1-star Gemini JSON roast!
),''';

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
