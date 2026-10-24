import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class ArchitectureRecapSlide extends FlutterDeckSlideWidget {
  const ArchitectureRecapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/architecture-recap',
            title: '13. En Son Mimaride Ne Yaptik? (Architecture Recap)',
            speakerNotes: 'BEAT  [58:00 - 63:00] "En Son Mimaride Ne Yaptık?" (Ödül Töreni Öncesi Tam Mimari Özeti).\n'
                'SAY   "Ödüllerimizi dağıtmadan önce herkesin ekrana bakmasını istiyorum: bugün 40 dakikada eğlenceli bir kafe oyunu yaptık ama aslında arkada dört katmanlı, gerçek bir prodüksiyon bulut mimarisi kurduk! 1. Katmanda saf Flutter widget\'ları ile 12 hazır GitHub PNG görselini ve yolda ürettiğimiz AI vektörlerini birleştirdik. 2. Katmanda Firebase Remote Config ile uygulamamızı yeniden derlemeden 4 farklı DevFest şehrine (Berlin, Gaziantep, Adana, İstanbul) uyarladık. 3. Katmanda gemini-3.5-flash-lite ve yapılandırılmış JSON şeması (CafeReview) ile deterministik bir jüri kurup çevrimdışı yedeklemeyle koruduk. 4. Katmanda ise durumsuz konteynerimizi Google Cloud Run üzerinde canlı bir .run.app adresine ve GitHub\'a taşıdık!"\n'
                'HOLD  4 katmanı yukarıdan aşağıya veya soldan sağa net bir ritimle say; salondaki herkesin ne öğrendiğini içselleştirmesini sağla.\n'
                'NEXT  "Şimdi sahne sizin: canlı linkini yayınlayanları 60 saniyelik demoları ve Google piksel gözlük ödülleri için sahneye alıyoruz!"',
          ),
        );

  static const double _gap = 18;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 13 · EN SON MIMARIDE NE YAPTIK? (FULL PRODUCTION ARCHITECTURE RECAP)',
          title: 'What We Just Built: 4-Layer Production Cloud Architecture',
          subtitle: 'Every pattern you shipped today transfers directly to real production Flutter & Cloud apps',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'LAYER 1 · PRESENTATION & ASSETS',
                        title: 'Declarative Flutter UI + Hybrid Assets',
                        bullets: [
                          'Pure Flutter Widgets (Stack, AnimatedScale, CustomPaint) with <600px mobile responsiveness.',
                          '12 pre-generated studio PNGs in assets/base/ + on-the-fly AI-generated CustomPainter/SVG dishes.',
                        ],
                        footerText: 'flutter/one-codebase',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'LAYER 2 · MULTI-CITY CONFIG',
                        title: '3-Layer Firebase Remote Config',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'Priority 1: In-App Settings Drawer Override (uiOverrideCityCode).',
                          'Priority 2: Firebase Remote Config (active_city_id across Berlin, Gaziantep, Adana, Istanbul).',
                          'Priority 3: Bundled local city_editions.json fallback.',
                        ],
                        footerText: 'firebase/monitoring/remote-config',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'LAYER 3 · AI & GUARDRAILS',
                        title: 'Structured JSON Judge + Offline Net',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          'Single generateContent call per order (~270 tokens) on gemini-3.5-flash-lite / firebase_ai.',
                          'Strict responseSchema (CafeReview: ratingStars, tasteVerdict, customerFace, customerReaction).',
                          '8s network timeout + 250ms deterministic offline fallback (mock_responses.json).',
                        ],
                        footerText: 'ai/ai-dev-tools/ai-studio · ai/ai-dev-tools/antigravity',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'LAYER 4 · SERVERLESS CLOUD',
                        title: 'Google Cloud Run (*.run.app) & GitHub',
                        accentColor: DeckColors.googleRed,
                        bullets: [
                          'Stateless multi-stage Dockerfile (Flutter Web release served on PORT 8080) or AI Studio Starter Tier.',
                          "Scales to zero automatically; zero database lock-in; synced to each builder's GitHub repo.",
                        ],
                        footerText: 'cloud/serverless-containers/cloud-run',
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
