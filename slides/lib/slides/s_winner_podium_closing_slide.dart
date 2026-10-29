import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class WinnerPodiumClosingSlide extends FlutterDeckSlideWidget {
  const WinnerPodiumClosingSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/winner-podium-closing',
            title: '16. Winner Podium, Vibe Lounge Badge & Q&A',
            speakerNotes:
                'BEAT  [65:00 - 80:00] 60 Saniyelik Sahne Demoları, Google Piksel Gözlük + Dash Ödül Töreni, Vibe Lounge Rozeti ve Q&A.\n'
                'SAY   "Şimdi en heyecanlı an! Oyununu Cloud Run (.run.app) veya GitHub üzerinde yayınlayan arkadaşlarımızı 60 saniyelik canlı demoları için sahneye davet ediyorum. Tatlı siparişine tuz şakası yapıp 1 yıldızlı yorumu canlı gösteren en yaratıcı kafelere 4 adet Google renkli piksel gözlüğümüzü ve Dash hediyelerimizi takdim ediyoruz! Ayrıca herkes ekrandaki goo.gle/devfest26-vibe-lounge adresinden resmi DevFest 2026 Vibe Lounge rozetini alabilir. Hepinize enerjiniz ve harika oyunlarınız için çok teşekkür ederim, şimdi sorularınızı alabiliriz!"\n'
                'HOLD  Kazananlara gözlüklerini takdim ettikten sonra tüm salonla birlikte gözlükleri takıp büyük bir grup fotoğrafı çek. Ardından Q&A sorularını mikrofonda tekrar ederek yanıtla.\n'
                'NEXT  "Q&A ve grup fotoğrafı. Soruları mikrofonda tekrar et."',
            footer: FlutterDeckFooterConfiguration(showFooter: false),
          ),
        );

  static const double _gap = 24;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SHOWCASE PODIUM, VIBE LOUNGE BADGE & Q&A',
          title: 'Teşekkürler! Show Us Your Cafe & Claim Your Prizes',
          act: StoryAct.buildAndShip,
          subtitle: '60-second live demos -> Google Pixel Sunglasses + Dash Gifts -> Official Vibe Lounge Badge',
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: '1. STAGE DEMO & PRIZES',
                        badgeIcon: Icons.emoji_events,
                        title: '60-Second Live Showcase',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'Open your deployed *.run.app URL or GitHub repo on stage.',
                          'Show your custom Round 2 signature dish & trigger the Salt-instead-of-Sugar 1-star roast!',
                          'Win 1 of 4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) + Dash Gifts.',
                        ],
                        footerText: '2 winners per 45-min Vibe Lounge wave / 4 winners in 80-min workshop',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: '2. CLAIM BADGE & STAY IN TOUCH',
                        badgeIcon: Icons.verified,
                        title: 'Official Badge & Starter Repo',
                        accentColor: DeckColors.halftoneBlue,
                        bullets: [
                          'Claim your DevFest 2026 Vibe Lounge Badge: goo.gle/devfest26-vibe-lounge',
                          'Starter Repo & Slides: github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                          'Speaker: Esra Kadah · Tech Lead, Senior Flutter & AI Engineer · @esrakadah · esra.tech',
                          'Google Developer Expert, Flutter & Dart · Does not speak for Google',
                        ],
                        footerText: "Questions? Let's talk Cloud Run, Firebase AI Logic & Flutter!",
                      ),
                    ),
                    SizedBox(width: _gap),
                    QrCodeCard(
                      assetPath: 'assets/images/starter_repo_qr.png',
                      caption: 'Repo, prompts & slides',
                      url: 'github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                      size: 300,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GdeBadgeStrip(),
                  Wrap(
                    spacing: 12,
                    children: [
                      PillTag(
                        label: '4 PIXEL SUNGLASSES + DASH GIFTS',
                        color: DeckColors.googleYellow,
                        icon: Icons.celebration,
                      ),
                      PillTag(
                        label: 'goo.gle/devfest26-vibe-lounge',
                        color: DeckColors.googleGreen,
                        icon: Icons.qr_code_2,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
