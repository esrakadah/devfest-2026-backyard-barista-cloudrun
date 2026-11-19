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
                ? 'BEAT  [07:00 - 08:30] Gerçek Rakamlar #1: gecikme, zaman aşımı sınırları ve Cloud Run soğuk başlangıcı.\n'
                    'SAY   "Üretimde yapay zeka konuşuyorsak rakamları açık koymalıyız. Kodumuzdaki CafeJudgeService hiçbir ağ çağrısını ucu açık bırakmıyor. Canlı Gemini çağrısının sınırı tam 8 saniye; yanıt gelmezse 15 saniye sınırlı yerel Gemma 4\'e, o da yoksa 250 milisaniye sınırlı yerleşik JSON paketine düşüyor. Peki gerçek ölçümlerimiz ne diyor? 12 tepsiyle ölçtük: gemini-3.5-flash-lite kararı ortalama 1,4 saniyede veriyor. Bu laptoptaki Gemma 4 ısınmışken 5 ile 8,4 saniyede dönüyor. Cloud Run tarafında ise europe-west3 bölgesinde 50 istek koşturduk: statik sayfa sıcakken medyan yaklaşık 54 milisaniye, TLS dahil ilk soğuk çağrı ise yarım saniye civarında. Tam rakamlar ekranda."\n'
                    'HOLD  [KOD SABİTİ] 8 sn ve 250 ms (cafe_judge_service.dart:11-12), nginx:alpine PORT 8080 (Dockerfile:1-25). [ÖLÇÜLDÜ] 53,81 ms p50 ve 528,95 ms ilk çağrı (24 Ekim); Gemini 1,0-1,8 sn, Gemma 5-8,4 sn (11 Kasım, 12 tepsi).\n'
                    'NEXT  "Hız güzel. 1.000 sipariş değerlendirdiğimizde cüzdanımıza ne yazıyor?"'
                : 'BEAT  [11:30 - 14:00] Gerçek Rakamlar #1: Gecikme, zaman aşımı koruyucuları ve Cloud Run soğuk başlangıçları.\n'
                    'SAY   "Başlığımızda gerçek rakamlar sözü verdik; şimdi kodumuzdaki gerçek sınırları ve ölçtüğümüz süreleri açıkça konuşalım. CafeJudgeService içinde canlı Gemini çağrımız için tam 8 saniyelik bir zaman aşımı sınırı ve çevrimdışı JSON paketimiz için 250 milisaniyelik bir yükleme sınırı tanımlı. 11 Kasım\'da 12 tepsiyle ölçtük: gemini-3.5-flash-lite kararı 1,0 ile 1,8 saniyede veriyor, ortalama 1,4 saniye; laptoptaki Gemma 4 ise ısınmışken 5 ile 8,4 saniye, onun sınırı 15 saniye. Cloud Run\'ın statik sayfası ısınmışken p50 53,81 milisaniye, TLS dahil ilk çağrı 528,95 milisaniye."\n'
                    'HOLD  "Fact" (cafe_judge_service.dart:11-12: 8s / 250ms; Dockerfile:1-25: nginx:alpine on PORT 8080), "Measured" (53.81 ms p50, 528.95 ms ilk çağrı, 24 Ekim) ve Gemini 1,0-1,8 s / Gemma 5-8,4 s (11 Kasım) ölçümlerini vurgula; kod sabitleri ile ölçümleri birbirine karıştırma.\n'
                    'NEXT  "Peki 1.000 kafe siparişi değerlendirildiğinde bu çağrıların maliyeti ve model sınırları ne oluyor?"',
          ),
        );

  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck
              ? 'GERÇEK RAKAMLAR #1 (GECİKME, ZAMAN AŞIMI, SOĞUK BAŞLANGIÇ)'
              : 'GERÇEK RAKAMLAR #1 (LATENCY, TIMEOUTS & COLD STARTS)',
          title: isTurkishDeck
              ? 'Gerçek rakamlar #1: gecikme ve zaman aşımı sınırları'
              : 'Real Numbers #1: Latency Budgets & Timeout Guardrails',
          act: StoryAct.realNumbers,
          subtitle: isTurkishDeck
              ? "CafeJudgeService'teki her ağ çağrısının bir süre sınırı var: ekran sahnede donup kalmaz"
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
                        badge: isTurkishDeck ? 'OLGU · KOD SABİTİ' : 'FACT · CODE CONSTANT',
                        badgeIcon: Icons.verified,
                        title: isTurkishDeck ? 'Canlı Gemini zaman aşımı: 8 saniye' : 'Live Gemini JSON Timeout: 8,000 ms',
                        bullets: [
                          if (isTurkishDeck)
                            'Ölçüldü (11 Kasım, 12 tepsi): karar ortalama 1,4 sn.'
                          else
                            'Defined in lib/services/cafe_judge_service.dart:11 (_geminiRequestTimeout = Duration(seconds: 8)).',
                          if (isTurkishDeck)
                            'Yanıt gelmezse yerel Gemma 4: 5-8,4 sn, sınırı 15 sn.'
                          else
                            'Calls gemini-3.5-flash-lite with responseMimeType: application/json and 6 required schema keys.',
                          if (!isTurkishDeck)
                            'Measured 11 Nov (12 trays): 1.0-1.8 s per verdict, mean 1.4 s. Local Gemma 4 warm: 5-8.4 s, 15 s timeout.',
                        ],
                        footerText: isTurkishDeck
                            ? null
                            : 'Evidence: cafe_judge_service.dart:11 · docs/articles/cloud-vs-local-judge-draft.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'OLGU · DOCKERFILE VE CLOUD RUN' : 'FACT · DOCKERFILE & CLOUD RUN',
                        badgeIcon: Icons.speed,
                        title: isTurkishDeck ? "Cloud Run'da statik sayfa: 53,81 ms" : 'Stateless Container on PORT 8080',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'Ölçüldü (50 istek, europe-west3): p50 53,81 ms, p95 75,52 ms.'
                          else
                            'Defined in flutter_client/Dockerfile: multi-stage Flutter Web build served by nginx:alpine on PORT 8080.',
                          if (isTurkishDeck)
                            'TLS dahil ilk soğuk çağrı: 528,95 ms.'
                          else
                            'Measured 50 requests for the static index.html (europe-west3): 53.81 ms p50 / 75.52 ms p95 (first call with TLS: 528.95 ms).',
                          if (!isTurkishDeck)
                            'Zero server state: every order evaluation is self-contained.',
                        ],
                        footerText: isTurkishDeck
                            ? null
                            : 'Evidence: Dockerfile:1-25 · tool/benchmark_gaziantep.dart',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'OLGU · ÇEVRİMDIŞI YEDEK' : 'FACT · OFFLINE FALLBACK',
                        badgeIcon: Icons.bolt,
                        title: isTurkishDeck ? "Salon Wi-Fi'ı giderse: 250 ms" : 'Conference Wi-Fi Guard: 250 ms',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'mock_responses.json bir kez yüklenir, bellekte tutulur.'
                          else
                            'Defined in lib/services/cafe_judge_service.dart:12 (_offlineBundleLoadTimeout = Duration(milliseconds: 250)).',
                          if (isTurkishDeck)
                            'Wi-Fi tamamen giderse oyun ağ beklemeden devam eder.'
                          else
                            'Loads assets/offline_fallback/mock_responses.json once and caches reviewsByCity in memory.',
                          if (!isTurkishDeck)
                            'If Wi-Fi drops completely, gameplay continues at 60fps with 0 ms network wait.',
                        ],
                        footerText: isTurkishDeck
                            ? null
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
