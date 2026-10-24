import 'package:backyard_barista_deck/plugins/presenter_menu_plugin.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/demo_hiccup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

void main() {
  ErrorWidget.builder = (details) {
    return DemoHiccupScreen(
      message: 'Reload or run with --dart-define=OFFLINE_MODE=true.\n${details.exceptionAsString()}',
    );
  };
  runApp(const BackyardBaristaDeckApp());
}

class BackyardBaristaDeckApp extends StatelessWidget {
  const BackyardBaristaDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      configuration: const FlutterDeckConfiguration(
        slideSize: FlutterDeckSlideSize.custom(width: 2560, height: 1440),
        transition: FlutterDeckTransition.fade(),
        background: FlutterDeckBackgroundConfiguration(
          light: FlutterDeckBackground.solid(DeckColors.navy),
          dark: FlutterDeckBackground.solid(DeckColors.navy),
        ),
        footer: FlutterDeckFooterConfiguration(showSlideNumbers: true, showSocialHandle: true),
      ),
      themeMode: ThemeMode.dark,
      lightTheme: PresentationTheme.lightTheme,
      darkTheme: PresentationTheme.darkTheme,
      speakerInfo: const FlutterDeckSpeakerInfo(
        name: 'Esra Kadah',
        description: 'Google Developer Expert, Flutter & Dart · Tech Lead, Senior Flutter & AI Engineer',
        socialHandle: '@esrakadah',
        imagePath: 'assets/images/esra.png',
      ),
      plugins: [PresenterMenuPlugin()],
      slides: deckSlides,
    );
  }
}
