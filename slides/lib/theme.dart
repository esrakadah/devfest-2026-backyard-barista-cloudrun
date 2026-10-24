import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Official GDE 2026 deck palette: navy ground, off-white text, the four Google hues as accents, halftones for depth.
abstract final class DeckColors {
  static const Color navy = Color(0xFF20344B);
  static const Color offWhite = Color(0xFFF0F0F0);

  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFF9AB00);
  static const Color googleRed = Color(0xFFEA4335);

  static const Color halftoneBlue = Color(0xFF57CAFF);
  static const Color halftoneGreen = Color(0xFF5CDB6D);
  static const Color halftoneYellow = Color(0xFFFFD427);
  static const Color halftonePink = Color(0xFFFF7DAF);

  /// One step lighter than [navy], for cards and code blocks that sit on the slide background.
  static const Color surface = Color(0xFF2B4361);

  /// Hairlines and dividers on [surface].
  static const Color outline = Color(0xFF3D5878);

  /// Secondary text: captions, footers, the third line of a bullet.
  static const Color mutedText = Color(0xFFB3BDC9);
}

/// The two font families bundled under assets/fonts and declared in pubspec.yaml.
abstract final class DeckFonts {
  static const String sans = 'GoogleSansFlex';
  static const String mono = 'RobotoMono';
}

/// The type scale, in logical pixels on a 1920 x 1080 slide.
abstract final class DeckTypeScale {
  static const double display = 84;
  static const double header = 58;
  static const double title = 48;
  static const double subtitle = 34;
  static const double bodyLarge = 28;
  static const double bodyMedium = 22;
  static const double bodySmall = 16;

  /// Code is rendered verbatim by FlutterDeckCodeHighlight, with no auto-sizing, so it never goes below this.
  static const double code = 20;
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
        onPrimary: DeckColors.offWhite,
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
        color: DeckColors.halftoneBlue,
      ),
      bodyLarge: TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: DeckTypeScale.bodyLarge,
        color: Color.fromRGBO(0xF0, 0xF0, 0xF0, _bodyOpacity),
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
        socialHandleColor: DeckColors.halftoneBlue,
        socialHandleTextStyle: textTheme.bodySmall,
      ),
      speakerInfoWidgetTheme: FlutterDeckSpeakerInfoWidgetThemeData(
        nameTextStyle: textTheme.subtitle.copyWith(color: DeckColors.offWhite),
        descriptionTextStyle: textTheme.bodyMedium,
        socialHandleTextStyle: textTheme.bodyMedium.copyWith(color: DeckColors.halftoneBlue),
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
        backgroundColor: DeckColors.surface,
        textStyle: TextStyle(fontFamily: DeckFonts.mono, fontSize: DeckTypeScale.code, color: DeckColors.offWhite),
      ),
    );
  }

  /// The deck has one brightness; `themeMode` pins it to dark.
  static FlutterDeckThemeData get lightTheme => darkTheme;
}
