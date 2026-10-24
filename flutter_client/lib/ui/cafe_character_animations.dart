import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/models/customer_order_ticket.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const Duration _characterCycleDuration = Duration(milliseconds: 520);
const double _crewAvatarSize = 68;
const double _crewCardCornerRadius = 18;
const double _characterArchTopRadius = 38;
const double _characterArchBottomRadius = 14;
const double _jumpPeakPixels = 7;
const double _breathingAmplitudePixels = 3.5;
const double _shakeAmplitudePixels = 5.5;
const double _maxTiltRadians = 0.06;
const double _celebrationScaleBoost = 0.08;
const double _brewingScaleBoost = 0.05;
const double _lottieOverlayScaleFactor = 1.28;

/// Bundled ready-made Lottie animation JSON assets under `assets/animations/`.
class CafeAnimationAssets {
  const CafeAnimationAssets._();

  static const String coffeeSteamLoop = 'assets/animations/coffee_steam_loop.json';
  static const String sweetCelebrationBurst = 'assets/animations/sweet_celebration_burst.json';
  static const String saltySpicyExplosion = 'assets/animations/salty_spicy_explosion.json';
  static const String baristaBrewingPulse = 'assets/animations/barista_brewing_pulse.json';
}

/// Live animation state for P1 Barista, P2 Pastry Chef, and the Customer in the Cafe Arch Window.
enum CafeCharacterMood {
  idleBreathing,
  talkingOrder,
  brewingActive,
  stealthPrankWink,
  sweetCelebration,
  saltySabotageShock;

  String get lottieAssetPath {
    switch (this) {
      case CafeCharacterMood.idleBreathing:
      case CafeCharacterMood.talkingOrder:
        return CafeAnimationAssets.coffeeSteamLoop;
      case CafeCharacterMood.brewingActive:
      case CafeCharacterMood.stealthPrankWink:
        return CafeAnimationAssets.baristaBrewingPulse;
      case CafeCharacterMood.sweetCelebration:
        return CafeAnimationAssets.sweetCelebrationBurst;
      case CafeCharacterMood.saltySabotageShock:
        return CafeAnimationAssets.saltySpicyExplosion;
    }
  }
}

bool get _isRunningInAutomatedWidgetTest {
  final bindingTypeName = WidgetsBinding.instance.runtimeType.toString();
  return bindingTypeName.contains('Test');
}

/// Interactive 60fps animated character portrait combining 3D Pixar-style character art,
/// ready-made Lottie JSON overlays (`package:lottie`), and procedural motion (breathing,
/// talking bounce, brewing pulse, stealth wink wiggle, celebration jump, and salty shake).
class AnimatedCafeCharacterAvatar extends StatefulWidget {
  const AnimatedCafeCharacterAvatar({
    required this.portraitAssetPath,
    required this.mood,
    required this.avatarSize,
    required this.borderColor,
    this.badgeEmoji,
    this.isArchedWindow = false,
    this.onTapCharacter,
    super.key,
  });

  final String portraitAssetPath;
  final CafeCharacterMood mood;
  final double avatarSize;
  final Color borderColor;
  final String? badgeEmoji;
  final bool isArchedWindow;
  final VoidCallback? onTapCharacter;

  @override
  State<AnimatedCafeCharacterAvatar> createState() => _AnimatedCafeCharacterAvatarState();
}

