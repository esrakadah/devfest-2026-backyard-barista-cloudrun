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
            title: '7. Gerçek Rakamlar #1: Latency & Cold Starts',
            speakerNotes:
                'BEAT  [11:30 - 14:00] Gerçek Rakamlar #1: Gecikme, zaman aşımı koruyucuları ve Cloud Run soğuk başlangıçları.\n'
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
          eyebrow: 'GERÇEK RAKAMLAR #1 (LATENCY, TIMEOUTS & COLD STARTS)',
          title: 'Real Numbers #1: Latency Budgets & Timeout Guardrails',
          act: StoryAct.realNumbers,
          subtitle: 'Every network path in CafeJudgeService is bounded so the UI never hangs on stage',
          child: Column(
            children: [
              LatencyBudgetChartCard(),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'FACT · CODE CONSTANT',
                        badgeIcon: Icons.verified,
                        title: 'Live Gemini JSON Timeout: 8,000 ms',
                        bullets: [
                          'Defined in lib/services/cafe_judge_service.dart:11 (_geminiRequestTimeout = Duration(seconds: 8)).',
                          'Calls gemini-3.5-flash-lite with responseMimeType: application/json and 6 required schema keys.',
                          'Measured 11 Nov (12 trays): 1.0-1.8 s per verdict, mean 1.4 s. Local Gemma 4 warm: 5-8.4 s, 15 s timeout.',
                        ],
                        footerText: 'Evidence: cafe_judge_service.dart:11 · docs/articles/cloud-vs-local-judge-draft.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'FACT · DOCKERFILE & CLOUD RUN',
                        badgeIcon: Icons.speed,
                        title: 'Stateless Container on PORT 8080',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          'Defined in flutter_client/Dockerfile: multi-stage Flutter Web build served by nginx:alpine on PORT 8080.',
                          'Measured 50 requests for the static index.html (europe-west3): 53.81 ms p50 / 75.52 ms p95 (first call with TLS: 528.95 ms).',
                          'Zero server state: every order evaluation is self-contained.',
                        ],
                        footerText: 'Evidence: Dockerfile:1-25 · tool/benchmark_gaziantep.dart',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'FACT · OFFLINE FALLBACK',
                        badgeIcon: Icons.bolt,
                        title: 'Conference Wi-Fi Guard: 250 ms',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'Defined in lib/services/cafe_judge_service.dart:12 (_offlineBundleLoadTimeout = Duration(milliseconds: 250)).',
                          'Loads assets/offline_fallback/mock_responses.json once and caches reviewsByCity in memory.',
                          'If Wi-Fi drops completely, gameplay continues at 60fps with 0 ms network wait.',
                        ],
                        footerText: 'Evidence: cafe_judge_service.dart:12 (_evaluateFromOfflineFallback)',
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
