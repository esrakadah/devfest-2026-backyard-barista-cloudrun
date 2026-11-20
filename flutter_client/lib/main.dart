import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:backyard_barista_cloudrun/services/player_storage_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/player_storage_web.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_counter_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _defaultCityFromEnv = String.fromEnvironment(
  'DEFAULT_CITY',
  defaultValue: 'gaziantep',
);

const String _leaderboardProjectFromEnv = String.fromEnvironment('LEADERBOARD_PROJECT');
const String _leaderboardEventFromEnv = String.fromEnvironment(
  'LEADERBOARD_EVENT',
  defaultValue: LeaderboardService.defaultEventId,
);

/// Null when the build names no leaderboard project, which keeps the game free of the name dialog and of
/// any leaderboard request.
LeaderboardService? _buildLeaderboardService() {
  if (_leaderboardProjectFromEnv.isEmpty) {
    return null;
  }
  final eventId = LeaderboardService.resolveEventId(configuredEventId: _leaderboardEventFromEnv, uri: Uri.base);
  final playerIdKey = 'barista_player_id_$eventId';
  final playerNameKey = 'barista_player_name_$eventId';
  var playerId = readPlayerStorageValue(playerIdKey);
  if (playerId == null || playerId.length != LeaderboardService.playerIdLength) {
    playerId = LeaderboardService.generatePlayerId(math.Random.secure());
    writePlayerStorageValue(playerIdKey, playerId);
  }
  return LeaderboardService(
    projectId: _leaderboardProjectFromEnv,
    eventId: eventId,
    playerId: playerId,
    httpClient: http.Client(),
    clock: DateTime.now,
    rememberedPlayerName: readPlayerStorageValue(playerNameKey),
    onPlayerNameChosen: (playerName) => writePlayerStorageValue(playerNameKey, playerName),
  );
}

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
      leaderboardService: _buildLeaderboardService(),
    ),
  );
}

class BackyardBaristaApp extends StatelessWidget {
  const BackyardBaristaApp({
    required this.cityController,
    required this.judgeService,
    this.leaderboardService,
    super.key,
  });

  final CityEditionController cityController;
  final CafeJudgeService judgeService;
  final LeaderboardService? leaderboardService;

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
        leaderboardService: leaderboardService,
      ),
    );
  }
}
