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
            title: isTurkishDeck ? '13. Canlı sahne demosu ve seyirci QR testi' : '13. Live Build Dashboard (3 Rounds)',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [15:00 - 25:30] 3 adımlı canlı sahne demosu (10 dk) + tüm salonun telefondan canlı QR ile oynaması.\n'
                    'SAY   "Şimdi telefonlarınızı çıkarın, sağ alttaki yeşil QR kodu okutun! Arka sıralar için tam ekran QR sekmemi de hemen açıyorum. Üç adımlı canlı demomuza başlıyoruz. Birinci adım: canlı Cloud Run servisimizdeyiz. Önce doğru bir tatlı tepsi servis edip Gemini 3.5 Flash-Lite\'tan 5 yıldızı alıyoruz; hemen ardından şeker yerine tuz atıp 1 yıldızlı Alaaddin Tepesi yorumunu canlı görüyoruz. İkinci adım: tek bir Antigravity Agent Mode isteğiyle Konya sürümünün 11 dosyada nasıl eklendiğine ve 32 testi nasıl geçtiğine bakıyoruz. Üçüncü adım ise kaos testi: sahnede Wi-Fi\'ı kapatıyorum, aynı tuzlu tepsiyi tekrar gönderiyorum ve oyunun çökmeden laptoptaki yerel Gemma 4 ve 250 milisaniyelik çevrimdışı paketle nasıl devam ettiğini kanıtlıyoruz."\n'
                    "HOLD  Önce tam ekran QR sekmesini 15 saniye göster ki arka sıralar okutsun. Sonra sırayla: 1) Canlı Cloud Run sekmesi (tatlı 5 yıldız -> tuzlu 1 yıldız), 2) Terminalde git diff --stat ve Ayarlar çekmecesinden şehir geçişi, 3) Wi-Fi kapalı yerel Gemma sekmesi. Süre 24:00'ü geçerse 3. adımı 30 saniyede gösterip 14. slayta dön.\n"
                    'NEXT  "Canlı demoyu ve çevrimdışı yedeği gördük; şimdi arkadaki 4 katmanlı mimariyi 90 saniyede toparlayalım."'
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
          eyebrow: isTurkishDeck ? 'CANLI SAHNE DEMOSU · TELEFONUNUZLA KATILIN' : 'KEEP ON SCREEN · MINUTES 25 TO 60',
          title: isTurkishDeck
              ? 'Canlı sahne demosu: QR kodu okutun ve tatlıya tuz atın!'
              : 'Live Build Dashboard: 3 Rounds to Cloud Run & GitHub',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? 'Yeşil QR canlı oyunu telefonunuzda açar; sarı QR açık kaynak repoyu ve slaytları verir'
              : 'Fall behind? Use prompts/step-1..3.md or toggle the in-app Round 2 AI SVGs switch!',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              RoundTimelineBar(
                rounds: [
                  (
                    label: isTurkishDeck ? 'ADIM 1 · CANLI CLOUD RUN' : 'ROUND 1 · BASE CAFE',
                    minutes: isTurkishDeck ? 3 : 10,
                    color: DeckColors.googleBlue,
                  ),
                  (
                    label: isTurkishDeck ? 'ADIM 2 · KONYA KODU' : 'ROUND 2 · YOUR DISH',
                    minutes: isTurkishDeck ? 4 : 15,
                    color: DeckColors.googleYellow,
                  ),
                  (
                    label: isTurkishDeck ? 'ADIM 3 · WI-FI KAPALI' : 'ROUND 3 · SHIP',
                    minutes: isTurkishDeck ? 3 : 10,
                    color: DeckColors.googleGreen,
                  ),
                ],
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 1 · 3 DK (BULUT)' : 'ROUND 1 · 10 MIN (STEP 1)',
                        title: isTurkishDeck ? 'Canlı Cloud Run ve Gemini jürisi' : 'Base Cafe & City Switcher',
                        bullets: [
                          if (isTurkishDeck)
                            'Yeşil QR ile europe-west3 Cloud Run servisine telefonunuzdan bağlanın.'
                          else
                            'Lane A: Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          if (isTurkishDeck)
                            'Tatlı tepsiye 5 yıldız, tuzlu sabotaja 1 yıldızlı JSON yanıtı gelir.'
                          else
                            'Lane B: Run flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep.',
                          if (isTurkishDeck)
                            "Kartın altındaki rozet kararın canlı Gemini 3.5 Flash-Lite'tan geldiğini gösterir."
                          else
                            'Verify all 12 base PNGs load and switch City Edition in the top bar.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Ağ yolu: /api/gemini/generate (nginx proxy, anahtar sunucuda)'
                            : 'Checkpoint: prompts/step-1-base-cafe.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 2 · 4 DK (AJAN + KOD)' : 'ROUND 2 · 15 MIN (STEP 2)',
                        title: isTurkishDeck
                            ? (isIzmirDeck ? 'Çok dosyalı şehir sürümü farkı' : 'Konya sürümü: tek istek, 11 dosya')
                            : 'Custom AI Dish & Prank Judge',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Antigravity Agent Mode ile CityEditionId, JSON paketleri ve müşteri kuyruğu tek seferde güncellendi.'
                          else
                            'Lane A: Paste prompts/step-2-custom-dish.md to add 1 vector dish + 1 prank.',
                          if (isTurkishDeck)
                            'Üst bardaki bayrak rozetinden 5 DevFest şehri canlı değiştirilir.'
                          else
                            'Lane B: Use Antigravity Cmd+I to add roundTwoCustomItems in ingredients_catalog.dart.',
                          if (isTurkishDeck)
                            '32 birim ve widget testi kırılmadan yeşil kalır (flutter analyze + flutter test).'
                          else
                            'Test sneaking Salt (Tuz) onto the tray and verify the 1-star JSON roast!',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kanıt: city_editions.json + cafe_judge_service_test.dart'
                            : 'Checkpoint: Round 2 AI SVGs switch ON',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? 'ADIM 3 · 3 DK (ÇEVRİMDIŞI)' : 'ROUND 3 · 10 MIN (STEP 3)',
                        title: isTurkishDeck ? 'Wi-Fi kapalı: yerel Gemma 4 ve paket' : 'Ship to Cloud Run & GitHub',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            'Sahnede Wi-Fi kapatılır; aynı tuzlu tepsi yeniden servis edilir.'
                          else
                            'Lane A: Click Deploy to Cloud Run (.run.app) + Sync to GitHub in AI Studio.',
                          if (isTurkishDeck)
                            'Laptoptaki Ollama üzerinden gemma4:12b-it-qat Türkçe JSON kararını üretir.'
                          else
                            'Lane B: Run gcloud run deploy backyard-barista --source . inside flutter_client/.',
                          if (isTurkishDeck)
                            'Yerel model kapalıysa ya da 15 saniyeyi aşarsa mock_responses.json anında devralır.'
                          else
                            'Raise your hand to demo your live .run.app cafe in 60s for the Pixel Sunglasses!',
                        ],
                        footerText: isTurkishDeck
                            ? 'Koruma zinciri: Canlı Gemini (8 sn) -> Yerel Gemma (15 sn) -> Paket (250 ms)'
                            : 'Checkpoint: prompts/step-3-deploy.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QrCodeCard(
                          assetPath: 'assets/images/starter_repo_qr.png',
                          caption: isTurkishDeck ? 'Kod ve slaytlar' : 'Starter repo & prompts',
                          size: 205,
                        ),
                        SizedBox(height: _gap),
                        QrCodeCard(
                          assetPath: isTurkishDeck
                              ? (isIzmirDeck
                                  ? 'assets/images/backyard_barista_cloudrun_qr.png'
                                  : 'assets/images/backyard_barista_konya_qr.png')
                              : 'assets/images/backyard_barista_cloudrun_qr.png',
                          caption: isTurkishDeck
                              ? (isIzmirDeck ? 'Canlı kafeyi oyna' : 'Konya kafesini oyna')
                              : 'Play the reference cafe',
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
