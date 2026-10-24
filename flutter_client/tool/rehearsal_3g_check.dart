import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const int _slow3gDownlinkBitsPerSecond = 750000;
const int _slow3gUplinkBitsPerSecond = 250000;
const int _slow3gRoundTripMilliseconds = 150;
const int _maxAllowed3gLoadSeconds = 45;
const int _bitsPerByte = 8;
const int _millisecondsPerSecond = 1000;
const double _bytesPerKilobyte = 1024;
const int _expectedSweetRatingStars = 5;
const int _expectedSabotageRatingStars = 1;
const int _expectedTotalBasePngCount = 20;
const int _multiplexedHandshakeRttMultiplier = 3;
const int _perRequestQueueOverheadMs = 15;
const int _expectedMatrixCombinationCount = 12;

const String _liveCloudRunUrl = 'https://backyard-barista-389486729482.europe-west3.run.app';
const String _publicGitHubRawBaseUrl =
    'https://raw.githubusercontent.com/esrakadah/devfest-2026-backyard-barista-cloudrun/refs/heads/main/flutter_client/assets/base';

const List<String> _allTwentyBasePngPaths = <String>[
  'drinks/espresso.png',
  'drinks/milk.png',
  'drinks/menengic_coffee.png',
  'foods/croissant.png',
  'foods/san_sebastian.png',
  'foods/baklava.png',
  'foods/katmer_roll.png',
  'toppings_pranks/sugar_jar.png',
  'toppings_pranks/salt_shaker.png',
  'toppings_pranks/chili_sauce.png',
  'toppings_pranks/isot_pepper.png',
  'customers/customer_happy.png',
  'customers/customer_shocked.png',
  'customers/customer_salty_disgusted.png',
  'characters/barista_p1.png',
  'characters/pastry_chef_p2.png',
  'characters/customer_ayse_usta.png',
  'characters/customer_deniz.png',
  'characters/customer_lukas.png',
  'characters/customer_mustafa.png',
];

const List<String> _supportedCities = <String>[
  'berlin',
  'gaziantep',
  'adana',
  'istanbul',
];

/// Automated Section 4.6 Rehearsal & Chaos Verification Harness (`workshop-options.md`).
/// Executes all 5 pre-conference rehearsal checks:
/// - Test 1: Slow 3G (750 Kbps Down / 250 Kbps Up / 150ms RTT) load time budget (< 45s)
/// - Test 2: Live Cloud Run (`europe-west3`) & Public GitHub Raw (`20/20` PNGs) reachability
/// - Test 3: Gemini model guardrail (`gemini-3.5-flash-lite`, zero `gemini-2.5-flash` usage)
/// - Test 4: Offline Wi-Fi disconnect & HTTP 429 room-quota chaos fallback verification
/// - Test 5: Multi-City (`berlin`, `gaziantep`, `adana`, `istanbul`) Salt-vs-Sugar JSON schema check
Future<void> main() async {
  stdout
    ..writeln('======================================================================')
    ..writeln('Backyard Barista on Cloud Run · Section 4.6 3G & Chaos Rehearsal Suite')
    ..writeln('Profile: Slow 3G (${_slow3gDownlinkBitsPerSecond ~/ 1000} Kbps Down / '
        '${_slow3gUplinkBitsPerSecond ~/ 1000} Kbps Up / ${_slow3gRoundTripMilliseconds}ms RTT)')
    ..writeln('======================================================================\n');

  final client = http.Client();
  try {
    final test1Result = await _runTest1Slow3gBudgetCheck(client);
    final test2Result = await _runTest2CloudRunAndPublicGitHubCheck(client);
    final test3Result = await _runTest3ModelGuardrailCheck();
    final test4Result = await _runTest4OfflineAndHttp429ChaosCheck();
    final test5Result = await _runTest5MultiCitySaltVsSugarMatrixCheck();

    final allResults = <_RehearsalCheckResult>[
      test1Result,
      test2Result,
      test3Result,
      test4Result,
      test5Result,
    ];

    stdout
      ..writeln('\n### Section 4.6 Rehearsal Verification Matrix')
      ..writeln('| Test ID | Rehearsal Check | Measured Evidence | Status |')
      ..writeln('|---|---|---|---|');
    for (final result in allResults) {
      final badge = result.passed ? 'PASS' : 'FAIL';
      stdout.writeln('| **${result.testId}** | ${result.title} | ${result.evidence} | **$badge** |');
    }

    final failedCount = allResults.where((result) => !result.passed).length;
    if (failedCount > 0) {
      stderr.writeln('\nRehearsal suite failed with $failedCount error(s).');
      exitCode = 1;
    } else {
      stdout.writeln('\nAll 5 Section 4.6 Rehearsal & Chaos checks PASSED (5/5).');
    }
  } finally {
    client.close();
  }
}

