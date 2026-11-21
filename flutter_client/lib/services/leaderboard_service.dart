import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Where a player stands in the hall leaderboard.
enum LeaderboardPhase {
  /// No name yet; nothing is counted or sent.
  awaitingName,

  /// The player chose to play without the leaderboard.
  optedOut,

  /// A name is set and the window starts with the first served round.
  ready,

  /// The window is running and every served round is sent.
  running,

  /// The window is over; the score is final and nothing more is sent.
  finished,
}

/// Persisted browser state so navigating to the leaderboard tab and back (or reloading the page)
/// never re-prompts for the player's name or drops an active 3-minute window.
@immutable
class LeaderboardSessionSnapshot {
  const LeaderboardSessionSnapshot({
    required this.isOptedOut,
    this.playerName,
    this.score = 0,
    this.rounds = 0,
    this.firstRoundScore = 0,
    this.isDocumentCreated = false,
    this.windowStartedAt,
  });

  final bool isOptedOut;
  final String? playerName;
  final int score;
  final int rounds;
  final int firstRoundScore;
  final bool isDocumentCreated;
  final DateTime? windowStartedAt;

  String toJsonString() {
    return jsonEncode(<String, Object?>{
      'isOptedOut': isOptedOut,
      'playerName': playerName,
      'score': score,
      'rounds': rounds,
      'firstRoundScore': firstRoundScore,
      'isDocumentCreated': isDocumentCreated,
      'windowStartedAt': windowStartedAt?.toUtc().toIso8601String(),
    });
  }

  static LeaderboardSessionSnapshot? tryParse(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final rawStartedAt = decoded['windowStartedAt'];
      final rawName = decoded['playerName'];
      final rawScore = decoded['score'];
      final rawRounds = decoded['rounds'];
      final rawFirstScore = decoded['firstRoundScore'];
      return LeaderboardSessionSnapshot(
        isOptedOut: decoded['isOptedOut'] == true,
        playerName: rawName is String ? rawName : null,
        score: rawScore is int ? rawScore : 0,
        rounds: rawRounds is int ? rawRounds : 0,
        firstRoundScore: rawFirstScore is int ? rawFirstScore : 0,
        isDocumentCreated: decoded['isDocumentCreated'] == true,
        windowStartedAt: rawStartedAt is String ? DateTime.tryParse(rawStartedAt) : null,
      );
    } on Object {
      return null;
    }
  }
}

/// Sends one player's running total to the hall leaderboard in Firestore over plain REST.
///
/// Sending never blocks a serve: [recordRound] returns at once, a send that fails or hangs is dropped after
/// [sendTimeout], and the next served round carries the full totals again.
class LeaderboardService extends ChangeNotifier {
  LeaderboardService({
    required this.projectId,
    required this.eventId,
    required this.playerId,
    required http.Client httpClient,
    required DateTime Function() clock,
    String? rememberedPlayerName,
    void Function(String playerName)? onPlayerNameChosen,
    LeaderboardSessionSnapshot? restoredSession,
    void Function(LeaderboardSessionSnapshot? session)? onSessionChanged,
  })  : _httpClient = httpClient,
        _clock = clock,
        _onPlayerNameChosen = onPlayerNameChosen,
        _onSessionChanged = onSessionChanged,
        suggestedPlayerName = rememberedPlayerName == null ? null : normalizePlayerName(rememberedPlayerName) {
    if (restoredSession != null) {
      _restoreFromSnapshot(restoredSession);
    }
  }

  static const Duration playWindow = Duration(seconds: 180);
  static const Duration sendTimeout = Duration(seconds: 3);
  static const int minPlayerNameLength = 2;
  static const int maxPlayerNameLength = 16;
  static const int playerIdLength = 20;
  static const String defaultEventId = 'konya-2026';
  static const String eventQueryParameter = 'board';
  static const String pageQueryParameter = 'page';
  static const String leaderboardPageValue = 'leaderboard';

  static const String _playerIdAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const String _firestoreHost = 'firestore.googleapis.com';
  static const int _httpOk = 200;
  static const int _httpNotFound = 404;
  static const String _notFoundStatus = 'NOT_FOUND';
  static final RegExp _eventIdPattern = RegExp(r'^[a-z0-9-]{1,32}$');
  static final RegExp _whitespaceRun = RegExp(r'\s+');

  final String projectId;
  final String eventId;
  final String playerId;

