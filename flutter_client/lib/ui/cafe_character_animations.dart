import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/models/customer_order_ticket.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Total duration of the choreographed Turkish tea sipping animation (5.0 seconds).
const Duration kTeaSipAnimationDuration = Duration(seconds: 5);

const Duration _characterCycleDuration = Duration(milliseconds: 420);
const double _crewAvatarSize = 64;
const double _crewCardCornerRadius = 18;
const double _characterArchTopRadius = 38;
const double _characterArchBottomRadius = 14;
const double _jumpPeakPixels = 10;
const double _breathingAmplitudePixels = 4.5;
const double _shakeAmplitudePixels = 7;
const double _maxTiltRadians = 0.08;
const double _celebrationScaleBoost = 0.11;
const double _brewingScaleBoost = 0.07;
const double _lottieOverlayScaleFactor = 1.28;
const double _sipLiftPhaseEnd = 0.20;
const double _sipDrinkingPhaseEnd = 0.82;
const double _sipCupMaxTiltRadians = -0.52;
const double _totalSipSeconds = 5;

/// Bundled ready-made Lottie animation JSON assets under `assets/animations/`.
class CafeAnimationAssets {
  const CafeAnimationAssets._();

  static const String coffeeSteamLoop = 'assets/animations/coffee_steam_loop.json';
  static const String sweetCelebrationBurst = 'assets/animations/sweet_celebration_burst.json';
  static const String saltySpicyExplosion = 'assets/animations/salty_spicy_explosion.json';
  static const String baristaBrewingPulse = 'assets/animations/barista_brewing_pulse.json';
  static const String teaSipSteamLoop = 'assets/animations/tea_sip_steam_loop.json';
}

/// Live animation state for P1 Barista, P2 Pastry Chef, and the Customer in the Cafe Arch Window.
enum CafeCharacterMood {
  idleBreathing,
  talkingOrder,
  brewingActive,
  sippingTeaFiveSeconds,
  tastingPastryFiveSeconds,
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
      case CafeCharacterMood.sippingTeaFiveSeconds:
        return CafeAnimationAssets.teaSipSteamLoop;
      case CafeCharacterMood.tastingPastryFiveSeconds:
      case CafeCharacterMood.sweetCelebration:
        return CafeAnimationAssets.sweetCelebrationBurst;
      case CafeCharacterMood.saltySabotageShock:
        return CafeAnimationAssets.saltySpicyExplosion;
    }
  }
}

/// Returns true when running inside `flutter test` so animations never block `pumpAndSettle`.
bool get isRunningInAutomatedWidgetTest {
  final bindingTypeName = WidgetsBinding.instance.runtimeType.toString();
  return bindingTypeName.contains('Test');
}

/// Interactive 60fps animated character portrait combining 3D Pixar-style character art,
/// ready-made Lottie JSON overlays (`package:lottie`), procedural motion, and a
/// 5-second Turkish tulip-glass tea sipping (`İnce Belli Çay Yudumlama`) sequence.
class AnimatedCafeCharacterAvatar extends StatefulWidget {
  const AnimatedCafeCharacterAvatar({
    required this.portraitAssetPath,
    required this.mood,
    required this.avatarSize,
    required this.borderColor,
    this.badgeEmoji,
    this.isArchedWindow = false,
    this.isSippingTea = false,
    this.languageCode = 'tr',
    this.onTapCharacter,
    this.onSipTeaCompleted,
    super.key,
  });

  final String portraitAssetPath;
  final CafeCharacterMood mood;
  final double avatarSize;
  final Color borderColor;
  final String? badgeEmoji;
  final bool isArchedWindow;
  final bool isSippingTea;
  final String languageCode;
  final VoidCallback? onTapCharacter;
  final VoidCallback? onSipTeaCompleted;

  @override
  State<AnimatedCafeCharacterAvatar> createState() => _AnimatedCafeCharacterAvatarState();
}

