import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class RealNumbersLatencySlide extends FlutterDeckSlideWidget {
  const RealNumbersLatencySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/real-numbers-latency',
            title: '6. Gerçek Rakamlar #1: Latency & Cold Starts',
            speakerNotes:
                'BEAT  [11:30 - 14:00] Gerçek Rakamlar #1: Gecikme, zaman aşımı koruyucuları ve Cloud Run soğuk başlangıçları.\n'
                'SAY   "Başlığımızda gerçek rakamlar sözü verdik; şimdi kodumuzdaki gerçek sınırları ve hedef bütçelerimizi açıkça konuşalım. CafeJudgeService içinde canlı Gemini çağrımız için tam 8 saniyelik bir zaman aşımı sınırı ve çevrimdışı JSON paketimiz için 250 milisaniyelik bir yükleme sınırı tanımlı. 150 token girdi ve 120 token yapılandırılmış JSON çıktı için hedefimiz gemini-3.5-flash-lite üzerinde p50 gecikmeyi 1 saniyenin altında tutmak ve Cloud Run konteynerimizin soğuk başlangıcını 500 milisaniyenin altında tamamlamak."\n'
                'HOLD  "Fact" (cafe_judge_service.dart:11-12: 8s / 250ms; Dockerfile:1-20: nginx:alpine on PORT 8080) ve "Target" (<1s p50, <500ms cold start) rozetlerini özellikle vurgula; kesinleşmiş kod sabitleri ile sahne öncesi ölçüm hedeflerini birbirine karıştırma.\n'
                'NEXT  "Peki 1.000 kafe siparişi değerlendirildiğinde bu çağrıların maliyeti ve model sınırları ne oluyor?"',
          ),
        );

  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 6 · GERÇEK RAKAMLAR #1 (LATENCY, TIMEOUTS & COLD STARTS)',
          title: 'Real Numbers #1: Latency Budgets & Timeout Guardrails',
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
                          'Target Latency: sub-second p50 on warm gemini-3.5-flash-lite (~150 input / ~120 output tokens).',
                        ],
                        footerText: 'Evidence: cafe_judge_service.dart:11, 95-116',
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
                          'Measured 50-Req Warm Latency (europe-west3): 53.81 ms p50 / 75.52 ms p95 (initial TLS + cold call: 528.95 ms).',
                          'Zero server state: every order evaluation is self-contained.',
                        ],
                        footerText: 'Evidence: Dockerfile:1-20 · tool/benchmark_gaziantep.dart',
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
                        footerText: 'Evidence: cafe_judge_service.dart:12, 188-215',
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
