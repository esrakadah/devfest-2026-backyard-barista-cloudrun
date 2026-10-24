import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class AiStudioPipelineSlide extends FlutterDeckSlideWidget {
  const AiStudioPipelineSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/ai-studio-pipeline',
            title: '3. What Comes Out of Google AI Studio Today',
            speakerNotes: 'BEAT  [05:00 - 07:30] "AI Studio\'dan ne gelir?" sorusunun somut cevabı.\n'
                'SAY   "Mustafa ile konuşurken en önemli soru şuydu: Google AI Studio\'dan bugün tam olarak ne çıkıyor? Eskiden sadece bir prompt test ekranıydı. Bugün ise AI Studio Build modu size çalışan tam yığın bir web uygulaması üretiyor, çift yönlü GitHub senkronizasyonu yapıyor ve Starter Tier kapsamında kredi kartı veya fatura hesabı açmadan 2 adede kadar tam yığın uygulamayı tek tıkla Google Cloud Run üzerinde canlı bir .run.app adresine yayınlıyor. Dikkat etmeniz gereken tek önemli kural: eski Firebase Studio kapandı, yeni kayıt almıyor; doğru adres doğrudan Google AI Studio ve Google Antigravity."\n'
                'HOLD  Slayttaki 4 adımlı boru hattını soldan sağa doğru işaret et. [Fact (Oct 2026, ai.google.dev): Starter Tier = 2 Cloud Run apps; Firebase Studio sign-ups disabled 22 Jun 2026 ahead of Mar 2027 sunset].\n'
                'NEXT  "Peki işin çoklu dosya ve Flutter tarafında Google Antigravity bize ne kazandırıyor?"',
          ),
        );

  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 3 · GOOGLE AI STUDIO BUILD MODE (OCT 2026)',
          title: 'What Comes Out of Google AI Studio Today?',
          subtitle: 'From seed prompt to a live Google Cloud Run (*.run.app) service in one click',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              AiStudioPipelineDiagramCard(),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'STEP 1 · SEED + ASSETS',
                        badgeIcon: Icons.description,
                        title: 'Prompt + GitHub PNGs',
                        bullets: [
                          'Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          'Loads our 12 studio cafe PNGs directly from GitHub Raw URLs.',
                          'Targets gemini-3.5-flash-lite or gemini-3.8-flash.',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'STEP 2 · LIVE APP',
                        badgeIcon: Icons.web,
                        title: 'Full-Stack Web Preview',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          'Generates interactive 2-player cafe counter UI + backend.',
                          'Includes 4-City Edition switcher (Berlin, Gaziantep, Adana, Istanbul).',
                          'Evaluates trays via structured JSON schema (CafeReview).',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'STEP 3 · SOURCE CONTROL',
                        badgeIcon: Icons.sync,
                        title: 'Two-Way GitHub Sync',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'One-click export & two-way sync to your GitHub account.',
                          'Generates clean commit messages automatically.',
                          'Full ZIP download available as an offline backup.',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'STEP 4 · CLOUD RUN',
                        badgeIcon: Icons.cloud_done,
                        title: 'No-Card .run.app Deploy',
                        accentColor: DeckColors.googleRed,
                        bullets: [
                          'Starter Tier publishes up to 2 full-stack apps to Cloud Run.',
                          'Zero manual GCP billing setup or credit card required.',
                          'Keeps GEMINI_API_KEY server-side inside the container.',
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              DeckCard(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: DeckColors.surfaceInset,
                borderColor: DeckColors.halftonePink,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: DeckColors.halftonePink, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'VERIFIED 2026 GUARDRAIL: Legacy Firebase Studio (Project IDX) disabled new sign-ups on 22 June 2026 ahead of its March 2027 sunset. Use Google AI Studio (Browser Lane A) and Google Antigravity (IDE Lane B).',
                        style: TextStyle(
                          fontFamily: DeckFonts.sans,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DeckColors.offWhite,
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