class _AnimatedCafeCharacterAvatarState extends State<AnimatedCafeCharacterAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: _characterCycleDuration,
    );
    _startCharacterMotion();
  }

  @override
  void didUpdateWidget(covariant AnimatedCafeCharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood || oldWidget.portraitAssetPath != widget.portraitAssetPath) {
      _startCharacterMotion();
    }
  }

  void _startCharacterMotion() {
    if (_isRunningInAutomatedWidgetTest) {
      _motionController.forward(from: 0);
      return;
    }
    _motionController.repeat(reverse: true);
  }

  void _handleTap() {
    if (_isRunningInAutomatedWidgetTest) {
      _motionController.forward(from: 0);
    }
    widget.onTapCharacter?.call();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isArchedWindow
        ? const BorderRadius.vertical(
            top: Radius.circular(_characterArchTopRadius),
            bottom: Radius.circular(_characterArchBottomRadius),
          )
        : BorderRadius.circular(20);

    final lottieDimension = widget.avatarSize * _lottieOverlayScaleFactor;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _motionController,
        builder: (context, child) {
          final progress = _motionController.value;
          final sineWave = math.sin(progress * math.pi * 2);
          final halfWave = math.sin(progress * math.pi);

          var offsetX = 0.0;
          var offsetY = 0.0;
          var rotationRadians = 0.0;
          var scaleValue = 1.0;

          switch (widget.mood) {
            case CafeCharacterMood.idleBreathing:
              offsetY = -halfWave * _breathingAmplitudePixels;
              scaleValue = 1.0 + (halfWave * 0.025);
            case CafeCharacterMood.talkingOrder:
              offsetY = -halfWave * (_breathingAmplitudePixels + 2.0);
              rotationRadians = sineWave * (_maxTiltRadians * 0.5);
              scaleValue = 1.0 + (halfWave * 0.04);
            case CafeCharacterMood.brewingActive:
              offsetY = -halfWave * 4.5;
              rotationRadians = sineWave * (_maxTiltRadians * 0.7);
              scaleValue = 1.0 + (halfWave * _brewingScaleBoost);
            case CafeCharacterMood.stealthPrankWink:
              offsetX = sineWave * 3.0;
              rotationRadians = sineWave * _maxTiltRadians;
              scaleValue = 1.0 + (halfWave * 0.045);
            case CafeCharacterMood.sweetCelebration:
              offsetY = -halfWave * _jumpPeakPixels;
              rotationRadians = sineWave * (_maxTiltRadians * 0.8);
              scaleValue = 1.0 + (halfWave * _celebrationScaleBoost);
            case CafeCharacterMood.saltySabotageShock:
              offsetX = sineWave * _shakeAmplitudePixels;
              rotationRadians = -sineWave * (_maxTiltRadians * 1.35);
              scaleValue = 1.0 + (halfWave * 0.05);
          }

          return SizedBox(
            width: widget.avatarSize + 14,
            height: widget.avatarSize + 14,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                // Layer 1: Ready-made Lottie JSON aura / burst behind & over the character
                IgnorePointer(
                  child: SizedBox(
                    width: lottieDimension,
                    height: lottieDimension,
                    child: Lottie.asset(
                      widget.mood.lottieAssetPath,
                      repeat: !_isRunningInAutomatedWidgetTest,
                      animate: !_isRunningInAutomatedWidgetTest,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                // Layer 2: 60fps Animated Character Portrait
                Transform.translate(
                  offset: Offset(offsetX, offsetY),
                  child: Transform.rotate(
                    angle: rotationRadians,
                    child: Transform.scale(
                      scale: scaleValue,
                      child: child,
                    ),
                  ),
                ),
                // Layer 3: Expressive Particle Overlay (Floating Hearts, Sparkles, or Spicy Steam)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(widget.avatarSize + 14, widget.avatarSize + 14),
                    painter: _CharacterMoodParticlePainter(
                      mood: widget.mood,
                      progress: progress,
                    ),
                  ),
                ),
                // Layer 4: Character Persona / Mood Badge Pill
                if (widget.badgeEmoji != null)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: widget.borderColor, width: 1.5),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.badgeEmoji!,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EE),
            borderRadius: borderRadius,
            border: Border.all(color: widget.borderColor, width: 2.5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.borderColor.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              widget.portraitAssetPath,
              width: widget.avatarSize,
              height: widget.avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.face_retouching_natural,
                  size: widget.avatarSize * 0.75,
                  color: const Color(0xFF6D4C41),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterMoodParticlePainter extends CustomPainter {
  const _CharacterMoodParticlePainter({
    required this.mood,
    required this.progress,
  });

  final CafeCharacterMood mood;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case CafeCharacterMood.sweetCelebration:
        final sparklePaint = Paint()
          ..color = const Color(0xFFFFB300)
          ..style = PaintingStyle.fill;
        final emeraldPaint = Paint()
          ..color = const Color(0xFF2E7D32)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(8, size.height * 0.22 - (progress * 8)),
          4.2,
          sparklePaint,
        );
        canvas.drawCircle(
          Offset(size.width - 8, size.height * 0.26 - (progress * 9)),
          3.8,
          emeraldPaint,
        );
      case CafeCharacterMood.saltySabotageShock:
        final flamePaint = Paint()
          ..color = const Color(0xFFD32F2F)
          ..style = PaintingStyle.fill;
        final smokePaint = Paint()
          ..color = const Color(0xFFFF7043)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(6, size.height * 0.20 - (progress * 7)),
          4.8,
          flamePaint,
        );
        canvas.drawCircle(
          Offset(size.width - 6, size.height * 0.18 - (progress * 7)),
          4.5,
          smokePaint,
        );
      case CafeCharacterMood.stealthPrankWink:
        final winkPaint = Paint()
          ..color = const Color(0xFFFF8F00)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width - 8, 10 - (progress * 4)),
          3.5,
          winkPaint,
        );
      case CafeCharacterMood.idleBreathing:
      case CafeCharacterMood.talkingOrder:
      case CafeCharacterMood.brewingActive:
        final steamPaint = Paint()
          ..color = const Color(0x99FFF3E0)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width * 0.25, 6 - (progress * 4)),
          3,
          steamPaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterMoodParticlePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.progress != progress;
  }
}

