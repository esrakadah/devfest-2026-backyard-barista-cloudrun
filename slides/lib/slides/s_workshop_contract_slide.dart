import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class WorkshopContractSlide extends FlutterDeckSlideWidget {
  const WorkshopContractSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/workshop-contract',
            title: isTurkishDeck ? '3. Atölye anlaşması ve ödüller' : '3. The Workshop Contract & Prizes',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [03:30 - 05:00] Üç yol (A, B, C) ve ödüller. Kimsenin dışarıda kalmayacağını söyle.\n'
                    'SAY   "Bugün kimse sadece izleyici kalmayacak. Üç yolumuz var. Yol A: bilgisayarınızda hiçbir kurulum yoksa tarayıcıda Google AI Studio ile oyunu kurup Cloud Run\'da yayınlıyorsunuz, kredi kartı gerekmiyor. Yol B: Flutter ve Antigravity kuruluysa başlangıç reposundan ilerliyorsunuz. Yol C: sadece telefonunuz varsa sahnedeki QR kodları okutup arkadaşlarınızın kafesini test ediyorsunuz. Oyununu yayınlayıp sahnede 60 saniyede gösterenlere ödülümüz var: Google renkli piksel gözlükler ve Dash hediyeleri."\n'
                    'HOLD  Gözlükleri ve Dash oyuncaklarını elinde göster. Slayt 4 gözlük diyor: sahneye çıkmadan yanındakileri say, sayı farklıysa gerçek sayıyı söyle.\n'
                    'NEXT  "Önce en çok sorulan soru: Google AI Studio\'dan bugün tam olarak ne çıkıyor?"'
                : 'BEAT  [03:30 - 05:00] Üç Kulvar (Lane A, B, C) ve Ödül Sözleşmesi. Salondaki hiç kimsenin dışarıda kalmayacağını garanti et.\n'
                    'SAY   "Bugünkü anlaşmamız çok net: bu salondaki hiç kimse sadece izleyici olarak kalmayacak. Bilgisayarında hiçbir kurulum olmayanlar Yol A ile doğrudan tarayıcıda Google AI Studio üzerinden oyununu kurup kredi kartı gerekmeden Cloud Run üzerinde canlıya alacak. Bilgisayarında Flutter ve Antigravity yüklü olanlar Yol B ile başlangıç repomuzdan ilerleyecek. Sadece telefonuyla katılanlar bile Yol C ile sahnedeki QR kodları okutup arkadaşlarının kafelerinde şaka malzemelerini test edecek. Ve en güzeli: oyununu canlıya alıp sahnede 60 saniyede gösteren katılımcılarımıza yanımızda getirdiğimiz 4 adet Google renkli piksel gözlüğü ve Dash ödüllerini hediye ediyoruz!"\n'
                    'HOLD  Piksel gözlükleri ve Dash oyuncaklarını eline alıp salona göster. Enerjiyi yükselt.\n'
                    'NEXT  "Önce en çok sorulan soruya net bir yanıt verelim: Google AI Studio\'dan bugün tam olarak ne çıkıyor?"',
          ),
        );

  static const double _columnGap = 24;
  static const double _bannerGap = 24;
  static const double _bannerPadding = 22;
  static const double _bannerRadius = 18;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        final textTheme = FlutterDeckTheme.of(context).textTheme;
        return SlideFrame(
          eyebrow: isTurkishDeck ? 'KİMSE DIŞARIDA KALMIYOR · ÖDÜLLER' : 'ZERO-EXCLUSION CONTRACT & PRIZES',
          title: isTurkishDeck
              ? 'Üç yol, tek hedef: canlı bir link ya da GitHub reposu'
              : 'Three Lanes, One Finish Line: A Live URL or GitHub Repo',
          act: StoryAct.hook,
          subtitle: isTurkishDeck
              ? 'Hedef: herkes yayında çalışan bir AI kafe oyunuyla çıksın'
              : 'Every builder leaves with a deployed multiplayer AI cafe game',
          child: Column(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'YOL A · TARAYICI' : 'LANE A · BROWSER DEFAULT',
                        title: isTurkishDeck ? 'Kurulumsuz: AI Studio' : 'Zero-Install AI Studio',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'Tarayıcıda aistudio.google.com -> Build modunu açın.'
                          else
                            'Open aistudio.google.com -> Build mode in any browser.',
                          if (isTurkishDeck)
                            "step-1-base-cafe.md promptunu yapıştırın, 12 hazır PNG GitHub'dan gelir."
                          else
                            'Paste step-1-base-cafe.md + load 12 base PNGs from GitHub.',
                          if (isTurkishDeck)
                            "Deploy to Cloud Run (.run.app) ve Sync to GitHub'a tıklayın."
                          else
                            'Click Deploy to Cloud Run (.run.app) & Sync to GitHub.',
                        ],
                        footerText: isTurkishDeck
                            ? "0 kurulum · Starter Tier'da kredi kartı yok"
                            : '0 installs · No credit card on Starter Tier',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'YOL B · FLUTTER + ANTIGRAVITY' : 'LANE B · FLUTTER + ANTIGRAVITY',
                        title: isTurkishDeck ? 'Flutter ile tam uygulama' : 'Full-Stack Flutter Client',
                        bullets: [
                          if (isTurkishDeck)
                            'devfest-2026-backyard-barista-cloudrun/flutter_client klasörünü klonlayın.'
                          else
                            'Clone devfest-2026-backyard-barista-cloudrun/flutter_client.',
                          if (isTurkishDeck)
                            'Antigravity Agent Mode ile kendi SVG tatlınızı ürettirin.'
                          else
                            'Use Antigravity Agent Mode to generate custom SVG dishes.',
                          if (isTurkishDeck)
                            'gcloud run deploy --source . ile yayınlayın.'
                          else
                            'Deploy container via gcloud run deploy --source .',
                        ],
                        footerText: isTurkishDeck
                            ? "Saf Flutter widget'ları · 4 şehir sürümü"
                            : 'Pure Flutter widgets · 4 City Editions',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'YOL C · TELEFONLA TEST' : 'LANE C · PHONE PLAY-TESTER',
                        title: isTurkishDeck ? 'Telefondan kafe sabotajcısı' : 'Mobile Cafe Saboteur',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Laptop gerekmez: telefonda Safari ya da Chrome yeter.'
                          else
                            'No laptop required: join from mobile Safari or Chrome.',
                          if (isTurkishDeck)
                            'Sahnedeki .run.app QR kodlarını okutun.'
                          else
                            'Scan deployed .run.app QR codes from the stage wall.',
                          if (isTurkishDeck)
                            'Tatlı siparişe gizlice tuz atın, AI jüri yakalıyor mu görün!'
                          else
                            'Sneak Salt (Tuz) into sweet orders to test the AI Judge!',
                        ],
                        footerText: isTurkishDeck
                            ? '<620px: telefonda 2 sütunlu tezgah'
                            : '<620px responsive 2-column mobile counter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _bannerGap),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(_bannerPadding),
                decoration: BoxDecoration(
                  color: DeckColors.surface,
                  borderRadius: BorderRadius.circular(_bannerRadius),
                  border: Border.all(color: DeckColors.googleYellow, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: DeckColors.googleYellow, size: 42),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        isTurkishDeck
                            ? 'SAHNE ÖDÜLLERİ: Oyununu yayınlayıp (.run.app / GitHub) 60 saniyede gösterenlere 4 Google renkli piksel gözlük (sarı, mavi, yeşil, kırmızı) ve Dash hediyeleri!'
                            : 'STAGE PRIZES: 4 Google-Colored Pixel Sunglasses (Yellow, Blue, Green, Red) + Dash Gifts for builders who publish (.run.app / GitHub) & demo in 60 seconds!',
                        style: textTheme.bodyLarge.copyWith(
                          color: DeckColors.googleYellow,
                          fontWeight: FontWeight.w700,
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
