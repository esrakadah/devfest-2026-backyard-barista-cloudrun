import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Standard 1920x1080 slide frame with header badge, title, subtitle, and body content.
class SlideFrame extends StatelessWidget {
  const SlideFrame({
    required this.eyebrow,
    required this.title,
    required this.child,
    this.subtitle,
    this.accentColor = DeckColors.googleYellow,
    super.key,
  });

  static const double _outerHorizontalPadding = 80;
  static const double _outerVerticalPadding = 44;
  static const double _eyebrowGap = 10;
  static const double _subtitleGap = 8;
  static const double _bodyGap = 22;

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = FlutterDeckTheme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _outerHorizontalPadding,
        vertical: _outerVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeckBadge(label: eyebrow, color: accentColor),
          const SizedBox(height: _eyebrowGap),
          Text(title, style: textTheme.header),
          if (subtitle != null) ...[
            const SizedBox(height: _subtitleGap),
            Text(subtitle!, style: textTheme.bodyLarge.copyWith(color: DeckColors.googleBlue)),
          ],
          const SizedBox(height: _bodyGap),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Reusable elevated card container on the GDE Midnight Navy palette.
class DeckCard extends StatelessWidget {
  const DeckCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.accentStripeColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final Color? accentStripeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? DeckColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? DeckColors.outline, width: 1.5),
        boxShadow: const [
          BoxShadow(color: DeckColors.specularTop, offset: Offset(0, -1)),
          BoxShadow(color: Color(0x38000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: accentStripeColor == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentStripeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Flexible(child: child),
              ],
            ),
    );
  }
}

