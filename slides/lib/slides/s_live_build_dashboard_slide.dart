import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class LiveBuildDashboardSlide extends FlutterDeckSlideWidget {
  const LiveBuildDashboardSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/live-build-dashboard',
            title: '12. Live Build Dashboard (3 Rounds)',
            speakerNotes:
                'BEAT  [25:00 - 58:00] Canlı Kodlama ve Vibe Lounge Görev Panosu (Bu slayt inşa süresince ekranda açık kalır).\n'
                'SAY   "Şimdi 3 turluk inşa maratonumuz başlıyor! Bu slayt boyunca ekranda kalacak. 1. Turda (10 dakika) 12 hazır görselimizi çekip şehir modumuzu seçiyoruz. 2. Turda (15 dakika) kendi özel imza tatlımızı ve şaka malzememizi üretip Gemini JSON jürisine bağlıyoruz. 3. Turda (10 dakika) ise sağ üstteki Deploy to Cloud Run butonuna veya gcloud run deploy komutuna basıp canlı .run.app linkimizi ve GitHub repomuzu alıyoruz. Herhangi bir adımda geride kalan olursa repodaki step-1, step-2, step-3 etiketlerinden anında yakalayabilir!"\n'
                'HOLD  Sahnedeki zamanlayıcıyı (Stage Navigator -> Timer) başlat ve mentörlerle birlikte salonda dolaşarak katılımcıların ekranlarını kontrol et.\n'
                'NEXT  "Herkes canlı linkini aldığına göre, ödül töreninden hemen önce 5 dakikada bugün kurduğumuz uçtan uca bulut mimarisini özetleyelim!"',
          ),
        );

  static const double _gap = 20;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'SLIDE 12 · KEEP ON SCREEN DURING LIVE BUILD (MINUTES 25 - 58)',
          title: 'Live Build Dashboard: 3 Rounds to Cloud Run & GitHub',
          subtitle: 'Fall behind? Jump to git tag step-1, step-2, step-3, or final in our starter repo!',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ROUND 1 · 10 MIN (TAG: step-1)',
                        title: 'Base Cafe & City Switcher',
                        bullets: [
                          'Lane A: Paste prompts/step-1-base-cafe.md in AI Studio Build mode.',
                          'Lane B: Run flutter run -d chrome --dart-define=DEFAULT_CITY=gaziantep.',
                          'Verify all 12 base PNGs load and switch City Edition in the top bar.',
                        ],
                        footerText: 'Checkpoint: git checkout step-1',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ROUND 2 · 15 MIN (TAG: step-2)',
                        title: 'Custom AI Dish & Prank Judge',
                        accentColor: DeckColors.googleYellow,
                        bullets: [
                          'Lane A: Paste prompts/step-2-custom-dish.md to add 1 SVG dish + 1 prank.',
                          'Lane B: Use Antigravity Cmd+I to add your custom dish to ingredients_catalog.dart.',
                          'Test sneaking Salt (Tuz) onto the tray and verify the 1-star JSON roast!',
                        ],
                        footerText: 'Checkpoint: git checkout step-2',
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: DeckFeatureCard(
                        badge: 'ROUND 3 · 10 MIN (TAG: step-3 / final)',
                        title: 'Ship to Cloud Run & GitHub',
                        accentColor: DeckColors.googleGreen,
                        bullets: [
                          'Lane A: Click Deploy to Cloud Run (.run.app) + Sync to GitHub in AI Studio.',
                          'Lane B: Run gcloud run deploy backyard-barista --source . inside flutter_client/.',
                          'Raise your hand to demo your live .run.app cafe in 60s for the Pixel Sunglasses!',
                        ],
                        footerText: 'Checkpoint: git checkout final',
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
