import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Visual edition of the deck, picked at build time with `--dart-define=DECK_THEME=<name>`.
///
/// `gde` (default) is the GDE Midnight Navy deck. `candle` is the candlelit wizard-school edition
/// for DevFest Konya 2026 (the event has that theme): same navy ground, a serif for slide titles,
/// candle gold, stars and a thin gold frame. `konya` is the event-identity edition for the same
/// conference: parchment ground, a crimson ink skyline of Konya along the bottom, gothic slide
/// titles, and the content on dark ink plates. Each edition swaps tokens, fonts and the backdrop only.
const String deckTheme = String.fromEnvironment('DECK_THEME', defaultValue: 'gde');
const bool isCandleTheme = deckTheme == 'candle';
const bool isKonyaTheme = deckTheme == 'konya';

/// The two Konya editions share the wizard-school act labels and the arched portrait.
const bool isWizardEdition = isCandleTheme || isKonyaTheme;

/// Unified GDE Midnight Navy palette (`BoardTokens.gde` + 2026 GDE Brand Guide).
abstract final class DeckColors {
  /// Deep Midnight Navy canvas ground.
  static const Color navy = isKonyaTheme ? ink : (isCandleTheme ? Color(0xFF0B1320) : Color(0xFF0E1824));

  /// Primary text on dark surfaces.
  static const Color offWhite = isWizardEdition ? Color(0xFFF8F0DC) : Color(0xFFF2F6FC);

  /// Dark-mode pastel accents for text, chips, and data visualization on dark backgrounds.
  static const Color googleBlue = Color(0xFF8AB4F8);
  static const Color googleGreen = Color(0xFF81C995);
  static const Color googleYellow = isWizardEdition ? Color(0xFFF2CC6B) : Color(0xFFFDD663);
  static const Color googleRed = Color(0xFFF28B82);

  /// Official 2026 GDE Brand Guide core colors for bracket logos and primary fills.
  static const Color coreBlue = Color(0xFF4285F4);
  static const Color coreGreen = Color(0xFF34A853);
  static const Color coreYellow = Color(0xFFF9AB00);
  static const Color coreRed = Color(0xFFEA4335);

  /// Official 2026 GDE Brand Guide halftones for secondary accents and diagrams.
  static const Color halftoneBlue = Color(0xFF57CAFF);
  static const Color halftoneGreen = Color(0xFF5CDB6D);
  static const Color halftoneYellow = Color(0xFFFFD427);
  static const Color halftonePink = Color(0xFFFF7DAF);

  /// Surface hierarchy (`s1`, `s2`, `s3`, and `inset`).
  static const Color surface =
      isKonyaTheme ? Color(0xFF241619) : (isCandleTheme ? Color(0xFF152134) : Color(0xFF16273A));
  static const Color surfaceElevated =
      isKonyaTheme ? Color(0xFF2E1C20) : (isCandleTheme ? Color(0xFF1C2A40) : Color(0xFF1D3148));
  static const Color surface3 = isKonyaTheme ? Color(0xFF3A2428) : Color(0xFF22344F);
  static const Color surfaceInset =
      isKonyaTheme ? Color(0xFF150C0E) : (isCandleTheme ? Color(0xFF080E18) : Color(0xFF0B141F));

  /// Hairlines and borders on [surface].
  static const Color outline =
      isKonyaTheme ? Color(0xFF4A2B2F) : (isCandleTheme ? Color(0xFF3A3A44) : Color(0xFF284162));
  static const Color outlineLight =
      isKonyaTheme ? Color(0xFFB08A4A) : (isCandleTheme ? Color(0xFF8A7440) : Color(0xFF3A5C88));

  /// Top 1px specular highlight on elevated cards.
  static const Color specularTop = Color(0x1EFFFFFF);

  /// Candle gold of the candle edition.
  static const Color gold = Color(0xFFF2CC6B);