class _AnimatedCafeCharacterAvatarState extends State<AnimatedCafeCharacterAvatar> with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _teaSipController;
  bool _isLocalSippingActive = false;

  bool get _effectiveSipping =>
      widget.isSippingTea || _isLocalSippingActive || widget.mood == CafeCharacterMood.sippingTeaFiveSeconds;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: _characterCycleDuration,
    );
    _teaSipController = AnimationController(
      vsync: this,
      duration: kTeaSipAnimationDuration,
    )..addStatusListener(_handleTeaSipStatus);

    _startCharacterMotion();
    if (widget.isSippingTea || widget.mood == CafeCharacterMood.sippingTeaFiveSeconds) {
      _triggerFiveSecondTeaSip();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCafeCharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isSippingTea && !oldWidget.isSippingTea) ||
        (widget.mood == CafeCharacterMood.sippingTeaFiveSeconds &&
            oldWidget.mood != CafeCharacterMood.sippingTeaFiveSeconds)) {
      _triggerFiveSecondTeaSip();
    } else if (!widget.isSippingTea && oldWidget.isSippingTea && _isLocalSippingActive) {
      setState(() {
        _isLocalSippingActive = false;
      });
      _teaSipController.reset();
    }
    if (oldWidget.mood != widget.mood || oldWidget.portraitAssetPath != widget.portraitAssetPath) {
      _startCharacterMotion();
    }
  }

  void _handleTeaSipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _isLocalSippingActive = false;
      });
      widget.onSipTeaCompleted?.call();
    }
  }

  void _triggerFiveSecondTeaSip() {
    setState(() {
      _isLocalSippingActive = true;
    });
    _teaSipController.forward(from: 0);
  }

  void _startCharacterMotion() {
    if (isRunningInAutomatedWidgetTest) {
      _motionController.forward(from: 0);
      return;
    }
    _motionController.repeat(reverse: true);
  }

  void _handleTap() {
    final tapCallback = widget.onTapCharacter;
    if (tapCallback != null) {
      tapCallback();
      return;
    }
    _triggerFiveSecondTeaSip();
  }

  IconData _resolveBadgeIcon(String badgeText, CafeCharacterMood activeMood) {
    if (_effectiveSipping) {
      return Icons.emoji_food_beverage_rounded;
    }
    if (activeMood == CafeCharacterMood.stealthPrankWink ||
        activeMood == CafeCharacterMood.saltySabotageShock ||
        badgeText.contains('🧂') ||
        badgeText.contains('🤫')) {
      return Icons.whatshot_rounded;
    }
    if (activeMood == CafeCharacterMood.tastingPastryFiveSeconds || badgeText.contains('🥐')) {
      return Icons.bakery_dining_rounded;
    }
    if (badgeText.contains('☕')) {
      return Icons.coffee_rounded;
    }
    if (badgeText.contains('🎤') || badgeText.contains('🎙️')) {
      return Icons.mic_rounded;
    }
    if (badgeText.contains('💻') || badgeText.contains('🤖')) {
      return Icons.terminal_rounded;
    }
    if (badgeText.contains('👓') || badgeText.contains('🌟')) {
      return Icons.workspace_premium_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  @override
  void dispose() {
    _teaSipController
      ..removeStatusListener(_handleTeaSipStatus)
      ..dispose();
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
    final activeMood = _effectiveSipping ? CafeCharacterMood.sippingTeaFiveSeconds : widget.mood;

    return Semantics(
      button: true,
      label: widget.languageCode == 'en'
          ? 'Character avatar, tap for 5-second Turkish tea sip'
          : 'Karakter portresi, 5 saniye çay yudumlatmak için dokunun',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_motionController, _teaSipController]),
            builder: (context, child) {
              final progress = _motionController.value;
              final sipProgress = _teaSipController.value;
              final sineWave = math.sin(progress * math.pi * 2);
              final halfWave = math.sin(progress * math.pi);

              var offsetX = 0.0;
              var offsetY = 0.0;
              var rotationRadians = 0.0;
              var scaleValue = 1.0;

              switch (activeMood) {
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
                case CafeCharacterMood.sippingTeaFiveSeconds:
                  // 3-phase 5-second sipping head & body choreography
                  if (sipProgress < _sipLiftPhaseEnd) {
                    final liftRatio = sipProgress / _sipLiftPhaseEnd;
                    offsetY = -3.5 * liftRatio;
                    rotationRadians = 0.05 * liftRatio;
                    scaleValue = 1.0 + (0.04 * liftRatio);
                  } else if (sipProgress < _sipDrinkingPhaseEnd) {
                    final drinkPhase = (sipProgress - _sipLiftPhaseEnd) / (_sipDrinkingPhaseEnd - _sipLiftPhaseEnd);
                    // 3 distinct sips across the drinking window
                    final sipPulse = math.sin(drinkPhase * math.pi * 3).abs();
                    offsetY = -3.5 - (4.0 * sipPulse);
                    rotationRadians = -0.09 * sipPulse;
                    scaleValue = 1.03 + (0.05 * sipPulse);
                  } else {
                    final finishRatio = (sipProgress - _sipDrinkingPhaseEnd) / (1.0 - _sipDrinkingPhaseEnd);
                    final happyNod = math.sin(finishRatio * math.pi * 2);
                    offsetY = -4.5 * (1.0 - finishRatio);
                    rotationRadians = 0.06 * happyNod;
                    scaleValue = 1.0 + (0.05 * (1.0 - finishRatio));
                  }
                case CafeCharacterMood.tastingPastryFiveSeconds:
                  offsetY = -halfWave * 6.0;
                  rotationRadians = sineWave * (_maxTiltRadians * 0.9);
                  scaleValue = 1.0 + (halfWave * 0.07);
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

              final remainingSeconds = (_totalSipSeconds * (1.0 - sipProgress)).clamp(0.0, _totalSipSeconds);
              final badgeEmoji = widget.badgeEmoji;

              return SizedBox(
                width: widget.avatarSize + 18,
                height: widget.avatarSize + 24,
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
                          activeMood.lottieAssetPath,
                          repeat: !isRunningInAutomatedWidgetTest,
                          animate: !isRunningInAutomatedWidgetTest,
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
                        size: Size(widget.avatarSize + 18, widget.avatarSize + 18),
                        painter: _CharacterMoodParticlePainter(
                          mood: activeMood,
                          progress: _effectiveSipping ? sipProgress : progress,
                        ),
                      ),
                    ),
                    // Layer 4: 5-Second Turkish Tulip Tea Glass (İnce Belli Çay Bardağı) Sipping Animation
                    if (_effectiveSipping)
                      IgnorePointer(
                        child: CustomPaint(
                          key: const Key('turkish_tea_sip_canvas'),
                          size: Size(widget.avatarSize + 28, widget.avatarSize + 28),
                          painter: _TurkishTeaGlassSipPainter(
                            sipProgress: sipProgress,
                          ),
                        ),
                      ),
                    // Layer 5: Live 5-Second Tea Sipping Countdown Pill ("🫖 Hüüüp! · 3.8s")
                    if (_effectiveSipping)
                      Positioned(
                        top: -12,
                        child: Container(
                          key: const Key('tea_sip_countdown_badge'),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[Color(0xFFB71C1C), Color(0xFFD84315)],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFFFF8EE), width: 1.5),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.languageCode == 'en'
                                ? '🫖 Sipping · ${remainingSeconds.toStringAsFixed(1)}s'
                                : '🫖 Hüüüp! · ${remainingSeconds.toStringAsFixed(1)}sn',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    // Layer 6: Character Persona / Mood Badge Pill
                    if (badgeEmoji != null)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Tooltip(
                          message: badgeEmoji,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
                            child: Icon(
                              _resolveBadgeIcon(badgeEmoji, activeMood),
                              size: 13,
                              color: widget.borderColor,
                            ),
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
                      color: const Color(0xFFC59B27),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a prominent Turkish tulip tea glass (`İnce Belli Çay Bardağı`), crimson-rimmed porcelain
/// saucer, silver spoon, curling white steam, and decreasing ruby-red tea level across the 5s sip.
class _TurkishTeaGlassSipPainter extends CustomPainter {
  const _TurkishTeaGlassSipPainter({
    required this.sipProgress,
  });

  final double sipProgress;

  @override
  void paint(Canvas canvas, Size size) {
    // Compute cup position & tilt across the 3 phases of the 5-second sip
    double liftProgress;
    double cupTiltRadians;

    if (sipProgress < _sipLiftPhaseEnd) {
      liftProgress = Curves.easeOutBack.transform((sipProgress / _sipLiftPhaseEnd).clamp(0.0, 1.0));
      cupTiltRadians = _sipCupMaxTiltRadians * 0.35 * liftProgress;
    } else if (sipProgress < _sipDrinkingPhaseEnd) {
      liftProgress = 1.0;
      final drinkWindow = (sipProgress - _sipLiftPhaseEnd) / (_sipDrinkingPhaseEnd - _sipLiftPhaseEnd);
      final sipWave = math.sin(drinkWindow * math.pi * 3).abs();
      cupTiltRadians = _sipCupMaxTiltRadians * (0.45 + 0.55 * sipWave);
    } else {
      final lowerWindow = (sipProgress - _sipDrinkingPhaseEnd) / (1.0 - _sipDrinkingPhaseEnd);
      liftProgress = 1.0 - Curves.easeInOut.transform(lowerWindow.clamp(0.0, 1.0));
      cupTiltRadians = _sipCupMaxTiltRadians * 0.25 * liftProgress;
    }

    // Start near bottom-right of avatar, lift toward the character's mouth (center-right)
    final startCenter = Offset(size.width * 0.80, size.height * 0.82);
    final mouthCenter = Offset(size.width * 0.62, size.height * 0.54);
    final cupCenter = Offset.lerp(startCenter, mouthCenter, liftProgress) ?? startCenter;

    // Tea liquid level drops from 88% full down to 24% full across the 5 seconds
    final teaFillFraction = (0.88 - (0.64 * sipProgress)).clamp(0.24, 0.88);

    canvas.save();
    canvas.translate(cupCenter.dx, cupCenter.dy);
    canvas.rotate(cupTiltRadians);
    canvas.scale(1.22);

    // 1. Porcelain Saucer (Çay Tabağı) with traditional crimson & gold rim
    final saucerRect = Rect.fromCenter(center: const Offset(0, 13), width: 34, height: 9);
    final saucerPaint = Paint()
      ..color = const Color(0xFFFFF8EE)
      ..style = PaintingStyle.fill;
    final saucerRimPaint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas
      ..drawOval(saucerRect, saucerPaint)
      ..drawOval(saucerRect, saucerRimPaint);

    // 2. Miniature Silver Tea Spoon resting on saucer
    final spoonPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(6, 12), const Offset(17, 8), spoonPaint);

    // 3. Tulip Tea Glass Outline (İnce Belli Çay Bardağı silhouette)
    final glassPath = Path()
      ..moveTo(-9.5, -12.5)
      ..cubicTo(-10.5, -5, -5.5, -1, -6.5, 4)
      ..cubicTo(-8.5, 8, -9.5, 11, -7.5, 12.5)
      ..lineTo(7.5, 12.5)
      ..cubicTo(9.5, 11, 8.5, 8, 6.5, 4)
      ..cubicTo(5.5, -1, 10.5, -5, 9.5, -12.5)
      ..close();

    // 4. Ruby-Red Turkish Tea Fill (Tavşan Kanı Çay) clipped inside the tulip glass
    canvas.save();
    canvas.clipPath(glassPath);
    final teaTopY = 12.5 - (25.0 * teaFillFraction);
    final teaRect = Rect.fromLTRB(-12, teaTopY, 12, 13);
    final teaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFE64A19),
          Color(0xFF8E0000),
        ],
      ).createShader(teaRect);
    canvas.drawRect(teaRect, teaPaint);

    // Tea surface meniscus highlight
    final meniscusPaint = Paint()
      ..color = const Color(0xFFFFCCBC).withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, teaTopY), width: 15, height: 3.4),
      meniscusPaint,
    );
    canvas.restore();

    // 5. Glass rim & specular highlight
    final glassFillPaint = Paint()
      ..color = const Color(0x38FFFFFF)
      ..style = PaintingStyle.fill;
    final glassBorderPaint = Paint()
      ..color = const Color(0xFFFFECB3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas
      ..drawPath(glassPath, glassFillPaint)
      ..drawPath(glassPath, glassBorderPaint);

    // Gold rim band at top of tulip glass
    final rimOval = Rect.fromCenter(center: const Offset(0, -12.5), width: 19, height: 3.6);
    final goldRimPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawOval(rimOval, goldRimPaint);

    // 6. Curling Hot Steam Ribbons above the tea glass
    final steamWave = math.sin(sipProgress * math.pi * 8);
    final steamPaint = Paint()
      ..color = const Color(0xEEFFF8E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftSteam = Path()
      ..moveTo(-4, -15)
      ..quadraticBezierTo(-7 + (steamWave * 2.5), -21, -3, -27);
    final rightSteam = Path()
      ..moveTo(4, -15)
      ..quadraticBezierTo(7 - (steamWave * 2.5), -22, 3, -28);
    canvas
      ..drawPath(leftSteam, steamPaint)
      ..drawPath(rightSteam, steamPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TurkishTeaGlassSipPainter oldDelegate) {
    return oldDelegate.sipProgress != sipProgress;
  }
}

class _CharacterMoodParticlePainter extends CustomPainter {
  const _CharacterMoodParticlePainter({
    required this.mood,
    required this.progress,
  });

  final CafeCharacterMood mood;
  final double progress;

  void _drawStarSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final inner = radius * 0.28;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + inner, center.dy - inner)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + inner, center.dy + inner)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - inner, center.dy + inner)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - inner, center.dy - inner)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Orbiting Lumos wand sparkles around every character window
    final orbitAngle = progress * math.pi * 2;
    final leftSparkCenter = Offset(
      6 + math.sin(orbitAngle) * 3,
      size.height * 0.30 - (progress * 8),
    );
    final rightSparkCenter = Offset(
      size.width - 6 - math.cos(orbitAngle) * 3,
      size.height * 0.24 - (progress * 7),
    );
    _drawStarSparkle(canvas, leftSparkCenter, 4.8, const Color(0xFFFFD54F));
    _drawStarSparkle(canvas, rightSparkCenter, 4.2, const Color(0xFFFFF8E1));

    switch (mood) {
      case CafeCharacterMood.sweetCelebration:
      case CafeCharacterMood.tastingPastryFiveSeconds:
        _drawStarSparkle(
          canvas,
          Offset(10, size.height * 0.16 - (progress * 8)),
          5.8,
          const Color(0xFFFFB300),
        );
        _drawStarSparkle(
          canvas,
          Offset(size.width - 10, size.height * 0.18 - (progress * 9)),
          5.2,
          const Color(0xFF4E9F6E),
        );
      case CafeCharacterMood.sippingTeaFiveSeconds:
        // Warm ruby & golden aroma sparkles rising during the 5s tea sip
        final floatOffset = (progress * 24) % 16;
        _drawStarSparkle(
          canvas,
          Offset(10, size.height * 0.26 - floatOffset),
          5.2,
          const Color(0xFFFFB300),
        );
        _drawStarSparkle(
          canvas,
          Offset(size.width - 10, size.height * 0.22 - floatOffset * 0.8),
          5.5,
          const Color(0xFFFFCCBC),
        );
      case CafeCharacterMood.saltySabotageShock:
        _drawStarSparkle(
          canvas,
          Offset(6, size.height * 0.18 - (progress * 7)),
          5.8,
          const Color(0xFFD32F2F),
        );
        _drawStarSparkle(
          canvas,
          Offset(size.width - 6, size.height * 0.16 - (progress * 7)),
          5.4,
          const Color(0xFFFF7043),
        );
      case CafeCharacterMood.stealthPrankWink:
        _drawStarSparkle(
          canvas,
          Offset(size.width - 8, 10 - (progress * 4)),
          4.8,
          const Color(0xFFFF8F00),
        );
      case CafeCharacterMood.idleBreathing:
      case CafeCharacterMood.talkingOrder:
      case CafeCharacterMood.brewingActive:
        _drawStarSparkle(
          canvas,
          Offset(size.width * 0.24, 6 - (progress * 4)),
          4.2,
          const Color(0xCCFFF3E0),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterMoodParticlePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.progress != progress;
  }
}

