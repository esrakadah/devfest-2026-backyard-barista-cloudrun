import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class TitleSlide extends FlutterDeckSlideWidget {
  const TitleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/title',
            title: isTurkishDeck ? "1. Cloud Run'da Backyard Barista" : '1. Backyard Barista on Cloud Run',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [00:00 - 02:00] Açılış ve söz. Salonu selamla, kendini iki cümleyle tanıt, bugünün hedefini söyle.\n'
                    'SAY   "Bugünkü hedefimiz: bu salondan herkes çalışan bir oyunla çıksın. Ben Esra Kadah. Berlin\'de Antigua Mobile\'da Tech Lead olarak çalışıyorum, Flutter ve Dart alanında Google Developer Expert\'im. Çoğunuz Gemini ya da Claude ile bir şeyler denemişsinizdir, yani vibe coding yapmışsınızdır. Bugün bir adım öteye gidiyoruz: AI Studio (Google\'ın tarayıcıdaki AI uygulama atölyesi), Antigravity (AI ajanlı kod editörü) ve Flutter ile çok oyunculu bir AI kafe oyunu kurup Cloud Run\'da (Google\'ın sunucusuz uygulama barındırma servisi) yayınlayacağız. Rakamları da açık açık konuşacağız. Söylediklerim kendi görüşlerim, Google adına konuşmuyorum."\n'
                    'HOLD  İlk cümleyi ekrana değil salona bakarak söyle, sonra 2 saniye sus. "Eee, şey" yerine nefes al. Slayttaki rakamlar [ÖLÇÜLDÜ] ya da koddan; "herkes oyunla çıksın" ise [HEDEF], olmuş gibi söyleme.\n'
                    'NEXT  "Ama önce küçük bir oyun oynayalım."'
                : 'BEAT  [00:00 - 02:00] Enerjik Açılış ve Sözleşme. Salonu selamla, iki cümlelik GDE girişini yap ve herkesin bugün çalışan bir oyunla çıkacağını ilan et.\n'
                    'SAY   "Ben Esra Kadah, Berlin\'de Antigua Mobile\'da Tech Lead, Senior Flutter ve AI Engineer olarak çalışıyorum ve Flutter ile Dart alanında Google Developer Expert\'im. Önümüzdeki oturumda size sadece slayt göstermeyeceğim: Google AI Studio, Antigravity ve Flutter ile çok oyunculu bir AI kafe oyununu Google Cloud Run üzerinde canlıya alacağız ve gerçek rakamları konuşacağız. Söyleyeceklerim kendi görüşlerim, Google adına konuşmuyorum."\n'
                    'HOLD  İlk iki cümleyi ekrana bakmadan, doğrudan salonun gözlerinin içine bakarak söyle. "Google adına değil, sahadaki bir mühendis olarak" vurgusunu net tut.\n'
                    'NEXT  "Ama önce sizinle küçük bir oyun oynayalım."',
            footer: FlutterDeckFooterConfiguration(showFooter: false),
          ),
        );

  static const double _outerHorizontalPadding = 80;
  static const double _outerVerticalPadding = 44;
  static const double _gap = 16;
  static const double _largeGap = 24;
  static const double _badgeSpacing = 12;
  static const double _photoSize = 230;
  static const double _photoRadius = 26;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        final textTheme = FlutterDeckTheme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _outerHorizontalPadding,
            vertical: _outerVerticalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: _badgeSpacing,
                      runSpacing: _badgeSpacing,
                      children: isTurkishDeck
                          ? <Widget>[
                              DeckBadge(
                                label: 'DEVFEST GAZİANTEP 2026',
                                color: DeckColors.googleRed,
                                icon: Icons.location_on,
                              ),
                              DeckBadge(
                                label: '15 KASIM · ATÖLYE',
                                icon: Icons.build,
                              ),
                            ]
                          : <Widget>[
                              DeckBadge(
                                label: 'EN · Berlin · 14 Nov',
                                icon: Icons.location_on,
                              ),
                              DeckBadge(
                                label: 'TR · Gaziantep · 15 Nov',
                                color: DeckColors.googleRed,
                                icon: Icons.location_on,
                              ),
                              DeckBadge(
                                label: 'TR · Adana · 11 Dec',
                                color: DeckColors.googleGreen,
                                icon: Icons.location_on,
                              ),
                              DeckBadge(
                                label: 'TR · Istanbul · 19 Dec',
                                color: DeckColors.halftoneBlue,
                                icon: Icons.location_on,
                              ),
                            ],
                    ),
                    const SizedBox(height: _largeGap),
                    Text(
                      isTurkishDeck ? 'Backyard Barista\non Cloud Run' : 'Backyard Barista on Cloud Run',
                      style: textTheme.display,
                    ),
                    const SizedBox(height: _gap),
                    Text(
                      isTurkishDeck
                          ? 'AI Studio, Antigravity ve Flutter ile çok oyunculu bir AI kafe oyunu kurun ve canlıya alın'
                          : 'Build & Ship a Multiplayer AI Cafe Game with AI Studio, Antigravity & Flutter',
                      style: textTheme.subtitle,
                    ),
                    const SizedBox(height: _gap),
                    Text(
                      isTurkishDeck
                          ? 'Tatlı mı, tuzlu mu? Kararı Gemini verecek.'
                          : 'TR: AI Studio, Antigravity ve Flutter ile Kendi AI Kafe Oyununu Canlıya Al (Tatlı mı Tuzlu mu?)',
                      style: textTheme.bodyLarge.copyWith(color: DeckColors.googleYellow),
                    ),
                    const SizedBox(height: _largeGap),
                    const Wrap(
                      spacing: 14,
                      runSpacing: 12,
                      children: [
                        StatChip(
                          value: isTurkishDeck ? '53,81 ms' : '53.81 ms',
                          label: isTurkishDeck ? 'STATİK SAYFA P50 · ÖLÇÜLDÜ' : 'Static Page p50 Warm',
                          accentColor: DeckColors.googleGreen,
                        ),
                        StatChip(
                          value: '~270 tok',
                          label: isTurkishDeck ? 'SİPARİŞ BAŞINA 1 JSON ÇAĞRISI' : '1 JSON Call / Order',
                        ),
                        StatChip(
                          value: isTurkishDeck ? '60fps hedefi + NFC' : '60fps + NFC',
                          label: isTurkishDeck ? 'FLAME 3 ŞERİT · NDEFREADER' : 'Flame 3-Lane · NDEFReader',
                          accentColor: DeckColors.googleYellow,
                        ),
                        StatChip(
                          value: isTurkishDeck ? '4 şehir sürümü' : '4 City Editions',
                          label: isTurkishDeck ? 'REMOTE CONFIG İLE' : 'Remote Config + GDE Tour',
                          accentColor: DeckColors.halftonePink,
                        ),
                      ],
                    ),
                    const SizedBox(height: _gap),
                    const DeckCard(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      backgroundColor: DeckColors.surfaceInset,
                      borderColor: DeckColors.outlineLight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTurkishDeck
                                ? "Repo ve prompt'lar: github.com/esrakadah/devfest-2026-backyard-barista-cloudrun"
                                : 'Starter Repo & Prompts: github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                            style: TextStyle(
                              fontFamily: DeckFonts.mono,
                              fontSize: DeckTypeScale.code,
                              fontWeight: FontWeight.w700,
                              color: DeckColors.offWhite,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Topics: ai/ai-dev-tools/ai-studio · cloud/serverless-containers/cloud-run · firebase/monitoring/remote-config',
                            style: TextStyle(
                              fontFamily: DeckFonts.mono,
                              fontSize: DeckTypeScale.bodySmall,
                              color: DeckColors.halftoneBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 36),
              Expanded(
                flex: 3,
                child: DeckCard(
                  backgroundColor: DeckColors.surfaceElevated,
                  borderColor: DeckColors.outlineLight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_photoRadius),
                        child: Image.asset(
                          'assets/images/esra.png',
                          width: _photoSize,
                          height: _photoSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: _gap),
                      Text('Esra Kadah', style: textTheme.title),
                      const SizedBox(height: 6),
                      Text(
                        'Tech Lead, Senior Flutter & AI Engineer · Antigua Mobile Berlin',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall.copyWith(color: DeckColors.offWhite),
                      ),
                      const SizedBox(height: 16),
                      const GdeBadgeStrip(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
