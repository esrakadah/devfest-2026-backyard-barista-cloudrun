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
      seedColor: const Color(0xFFB84A24),
      primary: const Color(0xFF3A2218),
      secondary: const Color(0xFFC85A32),
      surface: const Color(0xFFFFF8EE),
    );

    final baseTheme = ThemeData(
      fontFamily: 'GoogleSans',
      fontFamilyFallback: _emojiFontFallbacks,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFF8EE),
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
