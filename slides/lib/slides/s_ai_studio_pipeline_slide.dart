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
                ? 'BEAT  [05:00 - 07:30] "AI Studio\'dan ne çıkar?" sorusunun somut cevabı.\n'
                    'SAY   "AI Studio artık sadece prompt denediğimiz bir ekran değil. Mustafa ile konuşurken en çok bunu sorduk: bugün tam olarak ne çıkıyor? Build modu size çalışan bir web uygulaması üretiyor. Kodu GitHub ile iki yönlü eşitliyor. Starter Tier\'da, kredi kartı ve fatura hesabı açmadan, 2 uygulamaya kadar tek tıkla Cloud Run\'da canlı bir .run.app adresine yayınlıyor. Bir uyarı: eski Firebase Studio kapanıyor ve yeni kayıt almıyor. Doğru adres Google AI Studio ve Google Antigravity."\n'
                    "HOLD  Slayttaki 4 adımı soldan sağa göster, her adımda bir nefes. [Olgu (Ekim 2026, ai.google.dev): Starter Tier = 2 Cloud Run uygulaması; Firebase Studio kayıtları 22 Haziran 2026'da kapandı, Mart 2027'de tamamen kapanıyor].\n"
                    'NEXT  "Peki çok dosyalı Flutter tarafında Google Antigravity bize ne kazandırıyor?"'
                : 'BEAT  [05:00 - 07:30] "AI Studio\'dan ne gelir?" sorusunun somut cevabı.\n'
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
          eyebrow: isTurkishDeck ? 'GOOGLE AI STUDIO BUILD MODU (EKİM 2026)' : 'GOOGLE AI STUDIO BUILD MODE (OCT 2026)',
          title: isTurkishDeck ? "Google AI Studio'dan bugün ne çıkıyor?" : 'What Comes Out of Google AI Studio Today?',
          act: StoryAct.tools,
          subtitle: isTurkishDeck
              ? 'İlk prompttan canlı bir Cloud Run (*.run.app) servisine tek tıkla'
              : 'From seed prompt to a live Google Cloud Run (*.run.app) service in one click',
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
                        badge: isTurkishDeck ? 'ADIM 1 · PROMPT + GÖRSELLER' : 'STEP 1 · SEED + ASSETS',
                        badgeIcon: Icons.description,
                        title: isTurkishDeck ? "Prompt + GitHub PNG'leri" : 'Prompt + GitHub PNGs',
                        bullets: [
                          if (isTurkishDeck)
                            'prompts/step-1-base-cafe.md dosyasını Build moduna yapıştırın.'
                          else
                            'Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          if (isTurkishDeck)
                            '12 kafe görseli GitHub Raw adresinden kendiliğinden yüklenir.'
                          else
                            'Loads our 12 studio cafe PNGs directly from GitHub Raw URLs.',
                          if (isTurkishDeck)
                            'Model: gemini-3.5-flash-lite ya da gemini-3.8-flash.'
                          else
                            'Targets gemini-3.5-flash-lite or gemini-3.8-flash.',
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
                        bullets: [
                          if (isTurkishDeck)
                            'İki oyunculu kafe tezgahını ve arka ucunu üretir.'
                          else
                            'Generates interactive 2-player cafe counter UI + backend.',
                          if (isTurkishDeck)
                            '4 şehir sürümü arasında geçiş: Berlin, Gaziantep, Adana, İstanbul.'
                          else
                            'Includes 4-City Edition switcher (Berlin, Gaziantep, Adana, Istanbul).',
                          if (isTurkishDeck)
                            'Tepsiyi JSON şemasıyla (CafeReview) değerlendirir.'
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
                        bullets: [
                          if (isTurkishDeck)
                            'Tek tıkla GitHub hesabınıza aktarır, iki yönlü eşitler.'
                          else
                            'One-click export & two-way sync to your GitHub account.',
                          if (isTurkishDeck)
                            'Commit mesajlarını kendisi yazar.'
                          else
                            'Generates clean commit messages automatically.',
                          if (isTurkishDeck)
                            'Yedek olarak ZIP indirebilirsiniz.'
                          else
                            'Full ZIP download available as an offline backup.',
                        ],
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 4 · CLOUD RUN' : 'STEP 4 · CLOUD RUN',
                        badgeIcon: Icons.cloud_done,
                        title: isTurkishDeck ? 'Kartsız .run.app yayını' : 'No-Card .run.app Deploy',
                        accentColor: DeckColors.googleRed,
                        bullets: [
                          if (isTurkishDeck)
                            "Starter Tier 2 uygulamaya kadar Cloud Run'da yayınlar."
                          else
                            'Starter Tier publishes up to 2 full-stack apps to Cloud Run.',
                          if (isTurkishDeck)
                            'Fatura hesabı ya da kredi kartı gerekmez.'
                          else
                            'Zero manual GCP billing setup or credit card required.',
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
                        isTurkishDeck
                            ? "DOĞRULANDI (2026): Eski Firebase Studio (Project IDX) 22 Haziran 2026'da yeni kayıtları kapattı, Mart 2027'de kapanıyor. Tarayıcı için Google AI Studio (Yol A), IDE için Google Antigravity (Yol B) kullanın."
                            : 'VERIFIED 2026 GUARDRAIL: Legacy Firebase Studio (Project IDX) disabled new sign-ups on 22 June 2026 ahead of its March 2027 sunset. Use Google AI Studio (Browser Lane A) and Google Antigravity (IDE Lane B).',
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
