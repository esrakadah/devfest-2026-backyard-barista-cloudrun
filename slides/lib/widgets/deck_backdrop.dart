import 'dart:math' as math;

import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';

/// Full-slide backdrop behind every slide.
///
/// The default deck is a flat navy ground. The candle edition paints a warm glow, stars and a
/// thin gold frame on top of it.
class DeckBackdrop extends StatelessWidget {
  const DeckBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: DeckColors.navy,
      child: isCandleTheme ? CustomPaint(painter: _BackdropPainter(), child: SizedBox.expand()) : SizedBox.expand(),
    );
  }
}

/// The four Google colours as an ornamental rule: the four "houses" of the deck.
class HouseFlourish extends StatelessWidget {
  const HouseFlourish({this.width = 420, super.key});

  static const double _gemSize = 14;
  static const double _gemGap = 10;
  static const List<Color> houseColors = [
    DeckColors.coreBlue,
    DeckColors.coreRed,
    DeckColors.coreYellow,
    DeckColors.coreGreen,
  ];

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          for (final color in houseColors) ...[
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: _gemSize, height: _gemSize, color: color),
            ),
            const SizedBox(width: _gemGap),
          ],
          const SizedBox(width: _gemGap),
          Expanded(child: Container(height: 2, color: DeckColors.gold.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

/// A row of floating candles for the opening and closing slides of the candle edition.
class CandleRow extends StatelessWidget {
  const CandleRow({this.height = 190, this.clearCenter = false, super.key});

  final double height;

  /// Leaves the middle third free for a centred heading.
  final bool clearCenter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _CandlePainter(clearCenter: clearCenter)),
    );
  }
}

class _CandlePainter extends CustomPainter {
  const _CandlePainter({required this.clearCenter});

  final bool clearCenter;

  /// Horizontal position (0 to 1), top offset (0 to 1) and body length in logical pixels.
  static const List<(double, double, double)> _candles = [
    (0.04, 0.30, 62),
    (0.13, 0.05, 84),
    (0.23, 0.42, 54),
    (0.34, 0.12, 74),
    (0.46, 0.36, 58),
    (0.57, 0.02, 88),
    (0.68, 0.40, 56),
    (0.79, 0.14, 76),
    (0.89, 0.34, 60),
    (0.97, 0.08, 70),
  ];
  static const double _centerStart = 0.3;
  static const double _centerEnd = 0.72;
  static const double _bodyWidth = 13;
  static const double _flameHeight = 26;
  static const double _glowRadius = 70;
  static const Color _wax = Color(0xFFF3E7C9);
  static const Color _waxShade = Color(0xFFB9A77E);
  static const Color _flameCore = Color(0xFFFFF3C4);
  static const Color _flameEdge = Color(0xFFF2A33B);

  @override
  void paint(Canvas canvas, Size size) {
    for (final (dx, dy, length) in _candles) {
      if (clearCenter && dx > _centerStart && dx < _centerEnd) continue;
      final left = size.width * dx;
      final flameTop = size.height * dy;
      final bodyTop = flameTop + _flameHeight + 4;
      final flameCenter = Offset(left + _bodyWidth / 2, flameTop + _flameHeight * 0.62);

      canvas.drawCircle(
        flameCenter,
        _glowRadius,
        Paint()
          ..shader = RadialGradient(colors: [_flameEdge.withValues(alpha: 0.34), _flameEdge.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: flameCenter, radius: _glowRadius)),
      );

      final body = RRect.fromRectAndRadius(Rect.fromLTWH(left, bodyTop, _bodyWidth, length), const Radius.circular(3));
      canvas.drawRRect(
        body,
        Paint()..shader = const LinearGradient(colors: [_wax, _waxShade]).createShader(body.outerRect),
      );

      final flame = Path()
        ..moveTo(left + _bodyWidth / 2, flameTop)
        ..quadraticBezierTo(
          left + _bodyWidth + 4,
          flameTop + _flameHeight * 0.7,
          left + _bodyWidth / 2,
          flameTop + _flameHeight,
        )
        ..quadraticBezierTo(left - 4, flameTop + _flameHeight * 0.7, left + _bodyWidth / 2, flameTop)
        ..close();
      canvas.drawPath(
        flame,
        Paint()
          ..shader = const RadialGradient(center: Alignment(0, 0.4), colors: [_flameCore, _flameEdge])
              .createShader(flame.getBounds()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Clips its child to a portrait frame with an arched top.
class ArchClipper extends CustomClipper<Path> {
  const ArchClipper();

  @override
  Path getClip(Size size) {
    final radius = size.width / 2;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  static const int _starCount = 70;
  static const int _starSeed = 21;
  static const double _frameInset = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    _paintGlow(canvas, size, const Alignment(0.95, -1.1), const Color(0x40E9A23B));
    _paintGlow(canvas, size, const Alignment(-1.1, 1.2), const Color(0x1F4285F4));
    _paintStars(canvas, size);
    _paintFrame(canvas, bounds, DeckColors.gold.withValues(alpha: 0.55));
  }

  void _paintGlow(Canvas canvas, Size size, Alignment center, Color color) {
    final bounds = Offset.zero & size;
    final glow = Paint()
      ..shader =
          RadialGradient(center: center, radius: 0.9, colors: [color, const Color(0x00000000)]).createShader(bounds);
    canvas.drawRect(bounds, glow);
  }

  void _paintStars(Canvas canvas, Size size) {
    final random = math.Random(_starSeed);
    for (var index = 0; index < _starCount; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = math.pow(random.nextDouble(), 2.2).toDouble() * size.height * 0.5 + _frameInset * 2;
      final radius = size.width / 1920 * (0.8 + random.nextDouble() * 1.6);
      final alpha = 0.18 + random.nextDouble() * 0.4;
      canvas.drawCircle(Offset(dx, dy), radius, Paint()..color = DeckColors.offWhite.withValues(alpha: alpha));
    }
  }

  void _paintFrame(Canvas canvas, Rect bounds, Color color) {
    final scale = bounds.width / 1920;
    canvas.drawRect(
      bounds.deflate(_frameInset * scale),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
