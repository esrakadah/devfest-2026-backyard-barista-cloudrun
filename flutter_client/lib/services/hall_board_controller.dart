import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// One ranked player row on the hall leaderboard.
@immutable
class HallBoardPlayerEntry {
  const HallBoardPlayerEntry({
    required this.name,
    required this.score,
    required this.rounds,
    required this.updatedAt,
  });

  final String name;
  final int score;
  final int rounds;
  final DateTime updatedAt;
}

/// Reads the hall leaderboard from Firestore and drives server-verified admin actions
/// (verify, pause/resume, and board reset) over `/api/leaderboard/*`.
class HallBoardController extends ChangeNotifier {
  HallBoardController({
    required this.projectId,
    required this.eventId,
    required http.Client httpClient,
    required Uri apiOrigin,
    bool enablePolling = true,
    String? initialAdminKey,
    void Function(String? adminKey)? onAdminKeyChanged,
  })  : _httpClient = httpClient,
        _apiOrigin = apiOrigin,
        _enablePolling = enablePolling,
        _verifiedAdminKey =
            (initialAdminKey != null && initialAdminKey.trim().isNotEmpty) ? initialAdminKey.trim() : null,
        _onAdminKeyChanged = onAdminKeyChanged;

  static const Duration pollInterval = Duration(seconds: 3);
  static const Duration requestTimeout = Duration(seconds: 5);
  static const int queryLimit = 50;

  static const String _firestoreHost = 'firestore.googleapis.com';
  static const String _statePath = '/api/leaderboard/state';
  static const String _verifyPath = '/api/leaderboard/admin/verify';
  static const String _pausePath = '/api/leaderboard/admin/pause';
  static const String _resetPath = '/api/leaderboard/admin/reset';
  static const String _adminHeaderName = 'X-Admin-Key';

  static const int _httpOk = 200;
  static const int _httpUnauthorized = 401;
  static const int _httpTooManyRequests = 429;
  static const int _httpServiceUnavailable = 503;

  final String projectId;
  final String eventId;
  final http.Client _httpClient;
  final Uri _apiOrigin;
  final bool _enablePolling;
  final void Function(String? adminKey)? _onAdminKeyChanged;

  List<HallBoardPlayerEntry> _allEntries = const <HallBoardPlayerEntry>[];
  bool _hasLoadedOnce = false;
  bool _isLastFetchFailed = false;
  bool _isRefreshing = false;
  bool _isPaused = false;
  DateTime? _frozenAt;
  String? _verifiedAdminKey;
  bool _isAdminActionInFlight = false;
  String? _adminErrorMessage;
  bool _isDisposed = false;
  Timer? _pollTimer;

  /// Ranked entries visible on the board. When the board is paused with a [frozenAt] timestamp,
  /// rows updated after that moment are excluded so late writes cannot alter frozen standings.
  List<HallBoardPlayerEntry> get entries {
    final cutoff = _isPaused ? _frozenAt : null;
    if (cutoff == null) {
      return _allEntries;
    }
    return _allEntries.where((entry) => !entry.updatedAt.isAfter(cutoff)).toList(growable: false);
  }

  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get isLastFetchFailed => _isLastFetchFailed;
  bool get isPaused => _isPaused;
  DateTime? get frozenAt => _frozenAt;
  bool get isAdminAuthenticated => _verifiedAdminKey != null;
  bool get isAdminActionInFlight => _isAdminActionInFlight;
  String? get adminErrorMessage => _adminErrorMessage;

  /// Starts periodic polling and triggers an immediate fetch.
  void startWatching() {
    if (_isDisposed) {
      return;
    }
    unawaited(refresh());
    if (_enablePolling && _pollTimer == null) {
      _pollTimer = Timer.periodic(pollInterval, (_) => unawaited(refresh()));
    }
  }

  /// Stops periodic polling without disposing the controller.
  void stopWatching() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Fetches both the event pause state and the top player rows.
  Future<void> refresh() async {
    if (_isRefreshing || _isDisposed) {
      return;
    }
    _isRefreshing = true;
    try {
      await Future.wait<void>(<Future<void>>[
        _fetchEventState(),
        _fetchStandings(),
      ]);
    } finally {
      _isRefreshing = false;
      _notifySafely();
    }
  }

