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
                ? '9. Gerçek rakamlar #3: 300 kişilik salonda kota tuzağı'
                : '9. Gerçek Rakamlar #3: The 300-Person Quota Trap',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [16:30 - 18:30] Gerçek Rakamlar #3: 300 kişilik salonda HTTP 429 tuzağı ve çözümümüz.\n'
                    'SAY   "Bir atölyeyi batıran klasik hata şu: konuşmacı kendi API anahtarını bütün salonla paylaşır. Ücretsiz katmanda hız sınırı anahtar başına değil, Google Cloud projesi başına. Dakikada 5 ile 15 istek kadar. 300 kişi tek projeye yüklenirse birkaç saniyede HTTP 429 alırsınız, yani \'kotan doldu\' hatası. Sanal laboratuvarlar da etkinlik başına 100 kişiyle sınırlı. Biz bunu dört katmanla aşıyoruz. Bir: herkes kendi ücretsiz AI Studio anahtarını kullanıyor. İki: sipariş başına tek istek atıyoruz. Üç: AI Studio Starter Tier ile Cloud Run\'a yayınlıyoruz. Dört: ağ giderse uygulama hazır cevaplara düşüyor."\n'
                    'HOLD  Önce soldaki kırmızı "3 saniyede 429" kutusunu, sonra sağdaki 4 katmanı göster. "3 saniye" bir [HESAP] (dakikada 15 istek sınırına 300 kişi), salonda ölçülmedi. [Olgu (ai.google.dev/gemini-api/docs/rate-limits): ücretsiz katman = GCP projesi başına 5-15 RPM; GEAR laboratuvarları 100 eşzamanlı VM ile sınırlı].\n'
                    'NEXT  "Peki aynı kodu yeniden derlemeden Berlin, Gaziantep, Adana ve İstanbul\'a nasıl uyarlıyoruz?"'
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
              ? 'Gerçek rakamlar #3: 300 kişilik salonda HTTP 429 almadan'
              : 'Real Numbers #3: Surviving a 300-Person Room Without HTTP 429',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? 'Ortak anahtar ve 100 kişilik laboratuvarlar neden yetmez, bizim mimari neden ayakta kalır'
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
                            ? 'SAHNE TUZAĞI · 3 SANİYEDE HTTP 429'
                            : 'THE STAGE TRAP · HTTP 429 IN 3 SECONDS',
                        badgeIcon: Icons.error_outline,
                        title: isTurkishDeck
                            ? 'Kalabalık atölyelerde ne bozulur?'
                            : 'What Breaks in Big Hands-On Workshops',
                        accentColor: DeckColors.googleRed,
                        bullets: [
                          if (isTurkishDeck)
                            'Kota proje başına (olgu): Gemini API ücretsiz katman sınırı API anahtarına değil Google Cloud projesine uygulanır (genelde 5-15 RPM, ~250K TPM).'
                          else
                            'Per-Project Quota Enforcement (Fact): Gemini API free-tier rate limits apply per Google Cloud project (typically 5 to 15 RPM, ~250K TPM), not per API key.',
                          if (isTurkishDeck)
                            'Ortak anahtar = anında 429: 300 kişi tek projeye yüklenince 15 RPM kotası 3 saniyeden kısa sürede biter.'
                          else
                            'Shared Key = Instant 429: 300 builders hitting 1 project exhausts the 15 RPM bucket in under 3 seconds.',
                          if (isTurkishDeck)
                            'GEAR laboratuvar sınırı (<100 kişi): Qwiklabs ortamları 100 eşzamanlı başlatmanın üstünde yavaşlar.'
                          else
                            'GEAR Lab VM Cap (<100 Seats): Hosted Qwiklabs sandboxes throttle above 100 concurrent starts.',
                          if (isTurkishDeck)
                            "Ortak salon IP'si: aynı Wi-Fi'dan aynı anda 300 anahtar açmak CAPTCHA engeline takılır."
                          else
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
                        badge: isTurkishDeck ? '4 KATMANLI SAVUNMAMIZ' : 'OUR 4-LAYER DEFENSE · 100% SURVIVABLE',
                        badgeIcon: Icons.shield,
                        title: isTurkishDeck
                            ? 'Backyard Barista 300 kişiyle nasıl ayakta kalır?'
                            : 'How Backyard Barista Stays Up for 300 Builders',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            '1. Herkese kendi AI Studio projesi: tek ortak kota yerine 300 ayrı kota.'
                          else
                            '1. One Personal AI Studio Project per Builder: 300 isolated RPM buckets instead of 1 shared bottleneck.',
                          if (isTurkishDeck)
                            '2. Tek seferlik JSON çağrısı: sadece "Servis Et!" tıklanınca 1 generateContent (oyuncu başına 1-2 RPM).'
                          else
                            '2. Single-Shot Structured JSON: Only 1 generateContent call when clicking "Serve Order!" (1-2 RPM per player).',
                          if (isTurkishDeck)
                            '3. AI Studio Starter Tier + Cloud Run: hesap başına 2 uygulama, fatura kartı ve VM sınırı yok.'
                          else
                            '3. AI Studio Starter Tier Cloud Run: Deploys up to 2 apps per account with zero billing card or VM lab cap.',
                          if (isTurkishDeck)
                            '4. Çevrimdışı güvenlik ağı: Wi-Fi ya da kota takılınca mock_responses.json devreye girer.'
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