/// Metric callout chip with tabular figures.
class StatChip extends StatelessWidget {
  const StatChip({
    required this.value,
    required this.label,
    this.accentColor = DeckColors.googleBlue,
    super.key,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.38), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable category or topic pill with optional vector icon (replaces unbundled Unicode emojis).
class PillTag extends StatelessWidget {
  const PillTag({
    required this.label,
    this.color = DeckColors.googleBlue,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill badge used for topic tags, city editions, and fact/target indicators.
class DeckBadge extends StatelessWidget {
  const DeckBadge({
    required this.label,
    this.color = DeckColors.googleYellow,
    this.icon,
    super.key,
  });

  static const double _horizontalPadding = 14;
  static const double _verticalPadding = 6;
  static const double _cornerRadius = 999;
  static const double _fontSize = 15;
  static const double _borderOpacity = 0.45;
  static const double _fillOpacity = 0.14;

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _fillOpacity),
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: color.withValues(alpha: _borderOpacity)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Official 2026 GDE Brand Guide badge and required speaker disclaimer.
class GdeBadgeStrip extends StatelessWidget {
  const GdeBadgeStrip({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20, vertical: compact ? 10 : 12),
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DeckColors.outlineLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomPaint(size: Size(34, 24), painter: _GdeBracketsPainter()),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Google Developer Expert · Flutter & Dart',
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Google Developer Expert, does not speak for Google',
                    style: TextStyle(
                      fontFamily: DeckFonts.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DeckColors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GdeBracketsPainter extends CustomPainter {
  const _GdeBracketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final midY = size.height / 2;

    stroke.color = DeckColors.coreRed;
    canvas.drawLine(const Offset(11, 3), Offset(2, midY), stroke);
    stroke.color = DeckColors.coreBlue;
    canvas.drawLine(Offset(2, midY), Offset(11, size.height - 3), stroke);

    stroke.color = DeckColors.coreGreen;
    canvas.drawLine(Offset(size.width - 11, 3), Offset(size.width - 2, midY), stroke);
    stroke.color = DeckColors.coreYellow;
    canvas.drawLine(Offset(size.width - 2, midY), Offset(size.width - 11, size.height - 3), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Surface card with colored top accent stripe for lanes, layers, and comparisons.
class DeckFeatureCard extends StatelessWidget {
  const DeckFeatureCard({
    required this.title,
    required this.bullets,
    this.badge,
    this.badgeIcon,
    this.accentColor = DeckColors.googleBlue,
    this.footerText,
    super.key,
  });

  static const double _padding = 22;
  static const double _titleGap = 12;
  static const double _bulletGap = 8;
  static const double _dotSize = 8;
  static const double _dotTopOffset = 9;
  static const double _dotRightGap = 12;

  final String title;
  final String? badge;
  final IconData? badgeIcon;
  final List<String> bullets;
  final Color accentColor;
  final String? footerText;

  @override
  Widget build(BuildContext context) {
    final textTheme = FlutterDeckTheme.of(context).textTheme;
    return DeckCard(
      padding: const EdgeInsets.all(_padding),
      borderColor: accentColor.withValues(alpha: 0.45),
      accentStripeColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            DeckBadge(label: badge!, color: accentColor, icon: badgeIcon),
            const SizedBox(height: _bulletGap),
          ],
          Text(
            title,
            style: textTheme.subtitle.copyWith(
              color: DeckColors.offWhite,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: _titleGap),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: _bulletGap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: _dotTopOffset),
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: _dotRightGap),
                  Expanded(
                    child: Text(bullet, style: textTheme.bodyMedium.copyWith(height: 1.32)),
                  ),
                ],
              ),
            ),
          if (footerText != null) ...[
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: DeckColors.surfaceInset,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DeckColors.outline),
              ),
              child: Text(
                footerText!,
                style: const TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: 13,
                  color: DeckColors.googleYellow,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// IDE-styled code/JSON snippet card with window header bar, file name, and syntax highlighting.
class DeckCodeCard extends StatelessWidget {
  const DeckCodeCard({
    required this.filePathLabel,
    required this.code,
    this.accentColor = DeckColors.halftoneBlue,
    this.badgeLabel,
    super.key,
  });

  final String filePathLabel;
  final String code;
  final Color accentColor;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1.5),
        boxShadow: const [
          BoxShadow(color: DeckColors.specularTop, offset: Offset(0, -1)),
          BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: const BoxDecoration(
              color: DeckColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: DeckColors.outline)),
            ),
            child: Row(
              children: [
                const _WindowDot(color: DeckColors.googleRed),
                const SizedBox(width: 7),
                const _WindowDot(color: DeckColors.googleYellow),
                const SizedBox(width: 7),
                const _WindowDot(color: DeckColors.googleGreen),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    filePathLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: DeckFonts.mono,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
                if (badgeLabel != null) ...[
                  const SizedBox(width: 10),
                  PillTag(label: badgeLabel!, color: accentColor),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FlutterDeckCodeHighlight(
                code: code,
                textStyle: const TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: DeckTypeScale.code,
                  color: DeckColors.offWhite,
                  height: 1.38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.85), shape: BoxShape.circle),
    );
  }
}

/// Displays one of the bundled cafe assets from `assets/cafe/` with a caption.
class CafeAssetThumb extends StatelessWidget {
  const CafeAssetThumb({
    required this.assetFileName,
    required this.label,
    this.badgeText,
    this.borderColor = DeckColors.outline,
    this.imageSize = 104,
    super.key,
  });

  static const double _padding = 12;
  static const double _cornerRadius = 16;
  static const double _gap = 8;

  final String assetFileName;
  final String label;
  final String? badgeText;
  final Color borderColor;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(color: DeckColors.specularTop, offset: Offset(0, -1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/cafe/$assetFileName',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: imageSize,
                height: imageSize,
                child: const Icon(Icons.local_cafe, color: DeckColors.googleYellow, size: 44),
              ),
            ),
          ),
          const SizedBox(height: _gap),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(height: 3),
            Text(
              badgeText!,
              style: TextStyle(
                fontFamily: DeckFonts.mono,
                fontSize: 13,
                color: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom-painted 4-step pipeline flow diagram for `/ai-studio-pipeline` (Slide 3).
class AiStudioPipelineDiagramCard extends StatelessWidget {
  const AiStudioPipelineDiagramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      backgroundColor: DeckColors.surfaceElevated,
      borderColor: DeckColors.halftoneBlue.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'END-TO-END AI STUDIO BUILD -> GITHUB -> CLOUD RUN PIPELINE',
                style: TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.halftoneBlue,
                ),
              ),
              PillTag(
                label: 'STARTER TIER: 2 FREE CLOUD RUN APPS · 0 CREDIT CARD',
                color: DeckColors.googleGreen,
                icon: Icons.verified,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            width: double.infinity,
            child: CustomPaint(painter: _AiStudioPipelinePainter()),
          ),
        ],
      ),
    );
  }
}

class _AiStudioPipelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final boxW = (size.width - 96) / 4;
    const boxH = 68.0;
    const topY = 4.0;

    final steps = [
      ('01 · SEED + ASSETS', 'step-1-base-cafe.md + 12 PNGs', DeckColors.googleBlue),
      ('02 · BUILD PREVIEW', '2-Player Counter + CafeReview JSON', DeckColors.googleGreen),
      ('03 · GITHUB SYNC', 'Two-Way Commits + ZIP Backup', DeckColors.googleYellow),
      ('04 · CLOUD RUN', 'Serverless *.run.app Container', DeckColors.googleRed),
    ];

    for (var i = 0; i < steps.length; i++) {
      final left = i * (boxW + 32);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, topY, boxW, boxH),
        const Radius.circular(12),
      );
      final color = steps[i].$3;

      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.14));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

      final tp1 = TextPainter(
        text: TextSpan(
          text: steps[i].$1,
          style: TextStyle(
            fontFamily: DeckFonts.mono,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp1.paint(canvas, Offset(left + 14, topY + 12));

      final tp2 = TextPainter(
        text: TextSpan(
          text: steps[i].$2,
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DeckColors.offWhite,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(left + 14, topY + 36));

      if (i < steps.length - 1) {
        final arrowStart = left + boxW + 6;
        final arrowEnd = arrowStart + 20;
        const midY = topY + boxH / 2;
        final linePaint = Paint()
          ..color = DeckColors.outlineLight
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(arrowStart, midY), Offset(arrowEnd, midY), linePaint);
        canvas.drawLine(Offset(arrowEnd - 5, midY - 5), Offset(arrowEnd, midY), linePaint);
        canvas.drawLine(Offset(arrowEnd - 5, midY + 5), Offset(arrowEnd, midY), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom-painted horizontal Latency & Timeout Budget Bar Chart for `/real-numbers-latency` (Slide 6).
class LatencyBudgetChartCard extends StatelessWidget {
  const LatencyBudgetChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      backgroundColor: DeckColors.surfaceElevated,
      borderColor: DeckColors.googleGreen.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEASURED CLOUD RUN BENCHMARKS vs BOUNDED TIMEOUT GUARDRAILS (LOG-SCALE VISUAL)',
                style: TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.googleGreen,
                ),
              ),
              PillTag(
                label: '50-REQ BENCHMARK · EUROPE-WEST3',
                color: DeckColors.halftoneBlue,
                icon: Icons.speed,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 108,
            width: double.infinity,
            child: CustomPaint(painter: _LatencyBarsPainter()),
          ),
        ],
      ),
    );
  }
}

