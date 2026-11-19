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
            title: isTurkishDeck ? '15. Üretime çıkan AI için 4 kural' : '15. Winner Podium, Vibe Lounge Badge & Q&A',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [27:00 - 28:15] Eve götürülecek dört kural ve açık kaynak repo daveti.\n'
                    'SAY   "Eve götürmenizi istediğim dört kural var. Bir: her yapay zeka çağrısına bir zaman aşımı ve bir yedek koyun; salonun Wi-Fi\'ı gittiğinde arayüzünüz donmasın. İki: API anahtarını tarayıcıya gömmeyin, sunucuda tutun. Üç: şema bir istektir, garanti değil; modelden her zaman şemalı JSON isteyin ama gelen cevaba körü körüne güvenmeyin. Dört, en önemlisi: şakayı model yazsın, kararı kodunuz versin. Bu dört kuralın hepsi repoda, testleriyle birlikte duruyor. Kodlar ve slaytlar açık kaynak; sağdaki QR kodda sizi bekliyor."\n'
                    'HOLD  Dört kuralı slayttan okuma, salona bakarak tane tane say. "Şakayı model yazsın, kararı kodunuz versin" cümlesinden sonra yarım saniye dur.\n'
                    'NEXT  "Ve son olarak: bana nasıl ulaşırsınız?"'
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
          eyebrow:
              isTurkishDeck ? 'EVE GÖTÜRÜLECEK DERSLER VE AÇIK KAYNAK KOD' : 'SHOWCASE PODIUM, VIBE LOUNGE BADGE & Q&A',
          title: isTurkishDeck
              ? 'Üretime çıkan AI uygulamaları için 4 kural'
              : 'Teşekkürler! Show Us Your Cafe & Claim Your Prizes',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? 'Şakayı model yazsın; sınırı ve son kararı kodunuz versin'
              : '60-second live demos -> Google Pixel Sunglasses + Dash Gifts -> Official Vibe Lounge Badge',
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '4 MÜHENDİSLİK KURALI' : '1. STAGE DEMO & PRIZES',
                        badgeIcon: isTurkishDeck ? Icons.lightbulb : Icons.emoji_events,
                        title: isTurkishDeck ? 'Pazartesi kendi projenize taşıyın' : '60-Second Live Showcase',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Her çağrıya zaman aşımı ve yedek: 8 sn, 15 sn, 250 ms. 429 testi yedeğe düşer.'
                          else
                            'Open your deployed *.run.app URL or GitHub repo on stage.',
                          if (isTurkishDeck)
                            'Anahtar sunucuda: nginx ekler, web paketinde yok (anahtarsız istek testi).'
                          else
                            'Show your custom Round 2 signature dish & trigger the Salt-instead-of-Sugar 1-star roast!',
                          if (isTurkishDeck)
                            'Şema istektir, garanti değil: boş yanıt tuzlu tepsiye 5 yıldız veremez (testli).'
                          else
                            'Win 1 of 4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) + Dash Gifts.',
                          if (isTurkishDeck) 'Şakayı model yazsın, kararı kodunuz versin: _verdictMatchesPranks, 2 testle sabit.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kural: AI çıktısı her zaman güvenilmeyen dış girdidir'
                            : '2 winners per 45-min Vibe Lounge wave / 4 winners in 80-min workshop',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: isTurkishDeck
                          ? DeckFeatureCard(
                              badge: 'KOD, SLAYTLAR VE YAZILAR',
                              badgeIcon: Icons.code,
                              title: 'Klonlayın, kurcalayın, kendi şehrinizi ekleyin',
                              accentColor: DeckColors.halftoneBlue,
                              bullets: [
                                'Tam kaynak kod ve prompt seti: github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                                'Web slaytları: esrakadah.github.io/devfest-2026-backyard-barista-cloudrun',
                                'Canlı oyun: backyard-barista-389486729482.europe-west3.run.app/?remote_city=konya',
                                'Teknik yazılar ve iletişim: esratech.com · @esrakadah',
                              ],
                              footerText: 'Sorular ve sohbet için konuşma sonrası fuayede buluşalım!',
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
                      caption: isTurkishDeck ? 'Açık kaynak repo ve slaytlar' : 'Repo, prompts & slides',
                      url: 'github.com/esrakadah/devfest-2026-backyard-barista-cloudrun',
                      size: 380,
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
                      if (isTurkishDeck)
                        PillTag(
                          label: isIzmirDeck ? 'DevFest İzmir 2026' : 'DevFest Konya 2026',
                          color: DeckColors.googleGreen,
                          icon: Icons.location_on,
                        )
                      else
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
