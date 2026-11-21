import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Who is talking: stage and community photos, the communities she hosts and the book.
class AboutMeSlide extends FlutterDeckSlideWidget {
  const AboutMeSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/about-me',
            title: '2. Merhaba, ben Esra',
            speakerNotes: 'BEAT  [00:30 - 01:15] Kim konuşuyor. Hafif tut, 45 saniyeyi geçme.\n'
                'SAY   "Ben Esra. Berlin\'de Antigua Mobile\'da Tech Lead olarak çalışıyorum, Flutter ve Dart alanında Google Developer Expert\'im ve Flutter Design Patterns and Best Practices kitabının yazarlarından biriyim. Flutteristas, Flutter Berlin, Flutter Community AI Circle ve GDG Cloud Berlin topluluklarını yürütüyorum. Yolunuz Berlin\'e düşerse ya da online etkinliklerimize katılmak isterseniz mutlaka yazın. Burada söylediklerim kendi görüşlerim, Google adına konuşmuyorum."\n'
                'HOLD  Sağdaki logoları ve kitabı göster, fotoğrafları tek tek anlatma. Fotoğraflardaki kişilerin adını söyleme.\n'
                'NEXT  "Önümüzdeki yarım saati nasıl kullanacağımızı göstereyim."',
          ),
        );

  static const double _gap = 24;
  static const double _photoAspectRatio = 1408 / 792;
  static const double _photoRadius = 22;
  static const double _photoBorderWidth = 3;
  static const double _captionGap = 12;
  static const double _captionSize = 28;
  static const int _shortFactFlex = 3;
  static const int _bookFactFlex = 5;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KİM KONUŞUYOR',
          title: 'Merhaba, ben Esra',
          act: StoryAct.hook,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PhotoCard(assetPath: 'assets/images/about_photos.png', caption: 'Sahnede ve toplulukta'),
                    ),
                    SizedBox(width: _gap),
                    Expanded(
                      child: _PhotoCard(
                        assetPath: 'assets/images/about_communities.png',
                        caption: 'Yürüttüğüm topluluklar ve kitap',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _gap),
              Row(
                children: [
                  Expanded(
                    flex: _shortFactFlex,
                    child: _FactChip(label: 'GOOGLE DEVELOPER EXPERT', value: 'Flutter ve Dart'),
                  ),
                  SizedBox(width: _gap),
                  Expanded(
                    flex: _shortFactFlex,
                    child: _FactChip(label: 'TECH LEAD', value: 'Antigua Mobile, Berlin'),
                  ),
                  SizedBox(width: _gap),
                  Expanded(
                    flex: _bookFactFlex,
                    child: _FactChip(label: 'KİTAP', value: 'Flutter Design Patterns and Best Practices'),
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

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.assetPath, required this.caption});

  final String assetPath;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: AboutMeSlide._photoAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AboutMeSlide._photoRadius),
                border: Border.all(color: DeckColors.onGroundAccent, width: AboutMeSlide._photoBorderWidth),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AboutMeSlide._photoRadius),
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: AboutMeSlide._captionGap),
        Text(
          caption,
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: AboutMeSlide._captionSize,
            fontWeight: FontWeight.w700,
            color: DeckColors.onGroundAccent,
          ),
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, required this.value});

  static const double _paddingHorizontal = 22;
  static const double _paddingVertical = 16;
  static const double _radius = 16;
  static const double _borderOpacity = 0.6;
  static const double _labelSize = 18;
  static const double _valueSize = 28;
  static const double _labelGap = 4;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _paddingHorizontal, vertical: _paddingVertical),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: DeckColors.googleYellow.withValues(alpha: _borderOpacity), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: _labelSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: DeckColors.googleYellow,
            ),
          ),
          const SizedBox(height: _labelGap),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _valueSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }
}