  /// Ink, crimson and parchment of the konya edition (the event's own print palette).
  static const Color ink = Color(0xFF1B1210);
  static const Color crimson = Color(0xFF7E1420);
  static const Color parchment = Color(0xFFF3E7CF);

  /// Text that sits directly on the slide ground, outside any card. The konya ground is light
  /// parchment, so these turn dark there; every pair is 4.5:1 or better on the darkest paper pixel.
  /// flutter_deck recolours the whole text theme with the slide colour (kept light for the cards),
  /// so ground text sets its colour at the call site.
  static const Color onGround = isKonyaTheme ? ink : offWhite;
  static const Color onGroundAccent = isKonyaTheme ? crimson : googleYellow;
  static const Color onGroundMuted = isKonyaTheme ? Color(0xFF4A3B2C) : mutedText;

  /// Slide subtitle and header accent.
  static const Color subtitleAccent = isKonyaTheme ? crimson : (isCandleTheme ? gold : googleBlue);

  /// Secondary text: captions, footers, muted labels.
  static const Color mutedText = isCandleTheme ? Color(0xFFC2B79C) : Color(0xFF9EB1C9);
}

/// The logical slide canvas. The type scale below is designed for it; flutter_deck scales the
/// canvas to whatever the projector is (1080p, 1440p or 4K), so text never shrinks on big screens.
abstract final class DeckCanvas {
  static const double width = 1920;
  static const double height = 1080;
  static const FlutterDeckSlideSize slideSize = FlutterDeckSlideSize.custom(width: width, height: height);
}

/// The two font families bundled under assets/fonts and declared in pubspec.yaml.
abstract final class DeckFonts {
  static const String sans = 'GoogleSansFlex';
  static const String mono = 'RobotoMono';

  /// Display face for slide titles: a serif in the candle edition, gothic lettering in the konya edition.
  static const String display = isKonyaTheme ? 'NewRocker' : (isCandleTheme ? 'PlayfairDisplay' : sans);

  /// Display face for names and headings inside dark cards, where gothic lettering gets too heavy.
  static const String cardDisplay = isWizardEdition ? 'PlayfairDisplay' : sans;
}

/// The type scale, in logical pixels on a 1920 x 1080 slide.
abstract final class DeckTypeScale {
  static const double display = 80;
  static const double header = 54;
  static const double title = 44;
  static const double subtitle = 32;
  static const double bodyLarge = 26;
  static const double bodyMedium = 21;
  static const double bodySmall = 16;

  /// Code is rendered verbatim by FlutterDeckCodeHighlight, with no auto-sizing, so it never goes below this.
  static const double code = 18;
}

/// Presentation theme for the DevFest 2026 Backyard Barista on Cloud Run deck.
abstract final class PresentationTheme {
  /// New Rocker ships one weight; asking for bold would make the engine smear a synthetic one.
  static const FontWeight _heavy = isKonyaTheme ? FontWeight.w400 : FontWeight.w700;

  static FlutterDeckThemeData get darkTheme {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DeckColors.navy,
      fontFamily: DeckFonts.sans,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DeckColors.googleBlue,
        primary: DeckColors.googleBlue,
        secondary: DeckColors.googleYellow,
        surface: DeckColors.surface,
        onSurface: DeckColors.offWhite,
        onPrimary: DeckColors.navy,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    const textTheme = FlutterDeckTextTheme(
      display: TextStyle(
        fontFamily: DeckFonts.display,
        fontSize: DeckTypeScale.display,
        fontWeight: _heavy,
        color: DeckColors.offWhite,
        height: 1.1,
      ),
      header: TextStyle(
        fontFamily: DeckFonts.display,
        fontSize: DeckTypeScale.header,
        fontWeight: _heavy,
        color: DeckColors.offWhite,
      ),
      title: TextStyle(
        fontFamily: DeckFonts.cardDisplay,
        fontSize: DeckTypeScale.title,
        fontWeight: FontWeight.w700,
        color: DeckColors.offWhite,
      ),
      subtitle: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.subtitle,
        fontWeight: FontWeight.w500,
        color: DeckColors.subtitleAccent,
      ),
      bodyLarge: TextStyle(fontFamily: DeckFonts.sans, fontSize: DeckTypeScale.bodyLarge, color: DeckColors.offWhite),
      bodyMedium: TextStyle(fontFamily: DeckFonts.sans, fontSize: DeckTypeScale.bodyMedium, color: DeckColors.offWhite),
      bodySmall: TextStyle(fontFamily: DeckFonts.sans, fontSize: DeckTypeScale.bodySmall, color: DeckColors.mutedText),
    );

