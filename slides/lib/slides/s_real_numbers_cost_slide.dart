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
            title: '8. Gerçek Rakamlar #2: Token Math & Model Trap',
            speakerNotes:
                'BEAT  [14:00 - 16:30] Gerçek Rakamlar #2: Token matematiği ve 2026 model kısıtlaması tuzağı.\n'
                'SAY   "İkinci gerçek rakamımız doğrudan cüzdanımızı ve yeni hesapları ilgilendiriyor. Bizim oyunumuzda her malzeme tıklamasında yapay zekaya gitmiyoruz; yalnızca tepsi hazır olup Servis Et butonuna basıldığında tek bir JSON çağrısı yapıyoruz. Bu çağrı yaklaşık 150 girdi tokenı ve 120 çıktı tokenı tüketiyor, yani toplamda sipariş başına 270 token! Ve çok kritik bir 2026 gerçeği: yeni açılan Google Cloud projelerinde eski gemini-2.5-flash modelleri kısıtlandı. Eğer atölyede eski model adını yazarsanız yeni hesaplar anında hata alır. Bu yüzden kodumuzda varsayılan model doğrudan gemini-3.5-flash-lite olarak sabitlendi."\n'
                "HOLD  Sağdaki kod kutusunda defaultValue: 'gemini-3.5-flash-lite' satırını işaret et. [Fact (cafe_judge_service.dart:20-25 & ai.google.dev/gemini-api/docs/models): REST generateContent via package:http for zero-setup workshop; firebase_ai + App Check in production].\n"
                'NEXT  "Peki aynı salonda 300 kişi aynı anda bu butona basarsa ne olur? Üçüncü gerçek rakama geçelim."',
          ),
        );

  static const double _columnGap = 24;

  static const String _modelConstantSnippet = '''
// flutter_client/lib/services/cafe_judge_service.dart (Lines 20-25)
this.geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY'),
this.geminiModel = const String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-3.5-flash-lite', // Safe for all new 2026 accounts!
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
          eyebrow: 'GERÇEK RAKAMLAR #2 (TOKEN MATH & 2026 MODEL GUARD)',
          title: 'Real Numbers #2: ~270 Tokens per Order & The 2.5 Trap',
          act: StoryAct.realNumbers,
          subtitle: 'Why 1 structured JSON call per order keeps costs near zero and avoids legacy model blocks',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: '0 Tokens',
                      label: 'Tray Tap Assembly (60fps Local)',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: '~150 In + ~120 Out',
                      label: '270 Tokens / Serve Call',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: 'gemini-3.5-flash-lite',
                      label: 'Default Safe 2026 Model',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: '2.5 Blocked',
                      label: 'New GCP Projects Trap',
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
                        badge: 'VERIFIED 2026 FACTS',
                        badgeIcon: Icons.verified,
                        title: 'Token Footprint & Model Selection',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          '0 Tokens During Tray Assembly: Tapping Espresso, Milk, Baklava, or Salt runs 100% locally in Flutter at 60fps.',
                          '1 Structured Call on Serve: ~150 input tokens + ~120 JSON output tokens (~270 tokens per completed order).',
                          'Legacy Model Restriction (Oct 2026): New Google Cloud projects are restricted from gemini-2.5-flash and gemini-2.5-flash-lite.',
                          'Always Use: gemini-3.5-flash-lite (default) or gemini-3.8-flash; pair with firebase_ai (^5.1.0) + App Check in production.',
                        ],
                        footerText: 'Source: ai.google.dev/gemini-api/docs/models (Verified 24 Oct 2026)',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/services/cafe_judge_service.dart',
                        code: _modelConstantSnippet,
                        accentColor: DeckColors.googleGreen,
                        badgeLabel: '270 TOKENS / ORDER',
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
