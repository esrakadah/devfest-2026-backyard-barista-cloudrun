import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class TitleSlide extends FlutterDeckSlideWidget {
  const TitleSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/title',
            title: '1. Backyard Barista on Cloud Run',
            speakerNotes:
                'BEAT  [00:00 - 02:00] Enerjik Açılış ve Sözleşme. Salonu selamla, iki cümlelik GDE girişini yap ve herkesin bugün çalışan bir oyunla çıkacağını ilan et.\n'
                'SAY   "Ben Esra Kadah, Berlin\'de Antigua Mobile\'da Senior Flutter ve AI Engineer olarak çalışıyorum ve Flutter ile Dart alanında Google Developer Expert\'im. Önümüzdeki oturumda size sadece slayt göstermeyeceğim: Google AI Studio, Antigravity ve Flutter ile çok oyunculu bir AI kafe oyununu Google Cloud Run üzerinde canlıya alacağız ve gerçek rakamları konuşacağız."\n'
                'HOLD  İlk iki cümleyi ekrana bakmadan, doğrudan salonun gözlerinin içine bakarak söyle. "Google adına değil, sahadaki bir mühendis olarak" vurgusunu net tut.\n'
                'NEXT  "Peki bugün bu salondan kim, ne kazanarak çıkacak? Hemen kurallarımıza ve ödüllerimize bakalım."',
            footer: FlutterDeckFooterConfiguration(showFooter: false),
          ),
        );

  static const double _outerHorizontalPadding = 88;
  static const double _outerVerticalPadding = 56;
  static const double _gap = 18;
  static const double _largeGap = 28;
  static const double _badgeSpacing = 12;
  static const double _photoSize = 260;
  static const double _photoRadius = 28;
  static const double _cardPadding = 22;
  static const double _cardRadius = 20;

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
                      children: [
                        DeckBadge(label: '🇩🇪 Berlin · 14 Nov'),
                        DeckBadge(label: '🇹🇷 Gaziantep · 15 Nov', color: DeckColors.googleRed),
                        DeckBadge(label: '🇹🇷 Adana · 11 Dec', color: DeckColors.googleGreen),
                        DeckBadge(label: '🇹🇷 Istanbul · 19 Dec', color: DeckColors.halftoneBlue),
                      ],
                    ),
                    const SizedBox(height: _largeGap),
                    Text(
                      'Backyard Barista on Cloud Run',
                      style: textTheme.display,
                    ),
                    const SizedBox(height: _gap),
                    Text(
                      'Build & Ship a Multiplayer AI Cafe Game with AI Studio, Antigravity & Flutter',
                      style: textTheme.subtitle,
                    ),
                    const SizedBox(height: _gap),
                    Text(
                      'TR: AI Studio, Antigravity ve Flutter ile Kendi AI Kafe Oyununu Canlıya Al (Tatlı mı Tuzlu mu?)',
                      style: textTheme.bodyLarge.copyWith(color: DeckColors.halftoneYellow),
                    ),
                    const SizedBox(height: _largeGap),
                    Container(
                      padding: const EdgeInsets.all(_cardPadding),
                      decoration: BoxDecoration(
                        color: DeckColors.surface,
                        borderRadius: BorderRadius.circular(_cardRadius),
                        border: Border.all(color: DeckColors.googleBlue),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starter Repo & Prompts: github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                            style: TextStyle(
                              fontFamily: DeckFonts.mono,
                              fontSize: DeckTypeScale.code,
                              fontWeight: FontWeight.w700,
                              color: DeckColors.offWhite,
                            ),
                          ),
                          SizedBox(height: 8),
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
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      'Google Developer Expert, Flutter & Dart',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium.copyWith(color: DeckColors.halftoneBlue),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Senior Flutter & AI Engineer · Antigua Mobile Berlin',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Google Developer Expert, does not speak for Google',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall.copyWith(color: DeckColors.mutedText),
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
