import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Full-stage 3-lane courtyard cafe runner game powered by Flame (`FlameGame`).
///
/// Players swipe left/right or tap any of the 3 wooden courtyard lanes to dash the
/// Barista character between:
/// - **Lane 0 (Left · Roasted Copper):** Steaming Coffee & Copper Cezve Drinks
/// - **Lane 1 (Center · Pistachio Sage):** Baklava, Katmer & Pastries
/// - **Lane 2 (Right · Warm Honey Amber):** Twin Sugar / Stealth Salt Jars
class SubwayBaristaFlameGame extends FlameGame with TapCallbacks, DragCallbacks {
  SubwayBaristaFlameGame({
    required this.onLaneTapped,
    required this.onSwipeServeRequested,
    CityEditionId initialCityId = CityEditionId.gaziantep,
  }) : _activeCityId = initialCityId;

  /// Callback fired when the player taps or dashes into one of the 3 lanes (`0`, `1`, or `2`).
  final ValueChanged<int> onLaneTapped;

  /// Callback fired when the player triggers a serve action from the stage.
  final VoidCallback onSwipeServeRequested;

  CityEditionId _activeCityId;
  int _activeRunnerLane = 0;
  double _runnerCurrentLanePosition = 0;
  double _runnerBouncePhase = 0;
  double _trackScrollDistance = 0;
  double _runnerJumpOffset = 0;
  double _runnerJumpVelocity = 0;
  double _horizontalDragAccumulator = 0;
  bool _hasDrinkPlated = false;
  bool _hasFoodPlated = false;
  bool _hasToppingPlated = false;
  bool _hasPrankOnTray = false;
  bool _isSippingTea = false;
  CafeReview? _latestReview;

  final List<_ArcadeFloatingBurst> _floatingBursts = <_ArcadeFloatingBurst>[];
  final List<_RollingTrackToken> _rollingTokens = <_RollingTrackToken>[
    _RollingTrackToken(
      laneIndex: 0,
      depthProgress: 0.16,
      accentColor: const Color(0xFFD98A4E),
    ),
    _RollingTrackToken(
      laneIndex: 0,
      depthProgress: 0.66,
      accentColor: const Color(0xFFD98A4E),
    ),
    _RollingTrackToken(
      laneIndex: 1,
      depthProgress: 0.38,
      accentColor: const Color(0xFF6BA368),
    ),
    _RollingTrackToken(
      laneIndex: 1,
      depthProgress: 0.88,
      accentColor: const Color(0xFF6BA368),
    ),
    _RollingTrackToken(
      laneIndex: 2,
      depthProgress: 0.28,
      accentColor: const Color(0xFFE0A952),
    ),
    _RollingTrackToken(
      laneIndex: 2,
      depthProgress: 0.78,
      accentColor: const Color(0xFFE0A952),
    ),
  ];

  /// Current lane index (`0` = Drink, `1` = Food, `2` = Twin Jar).
  int get activeRunnerLane => _activeRunnerLane;

  /// Number of active particle bursts on the Flame stage.
  int get activeBurstCount => _floatingBursts.length;

