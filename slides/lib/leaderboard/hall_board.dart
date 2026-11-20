import 'dart:async';
import 'dart:convert';

import 'package:backyard_barista_deck/deck_language.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

/// Google Cloud project that holds the hall leaderboard of the game.
const String hallBoardProject = String.fromEnvironment(
  'LEADERBOARD_PROJECT',
  defaultValue: 'devfest-backyard-barista-2026',
);

/// Event whose players the deck shows. The game is built with the same id.
const String _hallBoardEventFromBuild = String.fromEnvironment(
  'LEADERBOARD_EVENT',
  defaultValue: isIzmirDeck ? 'izmir-2026' : 'konya-2026',
);

final RegExp _eventIdPattern = RegExp(r'^[a-z0-9-]{1,32}$');

/// The event id of this run: `?board=prova` in the address overrides the build, for rehearsals.
String resolveHallBoardEvent(Uri address) {
  final fromAddress = address.queryParameters['board'];
  if (fromAddress != null && _eventIdPattern.hasMatch(fromAddress)) {
    return fromAddress;
  }
  return _hallBoardEventFromBuild;
}

/// One player on the board.
@immutable
class HallBoardEntry {
  const HallBoardEntry({required this.name, required this.score, required this.rounds, required this.updatedAt});

  final String name;
  final int score;
  final int rounds;
  final DateTime updatedAt;
}

/// Reads the top of the leaderboard from Firestore while a slide is watching, and keeps the last
/// good answer when the network drops: a silent board must not blank the slide.
class HallBoard extends ChangeNotifier {
  HallBoard({http.Client? client, String? eventId, bool? isNetworkAllowed})
      : _client = client ?? http.Client(),
        eventId = eventId ?? resolveHallBoardEvent(Uri.base),
        _isNetworkAllowed = isNetworkAllowed ?? !_isRunningInTest;

  /// The one board both leaderboard slides share, so the podium shows what was frozen earlier.
  static final HallBoard instance = HallBoard();

  static const Duration pollInterval = Duration(seconds: 3);
  static const Duration requestTimeout = Duration(seconds: 4);
  static const int queryLimit = 30;
  static const int _httpOk = 200;

  /// The same check the game uses: `flutter test` runs on a test binding, and tests must not reach the network.
  static bool get _isRunningInTest => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  final http.Client _client;
  final String eventId;
  final bool _isNetworkAllowed;

  List<HallBoardEntry> _entries = const <HallBoardEntry>[];
  bool _isFrozen = false;
  bool _hasAnswer = false;
  bool _isLastFetchFailed = false;
  bool _isFetching = false;
  int _watcherCount = 0;
  Timer? _pollTimer;

  /// Best score first; on a tie the player who got there earlier.
  List<HallBoardEntry> get entries => _entries;

  /// True once the speaker closed the round; the board stops changing.
  bool get isFrozen => _isFrozen;

  /// True once Firestore answered at least once.
  bool get hasAnswer => _hasAnswer;

  bool get isLastFetchFailed => _isLastFetchFailed;

  /// A slide starts watching: the board polls while at least one slide watches and it is not frozen.
  void watch() {
    _watcherCount++;
    _syncPolling();
  }

  void unwatch() {
    _watcherCount--;
    _syncPolling();
  }

  void freeze() {
    if (_isFrozen) {
      return;
    }
    _isFrozen = true;
    _syncPolling();
    notifyListeners();
  }

  void unfreeze() {
    if (!_isFrozen) {
      return;
    }
    _isFrozen = false;
    _syncPolling();
    notifyListeners();
  }

  /// Replaces the entries without the network, for tests and for exported sample pictures.
  void showEntries(List<HallBoardEntry> entries) {
    _entries = _ranked(entries);
    _hasAnswer = true;
    notifyListeners();
  }

  void _syncPolling() {
    final shouldPoll = _isNetworkAllowed && _watcherCount > 0 && !_isFrozen;
    if (!shouldPoll) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    if (_pollTimer != null) {
      return;
    }
    _pollTimer = Timer.periodic(pollInterval, (_) => unawaited(refresh()));
    unawaited(refresh());
  }