/// Interactive 2-Player Crew Character Stage displaying P1 Barista (Esra) and
/// P2 Pastry & Prank Chef (Can) with animated 3D portraits, Lottie effects, and
/// a 5-second Turkish Tea Sipping (`5sn Çay Yudumlama`) animation trigger.
class CafeCrewCharacterStage extends StatelessWidget {
  const CafeCrewCharacterStage({
    required this.languageCode,
    required this.selectedTray,
    required this.latestReview,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.onTapCharacterEmote,
    this.isCrewSippingTea = false,
    this.onTriggerFiveSecondTeaSip,
    this.onSipTeaCompleted,
    super.key,
  });

  final String languageCode;
  final List<CafeIngredient> selectedTray;
  final CafeReview? latestReview;
  final int playerOneScore;
  final int playerTwoScore;
  final VoidCallback onTapCharacterEmote;
  final bool isCrewSippingTea;
  final VoidCallback? onTriggerFiveSecondTeaSip;
  final VoidCallback? onSipTeaCompleted;

  bool get _hasHotDrinkOnTray =>
      selectedTray.any((ingredient) => ingredient.category == IngredientCategory.drink && ingredient.isHotDrink);

  bool get _hasPastryOnTray => selectedTray.any((ingredient) => ingredient.category == IngredientCategory.food);