  @override
  Color backgroundColor() => const Color(0xFF2D1E17);

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
      _spawnVerdictExplosion(isSabotage: latestReview.isPrankCaught);
    }
  }

  /// Moves the Barista Runner to [targetLane] (`0..2`), triggers a hop impulse, and spawns warm sparkles.
  void dashToLane(int targetLane, {bool triggerCallback = true}) {
    final clampedLane = targetLane.clamp(0, 2);
    _activeRunnerLane = clampedLane;
    _runnerJumpVelocity = 215;
    _spawnLanePickupBurst(clampedLane);
    if (triggerCallback) {
      onLaneTapped(clampedLane);
    }
  }

  void _spawnLanePickupBurst(int laneIndex) {
    final burstColor = switch (laneIndex) {
      0 => const Color(0xFFE59A59),
      1 => const Color(0xFF7BB677),
      _ => _hasPrankOnTray ? const Color(0xFFD96852) : const Color(0xFFE8B86B),
    };
    _floatingBursts.add(
      _ArcadeFloatingBurst(
        laneIndex: laneIndex,
        color: burstColor,
        remainingLife: 0.75,
        maxLife: 0.75,
      ),
    );
  }

  void _spawnVerdictExplosion({required bool isSabotage}) {
    final explosionColor = isSabotage ? const Color(0xFFD96852) : const Color(0xFF7BB677);
    for (var laneIndex = 0; laneIndex < 3; laneIndex++) {
      _floatingBursts.add(
        _ArcadeFloatingBurst(
          laneIndex: laneIndex,
          color: explosionColor,
          remainingLife: 1.1,
          maxLife: 1.1,
        ),
      );
    }
    _runnerJumpVelocity = 245;
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
    const swipeThreshold = 34.0;
    if (_horizontalDragAccumulator <= -swipeThreshold) {
      _horizontalDragAccumulator = 0;
      dashToLane(_activeRunnerLane - 1);
    } else if (_horizontalDragAccumulator >= swipeThreshold) {
      _horizontalDragAccumulator = 0;
      dashToLane(_activeRunnerLane + 1);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _horizontalDragAccumulator = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final safeDt = dt.clamp(0.0, 0.05);
    final speedMultiplier = _latestReview != null ? 1.35 : (_isSippingTea ? 0.65 : 1.05);

    _trackScrollDistance = (_trackScrollDistance + safeDt * 0.95 * speedMultiplier) % 1.0;
    _runnerBouncePhase = (_runnerBouncePhase + safeDt * 9.0 * speedMultiplier) % (math.pi * 2);

    // Smoothly interpolate horizontal lane position
    final targetLaneDouble = _activeRunnerLane.toDouble();
    final laneDelta = targetLaneDouble - _runnerCurrentLanePosition;
    _runnerCurrentLanePosition += laneDelta * (safeDt * 14).clamp(0.0, 1.0);

    // Vertical hop arc physics
    if (_runnerJumpOffset > 0 || _runnerJumpVelocity > 0) {
      _runnerJumpOffset += _runnerJumpVelocity * safeDt;
      _runnerJumpVelocity -= 660 * safeDt;
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
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final stageRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final horizonY = size.y * 0.25;
    final trackBottomY = size.y * 0.97;

    // 1. Hogwarts Great Hall & Three Broomsticks Candlelit Stone Wall Backdrop
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF120D09),
          Color(0xFF211710),
          Color(0xFF18110C),
        ],
      ).createShader(stageRect);
    canvas.drawRect(stageRect, skyPaint);

    // 2. Gothic Stained-Glass Windows & Warm Hearth Glow along the Horizon
    final cityWarmColor = switch (_activeCityId) {
      CityEditionId.berlin => const Color(0xFFC59B27),
      CityEditionId.gaziantep => const Color(0xFFB86B2B),
      CityEditionId.adana => const Color(0xFF9E2A2B),
      CityEditionId.istanbul => const Color(0xFF3B7A57),
    };
    final horizonGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.48),
        radius: 0.82,
        colors: <Color>[
          cityWarmColor.withValues(alpha: 0.30),
          Colors.transparent,
        ],
      ).createShader(stageRect);
    canvas.drawRect(stageRect, horizonGlowPaint);

    // Draw Gothic pointed castle arches along the stone wall
    const archCount = 5;
    final archSpacing = size.x / archCount;
    for (var i = 0; i < archCount; i++) {
      final archCenterX = (i + 0.5) * archSpacing;
      final archWidth = archSpacing * 0.44;
      final archBottom = horizonY;
      final archTop = horizonY - 30;
      final gothicArch = Path()
        ..moveTo(archCenterX - archWidth * 0.5, archBottom)
        ..lineTo(archCenterX - archWidth * 0.5, archBottom - 16)
        ..quadraticBezierTo(archCenterX - archWidth * 0.45, archTop, archCenterX, archTop)
        ..quadraticBezierTo(
          archCenterX + archWidth * 0.45,
          archTop,
          archCenterX + archWidth * 0.5,
          archBottom - 16,
        )
        ..lineTo(archCenterX + archWidth * 0.5, archBottom)
        ..close();
      canvas
        ..drawPath(
          gothicArch,
          Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.13),
        )
        ..drawPath(
          gothicArch,
          Paint()
            ..color = const Color(0xFF8C6D2E).withValues(alpha: 0.38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
    }

    // Hovering Enchanted Great Hall Candles across the ceiling
    const candleCount = 7;
    for (var i = 1; i <= candleCount; i++) {
      final candleX = (size.x / (candleCount + 1)) * i;
      final bobOffset = math.sin(_runnerBouncePhase * 0.55 + i * 1.3) * 3.2;
      final candleTopY = 14.0 + (i.isEven ? 6.0 : 0.0) + bobOffset;
      final waxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(candleX - 2.2, candleTopY, 4.4, 13),
        const Radius.circular(1.5),
      );
      canvas
        // Soft candlelight aura
        ..drawCircle(
          Offset(candleX, candleTopY - 3),
          9.5,
          Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.20),
        )
        // Ivory beeswax candle stick
        ..drawRRect(
          waxRect,
          Paint()..color = const Color(0xFFEDE0C8),
        )
        // Flickering golden flame teardrop
        ..drawOval(
          Rect.fromCenter(center: Offset(candleX, candleTopY - 3.2), width: 3.6, height: 6.2),
          Paint()..color = const Color(0xFFF5B041),
        )
        ..drawCircle(
          Offset(candleX, candleTopY - 2.2),
          1.3,
          Paint()..color = const Color(0xFFFFF8E1),
        );
    }

    // Carved mahogany & brass wainscot molding along the horizon
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.x, horizonY),
      Paint()
        ..color = const Color(0xFF9C7A2E)
        ..strokeWidth = 2.5,
    );

    // 3. 3-Lane Perspective Castle Flagstone & Dark Oak Runway
    final topTrackWidth = size.x * 0.44;
    final bottomTrackWidth = size.x * 0.96;
    final centerX = size.x * 0.5;

    final trackTopLeft = Offset(centerX - topTrackWidth * 0.5, horizonY);
    final trackTopRight = Offset(centerX + topTrackWidth * 0.5, horizonY);
    final trackBottomLeft = Offset(centerX - bottomTrackWidth * 0.5, trackBottomY);
    final trackBottomRight = Offset(centerX + bottomTrackWidth * 0.5, trackBottomY);

    final runwayPath = Path()
      ..moveTo(trackTopLeft.dx, trackTopLeft.dy)
      ..lineTo(trackTopRight.dx, trackTopRight.dy)
      ..lineTo(trackBottomRight.dx, trackBottomRight.dy)
      ..lineTo(trackBottomLeft.dx, trackBottomLeft.dy)
      ..close();

    canvas.drawPath(
      runwayPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF2B2017),
            Color(0xFF221912),
            Color(0xFF18110C),
          ],
        ).createShader(stageRect),
    );

    // 4. Scrolling Ancient Flagstone Joints across the Great Hall Floor
    const plankCount = 8;
    for (var index = 0; index < plankCount; index++) {
      final rawDepth = ((index / plankCount) + _trackScrollDistance) % 1.0;
      final perspectiveDepth = rawDepth * rawDepth;
      final lineY = horizonY + (trackBottomY - horizonY) * perspectiveDepth;
      final currentHalfWidth = (topTrackWidth * 0.5) + ((bottomTrackWidth - topTrackWidth) * 0.5 * perspectiveDepth);

      final plankPaint = Paint()
        ..color = const Color(0xFFB89658).withValues(
          alpha: (0.10 + 0.22 * perspectiveDepth).clamp(0.0, 1.0),
        )
        ..strokeWidth = 1.1 + (2.0 * perspectiveDepth);
      canvas.drawLine(
        Offset(centerX - currentHalfWidth, lineY),
        Offset(centerX + currentHalfWidth, lineY),
        plankPaint,
      );
    }

    // 5. 3 House-Tinted Tavern Lanes (Gryffindor Copper, Hufflepuff Gold, Slytherin Apothecary)
    final thirdLaneColor = _hasPrankOnTray ? const Color(0xFF9E2A2B) : const Color(0xFF3B7A57);
    final laneAccentColors = <Color>[
      const Color(0xFFB86B2B),
      const Color(0xFFC59B27),
      thirdLaneColor,
    ];
    final lanePlatedFlags = <bool>[_hasDrinkPlated, _hasFoodPlated, _hasToppingPlated];

    for (var laneIndex = 0; laneIndex < 3; laneIndex++) {
      final topStartFraction = laneIndex / 3.0;
      final topEndFraction = (laneIndex + 1) / 3.0;

      final laneTopLeftX = trackTopLeft.dx + topTrackWidth * topStartFraction;
      final laneTopRightX = trackTopLeft.dx + topTrackWidth * topEndFraction;
      final laneBottomLeftX = trackBottomLeft.dx + bottomTrackWidth * topStartFraction;
      final laneBottomRightX = trackBottomLeft.dx + bottomTrackWidth * topEndFraction;

      final lanePath = Path()
        ..moveTo(laneTopLeftX, horizonY)
        ..lineTo(laneTopRightX, horizonY)
        ..lineTo(laneBottomRightX, trackBottomY)
        ..lineTo(laneBottomLeftX, trackBottomY)
        ..close();

      final isCurrentRunnerLane = _activeRunnerLane == laneIndex;
      final isPlated = lanePlatedFlags[laneIndex];
      final laneColor = laneAccentColors[laneIndex];

      canvas.drawPath(
        lanePath,
        Paint()
          ..color = laneColor.withValues(
            alpha: isCurrentRunnerLane ? 0.25 : (isPlated ? 0.14 : 0.05),
          )
          ..style = PaintingStyle.fill,
      );

      // Warm brass/wood divider rails along each lane
      final railPaint = Paint()
        ..color = laneColor.withValues(alpha: isCurrentRunnerLane ? 0.90 : 0.44)
        ..strokeWidth = isCurrentRunnerLane ? 3.0 : 1.5
        ..style = PaintingStyle.stroke;
      canvas
        ..drawLine(Offset(laneTopLeftX, horizonY), Offset(laneBottomLeftX, trackBottomY), railPaint)
        ..drawLine(
          Offset(laneTopRightX, horizonY),
          Offset(laneBottomRightX, trackBottomY),
          railPaint,
        );
    }

    // 6. Illustrated Rolling Cafe Items on the 3 Lanes (Coffee Cup, Baklava Diamond, Twin Jar)
    for (final token in _rollingTokens) {
      final depth = token.depthProgress * token.depthProgress;
      // Keep rolling tokens in the upper-to-mid runway so the lower dock stays clear
      final clampedDepth = (depth * 0.72).clamp(0.04, 0.72);
      final itemY = horizonY + (trackBottomY - horizonY) * clampedDepth;
      final trackWidthAtDepth = topTrackWidth + (bottomTrackWidth - topTrackWidth) * clampedDepth;
      final trackLeftAtDepth = centerX - (trackWidthAtDepth * 0.5);
      final laneCenterX = trackLeftAtDepth + trackWidthAtDepth * ((token.laneIndex + 0.5) / 3.0);
      final itemRadius = (7.5 + 14.5 * clampedDepth).clamp(7.5, 22.0);

      _drawRollingCafeItem(
        canvas: canvas,
        center: Offset(laneCenterX, itemY),
        radius: itemRadius,
        laneIndex: token.laneIndex,
        accentColor: laneAccentColors[token.laneIndex],
      );
    }

    // 7. Warm Golden Sparkle Rings on Lane Pickups / Verdict
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
      final ringRadius = 14.0 + (lifeProgress * 44.0);
      final ringAlpha = (1.0 - lifeProgress).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(burstCenterX, burstCenterY),
        ringRadius,
        Paint()
          ..color = burst.color.withValues(alpha: ringAlpha * 0.82)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * ringAlpha,
      );

      for (var sparkIndex = 0; sparkIndex < 6; sparkIndex++) {
        final angle = (sparkIndex * math.pi / 3) + (lifeProgress * 1.1);
        final sparkDistance = 8.0 + (lifeProgress * 34.0);
        final sparkOffset = Offset(
          burstCenterX + math.cos(angle) * sparkDistance,
          burstCenterY + math.sin(angle) * sparkDistance * 0.65,
        );
        canvas.drawCircle(
          sparkOffset,
          3.6 * ringAlpha,
          Paint()..color = const Color(0xFFFFECB3).withValues(alpha: ringAlpha),
        );
      }
    }

    // 8. Illustrated Barista Character Carrying the Wooden Serving Tray on the Active Lane
    const runnerDepth = 0.56;
    final runnerX = _laneCenterXAtDepth(
      laneIndex: _runnerCurrentLanePosition,
      depth: runnerDepth,
      centerX: centerX,
      topTrackWidth: topTrackWidth,
      bottomTrackWidth: bottomTrackWidth,
    );
    final baseRunnerY = horizonY + (trackBottomY - horizonY) * runnerDepth;
    final bounceOffset = math.sin(_runnerBouncePhase).abs() * 6.0;
    final runnerY = baseRunnerY - bounceOffset - (_runnerJumpOffset * 0.34);

    _drawBaristaRunnerWithWoodenTray(
      canvas: canvas,
      runnerX: runnerX,
      runnerY: runnerY,
      baseRunnerY: baseRunnerY,
      activeLaneColor: laneAccentColors[_activeRunnerLane],
    );
  }

  void _drawRollingCafeItem({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required int laneIndex,
    required Color accentColor,
  }) {
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.72),
          width: radius * 1.9,
          height: radius * 0.55,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.32),
      )
      ..drawCircle(
        center,
        radius,
        Paint()..color = const Color(0xFFF7EDE2),
      )
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );

    if (laneIndex == 0) {
      final cupRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 1),
          width: radius * 0.95,
          height: radius * 0.78,
        ),
        Radius.circular(radius * 0.2),
      );
      canvas
        ..drawRRect(cupRect, Paint()..color = const Color(0xFF6D4C41))
        ..drawCircle(
          Offset(center.dx, center.dy - radius * 0.12),
          radius * 0.28,
          Paint()..color = const Color(0xFFD98A4E),
        );
    } else if (laneIndex == 1) {
      final diamondPath = Path()
        ..moveTo(center.dx, center.dy - radius * 0.58)
        ..lineTo(center.dx + radius * 0.62, center.dy)
        ..lineTo(center.dx, center.dy + radius * 0.58)
        ..lineTo(center.dx - radius * 0.62, center.dy)
        ..close();
      canvas
        ..drawPath(diamondPath, Paint()..color = const Color(0xFFD99B4E))
        ..drawCircle(center, radius * 0.24, Paint()..color = const Color(0xFF5B8C5A));
    } else {
      final jarRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 1.5),
          width: radius * 0.82,
          height: radius * 0.92,
        ),
        Radius.circular(radius * 0.22),
      );
      canvas
        ..drawRRect(jarRect, Paint()..color = const Color(0xFFEAE0D5))
        ..drawRect(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy - radius * 0.36),
            width: radius * 0.68,
            height: radius * 0.24,
          ),
          Paint()..color = accentColor,
        );
    }
  }

  void _drawBaristaRunnerWithWoodenTray({
    required Canvas canvas,
    required double runnerX,
    required double runnerY,
    required double baseRunnerY,
    required Color activeLaneColor,
  }) {
    final strideSwing = math.sin(_runnerBouncePhase) * 5.0;

    // 1. Soft oval shadow on the Great Hall flagstone floor
    canvas
      ..drawOval(
        Rect.fromCenter(center: Offset(runnerX, baseRunnerY + 18), width: 66, height: 15),
        Paint()..color = Colors.black.withValues(alpha: 0.48),
      )
      // 2. Animated Running Wizard Boots
      ..drawOval(
        Rect.fromCenter(
          center: Offset(runnerX - 9, runnerY + 18 + strideSwing * 0.5),
          width: 11,
          height: 8,
        ),
        Paint()..color = const Color(0xFF231610),
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(runnerX + 9, runnerY + 18 - strideSwing * 0.5),
          width: 11,
          height: 8,
        ),
        Paint()..color = const Color(0xFF231610),
      );

    // 3. Hogwarts Wizarding Robe & Burgundy/Gold House Scarf
    final robeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(runnerX, runnerY + 2), width: 38, height: 26),
      const Radius.circular(12),
    );
    canvas
      ..drawRRect(robeRect, Paint()..color = const Color(0xFF1F1916))
      ..drawRRect(
        robeRect,
        Paint()
          ..color = const Color(0xFFC59B27)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      )
      // Gryffindor Burgundy & Gold Striped Scarf
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(runnerX, runnerY - 4), width: 28, height: 7),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF7A1C1C),
      )
      ..drawRect(
        Rect.fromCenter(center: Offset(runnerX - 5, runnerY - 4), width: 3, height: 7),
        Paint()..color = const Color(0xFFD4AF37),
      )
      ..drawRect(
        Rect.fromCenter(center: Offset(runnerX + 5, runnerY - 4), width: 3, height: 7),
        Paint()..color = const Color(0xFFD4AF37),
      )
      // 4. Barista Head & Pointed Hogwarts Wizard Hat
      ..drawCircle(
        Offset(runnerX, runnerY - 16),
        13,
        Paint()..color = const Color(0xFFEDC29E),
      )
      // Wizard Hat Brim
      ..drawOval(
        Rect.fromCenter(center: Offset(runnerX, runnerY - 24), width: 35, height: 7),
        Paint()..color = const Color(0xFF231A14),
      );
    // Pointed Wizard Hat Cone
    final wizardHatCone = Path()
      ..moveTo(runnerX - 11, runnerY - 24)
      ..lineTo(runnerX + 3, runnerY - 40)
      ..lineTo(runnerX + 11, runnerY - 24)
      ..close();
    canvas
      ..drawPath(wizardHatCone, Paint()..color = const Color(0xFF231A14))
      ..drawLine(
        Offset(runnerX - 10, runnerY - 25),
        Offset(runnerX + 10, runnerY - 25),
        Paint()
          ..color = activeLaneColor
          ..strokeWidth = 2.4,
      );

    // 5. Held Carved Oak & Tarnished Brass Serving Tray
    final trayRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(runnerX, runnerY + 10), width: 72, height: 15),
      const Radius.circular(8),
    );
    canvas
      ..drawRRect(trayRect, Paint()..color = const Color(0xFF3E2616))
      ..drawRRect(
        trayRect,
        Paint()
          ..color = const Color(0xFFC59B27)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    // 6. 3 Plated Mini Items sitting right on the Barista's Wooden Tray
    final slotColors = <Color>[
      if (_hasDrinkPlated) const Color(0xFFB86B2B) else const Color(0x44FFFFFF),
      if (_hasFoodPlated) const Color(0xFFC59B27) else const Color(0x44FFFFFF),
      if (_hasToppingPlated)
        (_hasPrankOnTray ? const Color(0xFF9E2A2B) : const Color(0xFF3B7A57))
      else
        const Color(0x44FFFFFF),
    ];
    for (var slotIndex = 0; slotIndex < 3; slotIndex++) {
      final slotCenter = Offset(runnerX + (slotIndex - 1) * 19.0, runnerY + 6);
      canvas
        ..drawCircle(slotCenter, 6.2, Paint()..color = slotColors[slotIndex])
        ..drawCircle(
          slotCenter,
          6.2,
          Paint()
            ..color = const Color(0xFFF3E5C8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
    }
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
    required this.accentColor,
  });

  final int laneIndex;
  double depthProgress;
  final Color accentColor;
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
