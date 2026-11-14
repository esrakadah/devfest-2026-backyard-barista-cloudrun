import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class MeetAntigravitySlide extends FlutterDeckSlideWidget {
  const MeetAntigravitySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/meet-antigravity',
            title: isTurkishDeck ? '5. Google Antigravity ile tanışın' : '5. Meet Google Antigravity',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [07:30 - 09:30] Google Antigravity: tek istekle birden çok dosyayı değiştiren, AI ajanlı kod editörü.\n'
                    'SAY   "Tarayıcıda prototip yapmak güzel. Peki gerçek bir Flutter projesinde üç dosyayı aynı anda nasıl güncelleriz? Burada Google Antigravity devreye giriyor: içinde AI ajanı olan bir kod editörü. Cmd+I ya da Agent Mode ile \'kafeye yeni bir imza tatlısı ekle\' diyoruz. Dışarıdan resim aramıyor. Çizim kodunu, yani CustomVectorIngredientGraphic\'i kendisi yazıyor ve ingredients_catalog.dart içindeki roundTwoCustomItems listesine bağlıyor."\n'
                    'HOLD  Sağdaki kodda roundTwoCustomItems listesini (custom_katmer_roll ve custom_isot_pepper) göster. İsot satırında bir an dur, salon gülümser.\n'
                    'NEXT  "Bir mimari kararımız var: sahne için oyun motoru, tezgah için Flutter widget\'ları. Neden?"'
                : 'BEAT  [07:30 - 09:30] Google Antigravity ile çoklu dosya düzenleme ve yerinde vektör/widget üretimi.\n'
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
    // ...''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'AI AJANLI KOD EDİTÖRÜ (ai/ai-dev-tools/antigravity)'
              : 'AI-FIRST AGENTIC IDE (ai/ai-dev-tools/antigravity)',
          title: isTurkishDeck
              ? 'Google Antigravity: tek istekle birden çok dosya'
              : 'Meet Google Antigravity: Multi-File Flutter Velocity',
          act: StoryAct.tools,
          subtitle: isTurkishDeck
              ? "Resim yüklemeden vektör tatlı üretir, Gemini JSON'unu dosyalar arasında bağlar"
              : 'Generating zero-upload vector dishes and wiring Gemini JSON across files',
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: DeckFeatureCard(
                  badge: isTurkishDeck ? "YOL B'NİN GÜCÜ" : 'LANE B SUPERPOWER',
                  title: isTurkishDeck
                      ? "2. turda Antigravity'yi nasıl kullanıyoruz"
                      : 'How We Use Antigravity in Round 2',
                  accentColor: DeckColors.googleYellow,
                  bullets: [
                    if (isTurkishDeck)
                      'Tab ve Cmd+I: cafe_counter_screen.dart içinde satır tamamlama ve hızlı widget düzenleme.'
                    else
                      'Tab & Cmd+I: Inline completions and instant widget refactoring inside cafe_counter_screen.dart.',
                    if (isTurkishDeck)
                      'Agent Mode: ingredients_catalog.dart, custom_svg_items.dart ve cafe_judge_service.dart tek seferde güncellenir.'
                    else
                      'Agent Mode: Updates ingredients_catalog.dart, custom_svg_items.dart, and cafe_judge_service.dart in one pass.',
                    if (isTurkishDeck)
                      "Resim yükleme derdi yok: çizim CustomPainter / SVG kodu olarak Dart'ta üretilir, 300 laptopta aynı çalışır."
                    else
                      'Zero Asset-Hosting Failures: Generates CustomPainter / SVG code directly in Dart so 300 laptops never fail on image uploads.',
                    if (isTurkishDeck)
                      "Her platformda: Windows 10/11 (x64 ve ARM64), macOS ve Linux'ta çalışır."
                    else
                      'Cross-Platform Ready: Runs on Windows 10/11 (x64 & ARM64), macOS, and Linux.',
                  ],
                  footerText: isTurkishDeck
                      ? "İpucu: Kurulu değilse beklemeyin, salon Wi-Fi'ında Yol A ile devam edin!"
                      : 'Tip: Pre-install before the workshop; use Lane A on conference Wi-Fi!',
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
