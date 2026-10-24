import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class RoomQuotaTrapSlide extends FlutterDeckSlideWidget {
  const RoomQuotaTrapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/room-quota-trap',
            title: '8. Gercek Rakamlar #3: The 300-Person Quota Trap',
            speakerNotes:
                'BEAT  [16:30 - 18:30] Gerçek Rakamlar #3: 300 kişilik salonda HTTP 429 RESOURCE_EXHAUSTED tuzağı ve çözümümüz.\n'
                'SAY   "Bir konferans atölyesini batıran en klasik hata nedir? Konuşmacının kendi API anahtarını 300 kişiyle paylaşması! ✅ fact (Oct 2026, ai.google.dev/gemini-api/docs/rate-limits): Ücretsiz katman hız sınırları API anahtarı başına değil, Google Cloud projesi başına uygulanır ve dakikada 5 ila 15 istek (5-15 RPM) seviyesindedir. Yani 300 kişi tek bir projeye yüklenirse 3 saniye içinde HTTP 429 RESOURCE_EXHAUSTED hatası alırsınız. Ayrıca ✅ fact: GEAR / Qwiklabs sanal laboratuvarları etkinlik başına 100 katılımcı ile sınırlıdır. Biz bu iki engeli üç katmanlı savunmayla aşıyoruz: herkes kendi ücretsiz AI Studio anahtarını kullanıyor, sipariş başına sadece 1 JSON isteği atıyoruz ve ağ kesilirse uygulama otomatik olarak çevrimdışı şaka yanıtlarına düşüyor."\n'
                'HOLD  Sol karttaki kırmızı "3 Saniyede 429" uyarısını ve sağ karttaki 3 katmanlı çözümü göster.\n'
                'NEXT  "Peki aynı kod tabanını Berlin, Gaziantep, Adana ve İstanbul için kodu yeniden derlemeden nasıl özelleştiriyoruz?"',
          ),
        );

  static const double _columnGap = 28;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 8 · GERCEK RAKAMLAR #3 (QUOTAS & RATE LIMITS)',
          title: 'Real Numbers #3: Surviving a 300-Person Room Without HTTP 429',
          subtitle: 'Why shared keys and 100-seat lab VMs fail at scale, and how our architecture stays green',
          accentColor: DeckColors.googleRed,
          child: Row(
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'THE STAGE TRAP · HTTP 429 IN 3 SECONDS',
                  title: 'What Breaks in Big Hands-On Workshops',
                  accentColor: DeckColors.googleRed,
                  bullets: [
                    'Per-Project Quota Enforcement (✅ Fact): Gemini API free-tier rate limits apply per Google Cloud project (typically 5 to 15 RPM, ~250K TPM), not per API key.',
                    'Shared Key = Instant 429: 300 builders hitting 1 project exhausts the 15 RPM bucket in under 3 seconds.',
                    'GEAR Lab VM Cap (<100 Seats): Hosted Qwiklabs sandboxes throttle above 100 concurrent starts.',
                    'Shared Venue NAT IP: Creating 300 keys simultaneously on one Wi-Fi router triggers CAPTCHA throttles.',
                  ],
                  footerText: 'Source: ai.google.dev/gemini-api/docs/rate-limits',
                ),
              ),
              SizedBox(width: _columnGap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'OUR 3-LAYER DEFENSE · 100% SURVIVABLE',
                  title: 'How Backyard Barista Stays Up for 300 Builders',
                  accentColor: DeckColors.googleGreen,
                  bullets: [
                    '1. One Personal AI Studio Project per Builder: 300 isolated RPM buckets instead of 1 shared bottleneck.',
                    '2. Single-Shot Structured JSON: Only 1 generateContent call when clicking "Serve Order!" (1-2 RPM per player).',
                    '3. AI Studio Starter Tier Cloud Run: Deploys up to 2 apps per account with zero billing card or VM lab cap.',
                    '4. Deterministic Offline Net: Automatic fallback to mock_responses.json when Wi-Fi or quota hiccups.',
                  ],
                  footerText: 'Result: Every builder finishes & deploys regardless of venue Wi-Fi.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
