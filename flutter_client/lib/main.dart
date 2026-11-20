import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/services/browser_tab_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/browser_tab_web.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/hall_board_controller.dart';
import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:backyard_barista_cloudrun/services/player_storage_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/player_storage_web.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_counter_screen.dart';
import 'package:backyard_barista_cloudrun/ui/hall_leaderboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _defaultCityFromEnv = String.fromEnvironment(
  'DEFAULT_CITY',
  defaultValue: 'gaziantep',
);

const String _leaderboardProjectFromEnv = String.fromEnvironment('LEADERBOARD_PROJECT');
const String _defaultLeaderboardProject = 'devfest-backyard-barista-2026';
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

HallBoardController _buildHallBoardController() {
  final projectId = _leaderboardProjectFromEnv.isNotEmpty ? _leaderboardProjectFromEnv : _defaultLeaderboardProject;
  final eventId = LeaderboardService.resolveEventId(configuredEventId: _leaderboardEventFromEnv, uri: Uri.base);
  final adminSessionKey = 'barista_admin_key_$eventId';
  return HallBoardController(
    projectId: projectId,
    eventId: eventId,
    httpClient: http.Client(),
    apiOrigin: Uri.base,
    initialAdminKey: readSessionStorageValue(adminSessionKey),
    onAdminKeyChanged: (adminKey) => writeSessionStorageValue(adminSessionKey, adminKey),
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

  final isLeaderboardTab = LeaderboardService.isLeaderboardPageUri(Uri.base);
  final eventId = LeaderboardService.resolveEventId(configuredEventId: _leaderboardEventFromEnv, uri: Uri.base);
  final fallbackGameUrl = LeaderboardService.buildGameTabUri(Uri.base, eventId: eventId).toString();

  runApp(
    BackyardBaristaApp(
      cityController: cityController,
      judgeService: judgeService,
      leaderboardService: isLeaderboardTab ? null : _buildLeaderboardService(),
      hallBoardController: isLeaderboardTab ? _buildHallBoardController() : null,
      onBackToGame: () => returnToGameTab(fallbackGameUrl),
    ),
  );
}

class BackyardBaristaApp extends StatelessWidget {
  const BackyardBaristaApp({
    required this.cityController,
    required this.judgeService,
    this.leaderboardService,
    this.hallBoardController,
    this.onBackToGame,
    this.onOpenLeaderboardTab,
    super.key,
  });

  final CityEditionController cityController;
  final CafeJudgeService judgeService;
  final LeaderboardService? leaderboardService;
  final HallBoardController? hallBoardController;
  final VoidCallback? onBackToGame;
  final void Function(Uri leaderboardUri)? onOpenLeaderboardTab;

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

    final activeBoardController = hallBoardController;

    return MaterialApp(
      title: 'Backyard Barista on Cloud Run',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontFamily: 'GoogleSans',
          fontFamilyFallback: _emojiFontFallbacks,
        ),
      ),
      home: activeBoardController != null
          ? ListenableBuilder(
              listenable: cityController,
              builder: (context, _) => HallLeaderboardPage(
                controller: activeBoardController,
                languageCode: cityController.activeEdition.defaultLanguage,
                onBackToGame: onBackToGame ?? () {},
              ),
            )
          : CafeCounterScreen(
              cityController: cityController,
              judgeService: judgeService,
              leaderboardService: leaderboardService,
              onOpenLeaderboardTab: onOpenLeaderboardTab,
            ),
    );
  }
}
