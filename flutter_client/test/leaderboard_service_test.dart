import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String _projectId = 'test-project';
const String _eventId = 'prova';
const String _playerId = 'AbCdEfGhIjKlMnOpQrSt';
const String _documentPath = 'projects/$_projectId/databases/(default)/documents/events/$_eventId/players/$_playerId';
const int _sweetRoundPoints = 100;
const int _prankRoundPoints = 30;

Map<String, Object?> _firstWriteOf(http.Request request) {
  final body = jsonDecode(request.body) as Map<String, Object?>;
  final writes = body['writes']! as List<Object?>;
  expect(writes, hasLength(1));
  return writes.single! as Map<String, Object?>;
}

Map<String, Object?> _fieldsOf(Map<String, Object?> write) {
  final update = write['update']! as Map<String, Object?>;
  return update['fields']! as Map<String, Object?>;
}

List<String> _transformedFieldsOf(Map<String, Object?> write) {
  final transforms = write['updateTransforms']! as List<Object?>;
  return <String>[
    for (final transform in transforms) (transform! as Map<String, Object?>)['fieldPath']! as String,
  ];
}

void main() {
  late DateTime now;
  late List<http.Request> requests;

  setUp(() {
    now = DateTime.utc(2026, 11, 21, 11, 32);
    requests = <http.Request>[];
  });

  LeaderboardService buildService(MockClientHandler respond, {String? rememberedPlayerName}) {
    final service = LeaderboardService(
      projectId: _projectId,
      eventId: _eventId,
      playerId: _playerId,
      httpClient: MockClient((request) {
        requests.add(request);
        return respond(request);
      }),
      clock: () => now,
      rememberedPlayerName: rememberedPlayerName,
    );
    addTearDown(service.dispose);
    return service;
  }

  Future<http.Response> accept(http.Request request) async => http.Response('{}', 200);

  test('the first served round creates the row with both server timestamps', () async {
    final service = buildService(accept);
    expect(service.registerPlayer('  Esra   Kadah '), isTrue);

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();

    expect(requests, hasLength(1));
    final request = requests.single;
    expect(request.method, 'POST');
    expect(
      request.url.toString(),
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents:commit',
    );
    final write = _firstWriteOf(request);
    expect((write['update']! as Map<String, Object?>)['name'], _documentPath);
    expect(_fieldsOf(write), <String, Object?>{
      'name': <String, Object?>{'stringValue': 'Esra Kadah'},
      'score': <String, Object?>{'integerValue': '100'},
      'rounds': <String, Object?>{'integerValue': '1'},
    });
    expect(write['updateMask'], <String, Object?>{
      'fieldPaths': <String>['name', 'score', 'rounds'],
    });
    expect(_transformedFieldsOf(write), <String>['updatedAt', 'startedAt']);
    expect(write['currentDocument'], <String, Object?>{'exists': false});
  });

  test('later rounds update the row with the running totals and leave startedAt alone', () async {
    final service = buildService(accept)..registerPlayer('Esra');

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    service.recordRound(_prankRoundPoints);
    await pumpEventQueue();

    expect(requests, hasLength(2));
    final write = _firstWriteOf(requests.last);
    expect(_fieldsOf(write)['score'], <String, Object?>{'integerValue': '130'});
    expect(_fieldsOf(write)['rounds'], <String, Object?>{'integerValue': '2'});
    expect(_transformedFieldsOf(write), <String>['updatedAt']);
    expect(write['currentDocument'], <String, Object?>{'exists': true});
  });

  test('a player name is trimmed and must be 2 to 16 characters', () {
    expect(LeaderboardService.normalizePlayerName('  Şükrü   Çağrı '), 'Şükrü Çağrı');
    expect(LeaderboardService.normalizePlayerName('a'), isNull);
    expect(LeaderboardService.normalizePlayerName('   '), isNull);
    expect(LeaderboardService.normalizePlayerName('a' * LeaderboardService.maxPlayerNameLength), hasLength(16));
    expect(LeaderboardService.normalizePlayerName('a' * (LeaderboardService.maxPlayerNameLength + 1)), isNull);

    final service = buildService(accept);
    expect(service.registerPlayer('x'), isFalse);
    expect(service.phase, LeaderboardPhase.awaitingName);
    expect(service.registerPlayer('Esra'), isTrue);
    expect(service.registerPlayer('Someone else'), isFalse);
    expect(service.playerName, 'Esra');
  });

  test('the remembered name is offered again and a chosen name is handed to the store', () {
    final chosenNames = <String>[];
    final service = LeaderboardService(
      projectId: _projectId,
      eventId: _eventId,
      playerId: _playerId,
      httpClient: MockClient(accept),
      clock: () => now,
      rememberedPlayerName: ' Esra ',
      onPlayerNameChosen: chosenNames.add,
    );
    addTearDown(service.dispose);

    expect(service.suggestedPlayerName, 'Esra');
    expect(service.playerName, isNull);
    service.registerPlayer('Esra K');
    expect(chosenNames, <String>['Esra K']);
  });

  test('nothing is counted or sent before a name, or after choosing to play without the leaderboard', () async {
    final service = buildService(accept);

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, isEmpty);
    expect(service.score, 0);

    service
      ..playWithoutLeaderboard()
      ..recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, isEmpty);
    expect(service.phase, LeaderboardPhase.optedOut);
    expect(service.registerPlayer('Esra'), isFalse);
  });

  test('a round served after 180 seconds is not counted and not sent', () async {
    final service = buildService(accept)..registerPlayer('Esra');

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(service.remaining, LeaderboardService.playWindow);

    now = now.add(const Duration(seconds: 179));
    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, hasLength(2));
    expect(service.phase, LeaderboardPhase.running);

    now = now.add(const Duration(seconds: 1));
    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();

    expect(requests, hasLength(2));
    expect(service.phase, LeaderboardPhase.finished);
    expect(service.score, 200);
    expect(service.rounds, 2);
    expect(service.remaining, Duration.zero);
  });

  test('refreshWindow finishes a running window once its time is up', () {
    final service = buildService(accept)
      ..registerPlayer('Esra')
      ..recordRound(_sweetRoundPoints);

    now = now.add(const Duration(seconds: 100));
    service.refreshWindow();
    expect(service.phase, LeaderboardPhase.running);
    expect(service.remaining, const Duration(seconds: 80));

    now = now.add(const Duration(seconds: 80));
    service.refreshWindow();
    expect(service.phase, LeaderboardPhase.finished);
  });

  test('a send that throws is dropped and the next round creates the row, then sends the totals', () async {
    var shouldFail = true;
    final service = buildService((request) async {
      if (shouldFail) {
        throw http.ClientException('hall Wi-Fi is gone');
      }
      return http.Response('{}', 200);
    })
      ..registerPlayer('Esra');

    expect(() => service.recordRound(_prankRoundPoints), returnsNormally);
    await pumpEventQueue();
    expect(requests, hasLength(1));

    shouldFail = false;
    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();

    expect(requests, hasLength(3));
    final createWrite = _firstWriteOf(requests[1]);
    expect(createWrite['currentDocument'], <String, Object?>{'exists': false});
    expect(_fieldsOf(createWrite)['score'], <String, Object?>{'integerValue': '30'});
    expect(_fieldsOf(createWrite)['rounds'], <String, Object?>{'integerValue': '1'});
    final totalsWrite = _firstWriteOf(requests[2]);
    expect(totalsWrite['currentDocument'], <String, Object?>{'exists': true});
    expect(_fieldsOf(totalsWrite)['score'], <String, Object?>{'integerValue': '130'});
    expect(_fieldsOf(totalsWrite)['rounds'], <String, Object?>{'integerValue': '2'});
  });

  testWidgets('a send that hangs is given up after the timeout and later rounds still go out', (tester) async {
    var shouldHang = true;
    final service = buildService((request) {
      if (shouldHang) {
        return Completer<http.Response>().future;
      }
      return Future<http.Response>.value(http.Response('{}', 200));
    })
      ..registerPlayer('Esra')
      ..recordRound(_sweetRoundPoints);
    await tester.pump();
    expect(requests, hasLength(1));

    await tester.pump(LeaderboardService.sendTimeout + const Duration(seconds: 1));
    shouldHang = false;
    service.recordRound(_sweetRoundPoints);
    await tester.pump();
    await tester.pump();

    expect(requests.length, greaterThan(1));
    expect(_fieldsOf(_firstWriteOf(requests.last))['score'], <String, Object?>{'integerValue': '200'});
  });

  test('rounds served while a send is in flight go out as one write with the latest totals', () async {
    final firstResponse = Completer<http.Response>();
    final service = buildService((request) {
      if (requests.length == 1) {
        return firstResponse.future;
      }
      return Future<http.Response>.value(http.Response('{}', 200));
    })
      ..registerPlayer('Esra')
      ..recordRound(_sweetRoundPoints)
      ..recordRound(_prankRoundPoints)
      ..recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, hasLength(1));

    firstResponse.complete(http.Response('{}', 200));
    await pumpEventQueue();

    expect(requests, hasLength(2));
    final write = _firstWriteOf(requests.last);
    expect(_fieldsOf(write)['score'], <String, Object?>{'integerValue': '230'});
    expect(_fieldsOf(write)['rounds'], <String, Object?>{'integerValue': '3'});
    expect(service.score, 230);
  });

  test('a refused create falls back to the update form, as after a page reload', () async {
    final service = buildService((request) async {
      final isCreate = request.method == 'POST' && request.body.contains('"exists":false');
      return isCreate ? http.Response('{"error":{"status":"ALREADY_EXISTS"}}', 409) : http.Response('{}', 200);
    })
      ..registerPlayer('Esra');

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, hasLength(2));
    expect(_firstWriteOf(requests.last)['currentDocument'], <String, Object?>{'exists': true});

    service.recordRound(_sweetRoundPoints);
    await pumpEventQueue();
    expect(requests, hasLength(3));
    expect(_firstWriteOf(requests.last)['currentDocument'], <String, Object?>{'exists': true});
  });

  group('board reset', () {
    test('NOT_FOUND on an update zeroes the totals and the next round starts a fresh row and window', () async {
      var isBoardReset = false;
      final service = buildService((request) async {
        if (isBoardReset && request.body.contains('"exists":true')) {
          return http.Response('{"error":{"code":404,"status":"NOT_FOUND"}}', 404);
        }
        return http.Response('{}', 200);
      })
        ..registerPlayer('Esra');
      var finishedNotifications = 0;
      service.addListener(() {
        if (service.phase == LeaderboardPhase.finished) {
          finishedNotifications += 1;
        }
      });

      service.recordRound(_sweetRoundPoints);
      await pumpEventQueue();
      now = now.add(const Duration(seconds: 60));
      isBoardReset = true;
      service.recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      expect(service.phase, LeaderboardPhase.ready);
      expect(service.score, 0);
      expect(service.rounds, 0);
      expect(service.playerName, 'Esra');
      expect(service.remaining, LeaderboardService.playWindow);
      expect(finishedNotifications, 0);

      requests.clear();
      service.recordRound(_prankRoundPoints);
      await pumpEventQueue();

      expect(requests, hasLength(1));
      final write = _firstWriteOf(requests.single);
      expect(write['currentDocument'], <String, Object?>{'exists': false});
      expect(_fieldsOf(write)['score'], <String, Object?>{'integerValue': '30'});
      expect(_fieldsOf(write)['rounds'], <String, Object?>{'integerValue': '1'});
      expect(_transformedFieldsOf(write), <String>['updatedAt', 'startedAt']);
      expect(service.remaining, LeaderboardService.playWindow);

      now = now.add(const Duration(seconds: 150));
      service.refreshWindow();
      expect(service.phase, LeaderboardPhase.running);
    });

    test('a NOT_FOUND status in a non-404 answer is a reset too', () async {
      var isBoardReset = false;
      final service = buildService((request) async {
        if (isBoardReset) {
          return http.Response('{"error":{"code":400,"status":"NOT_FOUND"}}', 400);
        }
        return http.Response('{}', 200);
      })
        ..registerPlayer('Esra')
        ..recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      isBoardReset = true;
      service.recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      expect(service.phase, LeaderboardPhase.ready);
      expect(service.score, 0);
    });

    test('a refused update is checked with a read: a missing row is a reset', () async {
      var isBoardReset = false;
      final service = buildService((request) async {
        if (!isBoardReset) {
          return http.Response('{}', 200);
        }
        return request.method == 'GET'
            ? http.Response('{"error":{"code":404,"status":"NOT_FOUND"}}', 404)
            : http.Response('{"error":{"code":403,"status":"PERMISSION_DENIED"}}', 403);
      })
        ..registerPlayer('Esra')
        ..recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      isBoardReset = true;
      service.recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      expect(requests.last.method, 'GET');
      expect(requests.last.url.toString(), 'https://firestore.googleapis.com/v1/$_documentPath');
      expect(service.phase, LeaderboardPhase.ready);
      expect(service.score, 0);
    });

    test('a refused update with the row still there keeps the totals', () async {
      var isRefusing = false;
      final service = buildService((request) async {
        if (!isRefusing || request.method == 'GET') {
          return http.Response('{}', 200);
        }
        return http.Response('{"error":{"code":403,"status":"PERMISSION_DENIED"}}', 403);
      })
        ..registerPlayer('Esra')
        ..recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      isRefusing = true;
      service.recordRound(_sweetRoundPoints);
      await pumpEventQueue();

      expect(service.phase, LeaderboardPhase.running);
      expect(service.score, 200);
      expect(service.rounds, 2);
    });
  });

  test('the event id comes from ?board= when well formed, else from the build, else the default', () {
    String resolve(String configuredEventId, String url) =>
        LeaderboardService.resolveEventId(configuredEventId: configuredEventId, uri: Uri.parse(url));

    expect(resolve('konya-2026', 'https://game.example/?board=prova'), 'prova');
    expect(resolve('konya-2026', 'https://game.example/'), 'konya-2026');
    expect(resolve('konya-2026', 'https://game.example/?board=Not%20Valid'), 'konya-2026');
    expect(resolve('konya-2026', 'https://game.example/?board=${'a' * 33}'), 'konya-2026');
    expect(resolve('', 'https://game.example/'), LeaderboardService.defaultEventId);
    expect(resolve('../other', 'https://game.example/'), LeaderboardService.defaultEventId);
  });

  test('a player id is 20 characters of letters and digits', () {
    final playerId = LeaderboardService.generatePlayerId(math.Random(7));
    expect(playerId, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
    expect(LeaderboardService.generatePlayerId(math.Random(8)), isNot(playerId));
  });
}