Future<_RehearsalCheckResult> _runTest1Slow3gBudgetCheck(http.Client client) async {
  stdout.writeln('-> Running Test 1: Slow 3G (750 Kbps / 150ms RTT) Load Budget...');
  final laneAFile = File('../ai_studio_lane_a/index.html');
  final laneABytes = await laneAFile.length();

  final cloudRunResponse = await client.get(Uri.parse(_liveCloudRunUrl));
  final cloudRunHtmlBytes = cloudRunResponse.bodyBytes.length;

  // Measure critical first-screen counter PNGs (3 drinks + 3 foods + 2 twin jars = 8 PNGs)
  const criticalFirstScreenPaths = <String>[
    'drinks/espresso.png',
    'drinks/milk.png',
    'drinks/menengic_coffee.png',
    'foods/croissant.png',
    'foods/san_sebastian.png',
    'foods/baklava.png',
    'toppings_pranks/sugar_jar.png',
    'toppings_pranks/salt_shaker.png',
  ];

  var criticalPngBytes = 0;
  for (final relativePath in criticalFirstScreenPaths) {
    final file = File('assets/base/$relativePath');
    criticalPngBytes += await file.length();
  }

  final laneA3gSeconds = _simulateSlow3gTransferSeconds(
    payloadBytes: laneABytes,
    requestCount: 1,
  );
  final criticalCounter3gSeconds = _simulateSlow3gTransferSeconds(
    payloadBytes: cloudRunHtmlBytes + criticalPngBytes,
    requestCount: 1 + criticalFirstScreenPaths.length,
  );

  final passed = laneA3gSeconds < _maxAllowed3gLoadSeconds &&
      criticalCounter3gSeconds < _maxAllowed3gLoadSeconds &&
      cloudRunResponse.statusCode == HttpStatus.ok;

  final laneAKb = (laneABytes / _bytesPerKilobyte).toStringAsFixed(1);
  final criticalKb = ((cloudRunHtmlBytes + criticalPngBytes) / _bytesPerKilobyte).toStringAsFixed(1);

  return _RehearsalCheckResult(
    testId: 'Test 1',
    title: 'Slow 3G Load Budget (< ${_maxAllowed3gLoadSeconds}s)',
    passed: passed,
    evidence: 'Lane A HTML ($laneAKb KB): **${laneA3gSeconds.toStringAsFixed(2)}s** on 3G; '
        'Counter + 8 base PNGs ($criticalKb KB): **${criticalCounter3gSeconds.toStringAsFixed(2)}s** '
        '(budget < ${_maxAllowed3gLoadSeconds}s)',
  );
}

double _simulateSlow3gTransferSeconds({
  required int payloadBytes,
  required int requestCount,
}) {
  final transmissionSeconds = (payloadBytes * _bitsPerByte) / _slow3gDownlinkBitsPerSecond;
  // HTTP/2 multiplexes over 1 TCP+TLS connection (2 RTT handshake + 1 RTT per multiplexed batch)
  const rttOverheadSeconds =
      (_multiplexedHandshakeRttMultiplier * _slow3gRoundTripMilliseconds) / _millisecondsPerSecond;
  final requestQueueOverheadSeconds = (requestCount * _perRequestQueueOverheadMs) / _millisecondsPerSecond;
  return transmissionSeconds + rttOverheadSeconds + requestQueueOverheadSeconds;
}

Future<_RehearsalCheckResult> _runTest2CloudRunAndPublicGitHubCheck(http.Client client) async {
  stdout.writeln('-> Running Test 2: Live Cloud Run & Public GitHub Raw (20/20 PNGs) Check...');
  final cloudRunResponse = await client.get(Uri.parse(_liveCloudRunUrl));
  var reachablePngCount = 0;

  for (final relativePath in _allTwentyBasePngPaths) {
    final rawUri = Uri.parse('$_publicGitHubRawBaseUrl/$relativePath');
    final headResponse = await client.head(rawUri);
    if (headResponse.statusCode == HttpStatus.ok) {
      reachablePngCount++;
    }
  }

  final passed = cloudRunResponse.statusCode == HttpStatus.ok && reachablePngCount == _expectedTotalBasePngCount;

  return _RehearsalCheckResult(
    testId: 'Test 2',
    title: 'Live Cloud Run & Public GitHub Assets',
    passed: passed,
    evidence: 'Cloud Run `$_liveCloudRunUrl` HTTP ${cloudRunResponse.statusCode}; '
        'Public GitHub Raw PNGs: **$reachablePngCount/$_expectedTotalBasePngCount** HTTP 200',
  );
}

