import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

const double _laneDashJumpVelocity = 215;
const double _verdictJumpVelocity = 245;
const double _swipeThresholdPixels = 34;
const double _maxFrameDeltaSeconds = 0.05;
const double _runnerGravity = 660;
const double _horizonHeightRatio = 0.42;
const double _trackBottomHeightRatio = 0.98;
const int _floatingCandleCount = 11;
const int _steamPlumeCount = 5;
const int _runeGlyphCount = 8;
const double _topTrackWidthRatio = 0.34;
const double _bottomTrackWidthRatio = 0.94;
const double _runnerPerspectiveDepth = 0.56;

/// Full-stage 3-lane Universal Studios Hogsmeade cafe runner game powered by Flame (`FlameGame`).
///
/// Players swipe left/right or tap any of the 3 cobblestone lanes to dash the
/// Wizard Runner between:
/// - **Lane 0 (Left · Gryffindor Copper):** Steaming Coffee & Copper Cezve Drinks
/// - **Lane 1 (Center · Hufflepuff Gold):** Baklava, Katmer & Pastries
/// - **Lane 2 (Right · Slytherin Emerald):** Twin Sugar / Stealth Salt Jars
class SubwayBaristaFlameGame extends FlameGame with TapCallbacks, DragCallbacks {
  SubwayBaristaFlameGame({
    required this.onLaneTapped,
    required this.onSwipeServeRequested,
    CityEditionId initialCityId = CityEditionId.gaziantep,
  }) : _activeCityId = initialCityId;

  /// Callback fired when the player taps or dashes into one of the 3 lanes (`0`, `1`, or `2`).
  final ValueChanged<int> onLaneTapped;

  /// Callback fired when the player swipes upward on the stage to serve the plated tray.
  final VoidCallback onSwipeServeRequested;

  CityEditionId _activeCityId;
  int _activeRunnerLane = 0;
  double _runnerCurrentLanePosition = 0;
  double _runnerBouncePhase = 0;
  double _trackScrollDistance = 0;
  double _runnerJumpOffset = 0;
  double _runnerJumpVelocity = 0;
  double _horizontalDragAccumulator = 0;
  double _verticalDragAccumulator = 0;
  bool _hasDrinkPlated = false;
  bool _hasFoodPlated = false;
  bool _hasToppingPlated = false;
  bool _hasPrankOnTray = false;
  bool _isSippingTea = false;
  CafeReview? _latestReview;

  final List<_ArcadeFloatingBurst> _floatingBursts = <_ArcadeFloatingBurst>[];
  final List<_ActiveSpellBeam> _activeSpellBeams = <_ActiveSpellBeam>[];
  final List<_WandTrailSpark> _wandTrailSparks = <_WandTrailSpark>[];
  final List<_RollingTrackToken> _rollingTokens = <_RollingTrackToken>[
    _RollingTrackToken(laneIndex: 0, depthProgress: 0.16),
    _RollingTrackToken(laneIndex: 0, depthProgress: 0.66),
    _RollingTrackToken(laneIndex: 1, depthProgress: 0.38),
    _RollingTrackToken(laneIndex: 1, depthProgress: 0.88),
    _RollingTrackToken(laneIndex: 2, depthProgress: 0.28),
    _RollingTrackToken(laneIndex: 2, depthProgress: 0.78),
  ];

  /// Current lane index (`0` = Drink, `1` = Food, `2` = Twin Jar).
  int get activeRunnerLane => _activeRunnerLane;

  /// Number of active particle bursts on the Flame stage.
  int get activeBurstCount => _floatingBursts.length;

  /// Number of active wand spell beams on the Flame stage.
  int get activeSpellBeamCount => _activeSpellBeams.length;

  @override
  Color backgroundColor() => const Color(0x00000000);