    return FlutterDeckThemeData.fromThemeAndText(baseTheme, textTheme).copyWith(
      slideTheme: const FlutterDeckSlideThemeData(backgroundColor: DeckColors.navy, color: DeckColors.offWhite),
      titleSlideTheme: FlutterDeckTitleSlideThemeData(
        titleTextStyle: textTheme.display,
        subtitleTextStyle: textTheme.subtitle,
      ),
      bigFactSlideTheme: FlutterDeckBigFactSlideThemeData(
        titleTextStyle: textTheme.display.copyWith(color: DeckColors.googleYellow),
        subtitleTextStyle: textTheme.subtitle.copyWith(color: DeckColors.offWhite),
      ),
      quoteSlideTheme: FlutterDeckQuoteSlideThemeData(
        quoteTextStyle: textTheme.title.copyWith(fontStyle: FontStyle.italic),
        attributionTextStyle: textTheme.subtitle.copyWith(color: DeckColors.googleYellow),
      ),
      headerTheme: FlutterDeckHeaderThemeData(color: DeckColors.googleBlue, textStyle: textTheme.header),
      footerTheme: FlutterDeckFooterThemeData(
        slideNumberColor: isKonyaTheme ? DeckColors.parchment : DeckColors.mutedText,
        slideNumberTextStyle: textTheme.bodySmall,
        socialHandleColor: isKonyaTheme ? DeckColors.parchment : DeckColors.googleBlue,
        socialHandleTextStyle: textTheme.bodySmall,
      ),
      speakerInfoWidgetTheme: FlutterDeckSpeakerInfoWidgetThemeData(
        nameTextStyle: textTheme.subtitle.copyWith(color: DeckColors.offWhite),
        descriptionTextStyle: textTheme.bodyMedium,
        socialHandleTextStyle: textTheme.bodyMedium.copyWith(color: DeckColors.googleBlue),
      ),
      bulletListTheme: FlutterDeckBulletListThemeData(color: DeckColors.googleYellow, textStyle: textTheme.bodyLarge),
      imageSlideTheme: FlutterDeckImageSlideThemeData(labelTextStyle: textTheme.bodySmall),
      splitSlideTheme: const FlutterDeckSplitSlideThemeData(
        leftBackgroundColor: DeckColors.navy,
        rightBackgroundColor: DeckColors.surface,
        leftColor: DeckColors.offWhite,
        rightColor: DeckColors.offWhite,
      ),
      codeHighlightTheme: const FlutterDeckCodeHighlightThemeData(
        backgroundColor: DeckColors.surfaceInset,
        textStyle: TextStyle(fontFamily: DeckFonts.mono, fontSize: DeckTypeScale.code, color: DeckColors.offWhite),
      ),
    );
  }

  /// Slide progress bar. flutter_deck draws it in the primary colour (blue) by default; the konya
  /// edition draws it in sandstone gold on the crimson ground line.
  static FlutterDeckProgressIndicator get progressIndicator => isKonyaTheme
      ? const FlutterDeckProgressIndicator.solid(color: Color(0xFFE2B45A), backgroundColor: Color(0xFF6E111B))
      : const FlutterDeckProgressIndicator.solid();

  /// The deck has one brightness; `themeMode` pins it to dark.
  static FlutterDeckThemeData get lightTheme => darkTheme;
}
