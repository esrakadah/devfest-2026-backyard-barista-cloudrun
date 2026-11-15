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
            title: isTurkishDeck ? '13. Canlı yapım panosu (3 tur)' : '13. Live Build Dashboard (3 Rounds)',
            speakerNotes: isTurkishDeck
                ? 'BEAT  [25:00 - 60:00] Canlı yapım. Bu slayt üç tur boyunca ekranda kalır.\n'
                    'SAY   "Şimdi sıra sizde: üç turda kendi barista uygulamanızı kuruyorsunuz. Bu slayt ekranda kalacak. 1. tur, 10 dakika: başlangıç prompt\'unu yapıştırıyoruz, Gemini zevkinize göre kahve tarifi öneren baristanız oluyor. 2. tur, 15 dakika: demleme zamanlayıcısı ve alışveriş listesi ekliyoruz; hızlı olanlar Firebase tarif defterini de ekleyebilir. 3. tur, 10 dakika: AI Studio\'da Publish ile canlı linkimizi alıyoruz. Geride kalan olursa dert değil: QR kodundaki Türkçe repoda promptlar klasöründen bir sonraki tura atlayın."\n'
                    "HOLD  Zamanlayıcıyı başlat (Stage Navigator -> Timer) ve salonda dolaş, ekranlara bak. Süreler [HEDEF]: salon geride kalırsa 2. turu kısalt, 3. turu koru. [Antep'te geçersiz, ANTEP satırına bak] [Süre kuralı: 80 dk atölyede 35 dk tam tur; 2 x 45 dk olursa her blokta 20 dk'lık 2 turluk sprint].\n"
                    'ANTEP [15 Kasım] Önce 30 saniye: sağdaki yeşil QR\'daki örnek kafede bir tatlıya tuz at, 1 yıldızı göster: "Bu benim örnek kafem, Gemini hakem. Sizinkinde Gemini barista olacak." Blok 90 dakika: slayttaki gibi 10, 15, 10 = 35 dakika, saat 32:00 ile 67:00 arası, sonra 3 dakika tampon. Turlar arasında bir cümleyle kontrol listesine bağla: "AI kodu yazdı, siz uygulamada deneyip kontrol ediyorsunuz: her özelliği bir sonrakinden önce test edin." Publish seçeneği çıkmayan olursa: AI Studio\'daki Share ile paylaşsın ya da yanındakiyle devam etsin. Kodu bozulan olursa: QR kodundaki Türkçe repodan promptlar/tur-N dosyasını yapıştırsın. Terimler: Build modu = AI Studio\'nun uygulama yazan modu, Publish = Cloud Run\'da canlı link, Share = yayınlamadan paylaşım linki (başkalarının çağrıları sizin kotanızdan gider). Rehber Google\'ın resmi DevFest 2026 Vibe Lounge Backyard Barista rehberinden Türkçeye uyarlandı. Örnek kafe 8 saniyede cevap vermezse oyun yedek cevaba düşer: bunu söyle, devam et. Wi-Fi tamamen giderse yedekteki /demo-hiccup slaytı ve yerel Gemma sekmesi (run card bölüm 4). Bitince 14. slaytı atla, 15. slayta geç; alttaki NEXT yerine: "Şimdi bugünden aklımızda kalan dört şey."\n'
                    'NEXT  "Herkes linkini aldıysa, demolardan önce bugün ne kurduğumuzu 5 dakikada toparlayalım."'
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
          eyebrow: isTurkishDeck ? 'EKRANDA KALSIN · CANLI YAPIM, 3 TUR' : 'KEEP ON SCREEN · MINUTES 25 TO 60',
          title: isTurkishDeck
              ? "Canlı yapım panosu: 3 turda Cloud Run ve GitHub'a"
              : 'Live Build Dashboard: 3 Rounds to Cloud Run & GitHub',
          act: StoryAct.buildAndShip,
          subtitle: isTurkishDeck
              ? 'Geride mi kaldınız? QR kodundaki promptlar klasöründen sıradaki turu yapıştırın!'
              : 'Fall behind? Use prompts/step-1..3.md or toggle the in-app Round 2 AI SVGs switch!',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              RoundTimelineBar(
                rounds: [
                  (
                    label: isTurkishDeck ? '1. TUR · BARİSTA' : 'ROUND 1 · BASE CAFE',
                    minutes: 10,
                    color: DeckColors.googleBlue
                  ),
                  (
                    label: isTurkishDeck ? '2. TUR · ZAMANLAYICI + LİSTE' : 'ROUND 2 · YOUR DISH',
                    minutes: 15,
                    color: DeckColors.googleYellow
                  ),
                  (
                    label: isTurkishDeck ? '3. TUR · YAYINLA' : 'ROUND 3 · SHIP',
                    minutes: 10,
                    color: DeckColors.googleGreen
                  ),
                ],
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '1. TUR · 10 DK (ADIM 1)' : 'ROUND 1 · 10 MIN (STEP 1)',
                        title: isTurkishDeck ? 'Barista uygulaması' : 'Base Cafe & City Switcher',
                        bullets: [
                          if (isTurkishDeck)
                            'Yol A: ai.studio/build, kişisel Gmail, promptlar/tur-1-barista.md yapıştırın.'
                          else
                            'Lane A: Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          if (isTurkishDeck)
                            'Yol B (ileri): örnek kafede flutter run -d chrome çalıştırın.'
                          else
                            'Lane B: Run flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep.',
                          if (isTurkishDeck)
                            'Zevkinizi yazın: Gemini çekirdek, kavrum ve süt öneriyor mu?'
                          else
                            'Verify all 12 base PNGs load and switch City Edition in the top bar.',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kontrol noktası: promptlar/tur-1-barista.md'
                            : 'Checkpoint: prompts/step-1-base-cafe.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '2. TUR · 15 DK (ADIM 2)' : 'ROUND 2 · 15 MIN (STEP 2)',
                        title: isTurkishDeck
                            ? 'Demleme zamanlayıcısı ve alışveriş listesi'
                            : 'Custom AI Dish & Prank Judge',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          if (isTurkishDeck)
                            'Yol A: promptlar/tur-2-demleme-ve-liste.md ile zamanlayıcı ve liste ekleyin.'
                          else
                            'Lane A: Paste prompts/step-2-custom-dish.md to add 1 vector dish + 1 prank.',
                          if (isTurkishDeck)
                            'Bonus: Firebase tarif defteri ya da Tarifi kopyala düğmesi.'
                          else
                            'Lane B: Use Antigravity Cmd+I to add roundTwoCustomItems in ingredients_catalog.dart.',
                          if (isTurkishDeck)
                            'Her özelliği bir sonrakini eklemeden önce deneyin.'
                          else
                            'Test sneaking Salt (Tuz) onto the tray and verify the 1-star JSON roast!',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kontrol noktası: promptlar/tur-2-demleme-ve-liste.md'
                            : 'Checkpoint: Round 2 AI SVGs switch ON',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: isTurkishDeck ? '3. TUR · 10 DK (ADIM 3)' : 'ROUND 3 · 10 MIN (STEP 3)',
                        title: isTurkishDeck ? 'Yayın: Cloud Run ve GitHub' : 'Ship to Cloud Run & GitHub',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          if (isTurkishDeck)
                            "Yol A: AI Studio'da Publish ya da Share'e tıklayın."
                          else
                            'Lane A: Click Deploy to Cloud Run (.run.app) + Sync to GitHub in AI Studio.',
                          if (isTurkishDeck)
                            'Yol B (ileri): gcloud run deploy backyard-barista --source . çalıştırın.'
                          else
                            'Lane B: Run gcloud run deploy backyard-barista --source . inside flutter_client/.',
                          if (isTurkishDeck)
                            'Canlı uygulamanızı 60 saniyede sahnede göstermek için el kaldırın!'
                          else
                            'Raise your hand to demo your live .run.app cafe in 60s for the Pixel Sunglasses!',
                        ],
                        footerText: isTurkishDeck
                            ? 'Kontrol noktası: promptlar/tur-3-yayinla.md'
                            : 'Checkpoint: prompts/step-3-deploy.md',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QrCodeCard(
                          assetPath: isTurkishDeck
                              ? 'assets/images/gaziantep_atolye_qr.png'
                              : 'assets/images/starter_repo_qr.png',
                          caption: isTurkishDeck ? "Türkçe prompt'lar" : 'Starter repo & prompts',
                          size: 205,
                        ),
                        SizedBox(height: _gap),
                        QrCodeCard(
                          assetPath: 'assets/images/backyard_barista_cloudrun_qr.png',
                          caption: isTurkishDeck ? 'Örnek kafeyi oyna' : 'Play the reference cafe',
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