  /// Synchronizes the Flame courtyard stage with the latest Flutter counter state.
  void syncArcadeState({
    required CityEditionId cityId,
    required List<CafeIngredient> selectedTray,
    required CafeReview? latestReview,
    required bool isSippingTea,
  }) {
    final hadDrink = _hasDrinkPlated;
    final hadFood = _hasFoodPlated;
    final hadTopping = _hasToppingPlated;
    final previousReview = _latestReview;

    _activeCityId = cityId;
    _hasDrinkPlated = selectedTray.any((item) => item.category == IngredientCategory.drink);
    _hasFoodPlated = selectedTray.any((item) => item.category == IngredientCategory.food);
    _hasToppingPlated = selectedTray.any(
      (item) => item.category == IngredientCategory.toppingOrPrank,
    );
    _hasPrankOnTray = selectedTray.any((item) => item.isPrankItem);
    _isSippingTea = isSippingTea;
    _latestReview = latestReview;

    if (_hasDrinkPlated && !hadDrink) {
      dashToLane(0, triggerCallback: false);
    } else if (_hasFoodPlated && !hadFood) {
      dashToLane(1, triggerCallback: false);
    } else if (_hasToppingPlated && !hadTopping) {
      dashToLane(2, triggerCallback: false);
    }

    if (latestReview != null && latestReview != previousReview) {
      _spawnVerdictExplosion(
        isSabotage: latestReview.isPrankCaught,
        isIncomplete: latestReview.isIncompleteTray,
      );
    }
  }

  /// Moves the Wizard Runner to [targetLane] (`0..2`), triggers a hop impulse, and spawns warm sparkles.
  void dashToLane(int targetLane, {bool triggerCallback = true}) {
    final clampedLane = targetLane.clamp(0, 2);
    _activeRunnerLane = clampedLane;
    _runnerJumpVelocity = _laneDashJumpVelocity;
    _spawnLanePickupBurst(clampedLane);
    if (triggerCallback) {
      onLaneTapped(clampedLane);
    }
  }

  void _spawnLanePickupBurst(int laneIndex) {
    final burstColor = switch (laneIndex) {
      0 => const Color(0xFFE08E45),
      1 => const Color(0xFFD4AF37),
      _ => _hasPrankOnTray ? const Color(0xFFD96852) : const Color(0xFF4E9F6E),
    };
    _floatingBursts.add(
      _ArcadeFloatingBurst(
        laneIndex: laneIndex,
        color: burstColor,
        remainingLife: 0.85,
        maxLife: 0.85,
      ),
    );
    _activeSpellBeams.add(
      _ActiveSpellBeam(
        fromLaneIndex: laneIndex,
        toLaneIndex: _activeRunnerLane,
        color: burstColor,
        remainingLife: 0.65,
        maxLife: 0.65,
      ),
    );
    for (var index = 0; index < 8; index++) {
      _wandTrailSparks.add(
        _WandTrailSpark(
          lanePosition: _runnerCurrentLanePosition,
          depthOffset: (index - 4) * 0.025,
          lateralJitter: math.sin(index * 1.7) * 18,
          verticalJitter: math.cos(index * 1.3) * 14,
          color: burstColor,
          remainingLife: 0.55 + (index * 0.04),
          maxLife: 0.55 + (index * 0.04),
        ),
      );
    }
  }

