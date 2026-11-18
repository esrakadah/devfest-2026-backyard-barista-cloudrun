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
                ? 'BEAT  [02:30 - 03:15] 30 dakikanın yol haritası: başlangıç, orta ve ileri seviye için ne var + canlı QR sözü.\n'
                    'SAY   "Bu salonda hem ilk uygulamasını kurmak isteyen öğrenci arkadaşlar hem de üretimde sistem yaşatan kıdemli mühendisler var; konuşmayı üç katmanlı kurdum. Birinci katman sıfır kurulum: tarayıcıda Google AI Studio Build modundan GitHub\'a ve kredi kartsız Cloud Run yayınına nasıl çıkılır. İkinci katman mimari: Google Antigravity ile tek seferde çok dosyalı Flutter değişiklikleri ve neden sahneyi Flame oyun motoruyla, tezgahı ise saf Flutter widget\'larıyla ayırdığımız. Üçüncü katman gerçek üretim sınırları: gecikme, token faturası, 429 kota tuzağı ve çevrimdışı yerel Gemma yedeği. Ve söz veriyorum: konuşmanın son bölümünde QR kodu okutup bu oyunu kendi telefonunuzdan canlı test edeceksiniz."\n'
                    'HOLD  Üç kartı soldan sağa elinle göster, 45 saniyeyi geçirme; asıl et bir sonraki slaytta başlıyor.\n'
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
          eyebrow: isTurkishDeck ? '30 DAKİKALIK YOL HARİTASI · 3 KATMAN' : 'ZERO-EXCLUSION CONTRACT & PRIZES',
          title: isTurkishDeck
              ? 'Üç farklı deneyim seviyesi, tek canlı oyun'
              : 'Three Lanes, One Finish Line: A Live URL or GitHub Repo',
          act: StoryAct.hook,
          subtitle: isTurkishDeck
              ? 'İlk prompttan üretime dayanıklı bulut mimarisine ve salonda canlı QR testine'
              : 'Every builder leaves with a deployed multiplayer AI cafe game',
          child: Column(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '1 · HIZLI PROTOTİP' : 'LANE A · BROWSER DEFAULT',
                        title: isTurkishDeck ? 'Kurulumsuz: AI Studio' : 'Zero-Install AI Studio',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'Tarayıcıda aistudio.google.com -> Build modu ile tek prompttan çalışan web uygulaması.'
                          else
                            'Open aistudio.google.com -> Build mode in any browser.',
                          if (isTurkishDeck)
                            'Çift yönlü GitHub senkronizasyonu ve sunucu tarafında gizli API anahtarı.'
                          else
                            'Paste step-1-base-cafe.md + load 12 base PNGs from GitHub.',
                          if (isTurkishDeck)
                            'Starter Tier ile kredi kartı gerekmeden 2 adede kadar canlı .run.app yayını.'
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
                        badge: isTurkishDeck ? '2 · ÇOK DOSYALI MİMARİ' : 'LANE B · FLUTTER + ANTIGRAVITY',
                        title: isTurkishDeck ? 'Flutter + Antigravity' : 'Full-Stack Flutter Client',
                        bullets: [
                          if (isTurkishDeck)
                            'Antigravity Agent Mode ile katalog, çizim kodu ve testleri tek seferde güncelleme.'
                          else
                            'Clone devfest-2026-backyard-barista-cloudrun/flutter_client.',
                          if (isTurkishDeck)
                            'Arka planda Flame 3 şeritli sahne, önde 2x2 reaktif Flutter widget tezgahı.'
                          else
                            'Use Antigravity Agent Mode to generate custom SVG dishes.',
                          if (isTurkishDeck)
                            '3 katmanlı CityEditionController ile yeniden derlemeden 5 DevFest şehri.'
                          else
                            'Deploy container via gcloud run deploy --source .',
                        ],
                        footerText: isTurkishDeck
                            ? 'Flame + Flutter HUD · 5 şehir sürümü'
                            : 'Pure Flutter widgets · 4 City Editions',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '3 · GERÇEK RAKAMLAR' : 'LANE C · PHONE PLAY-TESTER',
                        title: isTurkishDeck ? 'Üretim korumaları + QR' : 'Mobile Cafe Saboteur',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            '8 sn canlı Gemini sınırı, 15 sn yerel Gemma 4 ve 250 ms çevrimdışı paket yedeği.'
                          else
                            'No laptop required: join from mobile Safari or Chrome.',
                          if (isTurkishDeck)
                            'Sipariş başına tek JSON çağrısı (~270 token) ve 1.000 siparişte 5 sentin altı.'
                          else
                            'Scan deployed .run.app QR codes from the stage wall.',
                          if (isTurkishDeck)
                            'Kalabalık salonda HTTP 429 savunması: birazdan telefonunuzdan bizzat deneyeceksiniz.'
                          else
                            'Sneak Salt (Tuz) into sweet orders to test the AI Judge!',
                        ],
                        footerText: isTurkishDeck
                            ? '<620px telefonda 2 sütunlu duyarlı tezgah'
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
                            ? 'CANLI SAHNE TESTİ: Konuşmanın 5. perdesinde ekrandaki QR kodu okutup tatlı siparişe gizlice tuz atacaksınız!'
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
