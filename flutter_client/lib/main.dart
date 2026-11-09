import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_counter_screen.dart';
import 'package:flutter/material.dart';

const String _defaultCityFromEnv = String.fromEnvironment(
  'DEFAULT_CITY',
  defaultValue: 'gaziantep',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cityController = CityEditionController(
    remoteConfigCityCode: _defaultCityFromEnv,
  );
  await cityController.loadBundledEditions();
  cityController.syncRemoteConfigFromUri();

  final judgeService = CafeJudgeService(
    clock: DateTime.now,
  );

  runApp(
    BackyardBaristaApp(
      cityController: cityController,
      judgeService: judgeService,
    ),
  );
}

class BackyardBaristaApp extends StatelessWidget {
  const BackyardBaristaApp({
    required this.cityController,
    required this.judgeService,
    super.key,
  });

  final CityEditionController cityController;
  final CafeJudgeService judgeService;

  static const List<String> _emojiFontFallbacks = <String>[
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Noto Color Emoji',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context) {
    final baseColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFFC59B27),
      primary: const Color(0xFFC59B27),
      secondary: const Color(0xFF7A1C1C),
      surface: const Color(0xFF1F1711),
    );

    final baseTheme = ThemeData(
      fontFamily: 'GoogleSans',
      fontFamilyFallback: _emojiFontFallbacks,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: const Color(0xFF14100C),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Backyard Barista on Cloud Run',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontFamily: 'GoogleSans',
          fontFamilyFallback: _emojiFontFallbacks,
        ),
      ),
      home: CafeCounterScreen(
        cityController: cityController,
        judgeService: judgeService,
      ),
    );
  }
}
