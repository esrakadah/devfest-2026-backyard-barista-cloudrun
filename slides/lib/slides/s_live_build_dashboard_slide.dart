import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class LiveBuildDashboardSlide extends FlutterDeckSlideWidget {
  const LiveBuildDashboardSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/live-build-dashboard',
            title: isTurkishDeck ? '13. Canlı demo ve salon QR testi' : '13. Live Build Dashboard (3 Rounds)',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [15:00 - 25:30] 3 adımlı canlı demo (5 + 2 + 3 dk). Önce kendi iki tepsin, sonra QR.\n'
                    'SAY   "Üç adımlı canlı demoya geçiyoruz. Birinci adım: canlı Cloud Run servisimizdeyiz. Önce ben doğru bir tatlı tepsi servis ediyorum: Gemini 3.5 Flash-Lite\'tan 5 yıldız. Şimdi şeker yerine tuz: 1 yıldız ve Alaaddin Tepesi yorumu. Sıra sizde: telefonlarınızı çıkarın, ekrandaki büyük QR kodu okutun, iki dakikanız var. Kartın altındaki rozete bakın. \'Canlı Gemini\' yerine \'Yerel JSON Şeması\' yazıyorsa bir şey bozulmadı: 850 kişi tek anahtarı zorladı ve az önce anlattığım son önlem şu an sizin telefonunuzda çalışıyor."\n'
                    'HOLD  1) 5 dk: önce kendi iki tepsin (tatlı 5 yıldız, tuzlu 1 yıldız), SONRA slayta dönüp QR. Salon oynarken sus ve bekle, salondan bir yorumu sesli oku, "Tamam, devam" de. 2) 2 dk: "İkinci adım: Konya sürümü 11 dosyalık bir değişiklikti." Tek ekran: runbook Adım 2 komutu (git show --stat, yalnızca başlık ve dosya listesi), sonra bayrak rozetinden bir şehir geçişi. 3) 3 dk: "Üçüncü adım kaos testi." Wi-Fi\'ı kapat, aynı tuzlu tepsiyi gönder. Gemma düşünürken söyle: "Gemma şu an düşünüyor, 8 saniyeye kadar sürebilir; 15 saniyelik sınırımız bunun için var." Süre 24:00\'ü geçerse 3. adımı 30 saniyede göster ve 14. slayta dön. QR arkadan okunmuyorsa tam ekran QR sekmesini aç.\n'
                    'NEXT  "Canlı demoyu ve çevrimdışı yedeği gördük. Şimdi arkadaki mimariyi 90 saniyede toparlayalım."'
                : 'BEAT  [25:00 - 60:00] Canlı Kodlama ve Vibe Lounge Görev Panosu (Bu slayt inşa süresince ekranda açık kalır).\n'
                    'SAY   "Şimdi 3 turluk inşa maratonumuz başlıyor! Bu slayt boyunca ekranda kalacak. 1. Turda (10 dakika) 12 hazır görselimizi çekip şehir modumuzu seçiyoruz. 2. Turda (15 dakika) kendi özel imza tatlımızı ve şaka malzememizi üretip Gemini JSON jürisine bağlıyoruz. 3. Turda (10 dakika) ise sağ üstteki Deploy to Cloud Run butonuna veya gcloud run deploy komutuna basıp canlı .run.app linkimizi ve GitHub repomuzu alıyoruz. Herhangi bir adımda geride kalan olursa QR kodundaki Türkçe repodan promptlar/tur-1, tur-2, tur-3 dosyalarından veya uygulama içi Round 2 AI SVGs anahtarından anında yakalayabilir!"\n'
                    'HOLD  Sahnedeki zamanlayıcıyı (Stage Navigator -> Timer) başlat ve mentörlerle birlikte salonda dolaşarak katılımcıların ekranlarını kontrol et. [Slot kesim kuralı: 80dk atölyede 35dk tam tur; 45dk Vibe Lounge dalgasında 20dk 2-tur sprint; 30+10dk Adana ana salon konuşmasında ise bu slaytı 60 saniyede özetleyip doğrudan kendi 3 adımlı canlı sahne demona geç].\n'
                    'NEXT  "Herkes canlı linkini aldığına göre, ödül töreninden hemen önce 5 dakikada bugün kurduğumuz uçtan uca bulut mimarisini özetleyelim!"',
          ),
        );

  static const double _gap = 20;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck ? 'CANLI DEMO · TELEFONUNUZLA KATILIN' : 'KEEP ON SCREEN · MINUTES 25 TO 60',
          title: isTurkishDeck
              ? 'Canlı demo: önce ben, sonra siz'
              : 'Live Build Dashboard: 3 Rounds to Cloud Run & GitHub',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? 'QR canlı oyunu telefonunuzda açar; kod ve slaytlar kapanış slaytındaki QR kodda'
              : 'Fall behind? Use prompts/step-1..3.md or toggle the in-app Round 2 AI SVGs switch!',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              RoundTimelineBar(
                rounds: [
                  (
                    label: isTurkishDeck ? '1 · CANLI CLOUD RUN' : 'ROUND 1 · BASE CAFE',
                    minutes: isTurkishDeck ? 5 : 10,
                    color: DeckColors.googleBlue,
                  ),
                  (
                    label: isTurkishDeck ? '2 · KOD' : 'ROUND 2 · YOUR DISH',
                    minutes: isTurkishDeck ? 2 : 15,
                    color: DeckColors.googleYellow,
                  ),
                  (
                    label: isTurkishDeck ? '3 · WI-FI KAPALI' : 'ROUND 3 · SHIP',
                    minutes: isTurkishDeck ? 3 : 10,
                    color: DeckColors.googleGreen,
                  ),
                ],
              ),
              SizedBox(height: _gap),
              Expanded(
                child: isTurkishDeck
                    ? _TalkDemoBody()
                    : Row(
                        children: [
                          Expanded(
                            child: DeckFeatureCard(
                              badge: 'ROUND 1 · 10 MIN (STEP 1)',
                              title: 'Base Cafe & City Switcher',
                              talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: [
                                'Lane A: Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                                'Lane B: Run flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep.',
                                'Verify all 12 base PNGs load and switch City Edition in the top bar.',
                              ],
                              footerText: 'Checkpoint: prompts/step-1-base-cafe.md',
                            ),
                          ),
                          SizedBox(width: _gap),
                          Expanded(
                            child: DeckFeatureCard(
                              badge: 'ROUND 2 · 15 MIN (STEP 2)',
                              title: 'Custom AI Dish & Prank Judge',
                              accentColor: DeckColors.googleYellow,
                              talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: [
                                'Lane A: Paste prompts/step-2-custom-dish.md to add 1 vector dish + 1 prank.',
                                'Lane B: Use Antigravity Cmd+I to add roundTwoCustomItems in ingredients_catalog.dart.',
                                'Test sneaking Salt (Tuz) onto the tray and verify the 1-star JSON roast!',
                              ],
                              footerText: 'Checkpoint: Round 2 AI SVGs switch ON',
                            ),
                          ),
                          SizedBox(width: _gap),
                          Expanded(
                            child: DeckFeatureCard(
                              badge: 'ROUND 3 · 10 MIN (STEP 3)',
                              title: 'Ship to Cloud Run & GitHub',
                              accentColor: DeckColors.googleGreen,
                              talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: [
                                'Lane A: Click Deploy to Cloud Run (.run.app) + Sync to GitHub in AI Studio.',
                                'Lane B: Run gcloud run deploy backyard-barista --source . inside flutter_client/.',
                                'Raise your hand to demo your live .run.app cafe in 60s for the Pixel Sunglasses!',
                              ],
                              footerText: 'Checkpoint: prompts/step-3-deploy.md',
                            ),
                          ),
                          SizedBox(width: _gap),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QrCodeCard(
                                assetPath: 'assets/images/starter_repo_qr.png',
                                caption: 'Starter repo & prompts',
                                size: 205,
                              ),
                              SizedBox(height: _gap),
                              QrCodeCard(
                                assetPath: 'assets/images/backyard_barista_cloudrun_qr.png',
                                caption: 'Play the reference cafe',
                                size: 205,
                                accentColor: DeckColors.googleGreen,
                              ),
                            ],
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

/// Turkish talk layout: three one-line demo steps and one QR large enough for the back rows.
class _TalkDemoBody extends StatelessWidget {
  const _TalkDemoBody();

  static const double _gap = 20;
  static const double _playQrSize = 400;

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 1 · 5 DK',
                  title: 'Canlı Cloud Run: önce ben, sonra siz',
                  talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: ['Tatlı tepsiye 5 yıldız, tuzlu tepsiye 1 yıldız. Rozet yanıtın nereden geldiğini söyler.'],
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 2 · 2 DK',
                  title: isIzmirDeck ? 'Şehir sürümü: çok dosyalı değişiklik' : 'Konya sürümü: 11 dosyalık değişiklik',
                  accentColor: DeckColors.googleYellow,
                  talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: ['Tek ekranda fark, ardından üst bardaki bayrak rozetinden şehir geçişi.'],
                ),
              ),
              SizedBox(height: _gap),
              Expanded(
                child: DeckFeatureCard(
                  badge: 'ADIM 3 · 3 DK',
                  title: 'Wi-Fi kapalı: yerel Gemma 4 ve hazır yanıtlar',
                  accentColor: DeckColors.googleGreen,
                  talkBulletFontSize: DeckTypeScale.bodyMedium,
                  talkTitleFontSize: DeckTypeScale.bodyLarge,
                  bullets: ['Canlı Gemini (8 sn) -> yerel Gemma (15 sn) -> paket (250 ms).'],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: _gap),
        QrCodeCard(
          assetPath: isIzmirDeck
              ? 'assets/images/backyard_barista_cloudrun_qr.png'
              : 'assets/images/backyard_barista_konya_qr.png',
          caption: isIzmirDeck ? 'Canlı kafeyi oyna' : 'Konya kafesini oyna',
          size: _playQrSize,
          accentColor: DeckColors.googleGreen,
        ),
      ],
    );
  }
}