class _LatencyBarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const rows = [
      ('Cloud Run p50 Warm', '53.81 ms (Measured)', 0.14, DeckColors.googleGreen),
      ('Cloud Run p95 Warm', '75.52 ms (Measured)', 0.20, DeckColors.halftoneBlue),
      ('Offline JSON Fallback', '250 ms (_offlineBundleLoadTimeout)', 0.36, DeckColors.googleYellow),
      ('Initial TLS + Cold Start', '528.95 ms (Measured)', 0.52, DeckColors.halftonePink),
      ('Live Gemini Guardrail', '8,000 ms (_geminiRequestTimeout)', 0.96, DeckColors.googleRed),
    ];

    const labelWidth = 220.0;
    const trackLeft = labelWidth + 12;
    final trackWidth = size.width - trackLeft - 240;
    const rowH = 17.0;
    const gap = 5.0;

    for (var i = 0; i < rows.length; i++) {
      final y = i * (rowH + gap);
      final row = rows[i];

      final labelTp = TextPainter(
        text: TextSpan(
          text: row.$1,
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: DeckColors.offWhite,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(0, y + 1));

      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(trackLeft, y + 2, trackWidth, rowH - 3),
        const Radius.circular(999),
      );
      canvas.drawRRect(trackRect, Paint()..color = DeckColors.surfaceInset);

      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(trackLeft, y + 2, trackWidth * row.$3, rowH - 3),
        const Radius.circular(999),
      );
      canvas.drawRRect(fillRect, Paint()..color = row.$4);

      final valTp = TextPainter(
        text: TextSpan(
          text: row.$2,
          style: TextStyle(
            fontFamily: DeckFonts.mono,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: row.$4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(trackLeft + trackWidth + 14, y + 1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom-painted 300-Person Room Quota Comparison Diagram for `/room-quota-trap` (Slide 8).
class QuotaComparisonDiagramCard extends StatelessWidget {
  const QuotaComparisonDiagramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      backgroundColor: DeckColors.surfaceElevated,
      borderColor: DeckColors.googleYellow.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WHY SHARED KEYS FAIL vs HOW 300 ISOLATED AI STUDIO PROJECTS STAY GREEN',
                style: TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DeckColors.googleYellow,
                ),
              ),
              PillTag(
                label: 'FREE TIER = 5 TO 15 RPM PER GCP PROJECT',
                color: DeckColors.googleRed,
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 82,
            width: double.infinity,
            child: CustomPaint(painter: _QuotaComparisonPainter()),
          ),
        ],
      ),
    );
  }
}

