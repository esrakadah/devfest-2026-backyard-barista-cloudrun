import 'dart:convert';

import 'package:backyard_barista_deck/leaderboard/hall_board.dart';
import 'package:backyard_barista_deck/leaderboard/hall_board_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> _row(String name, int score, int rounds, String updatedAt) {
  return <String, Object?>{
    'document': <String, Object?>{
      'name': 'projects/p/databases/(default)/documents/events/prova/players/$name',
      'fields': <String, Object?>{
        'name': <String, Object?>{'stringValue': name},
        'score': <String, Object?>{'integerValue': '$score'},
        'rounds': <String, Object?>{'integerValue': '$rounds'},
        'updatedAt': <String, Object?>{'timestampValue': updatedAt},
      },
    },
    'readTime': '2026-11-21T11:40:00Z',
  };
}

HallBoardEntry _entry(String name, int score) {
  return HallBoardEntry(name: name, score: score, rounds: score ~/ 100, updatedAt: DateTime.utc(2026, 11, 21, 11, 30));
}

HallBoard _boardAnswering(http.Response Function() answer) {
  return HallBoard(client: MockClient((request) async => answer()), eventId: 'prova', isNetworkAllowed: true);
}

Future<void> _pumpOnSlideCanvas(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1760, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

void main() {
  group('reading the board', () {
    test('rows without a document or with a missing field are skipped', () {
      final rows = parseHallBoardRows(<Object?>[
        _row('tuzlu', 300, 3, '2026-11-21T11:31:00Z'),
        <String, Object?>{'readTime': '2026-11-21T11:40:00Z'},
        <String, Object?>{
          'document': <String, Object?>{
            'fields': <String, Object?>{
              'name': <String, Object?>{'stringValue': 'yarım'},
            },
          },
        },
      ]);

      expect(rows.map((entry) => entry.name), <String>['tuzlu']);
      expect(rows.single.score, 300);
      expect(rows.single.rounds, 3);
    });

    test('an answer that is not a list gives an empty board', () {
      expect(parseHallBoardRows(<String, Object?>{'error': 'denied'}), isEmpty);
    });

    test('the best score leads and a tie goes to the earlier player', () async {
      final board = _boardAnswering(
        () => http.Response.bytes(
          utf8.encode(
            jsonEncode(<Object?>[
              _row('geç', 500, 5, '2026-11-21T11:33:00Z'),
              _row('erken', 500, 5, '2026-11-21T11:32:00Z'),
              _row('lider', 900, 9, '2026-11-21T11:34:00Z'),
            ]),
          ),
          200,
        ),
      );

      await board.refresh();

      expect(board.entries.map((entry) => entry.name), <String>['lider', 'erken', 'geç']);
      expect(board.hasAnswer, isTrue);
      expect(board.isLastFetchFailed, isFalse);
    });

    test('a failed read keeps the standing already on the screen', () async {
      var isOnline = true;
      final board = _boardAnswering(
        () => isOnline
            ? http.Response(jsonEncode(<Object?>[_row('lider', 900, 9, '2026-11-21T11:34:00Z')]), 200)
            : http.Response('too many requests', 429),
      );

      await board.refresh();
      isOnline = false;
      await board.refresh();

      expect(board.entries.single.name, 'lider');
      expect(board.isLastFetchFailed, isTrue);
    });

    test('a client that throws never breaks the slide', () async {
      final board = HallBoard(
        client: MockClient((request) async => throw http.ClientException('no network')),
        eventId: 'prova',
        isNetworkAllowed: true,
      );

      await board.refresh();

      expect(board.entries, isEmpty);
      expect(board.isLastFetchFailed, isTrue);
    });

    test('a frozen board does not change any more', () async {
      var score = 100;
      final board = _boardAnswering(
        () => http.Response(jsonEncode(<Object?>[_row('lider', score, 1, '2026-11-21T11:34:00Z')]), 200),
      );

      await board.refresh();
      board.freeze();
      score = 900;
      await board.refresh();

      expect(board.entries.single.score, 100);
    });

    test('the event comes from the address when it is a plain id', () {
      expect(resolveHallBoardEvent(Uri.parse('https://deck.example/?board=prova#/hall-leaderboard')), 'prova');
      expect(resolveHallBoardEvent(Uri.parse('https://deck.example/?board=../x')), isNot('../x'));
    });

    test('a rude word in a name never reaches the hall screen', () {
      expect(hallBoardDisplayName('Mevlana42'), 'Mevlana42');
      expect(hallBoardDisplayName('klasik kahve'), 'klasik kahve');
      expect(hallBoardDisplayName('AMK_esra'), '***');
    });
  });

  group('the leaderboard slides', () {
    testWidgets('the board shows the first ten players with place, rounds and score', (tester) async {
      final board = HallBoard(eventId: 'prova', isNetworkAllowed: false)
        ..showEntries(<HallBoardEntry>[
          for (var index = 0; index < 12; index++) _entry('oyuncu$index', 1200 - index * 100),
        ]);

      await _pumpOnSlideCanvas(tester, HallBoardView(isFrozen: false, board: board));

      expect(find.text('oyuncu0'), findsOneWidget);
      expect(find.text('oyuncu9'), findsOneWidget);
      expect(find.text('oyuncu10'), findsNothing);
      expect(find.text('1200'), findsOneWidget);
      expect(find.text('Dash'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one click forward freezes the board and one click back opens it again', (tester) async {
      final board = HallBoard(eventId: 'prova', isNetworkAllowed: false)
        ..showEntries(<HallBoardEntry>[_entry('lider', 900)]);

      await _pumpOnSlideCanvas(tester, HallBoardView(isFrozen: true, board: board));
      await tester.pump();
      expect(board.isFrozen, isTrue);
      expect(find.text('SÜRE DOLDU · SON DURUM'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: HallBoardView(isFrozen: false, board: board))));
      await tester.pump();
      expect(board.isFrozen, isFalse);
    });

    testWidgets('the podium reveals third place first and the winner last', (tester) async {
      final board = HallBoard(eventId: 'prova', isNetworkAllowed: false)
        ..showEntries(<HallBoardEntry>[_entry('birinci', 900), _entry('ikinci', 700), _entry('üçüncü', 500)]);

      await _pumpOnSlideCanvas(tester, WinnersPodiumView(revealedPlaces: 0, board: board));
      expect(find.text('?'), findsNWidgets(3));
      expect(board.isFrozen, isTrue);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WinnersPodiumView(revealedPlaces: 1, board: board))));
      await tester.pump();
      expect(find.text('üçüncü'), findsOneWidget);
      expect(find.text('birinci'), findsNothing);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WinnersPodiumView(revealedPlaces: 3, board: board))));
      await tester.pump();
      expect(find.text('birinci'), findsOneWidget);
      expect(find.text('?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a podium with fewer than three players says so instead of inventing a winner', (tester) async {
      final board = HallBoard(eventId: 'prova', isNetworkAllowed: false)
        ..showEntries(<HallBoardEntry>[_entry('tek', 100)]);

      await _pumpOnSlideCanvas(tester, WinnersPodiumView(revealedPlaces: 3, board: board));

      expect(find.text('tek'), findsOneWidget);
      expect(find.text('Henüz kimse yok'), findsNWidgets(2));
    });
  });
}