  /// One read of the board. Never throws: a failed read keeps the entries already shown.
  Future<void> refresh() async {
    if (_isFetching || _isFrozen || !_isNetworkAllowed) {
      return;
    }
    _isFetching = true;
    try {
      final response = await _client
          .post(
            Uri.https(
              'firestore.googleapis.com',
              '/v1/projects/$hallBoardProject/databases/(default)/documents/events/$eventId:runQuery',
            ),
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, Object?>{
              'structuredQuery': <String, Object?>{
                'from': <Object?>[
                  <String, Object?>{'collectionId': 'players'},
                ],
                'orderBy': <Object?>[
                  <String, Object?>{
                    'field': <String, Object?>{'fieldPath': 'score'},
                    'direction': 'DESCENDING',
                  },
                ],
                'limit': queryLimit,
              },
            }),
          )
          .timeout(requestTimeout);
      if (response.statusCode != _httpOk) {
        _isLastFetchFailed = true;
      } else if (!_isFrozen) {
        _entries = _ranked(parseHallBoardRows(jsonDecode(utf8.decode(response.bodyBytes))));
        _hasAnswer = true;
        _isLastFetchFailed = false;
      }
    } on Object {
      _isLastFetchFailed = true;
    } finally {
      _isFetching = false;
    }
    notifyListeners();
  }

  static List<HallBoardEntry> _ranked(List<HallBoardEntry> entries) {
    return List<HallBoardEntry>.of(entries)
      ..sort((first, second) {
        final byScore = second.score.compareTo(first.score);
        return byScore != 0 ? byScore : first.updatedAt.compareTo(second.updatedAt);
      });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

/// Reads the rows of a Firestore `runQuery` answer. Rows that miss a field are skipped, never guessed.
List<HallBoardEntry> parseHallBoardRows(Object? decodedBody) {
  if (decodedBody is! List<Object?>) {
    return const <HallBoardEntry>[];
  }
  final entries = <HallBoardEntry>[];
  for (final row in decodedBody) {
    if (row is! Map<String, Object?>) {
      continue;
    }
    final document = row['document'];
    if (document is! Map<String, Object?>) {
      continue;
    }
    final fields = document['fields'];
    if (fields is! Map<String, Object?>) {
      continue;
    }
    final name = _fieldValue(fields, 'name', 'stringValue');
    final score = int.tryParse(_fieldValue(fields, 'score', 'integerValue') ?? '');
    final rounds = int.tryParse(_fieldValue(fields, 'rounds', 'integerValue') ?? '');
    final updatedAt = DateTime.tryParse(_fieldValue(fields, 'updatedAt', 'timestampValue') ?? '');
    if (name == null || score == null || rounds == null || updatedAt == null) {
      continue;
    }
    entries.add(HallBoardEntry(name: name, score: score, rounds: rounds, updatedAt: updatedAt));
  }
  return entries;
}

String? _fieldValue(Map<String, Object?> fields, String fieldName, String valueKind) {
  final field = fields[fieldName];
  if (field is! Map<String, Object?>) {
    return null;
  }
  final value = field[valueKind];
  return value is String ? value : null;
}

/// Words that must not reach the hall screen. The list is short on purpose: it catches the lazy
/// attempts, the speaker reads the names before calling anyone to the stage.
const List<String> _wordsKeptOffTheScreen = <String>['amk', 'sik', 'orospu', 'piç', 'yarra', 'fuck', 'shit'];

final RegExp _nameWordBreak = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

const String _maskedName = '***';

/// The name as the hall screen shows it.
String hallBoardDisplayName(String name) {
  for (final nameWord in name.toLowerCase().split(_nameWordBreak)) {
    for (final word in _wordsKeptOffTheScreen) {
      if (nameWord.startsWith(word)) {
        return _maskedName;
      }
    }
  }
  return name.trim();
}