class _QuotaComparisonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final halfW = (size.width - 28) / 2;
    const h = 76.0;

    void drawLane({
      required double left,
      required String badge,
      required String flow,
      required String outcome,
      required Color color,
    }) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 2, halfW, h),
        const Radius.circular(14),
      );
      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.12));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

      final tp1 = TextPainter(
        text: TextSpan(
          text: badge,
          style: TextStyle(
            fontFamily: DeckFonts.mono,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp1.paint(canvas, Offset(left + 16, 10));

      final tp2 = TextPainter(
        text: TextSpan(
          text: flow,
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: DeckColors.offWhite,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(left + 16, 30));

      final tp3 = TextPainter(
        text: TextSpan(
          text: outcome,
          style: const TextStyle(
            fontFamily: DeckFonts.mono,
            fontSize: 12,
            color: DeckColors.mutedText,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp3.paint(canvas, Offset(left + 16, 53));
    }

    drawLane(
      left: 0,
      badge: 'TRAP · SHARED SPEAKER KEY OR 100-SEAT LAB',
      flow: '300 Builders -> 1 Shared GCP Project (15 RPM Cap)',
      outcome: 'HTTP 429 RESOURCE_EXHAUSTED in < 3.0 seconds',
      color: DeckColors.googleRed,
    );

    drawLane(
      left: halfW + 28,
      badge: 'SOLUTION · ISOLATED KEYS + 1 CALL ON SERVE',
      flow: '300 Builders -> 300 Personal Projects (300 x 15 RPM)',
      outcome: '1-2 RPM per player + 250ms mock_responses.json net',
      color: DeckColors.googleGreen,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom-painted Round 2 Vector Artwork Showcase (`CustomVectorIngredientGraphic`) for Slide 11.
class RoundTwoVectorPreviewCard extends StatelessWidget {
  const RoundTwoVectorPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DeckCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: DeckColors.surfaceElevated,
      borderColor: DeckColors.googleYellow.withValues(alpha: 0.5),
      child: const Row(
        children: [
          CustomPaint(
            size: Size(68, 68),
            painter: _RoundTwoVectorPainter(isKatmer: true),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PillTag(
                  label: 'LIVE DART CUSTOMPAINTER',
                  color: DeckColors.googleGreen,
                  icon: Icons.brush,
                ),
                SizedBox(height: 6),
                Text(
                  'pistachioKatmerRoll',
                  style: TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
                Text(
                  'Crispy Phyllo · Kaymak & Boz Fıstık',
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: 13,
                    color: DeckColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          CustomPaint(
            size: Size(68, 68),
            painter: _RoundTwoVectorPainter(isKatmer: false),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PillTag(
                  label: 'PRANK VECTOR SHAKER',
                  color: DeckColors.googleRed,
                  icon: Icons.whatshot,
                ),
                SizedBox(height: 6),
                Text(
                  'isotPepperShaker',
                  style: TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
                Text(
                  'Smoky Urfa & Antep Chili Flakes',
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: 13,
                    color: DeckColors.mutedText,
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

class _RoundTwoVectorPainter extends CustomPainter {
  const _RoundTwoVectorPainter({required this.isKatmer});

  final bool isKatmer;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (isKatmer) {
      canvas.drawCircle(center, radius - 2, Paint()..color = const Color(0xFFE8F5E9));
      canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = const Color(0xFF43A047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      final rollRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * 0.68, height: size.height * 0.36),
        const Radius.circular(12),
      );
      canvas.drawRRect(rollRect, Paint()..color = const Color(0xFFD49B35));
      canvas.drawCircle(Offset(center.dx - 10, center.dy), 6, Paint()..color = const Color(0xFFFFFDF7));
      canvas.drawCircle(Offset(center.dx + 10, center.dy), 6, Paint()..color = const Color(0xFFFFFDF7));
      canvas.drawCircle(center, 7, Paint()..color = const Color(0xFF2E7D32));
    } else {
      canvas.drawCircle(center, radius - 2, Paint()..color = const Color(0xFFFFEBEE));
      canvas.drawCircle(
        center,
        radius - 2,
        Paint()
          ..color = const Color(0xFFC62828)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      final bodyRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 4),
          width: size.width * 0.44,
          height: size.height * 0.52,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF6A1B1A));
      final flakePaint = Paint()..color = const Color(0xFFFF7043);
      canvas.drawCircle(Offset(center.dx - 5, center.dy + 2), 3, flakePaint);
      canvas.drawCircle(Offset(center.dx + 5, center.dy + 6), 3, flakePaint);
      canvas.drawCircle(Offset(center.dx, center.dy - 4), 3, flakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoundTwoVectorPainter oldDelegate) {
    return oldDelegate.isKatmer != isKatmer;
  }
}
