import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class AiStudioPipelineSlide extends FlutterDeckSlideWidget {
  const AiStudioPipelineSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/ai-studio-pipeline',
            title: isTurkishDeck
                ? "4. Google AI Studio'dan bugün ne çıkıyor?"
                : '4. What Comes Out of Google AI Studio Today',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [03:15 - 04:30] "AI Studio\'dan bugün ne çıkar?" sorusunun somut cevabı.\n'
                    'SAY   "Google AI Studio eskiden sadece prompt denediğimiz bir metin kutusuydu. Bugün Build moduna başlangıç promptumuzu veriyoruz, bize çalışan bir web uygulaması ve arka uç üretiyor. Kodu GitHub hesabımızla iki yönlü eşitliyor. Starter Tier kapsamında, kredi kartı ya da fatura hesabı açmadan Cloud Run\'da canlı bir .run.app adresine yayınlıyor. En güzel yanı: GEMINI_API_KEY sunucudaki container\'da kalıyor, tarayıcıdaki JavaScript paketine sızmıyor."\n'
                    'HOLD  Dört kartı soldan sağa göster. [Olgu (Ekim 2026, ai.google.dev): Starter Tier = 2 Cloud Run uygulaması.]\n'
                    'NEXT  "Tarayıcıda prototip hızlı. Gerçek, çok dosyalı bir Flutter projesinde ne oluyor?"'
                : 'BEAT  [05:00 - 07:30] "AI Studio\'dan ne gelir?" sorusunun somut cevabı.\n'
                    'SAY   "Mustafa ile konuşurken en önemli soru şuydu: Google AI Studio\'dan bugün tam olarak ne çıkıyor? Eskiden sadece bir prompt test ekranıydı. Bugün ise AI Studio Build modu size çalışan tam yığın bir web uygulaması üretiyor, çift yönlü GitHub senkronizasyonu yapıyor ve Starter Tier kapsamında kredi kartı veya fatura hesabı açmadan 2 adede kadar tam yığın uygulamayı tek tıkla Google Cloud Run üzerinde canlı bir .run.app adresine yayınlıyor. Dikkat etmeniz gereken tek önemli kural: eski Firebase Studio kapandı, yeni kayıt almıyor; doğru adres doğrudan Google AI Studio ve Google Antigravity."\n'
                    'HOLD  Slayttaki 4 adımlı boru hattını soldan sağa doğru işaret et. [Fact (Oct 2026, ai.google.dev): Starter Tier = 2 Cloud Run apps; Firebase Studio sign-ups disabled 22 Jun 2026 ahead of Mar 2027 sunset].\n'
                    'NEXT  "Peki işin çoklu dosya ve Flutter tarafında Google Antigravity bize ne kazandırıyor?"',
          ),
        );

  static const double _talkBulletSize = 26;
  static const double _gap = 16;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck ? 'GOOGLE AI STUDIO BUILD MODU (EKİM 2026)' : 'GOOGLE AI STUDIO BUILD MODE (OCT 2026)',
          title: isTurkishDeck ? "Google AI Studio'dan bugün ne çıkıyor?" : 'What Comes Out of Google AI Studio Today?',
          act: StoryAct.tools,
          subtitle: isTurkishDeck
              ? 'İlk prompttan canlı bir Cloud Run (*.run.app) servisine tek tıkla'
              : 'From seed prompt to a live Google Cloud Run (*.run.app) service in one click',
          accentColor: DeckColors.halftoneBlue,
          child: Column(
            children: [
              if (!isTurkishDeck) AiStudioPipelineDiagramCard(),
              if (!isTurkishDeck) SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 1 · PROMPT + GÖRSEL' : 'STEP 1 · SEED + ASSETS',
                        badgeIcon: Icons.description,
                        title: isTurkishDeck ? 'Prompt + hazır PNG seti' : 'Prompt + GitHub PNGs',
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            'prompts/step-1-base-cafe.md dosyası AI Studio Build moduna verilir.'
                          else
                            'Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          if (isTurkishDeck)
                            '12 hazır kafe PNG görseli doğrudan GitHub Raw adreslerinden çekilir.'
                          else
                            'Loads our 12 studio cafe PNGs directly from GitHub Raw URLs.',
                          if (!isTurkishDeck) 'Targets gemini-3.5-flash-lite or gemini-3.8-flash.',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 2 · ÇALIŞAN UYGULAMA' : 'STEP 2 · LIVE APP',
                        badgeIcon: Icons.web,
                        title: isTurkishDeck ? 'Canlı web önizlemesi' : 'Full-Stack Web Preview',
                        accentColor: DeckColors.googleGreen,
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            '2 oyunculu kafe tezgahı arayüzünü ve arka uç servisini üretir.'
                          else
                            'Generates interactive 2-player cafe counter UI + backend.',
                          if (!isTurkishDeck) 'Includes 4-City Edition switcher (Berlin, Gaziantep, Adana, Istanbul).',
                          if (isTurkishDeck)
                            'Tepsileri yapılandırılmış JSON şemasıyla (CafeReview) değerlendirir.'
                          else
                            'Evaluates trays via structured JSON schema (CafeReview).',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? "ADIM 3 · KOD GITHUB'DA" : 'STEP 3 · SOURCE CONTROL',
                        badgeIcon: Icons.sync,
                        title: isTurkishDeck ? 'İki yönlü GitHub eşitleme' : 'Two-Way GitHub Sync',
                        accentColor: DeckColors.googleYellow,
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            'Tek tıkla GitHub hesabınıza aktarır, iki yönlü eşitler.'
                          else
                            'One-click export & two-way sync to your GitHub account.',
                          if (isTurkishDeck)
                            'Commit mesajlarını kendisi yazar.'
                          else
                            'Generates clean commit messages automatically.',
                          if (!isTurkishDeck) 'Full ZIP download available as an offline backup.',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 4 · CLOUD RUN' : 'STEP 4 · CLOUD RUN',
                        badgeIcon: Icons.cloud_done,
                        title: isTurkishDeck ? 'Kredi kartsız .run.app yayını' : 'No-Card .run.app Deploy',
                        accentColor: DeckColors.googleRed,
                        talkBulletFontSize: _talkBulletSize,
                        bullets: [
                          if (isTurkishDeck)
                            "Starter Tier 2 uygulamaya kadar Cloud Run'da yayınlar."
                          else
                            'Starter Tier publishes up to 2 full-stack apps to Cloud Run.',
                          if (!isTurkishDeck) 'Zero manual GCP billing setup or credit card required.',
                          if (isTurkishDeck)
                            'GEMINI_API_KEY sunucuda kalır, tarayıcıya çıkmaz.'
                          else
                            'Keeps GEMINI_API_KEY server-side inside the container.',
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isTurkishDeck) SizedBox(height: _gap),
              if (!isTurkishDeck)
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
