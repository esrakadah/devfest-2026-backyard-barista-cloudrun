import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class RealNumbersLatencySlide extends FlutterDeckSlideWidget {
  const RealNumbersLatencySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/real-numbers-latency',
            title: isTurkishDeck
                ? '7. Gerçek rakamlar #1: gecikme ve zaman aşımı sınırları'
                : '7. Gerçek Rakamlar #1: Latency & Cold Starts',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [07:00 - 08:30] Gerçek rakamlar #1: gecikme, zaman aşımı sınırları ve Cloud Run soğuk başlangıcı.\n'
                    'SAY   "Üretimde yapay zekadan söz ediyorsak rakamları ortaya koymalıyız. CafeJudgeService\'te hiçbir ağ çağrısı sonsuza kadar beklemiyor. Canlı Gemini çağrısı en fazla 8 saniye bekliyor. Bu laptoptaki sekmede yanıt gelmezse yerel Gemma 4\'e geçiyor, ona da en fazla 15 saniye veriyor. O da olmazsa en fazla 250 milisaniye bekleyip paketteki hazır yanıtlara düşüyor. Peki ölçümler ne diyor? 12 tepside ölçtük: Gemini kararı ortalama 1,4 saniyede veriyor. Bu laptoptaki Gemma 4 ısınmışken 5 ile 8,4 saniye arasında dönüyor. Cloud Run\'a 50 istek attık. Isınmış sayfa yaklaşık 54 milisaniyede geliyor. İlk soğuk çağrı yarım saniye civarında. Tam rakamlar ekranda."\n'
                    'HOLD  Önce üstteki çubukları, sonra üç kartı göster. [KOD SABİTİ] 8 sn ve 250 ms (cafe_judge_service.dart:11-12). [ÖLÇÜLDÜ] 53,81 ms p50 ve 528,95 ms ilk çağrı (24 Ekim); Gemini 1,0-1,8 sn, Gemma 5-8,4 sn (11 Kasım, 12 tepsi).\n'
                    'NEXT  "Hız güzel. 1.000 sipariş değerlendirdiğimizde cüzdanımıza ne yazıyor?"'
                : 'BEAT  [11:30 - 14:00] Gerçek Rakamlar #1: Gecikme, zaman aşımı koruyucuları ve Cloud Run soğuk başlangıçları.\n'
                    'SAY   "Başlığımızda gerçek rakamlar sözü verdik; şimdi kodumuzdaki gerçek sınırları ve ölçtüğümüz süreleri açıkça konuşalım. CafeJudgeService içinde canlı Gemini çağrımız için tam 8 saniyelik bir zaman aşımı sınırı ve çevrimdışı JSON paketimiz için 250 milisaniyelik bir yükleme sınırı tanımlı. 11 Kasım\'da 12 tepsiyle ölçtük: gemini-3.5-flash-lite kararı 1,0 ile 1,8 saniyede veriyor, ortalama 1,4 saniye; laptoptaki Gemma 4 ise ısınmışken 5 ile 8,4 saniye, onun sınırı 15 saniye. Cloud Run\'ın statik sayfası ısınmışken p50 53,81 milisaniye, TLS dahil ilk çağrı 528,95 milisaniye."\n'
                    'HOLD  "Fact" (cafe_judge_service.dart:11-12: 8s / 250ms; Dockerfile:1-25: nginx:alpine on PORT 8080), "Measured" (53.81 ms p50, 528.95 ms ilk çağrı, 24 Ekim) ve Gemini 1,0-1,8 s / Gemma 5-8,4 s (11 Kasım) ölçümlerini vurgula; kod sabitleri ile ölçümleri birbirine karıştırma.\n'
                    'NEXT  "Peki 1.000 kafe siparişi değerlendirildiğinde bu çağrıların maliyeti ve model sınırları ne oluyor?"',
          ),
        );

  static const double _talkBulletSize = 28;
  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'GERÇEK RAKAMLAR 1 · HIZ'
              : 'GERÇEK RAKAMLAR #1 (LATENCY, TIMEOUTS & COLD STARTS)',
          title: isTurkishDeck
              ? 'Yapay zeka geç kalırsa ekran donmaz'
              : 'Real Numbers #1: Latency Budgets & Timeout Guardrails',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? 'Her çağrıya "en fazla şu kadar bekle" sınırı koyduk; süre dolunca yedeğe geçer'
              : 'Every network path in CafeJudgeService is bounded so the UI never hangs on stage',
          child: Column(
            children: [
              LatencyBudgetChartCard(),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'SINIR + ÖLÇÜM' : 'FACT · CODE CONSTANT',
                        badgeIcon: Icons.verified,
                        title: isTurkishDeck ? 'Gemini: en fazla 8 saniye bekleriz' : 'Live Gemini JSON Timeout: 8,000 ms',
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            'Ölçtük (12 tepsi): ortalama 1,4 saniye.'
                          else
                            'Defined in lib/services/cafe_judge_service.dart:11 (_geminiRequestTimeout = Duration(seconds: 8)).',
                          if (isTurkishDeck)
                            'Yedek: bu laptopta Gemma 4, 5-8,4 saniye.'
                          else
                            'Calls gemini-3.5-flash-lite with responseMimeType: application/json and 6 required schema keys.',
                          if (!isTurkishDeck)
                            'Measured 11 Nov (12 trays): 1.0-1.8 s per verdict, mean 1.4 s. Local Gemma 4 warm: 5-8.4 s, 15 s timeout.',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: _geminiRequestTimeout 8 sn, Gemma sınırı 15 sn'
                            : 'Evidence: cafe_judge_service.dart:11 · docs/articles/cloud-vs-local-judge-draft.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ÖLÇÜLDÜ' : 'FACT · DOCKERFILE & CLOUD RUN',
                        badgeIcon: Icons.speed,
                        title: isTurkishDeck ? "Cloud Run'da sayfa: 54 milisaniye" : 'Stateless Container on PORT 8080',
                        accentColor: DeckColors.googleGreen,
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            'Ölçtük: 50 istek, Frankfurt bölgesi.'
                          else
                            'Defined in flutter_client/Dockerfile: multi-stage Flutter Web build served by nginx:alpine on PORT 8080.',
                          if (isTurkishDeck)
                            'İlk açılış (soğuk başlangıç): yarım saniye.'
                          else
                            'Measured 50 requests for the static index.html (europe-west3): 53.81 ms p50 / 75.52 ms p95 (first call with TLS: 528.95 ms).',
                          if (!isTurkishDeck)
                            'Zero server state: every order evaluation is self-contained.',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: p50 53,81 ms · p95 75,52 ms · ilk çağrı 528,95 ms'
                            : 'Evidence: Dockerfile:1-25 · tool/benchmark_gaziantep.dart',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'SON YEDEK' : 'FACT · OFFLINE FALLBACK',
                        badgeIcon: Icons.bolt,
                        title: isTurkishDeck ? 'Wi-Fi giderse: hazır yanıtlar' : 'Conference Wi-Fi Guard: 250 ms',
                        accentColor: DeckColors.googleYellow,
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            'Paketteki hazır yanıtlar 250 ms içinde gelir.'
                          else
                            'Defined in lib/services/cafe_judge_service.dart:12 (_offlineBundleLoadTimeout = Duration(milliseconds: 250)).',
                          if (isTurkishDeck)
                            'Oyun internet beklemeden devam eder.'
                          else
                            'Loads assets/offline_fallback/mock_responses.json once and caches reviewsByCity in memory.',
                          if (!isTurkishDeck)
                            'If Wi-Fi drops completely, gameplay continues at 60fps with 0 ms network wait.',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: mock_responses.json bir kez yüklenir, bellekte tutulur'
                            : 'Evidence: cafe_judge_service.dart:12 (_evaluateFromOfflineFallback)',
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
