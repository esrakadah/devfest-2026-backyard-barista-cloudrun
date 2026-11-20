import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const Size _testSurfaceSize = Size(1280, 1200);
const Duration _oneTick = Duration(seconds: 1);

void main() {
  late DateTime now;
  late List<http.Request> leaderboardRequests;

  setUp(() {
    now = DateTime.utc(2026, 11, 21, 11, 32);
    leaderboardRequests = <http.Request>[];
  });

  LeaderboardService buildLeaderboard({MockClientHandler? respond, String? rememberedPlayerName}) {
    final leaderboardService = LeaderboardService(
      projectId: 'test-project',
      eventId: 'prova',
      playerId: 'AbCdEfGhIjKlMnOpQrSt',
      httpClient: MockClient((request) {
        leaderboardRequests.add(request);
        return respond?.call(request) ?? Future<http.Response>.value(http.Response('{}', 200));
      }),
      clock: () => now,
      rememberedPlayerName: rememberedPlayerName,
    );
    addTearDown(leaderboardService.dispose);
    return leaderboardService;
  }

  Future<void> pumpCounter(WidgetTester tester, {LeaderboardService? leaderboardService}) async {
    await tester.binding.setSurfaceSize(_testSurfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      BackyardBaristaApp(
        cityController: CityEditionController(remoteConfigCityCode: 'gaziantep'),
        judgeService: CafeJudgeService(clock: () => now, forceOfflineMode: true),
        leaderboardService: leaderboardService,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> joinAs(WidgetTester tester, String playerName) async {
    await tester.enterText(find.byKey(const Key('leaderboard_name_field')), playerName);
    await tester.pump();
    await tester.tap(find.byKey(const Key('leaderboard_start_button')));
    await tester.pumpAndSettle();
  }

  Future<void> serveSweetTray(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('ingredient_card_espresso')));
    await tester.tap(find.byKey(const Key('ingredient_card_baklava')));
    final sugarCard = find.byKey(const Key('ingredient_card_sugar_jar'));
    await tester.ensureVisible(sugarCard);
    await tester.pumpAndSettle();
    await tester.tap(sugarCard);
    await tester.pumpAndSettle();
    final serveButton = find.byKey(const Key('serve_order_button'));
    await tester.ensureVisible(serveButton);
    await tester.pumpAndSettle();
    await tester.tap(serveButton);
    await tester.pumpAndSettle();
  }

  String pillText(WidgetTester tester) {
    final pillLabel = find.descendant(
      of: find.byKey(const Key('leaderboard_status_pill')),
      matching: find.byType(Text),
    );
    return tester.widget<Text>(pillLabel).data ?? '';
  }

  testWidgets('without a leaderboard the game opens with no name dialog and no pill', (tester) async {
    await pumpCounter(tester);

    expect(find.byKey(const Key('leaderboard_name_field')), findsNothing);
    expect(find.byKey(const Key('leaderboard_status_pill')), findsNothing);
  });

  testWidgets('the name dialog starts the leaderboard once the name has two characters', (tester) async {
    final leaderboardService = buildLeaderboard();
    await pumpCounter(tester, leaderboardService: leaderboardService);

    expect(find.text('Kullanıcı adın?'), findsOneWidget);
    FilledButton startButton() => tester.widget<FilledButton>(find.byKey(const Key('leaderboard_start_button')));
    expect(startButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('leaderboard_name_field')), ' e ');
    await tester.pump();
    expect(startButton().onPressed, isNull);

    await joinAs(tester, ' Esra ');

    expect(find.text('Kullanıcı adın?'), findsNothing);
    expect(leaderboardService.playerName, 'Esra');
    expect(pillText(tester), 'Esra');
    expect(leaderboardRequests, isEmpty);
  });

  testWidgets('the name this browser used before is prefilled', (tester) async {
    await pumpCounter(tester, leaderboardService: buildLeaderboard(rememberedPlayerName: 'Esra'));

    expect(tester.widget<TextField>(find.byKey(const Key('leaderboard_name_field'))).controller?.text, 'Esra');
    expect(tester.widget<FilledButton>(find.byKey(const Key('leaderboard_start_button'))).onPressed, isNotNull);
  });

  testWidgets('skipping the dialog plays without the leaderboard', (tester) async {
    final leaderboardService = buildLeaderboard();
    await pumpCounter(tester, leaderboardService: leaderboardService);

    await tester.tap(find.byKey(const Key('leaderboard_skip_button')));
    await tester.pumpAndSettle();
    await serveSweetTray(tester);

    expect(find.byKey(const Key('customer_review_card')), findsOneWidget);
    expect(leaderboardService.phase, LeaderboardPhase.optedOut);
    expect(find.byKey(const Key('leaderboard_status_pill')), findsNothing);
    expect(leaderboardRequests, isEmpty);
  });

  testWidgets('the pill counts down from the first served tray and ends on the final score', (tester) async {
    final leaderboardService = buildLeaderboard();
    await pumpCounter(tester, leaderboardService: leaderboardService);
    await joinAs(tester, 'Esra');

    await serveSweetTray(tester);

    expect(leaderboardRequests, hasLength(1));
    expect(leaderboardService.score, 100);
    expect(pillText(tester), 'Esra · 03:00');

    now = now.add(const Duration(seconds: 19));
    await tester.pump(_oneTick);
    expect(pillText(tester), 'Esra · 02:41');
    expect(find.byKey(const Key('leaderboard_finished_message')), findsNothing);

    now = now.add(const Duration(seconds: 161));
    await tester.pump(_oneTick);
    await tester.pumpAndSettle();

    expect(pillText(tester), 'Esra · 100p');
    expect(find.text('Süre doldu! Puanın: 100. Sahnedeki tabloya bak.'), findsOneWidget);
  });

  testWidgets('a leaderboard that cannot be reached never breaks a serve', (tester) async {
    final leaderboardService = buildLeaderboard(
      respond: (request) async => throw http.ClientException('hall Wi-Fi is gone'),
    );
    await pumpCounter(tester, leaderboardService: leaderboardService);
    await joinAs(tester, 'Esra');

    await serveSweetTray(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('customer_review_card')), findsOneWidget);
    expect(find.textContaining('5/5'), findsOneWidget);
    expect(leaderboardRequests, hasLength(1));
    expect(pillText(tester), 'Esra · 03:00');
  });
}
