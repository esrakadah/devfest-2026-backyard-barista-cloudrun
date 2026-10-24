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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backyard Barista on Cloud Run',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
        useMaterial3: true,
      ),
      home: CafeCounterScreen(
        cityController: cityController,
        judgeService: judgeService,
      ),
    );
  }
}