  void _spawnVerdictExplosion({
    required bool isSabotage,
    required bool isIncomplete,
  }) {
    final explosionColor = isSabotage
        ? const Color(0xFFD96852)
        : isIncomplete
            ? const Color(0xFFD4AF37)
            : const Color(0xFF4E9F6E);
    for (var laneIndex = 0; laneIndex < 3; laneIndex++) {
      _floatingBursts.add(
        _ArcadeFloatingBurst(
          laneIndex: laneIndex,
          color: explosionColor,
          remainingLife: 1.2,
          maxLife: 1.2,
        ),
      );
      _activeSpellBeams.add(
        _ActiveSpellBeam(
          fromLaneIndex: laneIndex,
          toLaneIndex: _activeRunnerLane,
          color: explosionColor,
          remainingLife: 0.95,
          maxLife: 0.95,
        ),
      );
    }
    _runnerJumpVelocity = _verdictJumpVelocity;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (size.x <= 0) {
      return;
    }
    final localPosition = event.localPosition;
    final thirdWidth = size.x / 3;
    final tappedLane = (localPosition.x / thirdWidth).floor().clamp(0, 2);
    dashToLane(tappedLane);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _horizontalDragAccumulator += event.localDelta.x;
    _verticalDragAccumulator += event.localDelta.y;
    if (_horizontalDragAccumulator <= -_swipeThresholdPixels) {
      _horizontalDragAccumulator = 0;
      if (_activeRunnerLane > 0) {
        dashToLane(_activeRunnerLane - 1);
      }
    } else if (_horizontalDragAccumulator >= _swipeThresholdPixels) {
      _horizontalDragAccumulator = 0;
      if (_activeRunnerLane < 2) {
        dashToLane(_activeRunnerLane + 1);
      }
    } else if (_verticalDragAccumulator <= -_swipeThresholdPixels) {
      _verticalDragAccumulator = 0;
      if (_hasDrinkPlated || _hasFoodPlated || _hasToppingPlated) {
        onSwipeServeRequested();
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _horizontalDragAccumulator = 0;
    _verticalDragAccumulator = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final safeDt = dt.clamp(0.0, _maxFrameDeltaSeconds);
    final speedMultiplier = _latestReview != null ? 1.35 : (_isSippingTea ? 0.65 : 1.05);

    _trackScrollDistance = (_trackScrollDistance + safeDt * 0.95 * speedMultiplier) % 1.0;
    _runnerBouncePhase = (_runnerBouncePhase + safeDt * 9.0 * speedMultiplier) % (math.pi * 2);

    // Smoothly interpolate horizontal lane position and spawn wand trail sparks while gliding
    final targetLaneDouble = _activeRunnerLane.toDouble();
    final laneDelta = targetLaneDouble - _runnerCurrentLanePosition;
    if (laneDelta.abs() > 0.04 && _wandTrailSparks.length < 36) {
      _wandTrailSparks.add(
        _WandTrailSpark(
          lanePosition: _runnerCurrentLanePosition,
          depthOffset: 0,
          lateralJitter: math.sin(_runnerBouncePhase * 2.3) * 12,
          verticalJitter: math.cos(_runnerBouncePhase * 1.9) * 10,
          color: const Color(0xFFD4AF37),
          remainingLife: 0.45,
          maxLife: 0.45,
        ),
      );
    }
    _runnerCurrentLanePosition += laneDelta * (safeDt * 14).clamp(0.0, 1.0);

    // Vertical hop arc physics
    if (_runnerJumpOffset > 0 || _runnerJumpVelocity > 0) {
      _runnerJumpOffset += _runnerJumpVelocity * safeDt;
      _runnerJumpVelocity -= _runnerGravity * safeDt;
      if (_runnerJumpOffset <= 0) {
        _runnerJumpOffset = 0;
        _runnerJumpVelocity = 0;
      }
    }

    // Advance rolling cafe items down the 3 perspective lanes
    for (final token in _rollingTokens) {
      token.depthProgress += safeDt * 0.32 * speedMultiplier;
      if (token.depthProgress >= 1.0) {
        token.depthProgress -= 1.0;
      }
    }

    // Update warm sparkle bursts
    for (var index = _floatingBursts.length - 1; index >= 0; index--) {
      final burst = _floatingBursts[index];
      burst.remainingLife -= safeDt;
      if (burst.remainingLife <= 0) {
        _floatingBursts.removeAt(index);
      }
    }

    // Update active spell beams
    for (var index = _activeSpellBeams.length - 1; index >= 0; index--) {
      final beam = _activeSpellBeams[index];
      beam.remainingLife -= safeDt;
      if (beam.remainingLife <= 0) {
        _activeSpellBeams.removeAt(index);
      }
    }

    // Update wand trail sparks
    for (var index = _wandTrailSparks.length - 1; index >= 0; index--) {
      final spark = _wandTrailSparks[index];
      spark.remainingLife -= safeDt;
      if (spark.remainingLife <= 0) {
        _wandTrailSparks.removeAt(index);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final stageRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final horizonY = size.y * _horizonHeightRatio;
    final trackBottomY = size.y * _trackBottomHeightRatio;

    // 1. Universal Studios Hogsmeade Twilight & Hogwarts Castle Translucent Glaze
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0x140B1328),
          Color(0x26141B2E),
          Color(0x6615100C),
        ],
      ).createShader(stageRect);
    canvas.drawRect(stageRect, skyPaint);

    // 2. Subtle Warm Hogsmeade Lantern Glow along the Horizon
    final cityWarmColor = switch (_activeCityId) {
      CityEditionId.berlin => const Color(0xFFC59B27),
      CityEditionId.gaziantep => const Color(0xFFB86B2B),
      CityEditionId.adana => const Color(0xFF9E2A2B),
      CityEditionId.istanbul => const Color(0xFF3B7A57),
    };
    final horizonGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.18),
        radius: 0.78,
        colors: <Color>[
          cityWarmColor.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(stageRect);
    canvas.drawRect(stageRect, horizonGlowPaint);

    // 2B. Hogwarts Castle Astronomy Tower Patronus / Lumos Aurora Ribbon across the upper sky
    _drawPatronusAuroraRibbon(canvas, size.x, horizonY);

    // 2C. Hogwarts Express 5972 Enchanted Steam Plumes rising from the left locomotive chimney
    _drawHogwartsExpressSteamPlumes(canvas, size.x, size.y);

    // Hovering Enchanted Great Hall Candles & Hogsmeade Snow Sparkles across the Twilight Sky
    for (var candleIndex = 1; candleIndex <= _floatingCandleCount; candleIndex++) {
      final candleX = (size.x / (_floatingCandleCount + 1)) * candleIndex;
      final bobOffset = math.sin(_runnerBouncePhase * 0.65 + candleIndex * 1.15) * 4.2;
      final candleTopY = 22.0 + (candleIndex.isEven ? 10.0 : 0.0) + bobOffset;
      final flameFlicker = 1.0 + math.sin(_runnerBouncePhase * 2.4 + candleIndex) * 0.22;
      final waxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(candleX - 2.2, candleTopY, 4.4, 13.5),
        const Radius.circular(1.6),
      );
      canvas
        // Outer golden Lumos candle halo
        ..drawCircle(
          Offset(candleX, candleTopY - 3.5),
          12.5 * flameFlicker,
          Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.26),
        )
        // Ivory beeswax candle stick
        ..drawRRect(
          waxRect,
          Paint()..color = const Color(0xFFF3E5C8),
        )
        // Flickering golden flame teardrop
        ..drawOval(
          Rect.fromCenter(
            center: Offset(candleX, candleTopY - 3.6),
            width: 3.8 * flameFlicker,
            height: 6.8 * flameFlicker,
          ),
          Paint()..color = const Color(0xFFF5B041),
        )
        ..drawCircle(
          Offset(candleX, candleTopY - 2.4),
          1.5,
          Paint()..color = const Color(0xFFFFF8E1),
        );
    }