  bool get _hasPrankOnTray => selectedTray.any((ingredient) => ingredient.isPrankItem);

  CafeCharacterMood get _baristaMood {
    if (isCrewSippingTea) {
      return CafeCharacterMood.sippingTeaFiveSeconds;
    }
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return CafeCharacterMood.saltySabotageShock;
      }
      if (currentReview.isIncompleteTray) {
        return CafeCharacterMood.idleBreathing;
      }
      return CafeCharacterMood.sweetCelebration;
    }
    if (_hasHotDrinkOnTray) {
      return CafeCharacterMood.brewingActive;
    }
    return CafeCharacterMood.idleBreathing;
  }

  CafeCharacterMood get _pastryChefMood {
    if (isCrewSippingTea) {
      return CafeCharacterMood.sippingTeaFiveSeconds;
    }
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return CafeCharacterMood.stealthPrankWink;
      }
      if (currentReview.isIncompleteTray) {
        return CafeCharacterMood.idleBreathing;
      }
      return CafeCharacterMood.sweetCelebration;
    }
    if (_hasPrankOnTray) {
      return CafeCharacterMood.stealthPrankWink;
    }
    if (_hasPastryOnTray) {
      return CafeCharacterMood.tastingPastryFiveSeconds;
    }
    return CafeCharacterMood.idleBreathing;
  }

  String _baristaSpeechLine(bool isEnglish) {
    if (isCrewSippingTea) {
      return isEnglish
          ? '🫖 Siiip... Ah! Nothing beats 5 seconds of hot Turkish tulip-glass tea on stage!'
          : '🫖 Hüüüp... Ohhh! Tezgah başında 5 saniye ince belli demli çay keyfi gibisi yok!';
    }
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return isEnglish
            ? '😱 Hey! Who sneaked salt or chili into my specialty coffee?!'
            : '😱 Eyvah! Özenle demlediğim kahveye kim tuz/biber karıştırdı?!';
      }
      if (currentReview.isIncompleteTray) {
        return isEnglish
            ? '🧩 Hold on! Plate all 3 stations (Drink + Pastry + Sugar) for 5 stars! (+15 pts)'
            : '🧩 Tepside eksik istasyon var! 5 yıldız için içecek, tatlı ve şekeri birlikte dizelim! (+15p)';
      }
      return isEnglish
          ? '🎉 5-Star Sweet Perfection! Our espresso crema is unbeatable!'
          : '🎉 5 Yıldız Tatlı Mükemmellik! Cezve ve espresso tam kıvamında!';
    }
    if (_hasHotDrinkOnTray) {
      return isEnglish
          ? 'Steaming hot coffee is on the tray! Ready to serve!'
          : 'Sıcak kahve tepside tütüyor! Tatlı ve şekerle servise hazır!';
    }
    return isEnglish
        ? 'Tap a coffee on my bar (or tap me for a 5s tea sip break!)'
        : 'Kahve barından içeceği seç (veya bana tıklayıp 5sn çay yudumlat!)';
  }

  String _pastryChefSpeechLine(bool isEnglish) {
    if (isCrewSippingTea) {
      return isEnglish
          ? '🫖 Siiip... Pairing hot ruby tea with fresh pistachio baklava for 5 seconds! ✨'
          : '🫖 Hüüüp... Çıtır fıstıklı baklava yanında 5 saniye tavşan kanı çay molası! ✨';
    }
    final currentReview = latestReview;
    if (currentReview != null) {
      if (currentReview.isPrankCaught) {
        return isEnglish
            ? 'Hehehe! Twin jar prank worked! +30 Sabotage points for P2!'
            : 'Hehehe! İkiz kavanoz şakası tuttu! +30 Sabotaj puanı kaptım!';
      }
      if (currentReview.isIncompleteTray) {
        return isEnglish
            ? '🧩 Missing a course on the wooden tray! Add the missing station for 5 stars! (+15 pts)'
            : '🧩 Tepsideki 3 istasyondan biri eksik kaldı! Tam tepsiyle 5 yıldızı kapalım! (+15p)';
      }
      return isEnglish
          ? 'Golden flaky pastry + sweet sugar = happy customer! +50 pts!'
          : 'Çıtır tatlı ve gerçek şeker ile müşteri mest oldu! +50 puan!';
    }
    if (_hasPrankOnTray) {
      return isEnglish
          ? 'Shhh! I swapped in the twin prank jar... Watch their face!'
          : 'Şşşt! Çaktırmadan ikiz şaka kavanozunu tepsiye koydum!';
    }
    if (_hasPastryOnTray) {
      return isEnglish
          ? 'Fresh pastry plated! Will we add Sweet Sugar or a salty surprise?'
          : 'Taze tatlı tepside! Şimdi Tatlı Şeker mi yoksa gizli tuz şakası mı?';
    }
    return isEnglish
        ? 'Pick a signature dessert from the vitrine (or sneak a twin jar!)'
        : 'Vitrinden taze tatlıyı seç (istersen ikiz tuzlukla şaka yap!)';
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
          characterTitle: isEnglish ? 'P1 · Master Barista Esra' : 'P1 · Barista Esra',
          roleSubtitle:
              isEnglish ? 'Station 1 · Three Broomsticks Espresso Bar' : 'İstasyon 1 · Üç Süpürge Kahve & İksir Barı',
          speechText: _baristaSpeechLine(isEnglish),
          scoreLabel: '${playerOneScore}p',
          mood: _baristaMood,
          badgeEmoji: _hasHotDrinkOnTray ? '☕🔥' : '☕✨',
          cardBackgroundColor: const Color(0xCC141B2D),
          borderColor: const Color(0xFFD4AF37),
          houseAccentColor: const Color(0xFF7A1C1C),
          languageCode: languageCode,
          isSippingTea: isCrewSippingTea,
          onTapCharacter: onTriggerFiveSecondTeaSip ?? onTapCharacterEmote,
          onSipTeaCompleted: onSipTeaCompleted,
        );

        final pastryChefCard = _CrewCharacterCard(
          key: const Key('crew_character_pastry_p2'),
          portraitAssetPath: CafeCharacterAssets.pastryChefPlayerTwo,
          characterTitle: isEnglish ? 'P2 · Apothecary & Pastry Can' : 'P2 · Tatlı & Şaka Can',
          roleSubtitle:
              isEnglish ? 'Station 2 & 3 · Honeydukes & Twin Jars' : 'İstasyon 2 & 3 · Honeydukes Tatlı & İkiz Kavanoz',
          speechText: _pastryChefSpeechLine(isEnglish),
          scoreLabel: '${playerTwoScore}p',
          mood: _pastryChefMood,
          badgeEmoji: _hasPrankOnTray ? '🤫🧂' : '🥐😉',
          cardBackgroundColor: const Color(0xCC12221D),
          borderColor: const Color(0xFFD4AF37),
          houseAccentColor: const Color(0xFF28593E),
          languageCode: languageCode,
          isSippingTea: isCrewSippingTea,
          onTapCharacter: onTriggerFiveSecondTeaSip ?? onTapCharacterEmote,
          onSipTeaCompleted: onSipTeaCompleted,
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

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: baristaCard),
              const SizedBox(width: 12),
              Expanded(child: pastryChefCard),
            ],
          ),
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
    required this.houseAccentColor,
    required this.languageCode,
    required this.isSippingTea,
    required this.onTapCharacter,
    this.onSipTeaCompleted,
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
  final Color houseAccentColor;
  final String languageCode;
  final bool isSippingTea;
  final VoidCallback onTapCharacter;
  final VoidCallback? onSipTeaCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(_crewCardCornerRadius),
        border: Border.all(color: borderColor.withValues(alpha: 0.82), width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0xFF0E0906),
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          AnimatedCafeCharacterAvatar(
            portraitAssetPath: portraitAssetPath,
            mood: mood,
            avatarSize: _crewAvatarSize,
            borderColor: borderColor,
            badgeEmoji: badgeEmoji,
            languageCode: languageCode,
            isSippingTea: isSippingTea,
            onTapCharacter: onTapCharacter,
            onSipTeaCompleted: onSipTeaCompleted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        characterTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFFF3E5C8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: houseAccentColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: borderColor, width: 1.2),
                      ),
                      child: Text(
                        scoreLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF3E5C8),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  roleSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xD90E1525),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF9C7A2E), width: 1.2),
                  ),
                  child: Text(
                    speechText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3E5C8),
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

