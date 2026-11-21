import 'dart:convert';
import 'dart:io';

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/hall_board_controller.dart';
import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DateTime fixedClock() => DateTime.utc(2026, 11, 21, 11, 30);

  Map<String, Object?> firestorePlayerRow({
    required String id,
    required String name,
    required int score,
    required int rounds,
    required String updatedAt,
  }) {
    return <String, Object?>{
      'document': <String, Object?>{
        'name': 'projects/devfest-backyard-barista-2026/databases/(default)/documents/events/konya-2026/players/$id',
        'fields': <String, Object?>{
          'name': <String, Object?>{'stringValue': name},
          'score': <String, Object?>{'integerValue': '$score'},
          'rounds': <String, Object?>{'integerValue': '$rounds'},
          'updatedAt': <String, Object?>{'timestampValue': updatedAt},
        },
      },
    };
  }

  group('Leaderboard tab URL routing', () {
    test('buildLeaderboardTabUri and buildGameTabUri round-trip query parameters cleanly', () {
      final gameUri = Uri.parse('https://backyard-barista.run.app/?remote_city=konya&board=prova');
      final boardUri = LeaderboardService.buildLeaderboardTabUri(gameUri, eventId: 'prova');

      expect(LeaderboardService.isLeaderboardPageUri(gameUri), isFalse);
      expect(LeaderboardService.isLeaderboardPageUri(boardUri), isTrue);
      expect(boardUri.queryParameters['remote_city'], 'konya');
      expect(boardUri.queryParameters['board'], 'prova');
      expect(boardUri.queryParameters['page'], 'leaderboard');

      final returnedGameUri = LeaderboardService.buildGameTabUri(boardUri, eventId: 'prova');
      expect(LeaderboardService.isLeaderboardPageUri(returnedGameUri), isFalse);
      expect(returnedGameUri.queryParameters['remote_city'], 'konya');
      expect(returnedGameUri.queryParameters['board'], 'prova');
      expect(returnedGameUri.queryParameters.containsKey('page'), isFalse);
    });

    test('Dockerfile and nginx template never bake LEADERBOARD_ADMIN_KEY into image or config', () {
      final dockerfile = File('Dockerfile').readAsStringSync();
      final nginxTemplate = File('nginx/default.conf.template').readAsStringSync();

      expect(dockerfile, isNot(contains('LEADERBOARD_ADMIN_KEY')));
      expect(nginxTemplate, isNot(contains('LEADERBOARD_ADMIN_KEY')));
      expect(nginxTemplate, contains('location ^~ /api/leaderboard/admin/'));
      expect(nginxTemplate, contains('limit_req zone=admin_auth'));
    });
  });

  group('In-game Skor Tablosu button', () {
    testWidgets('opens the standalone leaderboard tab URL when tapped', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Uri? openedUri;
      final leaderboardService = LeaderboardService(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'prova',
        playerId: 'AbCdEfGhIjKlMnOpQrSt',
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        clock: fixedClock,
      )..playWithoutLeaderboard();
      addTearDown(leaderboardService.dispose);

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'konya'),
          judgeService: CafeJudgeService(
            clock: fixedClock,
            httpClient: MockClient((_) async => http.Response('offline', 503)),
          ),
          leaderboardService: leaderboardService,
          onOpenLeaderboardTab: (uri) => openedUri = uri,
        ),
      );
      await tester.pump();

      final openButton = find.byKey(const Key('open_leaderboard_tab_button'));
      expect(openButton, findsOneWidget);

      await tester.tap(openButton);
      await tester.pump();

      expect(openedUri, isNotNull);
      expect(openedUri!.queryParameters['page'], 'leaderboard');
      expect(openedUri!.queryParameters['board'], 'prova');
    });
  });

  group('HallLeaderboardPage participant vs speaker admin access', () {
    testWidgets('participants see ranked rows and Back to Game, with no Reset or Pause buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var didReturnToGame = false;
      final controller = HallBoardController(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'konya-2026',
        apiOrigin: Uri.parse('https://backyard-barista.run.app'),
        enablePolling: false,
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/leaderboard/state') {
            return http.Response(
              jsonEncode(<String, Object?>{
                'eventId': 'konya-2026',
                'isPaused': false,
                'frozenAt': null,
              }),
              200,
            );
          }
          if (request.url.path.endsWith(':runQuery')) {
            return http.Response(
              jsonEncode(<Object?>[
                firestorePlayerRow(
                  id: 'p1',
                  name: 'Zeynep',
                  score: 300,
                  rounds: 3,
                  updatedAt: '2026-11-21T11:31:00Z',
                ),
                firestorePlayerRow(
                  id: 'p2',
                  name: 'amk trol',
                  score: 200,
                  rounds: 2,
                  updatedAt: '2026-11-21T11:31:10Z',
                ),
              ]),
              200,
            );
          }
          return http.Response('Not Found', 404);
        }),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'konya'),
          judgeService: CafeJudgeService(clock: fixedClock),
          hallBoardController: controller,
          onBackToGame: () => didReturnToGame = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zeynep'), findsWidgets);
      expect(find.text('300p'), findsOneWidget);
      expect(find.text('***'), findsWidgets);
      expect(find.byKey(const Key('leaderboard_admin_toolbar')), findsNothing);
      expect(find.byKey(const Key('leaderboard_toggle_pause_button')), findsNothing);
      expect(find.byKey(const Key('leaderboard_reset_button')), findsNothing);

      await tester.tap(find.byKey(const Key('leaderboard_back_to_game_button')));
      await tester.pump();
      expect(didReturnToGame, isTrue);
    });

    testWidgets('rejects wrong admin key and unlocks Stop + Reset only after server 200', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const validSecret = 'konya-sahne-4242';
      var isPausedOnServer = false;
      String? frozenAtOnServer;
      var playersOnServer = <Map<String, Object?>>[
        firestorePlayerRow(
          id: 'p1',
          name: 'Ayşe',
          score: 200,
          rounds: 2,
          updatedAt: '2026-11-21T11:30:00Z',
        ),
        firestorePlayerRow(
          id: 'p2',
          name: 'Geç Kalan',
          score: 500,
          rounds: 5,
          updatedAt: '2026-11-21T11:35:00Z',
        ),
      ];

      final controller = HallBoardController(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'konya-2026',
        apiOrigin: Uri.parse('https://backyard-barista.run.app'),
        enablePolling: false,
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/leaderboard/state') {
            return http.Response(
              jsonEncode(<String, Object?>{
                'eventId': 'konya-2026',
                'isPaused': isPausedOnServer,
                'frozenAt': frozenAtOnServer,
              }),
              200,
            );
          }
          if (request.url.path == '/api/leaderboard/admin/verify') {
            final headerKey = request.headers['X-Admin-Key'];
            return headerKey == validSecret
                ? http.Response(jsonEncode(<String, Object?>{'ok': true}), 200)
                : http.Response(jsonEncode(<String, Object?>{'error': 'invalid_admin_key'}), 401);
          }
          if (request.url.path == '/api/leaderboard/admin/pause') {
            if (request.headers['X-Admin-Key'] != validSecret) {
              return http.Response('{}', 401);
            }
            final decoded = jsonDecode(request.body) as Map<String, Object?>;
            isPausedOnServer = decoded['isPaused'] == true;
            frozenAtOnServer = isPausedOnServer ? '2026-11-21T11:32:00Z' : null;
            return http.Response(
              jsonEncode(<String, Object?>{
                'eventId': 'konya-2026',
                'isPaused': isPausedOnServer,
                'frozenAt': frozenAtOnServer,
              }),
              200,
            );
          }
          if (request.url.path == '/api/leaderboard/admin/reset') {
            if (request.headers['X-Admin-Key'] != validSecret) {
              return http.Response('{}', 401);
            }
            final deletedCount = playersOnServer.length;
            playersOnServer = <Map<String, Object?>>[];
            isPausedOnServer = false;
            frozenAtOnServer = null;
            return http.Response(
              jsonEncode(<String, Object?>{
                'eventId': 'konya-2026',
                'isPaused': false,
                'frozenAt': null,
                'deletedPlayers': deletedCount,
              }),
              200,
            );
          }
          if (request.url.path.endsWith(':runQuery')) {
            return http.Response.bytes(
              utf8.encode(jsonEncode(playersOnServer)),
              200,
              headers: const <String, String>{'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('Not Found', 404);
        }),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'konya'),
          judgeService: CafeJudgeService(clock: fixedClock),
          hallBoardController: controller,
        ),
      );
      await tester.pumpAndSettle();

      // Try wrong admin password first.
      await tester.tap(find.byKey(const Key('leaderboard_admin_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('admin_password_field')), 'yanlis-sifre');
      await tester.tap(find.byKey(const Key('admin_login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin_login_error_text')), findsOneWidget);
      expect(find.byKey(const Key('leaderboard_admin_toolbar')), findsNothing);

      // Now enter the valid server-verified secret.
      await tester.enterText(find.byKey(const Key('admin_password_field')), validSecret);
      await tester.tap(find.byKey(const Key('admin_login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('leaderboard_admin_toolbar')), findsOneWidget);

      // Freeze the board: rows updated after frozenAt ('Geç Kalan') are excluded.
      await tester.tap(find.byKey(const Key('leaderboard_toggle_pause_button')));
      await tester.pumpAndSettle();

      expect(controller.isPaused, isTrue);
      expect(find.text('Ayşe'), findsWidgets);
      expect(find.text('Geç Kalan'), findsNothing);

      // Reset the board through the confirmation dialog.
      await tester.tap(find.byKey(const Key('leaderboard_reset_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leaderboard_confirm_reset_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('leaderboard_confirm_reset_button')));
      await tester.pumpAndSettle();

      expect(controller.entries, isEmpty);
      expect(controller.isPaused, isFalse);

      // Sign out hides admin controls again.
      await tester.tap(find.byKey(const Key('leaderboard_admin_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leaderboard_admin_toolbar')), findsNothing);
    });
  });

  group('Persisted player session across tab switches and reloads', () {
    testWidgets('restores a joined mid-round session without re-opening the name dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var currentTime = DateTime.utc(2026, 11, 21, 11, 30, 30);
      final savedJson = LeaderboardSessionSnapshot(
        isOptedOut: false,
        playerName: 'Esra',
        score: 200,
        rounds: 2,
        firstRoundScore: 100,
        isDocumentCreated: true,
        windowStartedAt: DateTime.utc(2026, 11, 21, 11, 30),
      ).toJsonString();

      final leaderboardService = LeaderboardService(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'konya-2026',
        playerId: 'AbCdEfGhIjKlMnOpQrSt',
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        clock: () => currentTime,
        restoredSession: LeaderboardSessionSnapshot.tryParse(savedJson),
      );
      addTearDown(leaderboardService.dispose);

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'konya'),
          judgeService: CafeJudgeService(clock: () => currentTime, forceOfflineMode: true),
          leaderboardService: leaderboardService,
        ),
      );
      await tester.pump();

      expect(find.text('Kullanıcı adın?'), findsNothing);
      expect(leaderboardService.phase, LeaderboardPhase.running);
      expect(leaderboardService.score, 200);
      expect(find.text('Esra · 02:30'), findsOneWidget);

      currentTime = currentTime.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Esra · 02:25'), findsOneWidget);
    });

    testWidgets('restores an opted-out session silently and allows voluntary rejoin', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final leaderboardService = LeaderboardService(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'konya-2026',
        playerId: 'AbCdEfGhIjKlMnOpQrSt',
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        clock: fixedClock,
        restoredSession: const LeaderboardSessionSnapshot(isOptedOut: true),
      );
      addTearDown(leaderboardService.dispose);

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: CityEditionController(remoteConfigCityCode: 'konya'),
          judgeService: CafeJudgeService(clock: fixedClock, forceOfflineMode: true),
          leaderboardService: leaderboardService,
        ),
      );
      await tester.pump();

      expect(find.text('Kullanıcı adın?'), findsNothing);
      expect(leaderboardService.phase, LeaderboardPhase.optedOut);

      await tester.tap(find.byKey(const Key('rejoin_leaderboard_button')));
      await tester.pumpAndSettle();
      expect(find.text('Kullanıcı adın?'), findsOneWidget);
    });

    test('reconciles a restored session to ready (0 pts) while keeping the name when the board was reset', () async {
      final leaderboardService = LeaderboardService(
        projectId: 'devfest-backyard-barista-2026',
        eventId: 'konya-2026',
        playerId: 'AbCdEfGhIjKlMnOpQrSt',
        httpClient: MockClient((_) async => http.Response('Not Found', 404)),
        clock: () => DateTime.utc(2026, 11, 21, 11, 40),
        restoredSession: LeaderboardSessionSnapshot(
          isOptedOut: false,
          playerName: 'Esra',
          score: 400,
          rounds: 4,
          firstRoundScore: 100,
          isDocumentCreated: true,
          windowStartedAt: DateTime.utc(2026, 11, 21, 11, 30),
        ),
      );
      addTearDown(leaderboardService.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(leaderboardService.playerName, 'Esra');
      expect(leaderboardService.score, 0);
      expect(leaderboardService.rounds, 0);
      expect(leaderboardService.phase, LeaderboardPhase.ready);
    });
  });
}
