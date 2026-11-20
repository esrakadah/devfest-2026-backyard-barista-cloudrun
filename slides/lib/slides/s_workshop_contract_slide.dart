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
            title: isTurkishDeck ? '3. Üç seviye, tek canlı oyun' : '3. The Workshop Contract & Prizes',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [02:30 - 03:15] 30 dakikanın yol haritası: üç katman ve canlı QR sözü. 45 saniyeyi geçme.\n'
                    'SAY   "Bu salonda ilk uygulamasını kurmak isteyen öğrenciler de var, üretimde sistem yaşatan kıdemli mühendisler de. O yüzden konuşmayı üç katmanlı kurdum. Birincisi sıfır kurulum: tarayıcıdan AI Studio ile kredi kartsız Cloud Run yayını. İkincisi mimari: Antigravity ile çok dosyalı Flutter değişiklikleri, Flame sahnesi ve Flutter tezgahı. Üçüncüsü gerçek üretim sınırları: gecikme, token faturası, 429 kota tuzağı ve çevrimdışı yedek. Ve söz: on beşinci dakikada QR kodu okutup oyunu kendi telefonunuzdan deneyeceksiniz."\n'
                    'HOLD  Üç kartı soldan sağa elinle göster. Ayrıntıya girme, hepsi sonraki slaytlarda.\n'
                    'NEXT  "İlk katmanla başlayalım: Google AI Studio\'dan bugün tam olarak ne çıkıyor?"'
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
          eyebrow: isTurkishDeck ? '30 DAKİKADA NE GÖRECEĞİZ' : 'ZERO-EXCLUSION CONTRACT & PRIZES',
          title: isTurkishDeck
              ? 'Sıfırdan canlı oyuna: üç adım'
              : 'Three Lanes, One Finish Line: A Live URL or GitHub Repo',
          act: StoryAct.hook,
          subtitle: isTurkishDeck
              ? 'Yeni başlayan da deneyimli olan da kendine bir şey bulacak'
              : 'Every builder leaves with a deployed multiplayer AI cafe game',
          child: Column(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '1 · BAŞLANGIÇ' : 'LANE A · BROWSER DEFAULT',
                        title: isTurkishDeck ? 'Kurulum yok, tarayıcı yeter' : 'Zero-Install AI Studio',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'AI Studio: isteğini yaz, çalışan uygulamayı al.'
                          else
                            'Open aistudio.google.com -> Build mode in any browser.',
                          if (isTurkishDeck)
                            'Kredi kartı olmadan internette yayınla.'
                          else
                            'Paste step-1-base-cafe.md + load 12 base PNGs from GitHub.',
                          if (!isTurkishDeck)
                            'Click Deploy to Cloud Run (.run.app) & Sync to GitHub.',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: Starter Tier, 2 Cloud Run uygulaması'
                            : '0 installs · No credit card on Starter Tier',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '2 · ORTA' : 'LANE B · FLUTTER + ANTIGRAVITY',
                        title: isTurkishDeck ? 'Flutter ile gerçek proje' : 'Full-Stack Flutter Client',
                        bullets: [
                          if (isTurkishDeck)
                            'Antigravity: tek istekle birçok dosyayı değiştiren AI editör.'
                          else
                            'Clone devfest-2026-backyard-barista-cloudrun/flutter_client.',
                          if (isTurkishDeck)
                            'Oyun sahnesi Flame, butonlar Flutter.'
                          else
                            'Use Antigravity Agent Mode to generate custom SVG dishes.',
                          if (!isTurkishDeck)
                            'Deploy container via gcloud run deploy --source .',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: tek kod, 5 şehir sürümü'
                            : 'Pure Flutter widgets · 4 City Editions',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '3 · İLERİ' : 'LANE C · PHONE PLAY-TESTER',
                        title: isTurkishDeck ? 'Kalabalıkta çökmeyen uygulama' : 'Mobile Cafe Saboteur',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Yapay zeka geç kalırsa yedek cevap hazır.'
                          else
                            'No laptop required: join from mobile Safari or Chrome.',
                          if (isTurkishDeck)
                            '1.000 sipariş 5 sentten ucuz.'
                          else
                            'Scan deployed .run.app QR codes from the stage wall.',
                          if (!isTurkishDeck)
                            'Sneak Salt (Tuz) into sweet orders to test the AI Judge!',
                        ],
                        footerText: isTurkishDeck
                            ? 'İleri seviye: zaman aşımı, HTTP 429, çevrimdışı yedek'
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
                    const Icon(
                      isTurkishDeck ? Icons.qr_code_scanner : Icons.emoji_events,
                      color: DeckColors.googleYellow,
                      size: 42,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        isTurkishDeck
                            ? 'CANLI TEST: 15. dakikada QR kodu okutun, tatlı siparişe gizlice tuz atın!'
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
