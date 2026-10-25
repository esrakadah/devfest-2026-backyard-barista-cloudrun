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
            title: '13. Live Build Dashboard (3 Rounds)',
            speakerNotes:
                'BEAT  [25:00 - 60:00] Canlı Kodlama ve Vibe Lounge Görev Panosu (Bu slayt inşa süresince ekranda açık kalır).\n'
                'SAY   "Şimdi 3 turluk inşa maratonumuz başlıyor! Bu slayt boyunca ekranda kalacak. 1. Turda (10 dakika) 12 hazır görselimizi çekip şehir modumuzu seçiyoruz. 2. Turda (15 dakika) kendi özel imza tatlımızı ve şaka malzememizi üretip Gemini JSON jürisine bağlıyoruz. 3. Turda (10 dakika) ise sağ üstteki Deploy to Cloud Run butonuna veya gcloud run deploy komutuna basıp canlı .run.app linkimizi ve GitHub repomuzu alıyoruz. Herhangi bir adımda geride kalan olursa repodaki prompts/step-1, step-2, step-3 dosyalarından veya uygulama içi Round 2 AI SVGs anahtarından anında yakalayabilir!"\n'
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
          eyebrow: 'KEEP ON SCREEN · MINUTES 25 TO 60',
          title: 'Live Build Dashboard: 3 Rounds to Cloud Run & GitHub',
          act: StoryAct.buildAndShip,
          subtitle: 'Fall behind? Use prompts/step-1..3.md or toggle the in-app Round 2 AI SVGs switch!',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              RoundTimelineBar(
                rounds: [
                  (label: 'ROUND 1 · BASE CAFE', minutes: 10, color: DeckColors.googleBlue),
                  (label: 'ROUND 2 · YOUR DISH', minutes: 15, color: DeckColors.googleYellow),
                  (label: 'ROUND 3 · SHIP', minutes: 10, color: DeckColors.googleGreen),
                ],
              ),
              SizedBox(height: _gap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ROUND 1 · 10 MIN (STEP 1)',
                        title: 'Base Cafe & City Switcher',
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
                          size: 170,
                        ),
                        SizedBox(height: _gap),
                        QrCodeCard(
                          assetPath: 'assets/images/backyard_barista_cloudrun_qr.png',
                          caption: 'Play the reference cafe',
                          size: 170,
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