/// Full-viewport 60fps Universal Studios Hogsmeade & Hogwarts Castle Magical Atmosphere Overlay.
///
/// Renders drifting Hogsmeade snow-starlight motes, golden Lumos wand fireflies,
/// and interactive spell-cast aura waves across the full screen without blocking pointer events.
class MagicalHogsmeadeAtmosphereOverlay extends StatefulWidget {
  const MagicalHogsmeadeAtmosphereOverlay({
    required this.platedItemCount,
    required this.isSippingTea,
    required this.hasActiveReview,
    required this.isSabotageReview,
    super.key,
  });

  final int platedItemCount;
  final bool isSippingTea;
  final bool hasActiveReview;
  final bool isSabotageReview;

  @override
  State<MagicalHogsmeadeAtmosphereOverlay> createState() => _MagicalHogsmeadeAtmosphereOverlayState();
}

class _MagicalHogsmeadeAtmosphereOverlayState extends State<MagicalHogsmeadeAtmosphereOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _atmosphereController;

  @override
  void initState() {
    super.initState();
    _atmosphereController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (isRunningInAutomatedWidgetTest) {
      _atmosphereController.value = 0.42;
    } else {
      _atmosphereController.repeat();
    }
  }

  @override
  void dispose() {
    _atmosphereController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _atmosphereController,
          builder: (context, _) {
            return CustomPaint(
              key: const Key('magical_hogsmeade_atmosphere_overlay'),
              size: Size.infinite,
              painter: _MagicalHogsmeadeAtmospherePainter(
                phase: _atmosphereController.value * math.pi * 2,
                platedItemCount: widget.platedItemCount,
                isSippingTea: widget.isSippingTea,
                hasActiveReview: widget.hasActiveReview,
                isSabotageReview: widget.isSabotageReview,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MagicalHogsmeadeAtmospherePainter extends CustomPainter {
  const _MagicalHogsmeadeAtmospherePainter({
    required this.phase,
    required this.platedItemCount,
    required this.isSippingTea,
    required this.hasActiveReview,
    required this.isSabotageReview,
  });

  final double phase;
  final int platedItemCount;
  final bool isSippingTea;
  final bool hasActiveReview;
  final bool isSabotageReview;

  static const int _starlightFireflyCount = 28;

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final inner = radius * 0.26;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + inner, center.dy - inner)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + inner, center.dy + inner)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - inner, center.dy + inner)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - inner, center.dy - inner)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    // 1. Drifting Hogsmeade Snow-Starlight & Golden Lumos Fireflies across the full viewport
    for (var index = 0; index < _starlightFireflyCount; index++) {
      final seed = index * 1.6180339;
      final normalizedX = ((seed * 0.37) + math.sin(phase * 0.5 + index) * 0.03) % 1.0;
      final normalizedY = ((seed * 0.53) + (phase / (math.pi * 2)) * (0.35 + (index % 3) * 0.15)) % 1.0;
      final x = normalizedX * size.width;
      final y = normalizedY * size.height;
      final twinkle = 0.45 + 0.55 * math.sin(phase * 2.0 + index * 1.3).abs();
      final isGoldenLumos = index % 3 != 0;
      final baseColor = isSabotageReview && index.isEven
          ? const Color(0xFFFF7043)
          : isGoldenLumos
              ? const Color(0xFFFFD54F)
              : const Color(0xFFE0F2FE);

      canvas.drawCircle(
        Offset(x, y),
        (isGoldenLumos ? 7.5 : 5.5) * twinkle,
        Paint()..color = baseColor.withValues(alpha: 0.16 * twinkle),
      );
      _drawStar(
        canvas,
        Offset(x, y),
        (isGoldenLumos ? 4.4 : 3.2) * twinkle,
        baseColor.withValues(alpha: 0.72 * twinkle),
      );
    }

    // 2. Interactive Spell Resonance Rings when tray items are plated, tea is sipped, or verdict is active
    if (platedItemCount > 0 || isSippingTea || hasActiveReview) {
      final spellColor = isSabotageReview
          ? const Color(0xFFD96852)
          : isSippingTea
              ? const Color(0xFFFFB300)
              : const Color(0xFFD4AF37);
      final ringPulse = (phase / (math.pi * 2)) % 1.0;
      final maxRadius = math.min(size.width, size.height) * 0.42;
      final currentRadius = 40.0 + (ringPulse * maxRadius);
      final ringAlpha = (1.0 - ringPulse) * 0.24;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.48),
        currentRadius,
        Paint()
          ..color = spellColor.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MagicalHogsmeadeAtmospherePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.platedItemCount != platedItemCount ||
        oldDelegate.isSippingTea != isSippingTea ||
        oldDelegate.hasActiveReview != hasActiveReview ||
        oldDelegate.isSabotageReview != isSabotageReview;
  }
}