  /// Verifies [candidateKey] against `/api/leaderboard/admin/verify`. Only a server 200 unlocks admin controls.
  Future<bool> signInAdmin(String candidateKey) async {
    final trimmedKey = candidateKey.trim();
    if (trimmedKey.isEmpty || _isAdminActionInFlight) {
      return false;
    }
    _isAdminActionInFlight = true;
    _adminErrorMessage = null;
    _notifySafely();

    try {
      final response = await _httpClient
          .post(
            _endpointUri(_verifyPath),
            headers: <String, String>{
              'Content-Type': 'application/json',
              _adminHeaderName: trimmedKey,
            },
            body: '{}',
          )
          .timeout(requestTimeout);

      if (response.statusCode == _httpOk) {
        _verifiedAdminKey = trimmedKey;
        _adminErrorMessage = null;
        _onAdminKeyChanged?.call(trimmedKey);
        return true;
      }
      if (response.statusCode == _httpUnauthorized) {
        _adminErrorMessage = 'Şifre hatalı.';
        return false;
      }
      if (response.statusCode == _httpTooManyRequests) {
        _adminErrorMessage = 'Çok fazla deneme yapıldı. Birkaç saniye bekle.';
        return false;
      }
      if (response.statusCode == _httpServiceUnavailable) {
        _adminErrorMessage = 'Admin şifresi sunucuda henüz tanımlı değil.';
        return false;
      }
      _adminErrorMessage = 'Sunucu doğrulanamadı (HTTP ${response.statusCode}).';
      return false;
    } on Object {
      _adminErrorMessage = 'Sunucuya ulaşılamadı.';
      return false;
    } finally {
      _isAdminActionInFlight = false;
      _notifySafely();
    }
  }

  /// Clears the active admin session in this tab.
  void signOutAdmin() {
    _verifiedAdminKey = null;
    _adminErrorMessage = null;
    _onAdminKeyChanged?.call(null);
    _notifySafely();
  }

  /// Pauses (freezes) or resumes the hall leaderboard on the server.
  Future<bool> setPaused({required bool paused}) async {
    final adminKey = _verifiedAdminKey;
    if (adminKey == null || _isAdminActionInFlight) {
      return false;
    }
    _isAdminActionInFlight = true;
    _adminErrorMessage = null;
    _notifySafely();

    try {
      final response = await _httpClient
          .post(
            _endpointUri(_pausePath),
            headers: <String, String>{
              'Content-Type': 'application/json',
              _adminHeaderName: adminKey,
            },
            body: jsonEncode(<String, Object?>{
              'eventId': eventId,
              'isPaused': paused,
            }),
          )
          .timeout(requestTimeout);

      if (response.statusCode == _httpUnauthorized) {
        signOutAdmin();
        _adminErrorMessage = 'Admin oturumu geçersiz, tekrar giriş yap.';
        return false;
      }
      if (response.statusCode != _httpOk) {
        _adminErrorMessage = 'Durum güncellenemedi (HTTP ${response.statusCode}).';
        return false;
      }
      _applyStatePayload(jsonDecode(utf8.decode(response.bodyBytes)));
      await _fetchStandings();
      return true;
    } on Object {
      _adminErrorMessage = 'Durum güncellenirken bağlantı hatası oluştu.';
      return false;
    } finally {
      _isAdminActionInFlight = false;
      _notifySafely();
    }
  }

