import 'package:flutter/material.dart';

/// Custom on-the-fly vector artwork kind generated during Build Round 2 in Google Antigravity.
enum CustomVectorArtworkKind {
  pistachioKatmerRoll,
  isotPepperShaker,
}

const double _customVectorIconSize = 56;
const double _customStrokeWidth = 2.5;

/// Renders the Round 2 on-the-fly custom signature dish and prank ingredient as pure vector graphics
/// so attendees never hit broken external image URLs on conference Wi-Fi.
class CustomVectorIngredientGraphic extends StatelessWidget {
  const CustomVectorIngredientGraphic({
    required this.artworkKind,
    this.size = _customVectorIconSize,
    super.key,
  });

  final CustomVectorArtworkKind artworkKind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CustomVectorIngredientPainter(artworkKind: artworkKind),
      ),
    );
  }
}

class _CustomVectorIngredientPainter extends CustomPainter {
  const _CustomVectorIngredientPainter({required this.artworkKind});

  final CustomVectorArtworkKind artworkKind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (artworkKind) {
      case CustomVectorArtworkKind.pistachioKatmerRoll:
        final backgroundPaint = Paint()..color = const Color(0xFFE8F5E9);
        final rimPaint = Paint()
          ..color = const Color(0xFF43A047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _customStrokeWidth;
        canvas.drawCircle(center, radius - 2, backgroundPaint);
        canvas.drawCircle(center, radius - 2, rimPaint);

        final pastryPaint = Paint()..color = const Color(0xFFD49B35);
        final creamPaint = Paint()..color = const Color(0xFFFFFDF7);
        final pistachioPaint = Paint()..color = const Color(0xFF2E7D32);

        final rollRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: size.width * 0.68, height: size.height * 0.36),
          const Radius.circular(12),
        );
        canvas.drawRRect(rollRect, pastryPaint);
        canvas.drawCircle(Offset(center.dx - 10, center.dy), 6, creamPaint);
        canvas.drawCircle(Offset(center.dx + 10, center.dy), 6, creamPaint);
        canvas.drawCircle(center, 7, pistachioPaint);

      case CustomVectorArtworkKind.isotPepperShaker:
        final backgroundPaint = Paint()..color = const Color(0xFFFFEBEE);
        final rimPaint = Paint()
          ..color = const Color(0xFFC62828)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _customStrokeWidth;
        canvas.drawCircle(center, radius - 2, backgroundPaint);
        canvas.drawCircle(center, radius - 2, rimPaint);

        final bottlePaint = Paint()..color = const Color(0xFF6A1B1A);
        final flakePaint = Paint()..color = const Color(0xFFFF7043);
        final bodyRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + 4),
            width: size.width * 0.44,
            height: size.height * 0.52,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(bodyRect, bottlePaint);
        canvas.drawCircle(Offset(center.dx - 5, center.dy + 2), 3, flakePaint);
        canvas.drawCircle(Offset(center.dx + 5, center.dy + 6), 3, flakePaint);
        canvas.drawCircle(Offset(center.dx, center.dy - 4), 3, flakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CustomVectorIngredientPainter oldDelegate) {
    return oldDelegate.artworkKind != artworkKind;
  }
}
