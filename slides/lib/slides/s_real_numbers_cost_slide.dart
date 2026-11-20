import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class RealNumbersCostSlide extends FlutterDeckSlideWidget {
  const RealNumbersCostSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/real-numbers-cost',
            title: isTurkishDeck
                ? '8. Gerçek rakamlar #2: token hesabı ve model tuzağı'
                : '8. Gerçek Rakamlar #2: Token Math & Model Trap',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [08:30 - 10:00] Gerçek rakamlar #2: token hesabı ve eski model tuzağı.\n'
                    'SAY   "Sıra maliyette ve model seçiminde. Token, modelin okuduğu ve yazdığı kelime parçası; fatura token sayısına göre kesiliyor. Tepsiyi dizerken, yani kahveye, baklavaya ya da tuza dokunurken modele hiç gitmiyoruz: sıfır token. Yalnızca Servis Et\'e basıldığında tek bir JSON çağrısı gidiyor. Yaklaşık 150 girdi, 120 çıktı, toplam 270 token. Liste fiyatıyla 1.000 sipariş 5 sentin altında, yaklaşık 4,7 sent. Bir de Ekim 2026\'dan kalan bir tuzak var: yeni açılan Google Cloud projelerinde eski gemini-2.5-flash modelleri kapalı. Eski yazılardan model adı kopyalarsanız yeni proje anında hata verir. Biz varsayılanı gemini-3.5-flash-lite olarak sabitledik."\n'
                    "HOLD  Sağdaki kodda defaultValue: 'gemini-3.5-flash-lite' satırını göster. 270 token ve 1.000 sipariş = 0,0468 dolar [YAKLAŞIK HESAP].\n"
                    'NEXT  "Peki bu 850 kişilik salonda yüzlerce kişi aynı anda Servis Et\'e basarsa ne olur?"'
                : 'BEAT  [14:00 - 16:30] Gerçek Rakamlar #2: Token matematiği ve 2026 model kısıtlaması tuzağı.\n'
                    'SAY   "İkinci gerçek rakamımız doğrudan cüzdanımızı ve yeni hesapları ilgilendiriyor. Bizim oyunumuzda her malzeme tıklamasında yapay zekaya gitmiyoruz; yalnızca tepsi hazır olup Servis Et butonuna basıldığında tek bir JSON çağrısı yapıyoruz. Bu çağrı yaklaşık 150 girdi token\'ı ve 120 çıktı token\'ı tüketiyor, yani toplamda sipariş başına 270 token! Ve çok kritik bir 2026 gerçeği: yeni açılan Google Cloud projelerinde eski gemini-2.5-flash modelleri kısıtlandı. Eğer atölyede eski model adını yazarsanız yeni hesaplar anında hata alır. Bu yüzden kodumuzda varsayılan model doğrudan gemini-3.5-flash-lite olarak sabitlendi."\n'
                    "HOLD  Sağdaki kod kutusunda defaultValue: 'gemini-3.5-flash-lite' satırını işaret et. [Fact (cafe_judge_service.dart:20-25 & ai.google.dev/gemini-api/docs/models): REST generateContent via package:http for zero-setup workshop; firebase_ai + App Check in production].\n"
                    'NEWS  [Bu hafta, yalnız sözlü] "Bu hafta Gemini 4 Hydrogen genel kullanıma açıldı: 1 milyon token bağlam, 1 milyon girdi token\'ı 1,50 dolar, 1 milyon çıktı token\'ı 7,50 dolar. Biz atölyede gemini-3.5-flash-lite\'ta kalıyoruz. Yeni model çıktı diye canlı sistemi aynı gün değiştirmiyoruz, önce rakamları ölçüyoruz." [Fact (aistudio.google.com/docs/changelog 12 Nov 2026 & aistudio.google.com/docs/pricing): gemini-4-hydrogen GA, 1M context, \$1.50 in / \$7.50 out per 1M tokens].\n'
                    'NEXT  "Peki aynı salonda 300 kişi aynı anda bu butona basarsa ne olur? Üçüncü gerçek rakama geçelim."',
          ),
        );

  static const double _columnGap = 24;

  static const double _talkCodeSize = 24;

  /// The model default and the token sum only: what the room needs to read.
  static const String _talkSnippet = '''
// cafe_judge_service.dart (sadeleştirildi)
this.geminiModel = const String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.5-flash-lite',
),

// 1 sipariş     = ~150 girdi + ~120 çıktı token
// 1.000 sipariş = ~270 bin token, 5 sentten az''';

  static const String _modelConstantSnippet = '''
// flutter_client/lib/services/cafe_judge_service.dart
this.geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY'),
this.geminiModel = const String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.5-flash-lite',
),

// ${isTurkishDeck ? 'Tamamlanan her sipariş (toplam ~270 token):' : 'Per completed tray order (~270 tokens total):'}
// ${isTurkishDeck ? '- Girdi promptText: ~150 token (aktif şehir + tepsi + şaka bayrakları)' : '- Input promptText: ~150 tokens (active city + tray ingredients + prank flags)'}
// ${isTurkishDeck ? '- Çıktı CafeReview JSON: ~120 token (6 alanlı şema)' : '- Output CafeReview JSON: ~120 tokens (6 strictly typed schema properties)'}
// ${isTurkishDeck ? '- 1.000 sipariş = ~150 bin girdi + ~120 bin çıktı token' : '- 1,000 cafe orders = ~150K input tokens + ~120K output tokens'}''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'GERÇEK RAKAMLAR 2 · MALİYET'
              : 'GERÇEK RAKAMLAR #2 (TOKEN MATH & 2026 MODEL GUARD)',
          title: isTurkishDeck
              ? '1.000 sipariş 5 sentten ucuz'
              : 'Real Numbers #2: ~270 Tokens per Order & The 2.5 Trap',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? 'Token, modelin okuduğu ve yazdığı kelime parçasıdır; fatura token sayısına göre kesilir'
              : 'Why 1 structured JSON call per order keeps costs near zero and avoids legacy model blocks',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '0 token' : '0 Tokens',
                      label: isTurkishDeck ? 'TEPSİYİ DİZERKEN' : 'Tray Tap Assembly (60fps Local)',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '~270 token' : '~150 In + ~120 Out',
                      label: isTurkishDeck ? 'SERVİS BAŞINA (~150 GİRDİ + ~120 ÇIKTI)' : '270 Tokens / Serve Call',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: 'gemini-3.5-flash-lite',
                      label: isTurkishDeck ? 'KULLANDIĞIMIZ MODEL' : 'Default Safe 2026 Model',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '2.5 kısıtlı' : '2.5 Blocked',
                      label: isTurkishDeck ? 'YENİ PROJELERDE ESKİ MODEL' : 'New GCP Projects Trap',
                      accentColor: DeckColors.googleRed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'NEDEN UCUZ?' : 'VERIFIED 2026 FACTS',
                        badgeIcon: Icons.verified,
                        title: isTurkishDeck ? 'Modele sadece gerektiğinde gidiyoruz' : 'Token Footprint & Model Selection',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'Tepsiyi dizerken modele gitmiyoruz: ücretsiz.'
                          else
                            '0 Tokens During Tray Assembly: Tapping Espresso, Milk, Baklava, or Salt runs 100% locally in Flutter at 60fps.',
                          if (isTurkishDeck)
                            "Sadece Servis Et'e basınca tek çağrı gider."
                          else
                            '1 Structured Call on Serve: ~150 input tokens + ~120 JSON output tokens (~270 tokens per completed order).',
                          if (isTurkishDeck)
                            'Dikkat: eski yazılardaki model adları yeni projede hata verir.'
                          else
                            'Legacy Model Restriction (Oct 2026): New Google Cloud projects are restricted from gemini-2.5-flash and gemini-2.5-flash-lite.',
                          if (!isTurkishDeck)
                            'Always Use: gemini-3.5-flash-lite (default) or gemini-3.8-flash; pair with firebase_ai (^5.1.0) + App Check in production.',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: yeni GCP projelerinde gemini-2.5-flash kapalı · ai.google.dev/gemini-api/docs/models'
                            : 'Source: ai.google.dev/gemini-api/docs/models (Verified 24 Oct 2026)',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/services/cafe_judge_service.dart',
                        code: isTurkishDeck ? _talkSnippet : _modelConstantSnippet,
                        talkFontSize: _talkCodeSize,
                        accentColor: DeckColors.googleGreen,
                        badgeLabel: isTurkishDeck ? 'SİPARİŞ BAŞINA YAKLAŞIK 270 TOKEN' : '270 TOKENS / ORDER',
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