  /// Deletes all player rows of [eventId] via the Cloud Run admin sidecar and unpauses the board.
  /// Returns the number of deleted players on success, or null on failure.
  Future<int?> resetBoard() async {
    final adminKey = _verifiedAdminKey;
    if (adminKey == null || _isAdminActionInFlight) {
      return null;
    }
    _isAdminActionInFlight = true;
    _adminErrorMessage = null;
    _notifySafely();

    try {
      final response = await _httpClient
          .post(
            _endpointUri(_resetPath),
            headers: <String, String>{
              'Content-Type': 'application/json',
              _adminHeaderName: adminKey,
            },
            body: jsonEncode(<String, Object?>{'eventId': eventId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == _httpUnauthorized) {
        signOutAdmin();
        _adminErrorMessage = 'Admin oturumu geçersiz, tekrar giriş yap.';
        return null;
      }
      if (response.statusCode != _httpOk) {
        _adminErrorMessage = 'Sıfırlama başarısız oldu (HTTP ${response.statusCode}).';
        return null;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      _applyStatePayload(decoded);
      _allEntries = const <HallBoardPlayerEntry>[];
      _hasLoadedOnce = true;
      _isLastFetchFailed = false;
      final deletedCount = decoded is Map<String, Object?> ? decoded['deletedPlayers'] : null;
      return deletedCount is int ? deletedCount : 0;
    } on Object {
      _adminErrorMessage = 'Sıfırlama sırasında bağlantı hatası oluştu.';
      return null;
    } finally {
      _isAdminActionInFlight = false;
      _notifySafely();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }

  Uri _endpointUri(String path, [Map<String, String>? queryParameters]) {
    final hasHttpOrigin = _apiOrigin.scheme == 'http' || _apiOrigin.scheme == 'https';
    if (!hasHttpOrigin || _apiOrigin.host.isEmpty) {
      return Uri.https('localhost', path, queryParameters);
    }
    return Uri(
      scheme: _apiOrigin.scheme,
      host: _apiOrigin.host,
      port: _apiOrigin.hasPort ? _apiOrigin.port : null,
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<void> _fetchEventState() async {
    try {
      final response =
          await _httpClient.get(_endpointUri(_statePath, <String, String>{'event': eventId})).timeout(requestTimeout);
      if (response.statusCode == _httpOk) {
        _applyStatePayload(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } on Object {
      // State sidecar is optional in local standalone runs; keep the last known pause state.
    }
  }

  void _applyStatePayload(Object? decoded) {
    if (decoded is! Map<String, Object?>) {
      return;
    }
    final rawPaused = decoded['isPaused'];
    if (rawPaused is bool) {
      _isPaused = rawPaused;
    }
    final rawFrozenAt = decoded['frozenAt'];
    _frozenAt = rawFrozenAt is String ? DateTime.tryParse(rawFrozenAt) : null;
  }

  Future<void> _fetchStandings() async {
    try {
      final response = await _httpClient
          .post(
            Uri.https(
              _firestoreHost,
              '/v1/projects/$projectId/databases/(default)/documents/events/$eventId:runQuery',
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
        return;
      }
      final parsed = parseHallBoardPlayerRows(jsonDecode(utf8.decode(response.bodyBytes)));
      _allEntries = _rankEntries(parsed);
      _hasLoadedOnce = true;
      _isLastFetchFailed = false;
    } on Object {
      _isLastFetchFailed = true;
    }
  }

  static List<HallBoardPlayerEntry> _rankEntries(List<HallBoardPlayerEntry> rawEntries) {
    return List<HallBoardPlayerEntry>.of(rawEntries)
      ..sort((first, second) {
        final scoreComparison = second.score.compareTo(first.score);
        return scoreComparison != 0 ? scoreComparison : first.updatedAt.compareTo(second.updatedAt);
      });
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}

/// Parses Firestore `runQuery` rows into [HallBoardPlayerEntry] items, skipping malformed documents.
List<HallBoardPlayerEntry> parseHallBoardPlayerRows(Object? decodedBody) {
  if (decodedBody is! List<Object?>) {
    return const <HallBoardPlayerEntry>[];
  }
  final parsedEntries = <HallBoardPlayerEntry>[];
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
    final name = _extractFirestoreString(fields, 'name', 'stringValue');
    final score = int.tryParse(_extractFirestoreString(fields, 'score', 'integerValue') ?? '');
    final rounds = int.tryParse(_extractFirestoreString(fields, 'rounds', 'integerValue') ?? '');
    final updatedAt = DateTime.tryParse(_extractFirestoreString(fields, 'updatedAt', 'timestampValue') ?? '');
    if (name == null || score == null || rounds == null || updatedAt == null) {
      continue;
    }
    parsedEntries.add(
      HallBoardPlayerEntry(
        name: name,
        score: score,
        rounds: rounds,
        updatedAt: updatedAt,
      ),
    );
  }
  return parsedEntries;
}

String? _extractFirestoreString(Map<String, Object?> fields, String fieldName, String valueKind) {
  final field = fields[fieldName];
  if (field is! Map<String, Object?>) {
    return null;
  }
  final value = field[valueKind];
  return value is String ? value : null;
}

const List<String> _blockedScreenWords = <String>[
  'amk',
  'sik',
  'orospu',
  'piç',
  'yarra',
  'fuck',
  'shit',
];

final RegExp _wordSeparatorPattern = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

/// Masks obvious profanity before displaying a free-text player name on a shared screen.
String hallBoardSafeDisplayName(String rawName) {
  for (final word in rawName.toLowerCase().split(_wordSeparatorPattern)) {
    for (final blockedPrefix in _blockedScreenWords) {
      if (word.startsWith(blockedPrefix)) {
        return '***';
      }
    }
  }
  return rawName.trim();
}
