import 'package:backyard_barista_deck/deck_language.dart';
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
            title:
                isTurkishDeck ? '15. Sahne demoları, ödüller ve sorular' : '15. Winner Podium, Vibe Lounge Badge & Q&A',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [65:00 - 80:00] 60 saniyelik sahne demoları, ödüller, bugün ne öğrendik ve sorular.\n'
                    'SAY   "Şimdi en güzel kısım: sahne sizin. Oyununu Cloud Run\'da ya da GitHub\'da yayınlayan arkadaşları 60 saniyelik demo için sahneye davet ediyorum. Tatlıya tuz atıp 1 yıldızlı yorumu canlı gösteren en yaratıcı kafelere piksel gözlüklerimizi ve Dash hediyelerimizi veriyoruz. Bugünden aklınızda dört şey kalsın, hepsini kendi vibe coding\'inize taşıyabilirsiniz. Şakayı model yazsın, puanı kodunuz versin. Cevabı şemayla isteyin. Her AI çağrısına süre sınırı ve yedek plan koyun. Anahtar ve kota kişiye özel olsun. Yazılarım esratech.com\'da, repo ve slaytlar ekrandaki QR kodda. Enerjiniz ve oyunlarınız için çok teşekkür ederim. Şimdi sorularınızı alayım."\n'
                    'HOLD  Ödülleri verdikten sonra grup fotoğrafı. Dört maddeyi slayttan okuma, salona bakarak say, her maddeden sonra kısa dur. Soruları mikrofonda tekrar et.\n'
                    'NEXT  "Sorular ve grup fotoğrafı. Soruyu mikrofonda tekrar et."'
                : 'BEAT  [65:00 - 80:00] 60 Saniyelik Sahne Demoları, Google Piksel Gözlük + Dash Ödül Töreni, Vibe Lounge Rozeti ve Q&A.\n'
                    'SAY   "Şimdi en heyecanlı an! Oyununu Cloud Run (.run.app) veya GitHub üzerinde yayınlayan arkadaşlarımızı 60 saniyelik canlı demoları için sahneye davet ediyorum. Tatlı siparişine tuz şakası yapıp 1 yıldızlı yorumu canlı gösteren en yaratıcı kafelere 4 adet Google renkli piksel gözlüğümüzü ve Dash hediyelerimizi takdim ediyoruz! Ayrıca herkes ekrandaki goo.gle/devfest26-vibe-lounge adresinden resmi DevFest 2026 Vibe Lounge rozetini alabilir. Bugünden aklınızda tek cümle kalsın: modeli şakayı yazmak için kullanın, puanı kodunuz versin. Hepinize enerjiniz ve harika oyunlarınız için çok teşekkür ederim, şimdi sorularınızı alabiliriz!"\n'
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
          eyebrow: isTurkishDeck ? 'SAHNE DEMOLARI, ÖDÜLLER VE SORULAR' : 'SHOWCASE PODIUM, VIBE LOUNGE BADGE & Q&A',
          title: isTurkishDeck
              ? 'Teşekkürler! Kafenizi gösterin, ödülünüzü alın'
              : 'Teşekkürler! Show Us Your Cafe & Claim Your Prizes',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? '60 saniyelik canlı demolar -> Google piksel gözlükler + Dash hediyeleri -> bugün ne öğrendik'
              : '60-second live demos -> Google Pixel Sunglasses + Dash Gifts -> Official Vibe Lounge Badge',
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '1. SAHNE DEMOSU VE ÖDÜLLER' : '1. STAGE DEMO & PRIZES',
                        badgeIcon: Icons.emoji_events,
                        title: isTurkishDeck ? '60 saniyelik canlı gösteri' : '60-Second Live Showcase',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Yayındaki *.run.app adresinizi ya da GitHub reponuzu sahnede açın.'
                          else
                            'Open your deployed *.run.app URL or GitHub repo on stage.',
                          if (isTurkishDeck)
                            '2. turdaki imza tatlınızı gösterin, şeker yerine tuz atıp 1 yıldızlı laf sokmayı tetikleyin!'
                          else
                            'Show your custom Round 2 signature dish & trigger the Salt-instead-of-Sugar 1-star roast!',
                          if (isTurkishDeck)
                            '4 Google renkli piksel gözlükten (sarı, mavi, yeşil, kırmızı) birini ve Dash hediyelerini kazanın.'
                          else
                            'Win 1 of 4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) + Dash Gifts.',
                        ],
                        footerText: isTurkishDeck
                            ? "80 dk atölyede 4 kazanan / 45 dk'lık blokta 2 kazanan"
                            : '2 winners per 45-min Vibe Lounge wave / 4 winners in 80-min workshop',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: isTurkishDeck
                          ? DeckFeatureCard(
                              badge: '2. BUGÜN NE ÖĞRENDİK?',
                              badgeIcon: Icons.lightbulb,
                              title: "Kendi vibe coding'inize taşıyın",
                              accentColor: DeckColors.halftoneBlue,
                              bullets: [
                                'Şakayı model yazsın, puanı kodunuz versin.',
                                'Cevabı şemayla isteyin: düz metin değil, kodun okuduğu JSON.',
                                'Her AI çağrısına süre sınırı (timeout) ve yedek plan koyun.',
                                'Anahtar ve kota kişiye özel olsun: ortak anahtar salonu batırır.',
                              ],
                              footerText: 'Yazılar ve iletişim: esratech.com · @esrakadah',
                            )
                          : DeckFeatureCard(
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
                      caption: isTurkishDeck ? "Repo, prompt'lar ve slaytlar" : 'Repo, prompts & slides',
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
                        label: isTurkishDeck ? 'esratech.com' : '4 PIXEL SUNGLASSES + DASH GIFTS',
                        color: DeckColors.googleYellow,
                        icon: isTurkishDeck ? Icons.language : Icons.celebration,
                      ),
                      if (!isTurkishDeck)
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
