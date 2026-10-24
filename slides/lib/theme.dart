import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Unified GDE Midnight Navy palette (`BoardTokens.gde` + 2026 GDE Brand Guide).
abstract final class DeckColors {
  /// Deep Midnight Navy canvas ground.
  static const Color navy = Color(0xFF0E1824);

  /// Primary text on dark surfaces.
  static const Color offWhite = Color(0xFFF2F6FC);

  /// Dark-mode pastel accents for text, chips, and data visualization on dark backgrounds.
  static const Color googleBlue = Color(0xFF8AB4F8);
  static const Color googleGreen = Color(0xFF81C995);
  static const Color googleYellow = Color(0xFFFDD663);
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
  static const Color surface = Color(0xFF16273A);
  static const Color surfaceElevated = Color(0xFF1D3148);
  static const Color surface3 = Color(0xFF22344F);
  static const Color surfaceInset = Color(0xFF0B141F);

  /// Hairlines and borders on [surface].
  static const Color outline = Color(0xFF284162);
  static const Color outlineLight = Color(0xFF3A5C88);

  /// Top 1px specular highlight on elevated cards.
  static const Color specularTop = Color(0x1EFFFFFF);

  /// Secondary text: captions, footers, muted labels.
  static const Color mutedText = Color(0xFF9EB1C9);
}

/// The two font families bundled under assets/fonts and declared in pubspec.yaml.
abstract final class DeckFonts {
  static const String sans = 'GoogleSansFlex';
  static const String mono = 'RobotoMono';
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
  static const FontWeight _heavy = FontWeight.w700;
  static const double _bodyOpacity = 0.92;

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
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.display,
        fontWeight: _heavy,
        color: DeckColors.offWhite,
        height: 1.1,
      ),
      header: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.header,
        fontWeight: _heavy,
        color: DeckColors.offWhite,
      ),
      title: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.title,
        fontWeight: _heavy,
        color: DeckColors.offWhite,
      ),
      subtitle: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.subtitle,
        fontWeight: FontWeight.w500,
        color: DeckColors.googleBlue,
      ),
      bodyLarge: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.bodyLarge,
        color: Color.fromRGBO(0xF2, 0xF6, 0xFC, _bodyOpacity),
      ),
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
        slideNumberColor: DeckColors.mutedText,
        slideNumberTextStyle: textTheme.bodySmall,
        socialHandleColor: DeckColors.googleBlue,
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

  /// The deck has one brightness; `themeMode` pins it to dark.
  static FlutterDeckThemeData get lightTheme => darkTheme;
}