  /// The name this browser used before, offered again so a reload keeps writing to the same row.
  final String? suggestedPlayerName;

  final http.Client _httpClient;
  final DateTime Function() _clock;
  final void Function(String playerName)? _onPlayerNameChosen;
  final void Function(LeaderboardSessionSnapshot? session)? _onSessionChanged;

  LeaderboardPhase _phase = LeaderboardPhase.awaitingName;
  String? _playerName;
  DateTime? _windowStartedAt;
  int _score = 0;
  int _rounds = 0;
  int _firstRoundScore = 0;
  bool _isDocumentCreated = false;
  bool _isSending = false;
  bool _hasUnsentTotals = false;
  bool _isDisposed = false;

  LeaderboardPhase get phase => _phase;
  String? get playerName => _playerName;
  int get score => _score;
  int get rounds => _rounds;

  /// Time left in the window. The full window before the first served round, zero once it is over.
  Duration get remaining {
    final windowStartedAt = _windowStartedAt;
    if (_phase == LeaderboardPhase.finished) {
      return Duration.zero;
    }
    if (windowStartedAt == null) {
      return playWindow;
    }
    final left = playWindow - _clock().difference(windowStartedAt);
    return left.isNegative ? Duration.zero : left;
  }

  /// The event id from `?board=<id>` when it is well formed, otherwise [configuredEventId], otherwise
  /// [defaultEventId].
  static String resolveEventId({
    required String configuredEventId,
    required Uri uri,
  }) {
    final requestedEventId = uri.queryParameters[eventQueryParameter];
    if (requestedEventId != null && _eventIdPattern.hasMatch(requestedEventId)) {
      return requestedEventId;
    }
    return _eventIdPattern.hasMatch(configuredEventId) ? configuredEventId : defaultEventId;
  }

  /// True when [uri] requests the standalone hall leaderboard page (`?page=leaderboard`).
  static bool isLeaderboardPageUri(Uri uri) => uri.queryParameters[pageQueryParameter] == leaderboardPageValue;

  /// Builds the URL for opening the standalone hall leaderboard in a separate browser tab.
  static Uri buildLeaderboardTabUri(Uri currentUri, {required String eventId}) {
    final updatedParameters = Map<String, String>.of(currentUri.queryParameters)
      ..[eventQueryParameter] = eventId
      ..[pageQueryParameter] = leaderboardPageValue;
    return _replaceQueryParameters(currentUri, updatedParameters);
  }

  /// Builds the URL for returning from the standalone hall leaderboard tab back to the cafe game.
  static Uri buildGameTabUri(Uri currentUri, {required String eventId}) {
    final updatedParameters = Map<String, String>.of(currentUri.queryParameters)
      ..[eventQueryParameter] = eventId
      ..remove(pageQueryParameter);
    return _replaceQueryParameters(currentUri, updatedParameters);
  }