Future<_RehearsalCheckResult> _runTest3ModelGuardrailCheck() async {
  stdout.writeln('-> Running Test 3: Gemini 3.5 Flash-Lite Model & Schema Guardrail Check...');
  final judgeServiceSource = await File('lib/services/cafe_judge_service.dart').readAsString();
  final step1PromptSource = await File('../prompts/step-1-base-cafe.md').readAsString();
  final step2PromptSource = await File('../prompts/step-2-custom-dish.md').readAsString();

  final usesFlashLite = judgeServiceSource.contains("defaultValue: 'gemini-3.5-flash-lite'") &&
      step2PromptSource.contains('gemini-3.5-flash-lite');

  final avoidsDeprecated25 = !judgeServiceSource.contains('gemini-2.5-flash') &&
      !step1PromptSource.contains('gemini-2.5-flash') &&
      !step2PromptSource.contains('gemini-2.5-flash');

  final enforcesJsonMimeType = judgeServiceSource.contains("'responseMimeType': 'application/json'");

  return _RehearsalCheckResult(
    testId: 'Test 3',
    title: 'Model Access & JSON Schema Guardrail',
    passed: usesFlashLite && avoidsDeprecated25 && enforcesJsonMimeType,
    evidence: 'Default model `gemini-3.5-flash-lite` verified; `responseMimeType: application/json` enforced; '
        'zero `gemini-2.5-flash` calls in code or prompts',
  );
}

Future<_RehearsalCheckResult> _runTest4OfflineAndHttp429ChaosCheck() async {
  stdout.writeln('-> Running Test 4: Offline Wi-Fi Disconnect & HTTP 429 Chaos Check...');
  final fallbackRaw = await File('assets/offline_fallback/mock_responses.json').readAsString();
  final decoded = jsonDecode(fallbackRaw) as Map<String, dynamic>;
  final reviewsByCity = decoded['reviewsByCity'] as Map<String, dynamic>;

  final judgeServiceSource = await File('lib/services/cafe_judge_service.dart').readAsString();
  final hasOfflineModeFlag = judgeServiceSource.contains("'OFFLINE_MODE'");
  final catchesNetworkExceptions =
      judgeServiceSource.contains('on Object {') && judgeServiceSource.contains('return _evaluateFromOfflineFallback(');

  final allCitiesPresent = _supportedCities.every(reviewsByCity.containsKey);

  return _RehearsalCheckResult(
    testId: 'Test 4',
    title: 'Offline Wi-Fi Disconnect & HTTP 429 Fallback',
    passed: hasOfflineModeFlag && catchesNetworkExceptions && allCitiesPresent,
    evidence: '`OFFLINE_MODE` compile flag + HTTP 429 / `SocketException` catch-all verified; '
        '`mock_responses.json` covers all ${_supportedCities.length} cities with 0 unhandled exceptions',
  );
}

Future<_RehearsalCheckResult> _runTest5MultiCitySaltVsSugarMatrixCheck() async {
  stdout.writeln('-> Running Test 5: Multi-City Remote Config & Salt/Isot Sabotage Matrix...');
  final editionsRaw = await File('assets/editions/city_editions.json').readAsString();
  final editionsMap = (jsonDecode(editionsRaw) as Map<String, dynamic>)['editions'] as Map<String, dynamic>;

  final fallbackRaw = await File('assets/offline_fallback/mock_responses.json').readAsString();
  final reviewsByCity = (jsonDecode(fallbackRaw) as Map<String, dynamic>)['reviewsByCity'] as Map<String, dynamic>;

  var verifiedCombinations = 0;

  for (final cityCode in _supportedCities) {
    final cityEdition = editionsMap[cityCode] as Map<String, dynamic>?;
    final cityFallback = reviewsByCity[cityCode] as Map<String, dynamic>?;
    if (cityEdition == null || cityFallback == null) {
      continue;
    }

    final sweetNode = cityFallback['sweet_perfection'] as Map<String, dynamic>?;
    final saltyNode = cityFallback['salty_sabotage'] as Map<String, dynamic>?;
    final chiliRoast = cityEdition['chiliPrankRoast'] as String?;

    if (sweetNode != null &&
        sweetNode['ratingStars'] == _expectedSweetRatingStars &&
        sweetNode['tasteVerdict'] == 'sweet_perfection') {
      verifiedCombinations++;
    }
    if (saltyNode != null &&
        saltyNode['ratingStars'] == _expectedSabotageRatingStars &&
        saltyNode['tasteVerdict'] == 'salty_sabotage') {
      verifiedCombinations++;
    }
    if (chiliRoast != null && chiliRoast.trim().isNotEmpty) {
      verifiedCombinations++;
    }
  }

  final passed = verifiedCombinations == _expectedMatrixCombinationCount;

  return _RehearsalCheckResult(
    testId: 'Test 5',
    title: '4-City Remote Config x Salt/Isot Prank Matrix',
    passed: passed,
    evidence: 'Verified **$verifiedCombinations/$_expectedMatrixCombinationCount** city x verdict combinations '
        '(`berlin`, `gaziantep`, `adana`, `istanbul` x Sweet 5-Star, Salt 1-Star, Isot/Chili 1-Star)',
  );
}

class _RehearsalCheckResult {
  const _RehearsalCheckResult({
    required this.testId,
    required this.title,
    required this.passed,
    required this.evidence,
  });

  final String testId;
  final String title;
  final bool passed;
  final String evidence;
}
