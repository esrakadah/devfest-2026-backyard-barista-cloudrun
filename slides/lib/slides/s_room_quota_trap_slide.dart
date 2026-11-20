import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class RoomQuotaTrapSlide extends FlutterDeckSlideWidget {
  const RoomQuotaTrapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/room-quota-trap',
            title: isTurkishDeck
                ? '9. Gerçek rakamlar #3: kalabalık salonda kota tuzağı'
                : '9. Gerçek Rakamlar #3: The 300-Person Quota Trap',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [10:00 - 11:30] Gerçek rakamlar #3: kalabalık salonda HTTP 429 tuzağı ve dört önlem.\n'
                    'SAY   "Canlı demoları batıran klasik hata şudur: tek bir ücretsiz API anahtarını bütün salonla paylaşmak. Ücretsiz katmanda hız sınırı anahtar başına değil, Google Cloud projesi başına uygulanıyor: dakikada 5 ile 15 istek. Yüzlerce kişi tek projeye yüklenince birkaç saniyede HTTP 429, yani kota doldu hatası alırsınız. Biz dört önlem aldık. Kendi uygulamasını kuran herkes kendi AI Studio projesini kullanıyor. Sipariş başına tek çağrı gidiyor. Cloud Run\'daki nginx saniyede 10 istek sınırı koyuyor. 429 dönse bile oyun çökmüyor, 250 milisaniyede şehre özel hazır yanıtlara geçiyor. Birazdan demoda bunu sizinle birlikte deneyeceğiz."\n'
                    'HOLD  Önce soldaki kırmızı "birkaç saniyede HTTP 429" kutusunu, sonra sağdaki dört önlemi göster. nginx 10 r/s + burst 20 kod sabiti (nginx/default.conf.template).\n'
                    'NEXT  "Savunma tamam. Aynı oyunu beş şehre, yeniden derlemeden nasıl uyarlıyoruz?"'
                : 'BEAT  [16:30 - 18:30] Gerçek Rakamlar #3: 300 kişilik salonda HTTP 429 RESOURCE_EXHAUSTED tuzağı ve çözümümüz.\n'
                    'SAY   "Bir konferans atölyesini batıran en klasik hata nedir? Konuşmacının kendi API anahtarını 300 kişiyle paylaşması! Ücretsiz katman hız sınırları API anahtarı başına değil, Google Cloud projesi başına uygulanır ve dakikada 5 ila 15 istek seviyesindedir. Yani 300 kişi tek bir projeye yüklenirse 3 saniye içinde HTTP 429 RESOURCE_EXHAUSTED hatası alırsınız. Ayrıca GEAR ve Qwiklabs sanal laboratuvarları etkinlik başına 100 katılımcı ile sınırlıdır. Biz bu iki engeli dört katmanlı savunmayla aşıyoruz: herkes kendi ücretsiz AI Studio anahtarını kullanıyor, sipariş başına sadece 1 JSON isteği atıyoruz, AI Studio Starter Tier ile sanal makine sınırına takılmadan Cloud Run yayını yapıyoruz ve ağ kesilirse uygulama otomatik olarak çevrimdışı şaka yanıtlarına düşüyor."\n'
                    'HOLD  Sol karttaki kırmızı "3 Saniyede 429" uyarısını ve sağ karttaki 4 katmanlı çözümü göster. [Fact (ai.google.dev/gemini-api/docs/rate-limits): Free tier = 5-15 RPM per GCP project; GEAR labs cap at 100 concurrent VMs].\n'
                    'NEXT  "Peki aynı kod tabanını Berlin, Gaziantep, Adana ve İstanbul için kodu yeniden derlemeden nasıl özelleştiriyoruz?"',
          ),
        );

  static const double _columnGap = 24;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'GERÇEK RAKAMLAR #3 (KOTA VE HIZ SINIRLARI)'
              : 'GERÇEK RAKAMLAR #3 (QUOTAS & RATE LIMITS)',
          title: isTurkishDeck
              ? "Gerçek rakamlar #3: salonda HTTP 429'a takılmadan"
              : 'Real Numbers #3: Surviving a 300-Person Room Without HTTP 429',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? 'Ortak anahtar neden yetmez, bizim mimari neden ayakta kalır'
              : 'Why shared keys and 100-seat lab VMs fail at scale, and how our architecture stays green',
          accentColor: DeckColors.googleRed,
          child: Column(
            children: [
              QuotaComparisonDiagramCard(),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck
                            ? 'SAHNE TUZAĞI · BİRKAÇ SANİYEDE HTTP 429'
                            : 'THE STAGE TRAP · HTTP 429 IN 3 SECONDS',
                        badgeIcon: Icons.error_outline,
                        title: isTurkishDeck
                            ? 'Kalabalık salonlarda ne bozulur?'
                            : 'What Breaks in Big Hands-On Workshops',
                        accentColor: DeckColors.googleRed,
                        bullets: [
                          if (isTurkishDeck)
                            'Kota proje başına (olgu): Gemini API ücretsiz katman sınırı API anahtarına değil Google Cloud projesine uygulanır (Ekim 2026: genelde dakikada 5-15 istek).'
                          else
                            'Per-Project Quota Enforcement (Fact): Gemini API free-tier rate limits apply per Google Cloud project (typically 5 to 15 RPM, ~250K TPM), not per API key.',
                          if (isTurkishDeck)
                            'Ortak anahtar = anında 429: 850 kişi tek projeye yüklenince 15 RPM kotası birkaç saniyede biter.'
                          else
                            'Shared Key = Instant 429: 300 builders hitting 1 project exhausts the 15 RPM bucket in under 3 seconds.',
                          if (isTurkishDeck)
                            'Salon tek ağın arkasında: nginx sınırı IP başına değil, bütün servis için tek kova.'
                          else
                            'GEAR Lab VM Cap (<100 Seats): Hosted Qwiklabs sandboxes throttle above 100 concurrent starts.',
                          if (!isTurkishDeck)
                            'Shared Venue NAT IP: Creating 300 keys simultaneously on one Wi-Fi router triggers CAPTCHA throttles.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kaynak: ai.google.dev/gemini-api/docs/rate-limits'
                            : 'Source: ai.google.dev/gemini-api/docs/rate-limits',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'DÖRT ÖNLEMİMİZ' : 'OUR 4-LAYER DEFENSE · 100% SURVIVABLE',
                        badgeIcon: Icons.shield,
                        title: isTurkishDeck
                            ? 'Backyard Barista 850 kişiyle nasıl ayakta kalır?'
                            : 'How Backyard Barista Stays Up for 300 Builders',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            '1. Herkese kendi AI Studio projesi: tek ortak kota yerine herkese ayrı kota.'
                          else
                            '1. One Personal AI Studio Project per Builder: 300 isolated RPM buckets instead of 1 shared bottleneck.',
                          if (isTurkishDeck)
                            '2. Tek seferlik JSON çağrısı: sadece "Servis Et!" tıklanınca 1 generateContent (oyuncu başına 1-2 RPM).'
                          else
                            '2. Single-Shot Structured JSON: Only 1 generateContent call when clicking "Serve Order!" (1-2 RPM per player).',
                          if (isTurkishDeck)
                            '3. Cloud Run üzerinde nginx hız sınırı: Gemini çağrılarına saniyede 10 istek + 20 burst, fazlası 429.'
                          else
                            '3. AI Studio Starter Tier Cloud Run: Deploys up to 2 apps per account with zero billing card or VM lab cap.',
                          if (isTurkishDeck)
                            '4. Çevrimdışı yedek: Wi-Fi ya da kota takılınca mock_responses.json devreye girer.'
                          else
                            '4. Deterministic Offline Net: Automatic fallback to mock_responses.json when Wi-Fi or quota hiccups.',
                        ],
                        footerText: isTurkishDeck
                            ? "Hedef: salon Wi-Fi'ı ne yaparsa yapsın herkes bitirip yayınlasın."
                            : 'Result: Every builder finishes & deploys regardless of venue Wi-Fi.',
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
