import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class ArchitectureRecapSlide extends FlutterDeckSlideWidget {
  const ArchitectureRecapSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/architecture-recap',
            title: '14. En Son Mimaride Ne Yaptık? (Architecture Recap)',
            speakerNotes: 'BEAT  [60:00 - 65:00] "En Son Mimaride Ne Yaptık?" (Ödül Töreni Öncesi Tam Mimari Özeti).\n'
                'SAY   "Ödüllerimizi dağıtmadan önce herkesin ekrana bakmasını istiyorum: bugün eğlenceli bir kafe oyunu yaptık ama aslında arkada dört katmanlı, gerçek bir prodüksiyon bulut mimarisi kurduk! 1. Katmanda saf Flutter widget\'ları ile 20 hazır stüdyo PNG görselini ve yolda ürettiğimiz CustomPaint AI vektörlerini birleştirdik. 2. Katmanda 3 öncelikli CityEditionController ve Firebase Remote Config şablonu ile uygulamamızı yeniden derlemeden 4 farklı DevFest şehrine (Berlin, Gaziantep, Adana, İstanbul) uyarladık. 3. Katmanda gemini-3.5-flash-lite ve yapılandırılmış JSON şeması (CafeReview) ile deterministik bir jüri kurup çevrimdışı yedeklemeyle koruduk. 4. Katmanda ise durumsuz konteynerimizi Google Cloud Run üzerinde canlı bir .run.app adresine ve GitHub\'a taşıdık!"\n'
                'HOLD  4 katmanı yukarıdan aşağıya, her bant için bir nefes vererek say; sağdaki sonuç sütununu (0 motor, 0 yeniden derleme, 1 çağrı, 0 sunucu durumu) ritim olarak kullan; salondaki herkesin ne öğrendiğini içselleştirmesini sağla.\n'
                'NEXT  "Şimdi sahne sizin: canlı linkini yayınlayanları 60 saniyelik demoları ve Google piksel gözlük ödülleri için sahneye alıyoruz!"',
          ),
        );

  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'EN SON MİMARİDE NE YAPTIK?',
          title: 'What We Just Built: A 4-Layer Production Architecture',
          act: StoryAct.buildAndShip,
          subtitle: 'Every layer you shipped today transfers directly to a real Flutter and Cloud product',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              Expanded(
                child: _LayerBand(
                  number: 1,
                  name: 'PRESENTATION',
                  color: DeckColors.googleBlue,
                  chips: [
                    'Stack · AnimatedScale · CustomPaint',
                    '20 PNGs',
                    '5 Lottie',
                    '10 WAV SFX',
                    '2x2 Desktop + 3-Slot Tray',
                  ],
                  outcome: '0 game engines',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 2,
                  name: 'CONFIG',
                  color: DeckColors.googleYellow,
                  chips: ['1 · In-app override', '2 · Remote Config active_city_id', '3 · city_editions.json'],
                  outcome: '4 cities, 0 rebuilds',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 3,
                  name: 'AI & GUARDRAILS',
                  color: DeckColors.googleGreen,
                  chips: ['gemini-3.5-flash-lite', 'CafeReview JSON schema', '8 s timeout', '250 ms offline fallback'],
                  outcome: '1 call ≈ 270 tokens',
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: _LayerBand(
                  number: 4,
                  name: 'SERVERLESS CLOUD',
                  color: DeckColors.googleRed,
                  chips: ['Multi-stage Dockerfile', 'nginx:alpine :8080', 'Cloud Run *.run.app', 'GitHub sync'],
                  outcome: '0 server state',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One horizontal band of the layer stack: name on the left, components in the middle, outcome on the right.
class _LayerBand extends StatelessWidget {
  const _LayerBand({
    required this.number,
    required this.name,
    required this.color,
    required this.chips,
    required this.outcome,
  });

  static const double _labelWidth = 330;
  static const double _outcomeWidth = 340;
  static const double _chipGap = 12;

  final int number;
  final String name;
  final Color color;
  final List<String> chips;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: EdgeInsets.zero,
      borderColor: color.withValues(alpha: 0.5),
      child: Row(
        children: [
          Container(
            width: _labelWidth,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
              border: Border(left: BorderSide(color: color, width: 8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAYER $number',
                  style: TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: DeckTypeScale.bodySmall,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: DeckTypeScale.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: _chipGap,
                runSpacing: _chipGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final chip in chips)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: DeckColors.surfaceInset,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DeckColors.outlineLight),
                      ),
                      child: Text(
                        chip,
                        style: const TextStyle(
                          fontFamily: DeckFonts.mono,
                          fontSize: DeckTypeScale.code,
                          color: DeckColors.offWhite,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: _outcomeWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerRight,
            child: Text(
              outcome,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: DeckTypeScale.subtitle,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