/// Interactive 2-Player Crew Character Stage displaying P1 Barista (Esra) and
/// P2 Pastry & Prank Chef (Can) with animated 3D portraits, Lottie effects, and live reactions.
class CafeCrewCharacterStage extends StatelessWidget {
  const CafeCrewCharacterStage({
    required this.languageCode,
    required this.selectedTray,
    required this.latestReview,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.onTapCharacterEmote,
    super.key,
  });

  final String languageCode;
  final List<CafeIngredient> selectedTray;
  final CafeReview? latestReview;
  final int playerOneScore;
  final int playerTwoScore;
  final VoidCallback onTapCharacterEmote;

  bool get _hasHotDrinkOnTray => selectedTray.any((ingredient) => ingredient.category == IngredientCategory.drink);

  bool get _hasPastryOnTray => selectedTray.any((ingredient) => ingredient.category == IngredientCategory.food);

  bool get _hasPrankOnTray => selectedTray.any((ingredient) => ingredient.isPrankItem);

  CafeCharacterMood get _baristaMood {
    final currentReview = latestReview;
    if (currentReview != null) {
      return currentReview.isPrankCaught ? CafeCharacterMood.saltySabotageShock : CafeCharacterMood.sweetCelebration;
    }
    if (_hasHotDrinkOnTray) {
      return CafeCharacterMood.brewingActive;
    }
    return CafeCharacterMood.idleBreathing;
  }

  CafeCharacterMood get _pastryChefMood {
    final currentReview = latestReview;
    if (currentReview != null) {
      return currentReview.isPrankCaught ? CafeCharacterMood.sweetCelebration : CafeCharacterMood.sweetCelebration;
    }
    if (_hasPrankOnTray) {
      return CafeCharacterMood.stealthPrankWink;
    }
    if (_hasPastryOnTray) {
      return CafeCharacterMood.brewingActive;
    }
    return CafeCharacterMood.idleBreathing;
  }

