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

  static const double _outerHorizontalPadding = 88;
  static const double _outerVerticalPadding = 56;
  static const double _eyebrowGap = 12;
  static const double _subtitleGap = 10;
  static const double _bodyGap = 28;

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
            Text(subtitle!, style: textTheme.bodyLarge.copyWith(color: DeckColors.halftoneBlue)),
          ],
          const SizedBox(height: _bodyGap),
          Expanded(child: child),
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
    super.key,
  });

  static const double _horizontalPadding = 14;
  static const double _verticalPadding = 6;
  static const double _cornerRadius = 999;
  static const double _fontSize = 18;
  static const double _borderOpacity = 0.45;
  static const double _fillOpacity = 0.14;

  final String label;
  final Color color;

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
      child: Text(
        label,
        style: TextStyle(
          fontFamily: DeckFonts.mono,
          fontSize: _fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Surface card with colored top accent bar for lanes, layers, and comparisons.
class DeckFeatureCard extends StatelessWidget {
  const DeckFeatureCard({
    required this.title,
    required this.bullets,
    this.badge,
    this.accentColor = DeckColors.googleBlue,
    this.footerText,
    super.key,
  });

  static const double _padding = 24;
  static const double _cornerRadius = 20;
  static const double _borderWidth = 1.5;
  static const double _titleGap = 14;
  static const double _bulletGap = 10;
  static const double _dotSize = 10;
  static const double _dotTopOffset = 10;
  static const double _dotRightGap = 12;

  final String title;
  final String? badge;
  final List<String> bullets;
  final Color accentColor;
  final String? footerText;

  @override
  Widget build(BuildContext context) {
    final textTheme = FlutterDeckTheme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: accentColor, width: _borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            DeckBadge(label: badge!, color: accentColor),
            const SizedBox(height: _bulletGap),
          ],
          Text(title, style: textTheme.subtitle.copyWith(color: DeckColors.offWhite, fontWeight: FontWeight.w700)),
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
                    child: Text(bullet, style: textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          if (footerText != null) ...[
            const Spacer(),
            Text(
              footerText!,
              style: const TextStyle(
                fontFamily: DeckFonts.mono,
                fontSize: DeckTypeScale.bodySmall,
                color: DeckColors.halftoneYellow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Monospace code/JSON snippet card backed by files in `flutter_client/`.
class DeckCodeCard extends StatelessWidget {
  const DeckCodeCard({
    required this.filePathLabel,
    required this.code,
    this.accentColor = DeckColors.halftoneBlue,
    super.key,
  });

  static const double _padding = 22;
  static const double _cornerRadius = 18;
  static const double _headerGap = 12;

  final String filePathLabel;
  final String code;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filePathLabel,
            style: TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: DeckTypeScale.bodySmall,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: _headerGap),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                code,
                style: const TextStyle(
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

/// Displays one of the 12 bundled cafe assets from `assets/cafe/` with a caption.
class CafeAssetThumb extends StatelessWidget {
  const CafeAssetThumb({
    required this.assetFileName,
    required this.label,
    this.badgeText,
    this.borderColor = DeckColors.outline,
    this.imageSize = 112,
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
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: borderColor, width: 1.5),
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
                child: const Icon(Icons.local_cafe, color: DeckColors.googleYellow, size: 48),
              ),
            ),
          ),
          const SizedBox(height: _gap),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DeckColors.offWhite,
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(height: 4),
            Text(
              badgeText!,
              style: TextStyle(
                fontFamily: DeckFonts.mono,
                fontSize: 14,
                color: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
