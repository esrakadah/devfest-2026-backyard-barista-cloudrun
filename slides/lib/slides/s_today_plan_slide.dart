import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// The map of the half hour, shown before the hall is asked to do anything: play, five rules, podium.
class TodayPlanSlide extends FlutterDeckSlideWidget {
  const TodayPlanSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/today-plan',
            title: '3. Bugün: 30 dakika, üç parça',
            speakerNotes: 'BEAT  [01:15 - 02:00] Harita ve ana fikir. Üç kartı göster, alttaki cümleyi yavaş söyle.\n'
                'SAY   "Yarım saatimiz üç parça. Önce oynuyoruz: birazdan telefonunuzla canlı bir oyuna gireceksiniz, ilk üçe ödül var. Sonra konuşmanın asıl kısmı: beş kural. Bu oyunun kodunu yapay zeka araçlarıyla birlikte yazdım; çalışıyor, testlerden geçiyor. Sonra aynı kodda beş hata buldum. O hatalardan üçünü ve bu oyundan çıkardığım beş kuralı göstereceğim. En sonda podyum ve ödüller. Başlıkta \'yap ve canlıya al\' yazıyor. Yapmak artık kolay; ben canlıya aldıktan sonra olanı anlatacağım."\n'
                'HOLD  Kartları okuma, üç parçayı soldan sağa göster. "Beş hata buldum" dedikten sonra 2 saniye bekle.\n'
                'NEXT  "Koda geçmeden önce bütün salonla küçük bir oylama yapalım."',
          ),
        );

  static const double _gap = 20;
  static const double _bannerPaddingHorizontal = 30;
  static const double _bannerPaddingVertical = 22;
  static const double _bannerTextSize = 40;
  static const double _bannerRadius = 18;
  static const double _bannerBorderOpacity = 0.7;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return SlideFrame(
          eyebrow: 'BUGÜN NE YAPACAĞIZ',
          title: '30 dakika, üç parça',
          act: StoryAct.hook,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PartCard(
                        badge: '1 · YAKLAŞIK 5 DK',
                        icon: Icons.sports_esports,
                        title: 'Önce oynuyoruz',
                        lines: ['Telefonunuzla canlı oyuna girin.', 'İlk üçe ödül var.'],
                        accentColor: DeckColors.googleGreen,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _PartCard(
                        badge: '2 · YAKLAŞIK 19 DK',
                        icon: Icons.rule,
                        title: 'Beş kural',
                        lines: ['Bu oyunun hatalarından çıktılar.', 'Her kuralda bir yeni kelime.'],
                        accentColor: DeckColors.googleYellow,
                      ),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _PartCard(
                        badge: '3 · YAKLAŞIK 3 DK',
                        icon: Icons.emoji_events,
                        title: 'Podyum',
                        lines: ['Kazananlar sahneye.', 'Kod ve slaytlar QR kodda.'],
                        accentColor: DeckColors.googleBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _gap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _bannerPaddingHorizontal,
                  vertical: _bannerPaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: DeckColors.surfaceInset,
                  borderRadius: BorderRadius.circular(_bannerRadius),
                  border: Border.all(color: DeckColors.googleYellow.withValues(alpha: _bannerBorderOpacity), width: 2),
                ),
                child: const Text(
                  'Yapmak artık kolay. Bugünün konusu: canlıya aldıktan sonra olanlar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _bannerTextSize,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.googleYellow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.badge,
    required this.icon,
    required this.title,
    required this.lines,
    required this.accentColor,
  });

  static const double _padding = 26;
  static const double _iconSize = 170;
  static const double _titleSize = 46;
  static const double _lineSize = 30;
  static const double _lineGap = 8;
  static const double _borderOpacity = 0.45;

  final String badge;
  final IconData icon;
  final String title;
  final List<String> lines;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(_padding),
      borderColor: accentColor.withValues(alpha: _borderOpacity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeckBadge(label: badge, color: accentColor),
          Expanded(
            child: Center(child: Icon(icon, size: _iconSize, color: accentColor)),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: DeckFonts.cardDisplay,
              fontSize: _titleSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
          for (final line in lines) ...[
            const SizedBox(height: _lineGap),
            Text(
              line,
              style: const TextStyle(fontFamily: DeckFonts.sans, fontSize: _lineSize, color: DeckColors.offWhite),
            ),
          ],
        ],
      ),
    );
  }
}