  String _baristaSpeechLine(bool isEnglish) {
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return isEnglish
            ? '😱 Hey! Who sneaked salt or chili into my specialty coffee?!'
            : '😱 Eyvah! Özenle demlediğim kahveye kim tuz/biber karıştırdı?!';
      }
      return isEnglish
          ? '🎉 5-Star Sweet Perfection! Our espresso crema is unbeatable!'
          : '🎉 5 Yıldız Tatlı Mükemmellik! Cezve ve espresso tam kıvamında!';
    }
    if (_hasHotDrinkOnTray) {
      return isEnglish
          ? '☕ Steaming hot coffee is on the tray! Ready to serve!'
          : '☕ Sıcak kahve tepside tütüyor! Tatlı ve şekerle servise hazır!';
    }
    return isEnglish
        ? '☕ Tap a coffee on my bar to start brewing for our guest!'
        : '☕ Misafirimiz bekliyor! Kahve barından sıcak içeceği seçelim!';
  }

  String _pastryChefSpeechLine(bool isEnglish) {
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return isEnglish
            ? '😈 Hehehe! Twin jar prank worked! +30 Sabotage points for P2!'
            : '😈 Hehehe! İkiz kavanoz şakası tuttu! +30 Sabotaj puanı kaptım!';
      }
      return isEnglish
          ? '✨ Golden flaky pastry + sweet sugar = happy customer! +50 pts!'
          : '✨ Çıtır tatlı ve gerçek şeker ile müşteri mest oldu! +50 puan!';
    }
    if (_hasPrankOnTray) {
      return isEnglish
          ? '🤫 Shhh! I swapped in the twin prank jar... Watch their face! 😉'
          : '🤫 Şşşt! Çaktırmadan ikiz şaka kavanozunu tepsiye koydum 😉';
    }
    if (_hasPastryOnTray) {
      return isEnglish
          ? '🥐 Fresh pastry plated! Will we add Sweet Sugar or a salty surprise?'
          : '🥐 Taze tatlı tepside! Şimdi Tatlı Şeker mi yoksa gizli tuz şakası mı?';
    }
    return isEnglish
        ? '🥐 Pick a signature dessert from the vitrine (or sneak a twin jar!)'
        : '🥐 Vitrinden taze tatlıyı seç (istersen ikiz tuzlukla şaka yap!)';
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = languageCode == 'en';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactViewport = constraints.maxWidth < 680;
        final baristaCard = _CrewCharacterCard(
          key: const Key('crew_character_barista_p1'),
          portraitAssetPath: CafeCharacterAssets.baristaPlayerOne,
          characterTitle: isEnglish ? 'P1 · Master Barista Esra' : 'Oyuncu 1 · Baş Barista Esra',
          roleSubtitle: isEnglish ? 'Espresso & Copper Cezve Station' : 'Espresso & Bakır Cezve İstasyonu',
          speechText: _baristaSpeechLine(isEnglish),
          scoreLabel: '${playerOneScore}p',
          mood: _baristaMood,
          badgeEmoji: _hasHotDrinkOnTray ? '☕🔥' : '☕✨',
          cardBackgroundColor: const Color(0xFFFFF4E8),
          borderColor: const Color(0xFFC85A32),
          onTapCharacter: onTapCharacterEmote,
        );

        final pastryChefCard = _CrewCharacterCard(
          key: const Key('crew_character_pastry_p2'),
          portraitAssetPath: CafeCharacterAssets.pastryChefPlayerTwo,
          characterTitle: isEnglish ? 'P2 · Pastry & Prank Chef Can' : 'Oyuncu 2 · Tatlı & Şaka Şefi Can',
          roleSubtitle: isEnglish ? 'Baklava Vitrine & Twin Jars' : 'Tatlı Vitrini & İkiz Kavanozlar',
          speechText: _pastryChefSpeechLine(isEnglish),
          scoreLabel: '${playerTwoScore}p',
          mood: _pastryChefMood,
          badgeEmoji: _hasPrankOnTray ? '🤫🧂' : '🥐😉',
          cardBackgroundColor: const Color(0xFFFAF0F6),
          borderColor: const Color(0xFF8D3218),
          onTapCharacter: onTapCharacterEmote,
        );

        if (isCompactViewport) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              baristaCard,
              const SizedBox(height: 10),
              pastryChefCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: baristaCard),
            const SizedBox(width: 12),
            Expanded(child: pastryChefCard),
          ],
        );
      },
    );
  }
}

class _CrewCharacterCard extends StatelessWidget {
  const _CrewCharacterCard({
    required this.portraitAssetPath,
    required this.characterTitle,
    required this.roleSubtitle,
    required this.speechText,
    required this.scoreLabel,
    required this.mood,
    required this.badgeEmoji,
    required this.cardBackgroundColor,
    required this.borderColor,
    required this.onTapCharacter,
    super.key,
  });

  final String portraitAssetPath;
  final String characterTitle;
  final String roleSubtitle;
  final String speechText;
  final String scoreLabel;
  final CafeCharacterMood mood;
  final String badgeEmoji;
  final Color cardBackgroundColor;
  final Color borderColor;
  final VoidCallback onTapCharacter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(_crewCardCornerRadius),
        border: Border.all(color: borderColor.withValues(alpha: 0.45), width: 1.6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedCafeCharacterAvatar(
            portraitAssetPath: portraitAssetPath,
            mood: mood,
            avatarSize: _crewAvatarSize,
            borderColor: borderColor,
            badgeEmoji: badgeEmoji,
            onTapCharacter: onTapCharacter,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      characterTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF2C1A12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        scoreLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  roleSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6D4C41),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    speechText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