    // 3. Subtle Ground Lantern Spotlights for the 3 Hogsmeade Station Lanes
    // (Leaves the Universal Studios Hogsmeade street, Hogwarts Express 5972 & Hogwarts Castle 100% unobstructed)
    final topTrackWidth = size.x * _topTrackWidthRatio;
    final bottomTrackWidth = size.x * _bottomTrackWidthRatio;
    final centerX = size.x * 0.5;

    final thirdLaneColor = _hasPrankOnTray ? const Color(0xFF9E2A2B) : const Color(0xFF4E9F6E);
    final laneAccentColors = <Color>[
      const Color(0xFFE08E45),
      const Color(0xFFD4AF37),
      thirdLaneColor,
    ];
    final lanePlatedFlags = <bool>[_hasDrinkPlated, _hasFoodPlated, _hasToppingPlated];

    for (var laneIndex = 0; laneIndex < 3; laneIndex++) {
      final isCurrentRunnerLane = _activeRunnerLane == laneIndex;
      final isPlated = lanePlatedFlags[laneIndex];
      final laneColor = laneAccentColors[laneIndex];
      final spotlightCenterX = _laneCenterXAtDepth(
        laneIndex: laneIndex.toDouble(),
        depth: _runnerPerspectiveDepth,
        centerX: centerX,
        topTrackWidth: topTrackWidth,
        bottomTrackWidth: bottomTrackWidth,
      );
      final spotlightCenterY = horizonY + (trackBottomY - horizonY) * _runnerPerspectiveDepth + 16;
      final spotlightRect = Rect.fromCenter(
        center: Offset(spotlightCenterX, spotlightCenterY),
        width: isCurrentRunnerLane ? 164 : 114,
        height: isCurrentRunnerLane ? 52 : 34,
      );

      canvas.drawOval(
        spotlightRect,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              laneColor.withValues(alpha: isCurrentRunnerLane ? 0.38 : (isPlated ? 0.22 : 0.10)),
              Colors.transparent,
            ],
          ).createShader(spotlightRect),
      );
    }

    // 4. Drifting Hogsmeade 4-Point Diamond Starlight Crystals along the 3 Lanes
    for (final token in _rollingTokens) {
      final depth = token.depthProgress * token.depthProgress;
      final clampedDepth = (depth * 0.72).clamp(0.08, 0.72);
      final itemY = horizonY + (trackBottomY - horizonY) * clampedDepth;
      final trackWidthAtDepth = topTrackWidth + (bottomTrackWidth - topTrackWidth) * clampedDepth;
      final trackLeftAtDepth = centerX - (trackWidthAtDepth * 0.5);
      final laneCenterX = trackLeftAtDepth + trackWidthAtDepth * ((token.laneIndex + 0.5) / 3.0);
      final moteRadius = (3.0 + 5.0 * clampedDepth).clamp(3.0, 8.0);

      _drawMagicalStarlightMote(
        canvas: canvas,
        center: Offset(laneCenterX, itemY),
        radius: moteRadius,
        accentColor: laneAccentColors[token.laneIndex],
      );
    }

    final runnerX = _laneCenterXAtDepth(
      laneIndex: _runnerCurrentLanePosition,
      depth: _runnerPerspectiveDepth,
      centerX: centerX,
      topTrackWidth: topTrackWidth,
      bottomTrackWidth: bottomTrackWidth,
    );
    final baseRunnerY = horizonY + (trackBottomY - horizonY) * _runnerPerspectiveDepth;
    final bounceOffset = math.sin(_runnerBouncePhase).abs() * 6.0;
    final runnerY = baseRunnerY - bounceOffset - (_runnerJumpOffset * 0.34);

    // 4B. Wand Trail Sparks behind Harry Potter when dashing across lanes
    for (final spark in _wandTrailSparks) {
      final alpha = (spark.remainingLife / spark.maxLife).clamp(0.0, 1.0);
      final sparkX = _laneCenterXAtDepth(
            laneIndex: spark.lanePosition,
            depth: (_runnerPerspectiveDepth + spark.depthOffset).clamp(0.2, 0.85),
            centerX: centerX,
            topTrackWidth: topTrackWidth,
            bottomTrackWidth: bottomTrackWidth,
          ) +
          spark.lateralJitter * (1.0 - alpha);
      final sparkY = runnerY + spark.verticalJitter * (1.0 - alpha);
      _drawFourPointStarSparkle(
        canvas: canvas,
        center: Offset(sparkX, sparkY),
        radius: 5.5 * alpha,
        color: spark.color.withValues(alpha: alpha * 0.9),
      );
    }

    // 4C. Curved Wingardium Leviosa / Lumos Maxima Spell Beams from Station Docks to Harry
    for (final beam in _activeSpellBeams) {
      final beamAlpha = (beam.remainingLife / beam.maxLife).clamp(0.0, 1.0);
      final originX = _laneCenterXAtDepth(
        laneIndex: beam.fromLaneIndex.toDouble(),
        depth: 0.94,
        centerX: centerX,
        topTrackWidth: topTrackWidth,
        bottomTrackWidth: bottomTrackWidth,
      );
      final originY = trackBottomY - 6;
      final controlPoint = Offset(
        (originX + runnerX) * 0.5,
        math.min(originY, runnerY) - 46.0,
      );
      final spellPath = Path()
        ..moveTo(originX, originY)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, runnerX, runnerY);

      canvas
        ..drawPath(
          spellPath,
          Paint()
            ..color = beam.color.withValues(alpha: beamAlpha * 0.48)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0 * beamAlpha
            ..strokeCap = StrokeCap.round,
        )
        ..drawPath(
          spellPath,
          Paint()
            ..color = const Color(0xFFFFF8E1).withValues(alpha: beamAlpha * 0.92)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * beamAlpha
            ..strokeCap = StrokeCap.round,
        );
    }

    // 5. Warm Golden Sparkle Rings on Lane Pickups / Verdict
    for (final burst in _floatingBursts) {
      final lifeProgress = 1.0 - (burst.remainingLife / burst.maxLife).clamp(0.0, 1.0);
      final burstCenterX = _laneCenterXAtDepth(
        laneIndex: burst.laneIndex.toDouble(),
        depth: 0.58,
        centerX: centerX,
        topTrackWidth: topTrackWidth,
        bottomTrackWidth: bottomTrackWidth,
      );
      final burstCenterY = horizonY + (trackBottomY - horizonY) * 0.58;
      final ringRadius = 14.0 + (lifeProgress * 48.0);
      final ringAlpha = (1.0 - lifeProgress).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(burstCenterX, burstCenterY),
        ringRadius,
        Paint()
          ..color = burst.color.withValues(alpha: ringAlpha * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 * ringAlpha,
      );

      for (var sparkIndex = 0; sparkIndex < 8; sparkIndex++) {
        final angle = (sparkIndex * math.pi / 4) + (lifeProgress * 1.3);
        final sparkDistance = 10.0 + (lifeProgress * 38.0);
        final sparkOffset = Offset(
          burstCenterX + math.cos(angle) * sparkDistance,
          burstCenterY + math.sin(angle) * sparkDistance * 0.65,
        );
        _drawFourPointStarSparkle(
          canvas: canvas,
          center: sparkOffset,
          radius: 5.2 * ringAlpha,
          color: const Color(0xFFFFECB3).withValues(alpha: ringAlpha),
        );
      }
    }

    // 6. Rotating Arcane Hogwarts Runic Circle & Orbiting Golden Snitch around the 3D Wizard Runner
    _drawRunnerMagicAuraRing(
      canvas: canvas,
      runnerX: runnerX,
      runnerY: runnerY,
      baseRunnerY: baseRunnerY,
      activeLaneColor: laneAccentColors[_activeRunnerLane],
    );
    _drawOrbitingGoldenSnitch(
      canvas: canvas,
      runnerX: runnerX,
      runnerY: runnerY,
    );
  }

  void _drawPatronusAuroraRibbon(Canvas canvas, double width, double horizonY) {
    final auroraPath = Path()..moveTo(width * 0.18, horizonY * 0.36);
    for (var step = 0; step <= 16; step++) {
      final ratio = step / 16.0;
      final x = width * (0.18 + ratio * 0.64);
      final wave = math.sin(_runnerBouncePhase * 0.45 + ratio * math.pi * 2.5) * 9.0;
      final y = (horizonY * 0.34) + wave;
      auroraPath.lineTo(x, y);
    }
    canvas
      ..drawPath(
        auroraPath,
        Paint()
          ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        auroraPath,
        Paint()
          ..color = const Color(0xFFD4AF37).withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
  }

  void _drawHogwartsExpressSteamPlumes(Canvas canvas, double width, double height) {
    final chimneyX = width * 0.18;
    final chimneyY = height * 0.44;
    for (var plumeIndex = 0; plumeIndex < _steamPlumeCount; plumeIndex++) {
      final progress = ((_trackScrollDistance * 0.8) + (plumeIndex / _steamPlumeCount)) % 1.0;
      final plumeX = chimneyX - (progress * 26.0) + math.sin(_runnerBouncePhase * 0.5 + plumeIndex) * 5.0;
      final plumeY = chimneyY - (progress * 52.0);
      final radius = 9.0 + (progress * 18.0);
      final alpha = (1.0 - progress) * 0.22;
      canvas.drawCircle(
        Offset(plumeX, plumeY),
        radius,
        Paint()..color = const Color(0xFFF3E5C8).withValues(alpha: alpha),
      );
    }
  }

  void _drawMagicalStarlightMote({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color accentColor,
  }) {
    canvas.drawCircle(
      center,
      radius * 2.2,
      Paint()..color = accentColor.withValues(alpha: 0.24),
    );
    _drawFourPointStarSparkle(
      canvas: canvas,
      center: center,
      radius: radius * 1.15,
      color: const Color(0xFFFFF8E1).withValues(alpha: 0.90),
    );
  }

  void _drawFourPointStarSparkle({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final inner = radius * 0.28;
    final starPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + inner, center.dy - inner)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + inner, center.dy + inner)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - inner, center.dy + inner)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - inner, center.dy - inner)
      ..close();
    canvas.drawPath(starPath, Paint()..color = color);
  }

  void _drawRunnerMagicAuraRing({
    required Canvas canvas,
    required double runnerX,
    required double runnerY,
    required double baseRunnerY,
    required Color activeLaneColor,
  }) {
    final pulse = 1.0 + math.sin(_runnerBouncePhase) * 0.08;
    final ringCenter = Offset(runnerX, runnerY + 14);
    final outerWidth = 108.0 * pulse;
    final outerHeight = 32.0 * pulse;

    // 1. Soft oval shadow on the Hogsmeade cobblestone floor
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(runnerX, baseRunnerY + 22),
          width: 92 * pulse,
          height: 24,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.45),
      )
      // 2. Outer Golden-House Hogwarts Runic Aura Ring under the 3D Wizard Runner
      ..drawOval(
        Rect.fromCenter(
          center: ringCenter,
          width: outerWidth,
          height: outerHeight,
        ),
        Paint()
          ..color = activeLaneColor.withValues(alpha: 0.68)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      )
      ..drawOval(
        Rect.fromCenter(
          center: ringCenter,
          width: 82 * pulse,
          height: 22 * pulse,
        ),
        Paint()
          ..color = const Color(0xFFD4AF37).withValues(alpha: 0.56)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

    // 3. Rotating 8-point Arcane Hogwarts Star Runes orbiting the aura ring
    for (var runeIndex = 0; runeIndex < _runeGlyphCount; runeIndex++) {
      final angle = (_runnerBouncePhase * 0.55) + (runeIndex * math.pi * 2 / _runeGlyphCount);
      final runeX = ringCenter.dx + math.cos(angle) * (outerWidth * 0.5);
      final runeY = ringCenter.dy + math.sin(angle) * (outerHeight * 0.5);
      _drawFourPointStarSparkle(
        canvas: canvas,
        center: Offset(runeX, runeY),
        radius: runeIndex.isEven ? 4.4 : 3.0,
        color: runeIndex.isEven ? const Color(0xFFFFECB3) : activeLaneColor,
      );
    }
  }

  void _drawOrbitingGoldenSnitch({
    required Canvas canvas,
    required double runnerX,
    required double runnerY,
  }) {
    final orbitAngle = _runnerBouncePhase * 1.15;
    final snitchX = runnerX + math.cos(orbitAngle) * 58.0;
    final snitchY = (runnerY - 22.0) + math.sin(orbitAngle * 2.0) * 14.0;
    final wingFlutter = math.sin(_runnerBouncePhase * 6.5) * 6.0;
    final snitchCenter = Offset(snitchX, snitchY);

    final leftWingPath = Path()
      ..moveTo(snitchX - 3, snitchY - 1)
      ..quadraticBezierTo(snitchX - 13, snitchY - 9 - wingFlutter, snitchX - 18, snitchY - 2 - wingFlutter)
      ..quadraticBezierTo(snitchX - 11, snitchY + 2, snitchX - 3, snitchY + 1)
      ..close();
    final rightWingPath = Path()
      ..moveTo(snitchX + 3, snitchY - 1)
      ..quadraticBezierTo(snitchX + 13, snitchY - 9 - wingFlutter, snitchX + 18, snitchY - 2 - wingFlutter)
      ..quadraticBezierTo(snitchX + 11, snitchY + 2, snitchX + 3, snitchY + 1)
      ..close();

    final wingPaint = Paint()..color = const Color(0xE6FFF8E1);
    canvas
      ..drawCircle(
        snitchCenter,
        10,
        Paint()..color = const Color(0x55D4AF37),
      )
      ..drawPath(leftWingPath, wingPaint)
      ..drawPath(rightWingPath, wingPaint)
      ..drawCircle(
        snitchCenter,
        4.2,
        Paint()..color = const Color(0xFFFFD54F),
      )
      ..drawCircle(
        Offset(snitchX - 1.2, snitchY - 1.2),
        1.4,
        Paint()..color = const Color(0xFFFFF8E1),
      );
  }

  double _laneCenterXAtDepth({
    required double laneIndex,
    required double depth,
    required double centerX,
    required double topTrackWidth,
    required double bottomTrackWidth,
  }) {
    final widthAtDepth = topTrackWidth + (bottomTrackWidth - topTrackWidth) * depth;
    final leftAtDepth = centerX - (widthAtDepth * 0.5);
    return leftAtDepth + widthAtDepth * ((laneIndex + 0.5) / 3.0);
  }
}

class _RollingTrackToken {
  _RollingTrackToken({
    required this.laneIndex,
    required this.depthProgress,
  });

  final int laneIndex;
  double depthProgress;
}

class _ArcadeFloatingBurst {
  _ArcadeFloatingBurst({
    required this.laneIndex,
    required this.color,
    required this.remainingLife,
    required this.maxLife,
  });

  final int laneIndex;
  final Color color;
  double remainingLife;
  final double maxLife;
}

class _ActiveSpellBeam {
  _ActiveSpellBeam({
    required this.fromLaneIndex,
    required this.toLaneIndex,
    required this.color,
    required this.remainingLife,
    required this.maxLife,
  });

  final int fromLaneIndex;
  final int toLaneIndex;
  final Color color;
  double remainingLife;
  final double maxLife;
}

class _WandTrailSpark {
  _WandTrailSpark({
    required this.lanePosition,
    required this.depthOffset,
    required this.lateralJitter,
    required this.verticalJitter,
    required this.color,
    required this.remainingLife,
    required this.maxLife,
  });

  final double lanePosition;
  final double depthOffset;
  final double lateralJitter;
  final double verticalJitter;
  final Color color;
  double remainingLife;
  final double maxLife;
}
