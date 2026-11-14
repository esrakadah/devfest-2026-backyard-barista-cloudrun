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
                ? 'BEAT  [14:00 - 16:30] Gerçek Rakamlar #2: token hesabı ve 2026 model kısıtlaması tuzağı.\n'
                    'SAY   "İkinci rakam cüzdanımızla ilgili. Token, modelin okuduğu ve yazdığı metin parçası; faturayı o belirliyor. Biz her tıklamada modele gitmiyoruz. Sadece tepsi hazır olup Servis Et\'e basılınca tek bir çağrı yapıyoruz. Bu çağrı yaklaşık 150 token okuyor, 120 token yazıyor: sipariş başına yaklaşık 270 token. Bir de tuzak var: yeni açılan Google Cloud projelerinde eski gemini-2.5-flash modelleri kısıtlı. Eski model adını yazarsanız yeni hesap hata alır. O yüzden kodda varsayılan model gemini-3.5-flash-lite."\n'
                    "HOLD  Sağdaki kodda defaultValue: 'gemini-3.5-flash-lite' satırını göster. 270 token [YAKLAŞIK HESAP] (~150 + ~120), ölçüm diye söyleme. [Olgu (cafe_judge_service.dart:20-25 ve ai.google.dev/gemini-api/docs/models): atölyede kurulum gerekmesin diye package:http ile REST generateContent; production'da firebase_ai + App Check].\n"
                    'NEWS  [Bu hafta, yalnız sözlü] "Bu hafta Gemini 4 Hydrogen genel kullanıma açıldı: 1 milyon token bağlam, 1 milyon girdi tokenı 1,50 dolar, 1 milyon çıktı tokenı 7,50 dolar. Biz atölyede gemini-3.5-flash-lite\'ta kalıyoruz. Yeni model çıktı diye canlı sistemi aynı gün değiştirmiyoruz, önce rakamları ölçüyoruz." [Olgu (aistudio.google.com/docs/changelog, 12 Kasım 2026 ve aistudio.google.com/docs/pricing): gemini-4-hydrogen genel kullanımda, 1M bağlam, 1M token başına \$1.50 girdi / \$7.50 çıktı].\n'
                    'NEXT  "Peki 300 kişi aynı anda bu butona basarsa ne olur? Üçüncü rakama geçelim."'
                : 'BEAT  [14:00 - 16:30] Gerçek Rakamlar #2: Token matematiği ve 2026 model kısıtlaması tuzağı.\n'
                    'SAY   "İkinci gerçek rakamımız doğrudan cüzdanımızı ve yeni hesapları ilgilendiriyor. Bizim oyunumuzda her malzeme tıklamasında yapay zekaya gitmiyoruz; yalnızca tepsi hazır olup Servis Et butonuna basıldığında tek bir JSON çağrısı yapıyoruz. Bu çağrı yaklaşık 150 girdi tokenı ve 120 çıktı tokenı tüketiyor, yani toplamda sipariş başına 270 token! Ve çok kritik bir 2026 gerçeği: yeni açılan Google Cloud projelerinde eski gemini-2.5-flash modelleri kısıtlandı. Eğer atölyede eski model adını yazarsanız yeni hesaplar anında hata alır. Bu yüzden kodumuzda varsayılan model doğrudan gemini-3.5-flash-lite olarak sabitlendi."\n'
                    "HOLD  Sağdaki kod kutusunda defaultValue: 'gemini-3.5-flash-lite' satırını işaret et. [Fact (cafe_judge_service.dart:20-25 & ai.google.dev/gemini-api/docs/models): REST generateContent via package:http for zero-setup workshop; firebase_ai + App Check in production].\n"
                    'NEWS  [Bu hafta, yalnız sözlü] "Bu hafta Gemini 4 Hydrogen genel kullanıma açıldı: 1 milyon token bağlam, 1 milyon girdi tokenı 1,50 dolar, 1 milyon çıktı tokenı 7,50 dolar. Biz atölyede gemini-3.5-flash-lite\'ta kalıyoruz. Yeni model çıktı diye canlı sistemi aynı gün değiştirmiyoruz, önce rakamları ölçüyoruz." [Fact (aistudio.google.com/docs/changelog 12 Nov 2026 & aistudio.google.com/docs/pricing): gemini-4-hydrogen GA, 1M context, \$1.50 in / \$7.50 out per 1M tokens].\n'
                    'NEXT  "Peki aynı salonda 300 kişi aynı anda bu butona basarsa ne olur? Üçüncü gerçek rakama geçelim."',
          ),
        );

  static const double _columnGap = 24;

  static const String _modelConstantSnippet = '''
// flutter_client/lib/services/cafe_judge_service.dart
this.geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY'),
this.geminiModel = const String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.5-flash-lite',
),

// Per completed tray order (~270 tokens total):
// - Input promptText: ~150 tokens (active city + tray ingredients + prank flags)
// - Output CafeReview JSON: ~120 tokens (6 strictly typed schema properties)
// - 1,000 cafe orders = ~150K input tokens + ~120K output tokens''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'GERÇEK RAKAMLAR #2 (TOKEN HESABI VE 2026 MODEL TUZAĞI)'
              : 'GERÇEK RAKAMLAR #2 (TOKEN MATH & 2026 MODEL GUARD)',
          title: isTurkishDeck
              ? 'Gerçek rakamlar #2: sipariş başına ~270 token ve 2.5 tuzağı'
              : 'Real Numbers #2: ~270 Tokens per Order & The 2.5 Trap',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? 'Sipariş başına tek JSON çağrısı maliyeti sıfıra yakın tutar, eski model engeline de takılmaz'
              : 'Why 1 structured JSON call per order keeps costs near zero and avoids legacy model blocks',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '0 token' : '0 Tokens',
                      label: isTurkishDeck ? 'TEPSİYİ HAZIRLARKEN (YEREL)' : 'Tray Tap Assembly (60fps Local)',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '~150 girdi + ~120 çıktı' : '~150 In + ~120 Out',
                      label: isTurkishDeck ? 'SERVİS BAŞINA ~270 TOKEN (YAKLAŞIK)' : '270 Tokens / Serve Call',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: 'gemini-3.5-flash-lite',
                      label: isTurkishDeck ? 'VARSAYILAN GÜVENLİ MODEL (2026)' : 'Default Safe 2026 Model',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '2.5 kısıtlı' : '2.5 Blocked',
                      label: isTurkishDeck ? 'YENİ GCP PROJELERİ TUZAĞI' : 'New GCP Projects Trap',
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
                        badge: isTurkishDeck ? 'DOĞRULANDI (2026)' : 'VERIFIED 2026 FACTS',
                        badgeIcon: Icons.verified,
                        title: isTurkishDeck ? 'Token tüketimi ve model seçimi' : 'Token Footprint & Model Selection',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            "Tepsiyi hazırlarken 0 token: Espresso, Süt, Baklava ya da Tuz'a dokunmak tamamen Flutter'da, yerelde çalışır."
                          else
                            '0 Tokens During Tray Assembly: Tapping Espresso, Milk, Baklava, or Salt runs 100% locally in Flutter at 60fps.',
                          if (isTurkishDeck)
                            "Servis Et'te 1 çağrı: ~150 girdi + ~120 JSON çıktı tokenı (sipariş başına ~270 token)."
                          else
                            '1 Structured Call on Serve: ~150 input tokens + ~120 JSON output tokens (~270 tokens per completed order).',
                          if (isTurkishDeck)
                            'Eski model kısıtı (Ekim 2026): yeni Google Cloud projeleri gemini-2.5-flash ve gemini-2.5-flash-lite kullanamaz.'
                          else
                            'Legacy Model Restriction (Oct 2026): New Google Cloud projects are restricted from gemini-2.5-flash and gemini-2.5-flash-lite.',
                          if (isTurkishDeck)
                            "Kullanın: gemini-3.5-flash-lite (varsayılan) ya da gemini-3.8-flash; production'da firebase_ai (^5.1.0) + App Check."
                          else
                            'Always Use: gemini-3.5-flash-lite (default) or gemini-3.8-flash; pair with firebase_ai (^5.1.0) + App Check in production.',
                        ],
                        footerText: isTurkishDeck
                            ? "Kaynak: ai.google.dev/gemini-api/docs/models (24 Ekim 2026'da doğrulandı)"
                            : 'Source: ai.google.dev/gemini-api/docs/models (Verified 24 Oct 2026)',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/services/cafe_judge_service.dart',
                        code: _modelConstantSnippet,
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
