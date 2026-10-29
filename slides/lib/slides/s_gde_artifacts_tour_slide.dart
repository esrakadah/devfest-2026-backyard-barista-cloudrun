import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class GdeArtifactsTourSlide extends FlutterDeckSlideWidget {
  const GdeArtifactsTourSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/gde-artifacts-tour',
            title: '15. GDE Claude Artifacts & Autumn 2026 Tour',
            speakerNotes: 'BEAT  [64:00 - 66:00] GDE Claude Artifacts Koleksiyonu ve Sonbahar 2026 Konuşma Turu.\n'
                'SAY   "Bu atölyedeki mimari notları, canlı AI demo güvenlik ağlarını ve sahne kontrol listelerini GDE Speaking Autumn 2026 kapsamında 6 interaktif Claude Artifact olarak birleştirdik: Phase 3 Speaker Notes, Live AI Demo Risks & Fallbacks, SoundStage Capability Ledger, modemoiselle x BlocSignal ve DevFest Adana Firebase AI + Genkit. Stockholm\'den başlayan sonbahar 2026 turumuz Gaziantep, Berlin, Adana, Hatay, Atyrau, Karlsruhe ve İstanbul duraklarıyla devam ediyor!"\n'
                'HOLD  Sol karttaki 6 GDE Claude Artifact başlığını ve sağ karttaki 8 duraklı Sonbahar 2026 tur takvimini göster.\n'
                'NEXT  "Şimdi sahne sizin: canlı linkini yayınlayanları 60 saniyelik demoları ve Google piksel gözlük ödülleri için sahneye alıyoruz!"',
          ),
        );

  static const double _columnGap = 24;
  static const double _rowGap = 16;

  static const List<(String, String, Color)> _tourStops = [
    ('Stockholm 22 Oct', 'SE · Flutter & AI Kickoff', DeckColors.halftoneBlue),
    ('Gaziantep 8 Nov', 'TR · Şehitkamil Baklava Edition', DeckColors.googleRed),
    ('Berlin 14 Nov', 'DE · Kreuzberg Späti Edition', DeckColors.googleYellow),
    ('Adana 21 Nov', 'TR · Firebase AI + Genkit & Bici Bici', DeckColors.googleGreen),
    ('Hatay 28 Nov', 'TR · Community DevFest Stage', DeckColors.halftonePink),
    ('Atyrau 29 Nov', 'KZ · Central Asia GDE Keynote', DeckColors.halftoneBlue),
    ('Karlsruhe 5 Dec', 'DE · Cloud Run & Agentic Workflows', DeckColors.googleYellow),
    ('Istanbul 6 Dec', 'TR · Galata & Vapur Kafe Finale', DeckColors.googleGreen),
  ];

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'UNIFIED GDE CLAUDE ARTIFACTS & AUTUMN 2026 TOUR',
          title: 'GDE Speaking Autumn 2026: Artifacts & Tour Roadmap',
          act: StoryAct.buildAndShip,
          subtitle: '6 interactive Claude Artifacts powering 8 DevFest and GDE stages across Europe and Central Asia',
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: '6 Artifacts',
                      label: 'GDE Claude Artifacts Suite',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: '8 Tour Stops',
                      label: 'Oct - Dec 2026 Roadshow',
                      accentColor: DeckColors.halftoneBlue,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: StatChip(
                      value: 'Flame + NFC',
                      label: 'BaristaFlameGame · NDEFReader',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _rowGap),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      flex: 6,
                      child: DeckFeatureCard(
                        badge: 'CLAUDE ARTIFACT SUITE · GDE SPEAKING AUTUMN 2026',
                        badgeIcon: Icons.auto_awesome,
                        title: '6 Unified Engineering & Stage Artifacts',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'GDE Speaking Autumn 2026: Master hub for talk tracks, city configs, and slide telemetry.',
                          'Phase 3 Speaker Notes & Live AI Demo Risks & Fallbacks: Bilingual cues + 250 ms guardrails.',
                          'SoundStage Capability Ledger: 20 PNGs, 5 Lottie JSONs, 10 WAV SFX, and Web NFC inventory.',
                          'modemoiselle x BlocSignal & DevFest Adana Firebase AI + Genkit: Reactive streams & Genkit flows.',
                        ],
                        footerText:
                            'Artifacts: GDE Speaking Autumn 2026 · Phase 3 Speaker Notes · SoundStage Capability Ledger',
                      ),
                    ),
                    const SizedBox(width: _columnGap),
                    Expanded(
                      flex: 6,
                      child: DeckCard(
                        borderColor: DeckColors.halftoneBlue.withValues(alpha: 0.45),
                        accentStripeColor: DeckColors.halftoneBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DeckBadge(
                              label: 'AUTUMN 2026 TOUR · 8 CITIES (OCT - DEC)',
                              color: DeckColors.halftoneBlue,
                              icon: Icons.flight_takeoff,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'From Stockholm to Istanbul',
                              style: TextStyle(
                                fontFamily: DeckFonts.sans,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: DeckColors.offWhite,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  for (final stop in _tourStops)
                                    _TourStopChip(
                                      cityDate: stop.$1,
                                      detail: stop.$2,
                                      accentColor: stop.$3,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

class _TourStopChip extends StatelessWidget {
  const _TourStopChip({
    required this.cityDate,
    required this.detail,
    required this.accentColor,
  });

  final String cityDate;
  final String detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cityDate,
            style: TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: 14,
              color: DeckColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }
}