  static Uri _replaceQueryParameters(Uri baseUri, Map<String, String> queryParameters) {
    final hasHttpOrigin = baseUri.scheme == 'http' || baseUri.scheme == 'https';
    if (!hasHttpOrigin || baseUri.host.isEmpty) {
      return Uri(path: '/', queryParameters: queryParameters.isEmpty ? null : queryParameters);
    }
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: baseUri.path.isEmpty ? '/' : baseUri.path,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  static String generatePlayerId(math.Random random) {
    return String.fromCharCodes(<int>[
      for (var index = 0; index < playerIdLength; index++)
        _playerIdAlphabet.codeUnitAt(random.nextInt(_playerIdAlphabet.length)),
    ]);
  }

  /// Trims [rawName] and collapses inner whitespace. Returns null when the result is shorter than
  /// [minPlayerNameLength] or longer than [maxPlayerNameLength].
  static String? normalizePlayerName(String rawName) {
    final normalizedName = rawName.trim().replaceAll(_whitespaceRun, ' ');
    final nameLength = normalizedName.runes.length;
    if (nameLength < minPlayerNameLength || nameLength > maxPlayerNameLength) {
      return null;
    }
    return normalizedName;
  }

  /// Sets the player name. Returns false, and changes nothing, for a name [normalizePlayerName] rejects or
  /// once a name is already set.
  bool registerPlayer(String rawName) {
    final normalizedName = normalizePlayerName(rawName);
    if (normalizedName == null || _phase != LeaderboardPhase.awaitingName) {
      return false;
    }
    _playerName = normalizedName;
    _phase = LeaderboardPhase.ready;
    _onPlayerNameChosen?.call(normalizedName);
    _persistSession();
    notifyListeners();
    return true;
  }

  void playWithoutLeaderboard() {
    if (_phase != LeaderboardPhase.awaitingName) {
      return;
    }
    _phase = LeaderboardPhase.optedOut;
    _persistSession();
    notifyListeners();
  }

  /// Lets a player who previously chose "Play without a name" voluntarily open the name prompt later.
  bool reopenNamePromptFromOptOut() {
    if (_phase != LeaderboardPhase.optedOut) {
      return false;
    }
    _phase = LeaderboardPhase.awaitingName;
    _onSessionChanged?.call(null);
    notifyListeners();
    return true;
  }

  /// Counts one served round worth [pointsGained]. The first round after the name starts the window; a round
  /// served after the window is not counted.
  void recordRound(int pointsGained) {
    if (_phase != LeaderboardPhase.ready && _phase != LeaderboardPhase.running) {
      return;
    }
    if (_phase == LeaderboardPhase.ready) {
      _windowStartedAt = _clock();
      _firstRoundScore = pointsGained;
      _phase = LeaderboardPhase.running;
    } else if (_closeWindowIfOver()) {
      return;
    }
    _score += pointsGained;
    _rounds += 1;
    _persistSession();
    notifyListeners();
    _hasUnsentTotals = true;
    if (!_isSending) {
      unawaited(_sendLatestTotals());
    }
  }

  /// Moves a running window to [LeaderboardPhase.finished] once its time is up. The counter screen calls
  /// this on its one-second tick.
  void refreshWindow() {
    if (_phase == LeaderboardPhase.running) {
      _closeWindowIfOver();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _restoreFromSnapshot(LeaderboardSessionSnapshot snapshot) {
    if (snapshot.isOptedOut) {
      _phase = LeaderboardPhase.optedOut;
      return;
    }
    final normalizedName = snapshot.playerName == null ? null : normalizePlayerName(snapshot.playerName!);
    if (normalizedName == null) {
      return;
    }
    _playerName = normalizedName;
    _score = snapshot.score >= 0 ? snapshot.score : 0;
    _rounds = snapshot.rounds >= 0 ? snapshot.rounds : 0;
    _firstRoundScore = snapshot.firstRoundScore >= 0 ? snapshot.firstRoundScore : 0;
    _isDocumentCreated = snapshot.isDocumentCreated;
    _windowStartedAt = snapshot.windowStartedAt;

    final startedAt = _windowStartedAt;
    if (startedAt == null || _rounds == 0) {
      _windowStartedAt = null;
      _score = 0;
      _rounds = 0;
      _firstRoundScore = 0;
      _phase = LeaderboardPhase.ready;
      return;
    }

    final isExpired = _clock().difference(startedAt) >= playWindow;
    _phase = isExpired ? LeaderboardPhase.finished : LeaderboardPhase.running;
    unawaited(_reconcileRestoredSessionWithFirestore());
  }

  Future<void> _reconcileRestoredSessionWithFirestore() async {
    try {
      final response =
          await _httpClient.get(Uri.https(_firestoreHost, '/v1/$_playerDocumentPath')).timeout(sendTimeout);
      if (response.statusCode == _httpNotFound) {
        _startOverAfterBoardReset();
      }
    } on Object {
      // Offline or slow network keeps the local restored state.
    }
  }

  void _persistSession() {
    final sessionCallback = _onSessionChanged;
    if (sessionCallback == null) {
      return;
    }
    if (_phase == LeaderboardPhase.awaitingName) {
      sessionCallback(null);
      return;
    }
    sessionCallback(
      LeaderboardSessionSnapshot(
        isOptedOut: _phase == LeaderboardPhase.optedOut,
        playerName: _playerName,
        score: _score,
        rounds: _rounds,
        firstRoundScore: _firstRoundScore,
        isDocumentCreated: _isDocumentCreated,
        windowStartedAt: _windowStartedAt,
      ),
    );
  }

  bool _closeWindowIfOver() {
    if (remaining > Duration.zero) {
      return false;
    }
    _phase = LeaderboardPhase.finished;
    _persistSession();
    notifyListeners();
    return true;
  }

  Future<void> _sendLatestTotals() async {
    _isSending = true;
    try {
      while (_hasUnsentTotals && !_isDisposed) {
        _hasUnsentTotals = false;
        await _sendTotals(score: _score, rounds: _rounds);
      }
    } finally {
      _isSending = false;
    }
  }

  /// The first write creates the row with round one, because the rules only accept a new row at one round.
  /// A create that was lost is therefore retried with round one and the current totals follow as an update.
  /// A create the server refuses usually means the row exists from before a reload, so the update is tried too.
  Future<void> _sendTotals({required int score, required int rounds}) async {
    try {
      final wasDocumentCreated = _isDocumentCreated;
      if (!wasDocumentCreated) {
        final createOutcome = await _postCommit(
          _commitBody(score: _firstRoundScore, rounds: 1, isFirstWrite: true),
        );
        if (createOutcome == _WriteOutcome.accepted) {
          _isDocumentCreated = true;
          _persistSession();
          if (rounds == 1) {
            return;
          }
        }
      }
      final updateOutcome = await _postCommit(
        _commitBody(score: score, rounds: rounds, isFirstWrite: false),
      );
      if (updateOutcome == _WriteOutcome.accepted) {
        _isDocumentCreated = true;
        _persistSession();
      } else if (wasDocumentCreated && await _wasPlayerDocumentDeleted(updateOutcome)) {
        _startOverAfterBoardReset();
      }
    } on Object {
      // The next served round sends the full totals again.
    }
  }

  /// True when the row this player already wrote to is gone, which is how a board reset reaches the game.
  /// The rules may answer a write to a missing row with a plain refusal, so a refusal is checked with a read.
  Future<bool> _wasPlayerDocumentDeleted(_WriteOutcome updateOutcome) async {
    if (updateOutcome == _WriteOutcome.documentMissing) {
      return true;
    }
    final response = await _httpClient.get(Uri.https(_firestoreHost, '/v1/$_playerDocumentPath')).timeout(sendTimeout);
    return response.statusCode == _httpNotFound;
  }

  /// Keeps the name and the player id, drops the totals and the window. The next served round starts a
  /// fresh window and goes out as a first write.
  void _startOverAfterBoardReset() {
    if (_isDisposed) {
      return;
    }
    _score = 0;
    _rounds = 0;
    _firstRoundScore = 0;
    _windowStartedAt = null;
    _isDocumentCreated = false;
    _hasUnsentTotals = false;
    _phase = LeaderboardPhase.ready;
    _persistSession();
    notifyListeners();
  }

  String get _playerDocumentPath =>
      'projects/$projectId/databases/(default)/documents/events/$eventId/players/$playerId';

  Future<_WriteOutcome> _postCommit(Map<String, Object?> body) async {
    final response = await _httpClient
        .post(
          Uri.https(
            _firestoreHost,
            '/v1/projects/$projectId/databases/(default)/documents:commit',
          ),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(sendTimeout);
    if (response.statusCode == _httpOk) {
      return _WriteOutcome.accepted;
    }
    if (response.statusCode == _httpNotFound || response.body.contains(_notFoundStatus)) {
      return _WriteOutcome.documentMissing;
    }
    return _WriteOutcome.refused;
  }

  Map<String, Object?> _commitBody({
    required int score,
    required int rounds,
    required bool isFirstWrite,
  }) {
    return <String, Object?>{
      'writes': <Map<String, Object?>>[
        <String, Object?>{
          'update': <String, Object?>{
            'name': _playerDocumentPath,
            'fields': <String, Object?>{
              'name': <String, Object?>{'stringValue': _playerName},
              'score': <String, Object?>{'integerValue': '$score'},
              'rounds': <String, Object?>{'integerValue': '$rounds'},
            },
          },
          'updateMask': <String, Object?>{
            'fieldPaths': <String>['name', 'score', 'rounds'],
          },
          'updateTransforms': <Map<String, Object?>>[
            <String, Object?>{
              'fieldPath': 'updatedAt',
              'setToServerValue': 'REQUEST_TIME',
            },
            if (isFirstWrite)
              <String, Object?>{
                'fieldPath': 'startedAt',
                'setToServerValue': 'REQUEST_TIME',
              },
          ],
          'currentDocument': <String, Object?>{'exists': !isFirstWrite},
        },
      ],
    };
  }
}

enum _WriteOutcome { accepted, documentMissing, refused }
