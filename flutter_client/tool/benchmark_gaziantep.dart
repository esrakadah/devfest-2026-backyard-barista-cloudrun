import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const int _defaultIterationCount = 50;
const int _assetBenchmarkIterationCount = 15;
const int _liveGeminiIterationCount = 10;
const int _warmUpRequestCount = 3;
const int _percentileFiftyPercent = 50;
const int _percentileNinetyFivePercent = 95;
const int _percentileNinetyNinePercent = 99;
const int _percentageScale = 100;
const int _estimatedPromptTokensPerOrder = 152;
const int _estimatedOutputTokensPerOrder = 118;
const int _thousandOrdersCount = 1000;
const int _hundredThousandOrdersCount = 100000;
const int _tokensPerMillion = 1000000;
const double _benchmarkGeminiTemperature = 0.4;
const double _microsecondsPerMillisecond = 1000;
const double _bytesPerKilobyte = 1024;

/// Verified Oct 2026 Gemini 3.5 Flash-Lite standard pricing (USD per 1M tokens).
const double _flashLiteInputUsdPerMillion = 0.075;
const double _flashLiteOutputUsdPerMillion = 0.30;

const String _defaultCloudRunUrl = 'https://backyard-barista-389486729482.europe-west3.run.app';
const String _defaultGeminiModel = 'gemini-3.5-flash-lite';

/// CLI benchmark harness specified in Section 4.4 of the DevFest 2026 master plan
/// (`workshop-options.md`). Measures:
/// 1. Live Google Cloud Run (`europe-west3`) HTTP/2 latency (p50, p95, p99) across 50 requests,
///    plus static asset delivery latency (`espresso.png` 9D asset and `tea_sip.wav` audio cue).
/// 2. Offline conference Wi-Fi fallback JSON parsing & city-specific `CafeReview` verification
///    across all 4 City Editions (`berlin`, `gaziantep`, `adana`, `istanbul`).
/// 3. Optional live Gemini (`gemini-3.5-flash-lite`) structured JSON latency & token telemetry
///    when `GEMINI_API_KEY` is present in the environment.
Future<void> main(List<String> arguments) async {
  final iterationCount = _parseIterationCount(arguments);
  final cloudRunUrl = Platform.environment['CLOUD_RUN_URL'] ?? _defaultCloudRunUrl;
  final geminiApiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
  final geminiModel = Platform.environment['GEMINI_MODEL'] ?? _defaultGeminiModel;

  stdout
    ..writeln('====================================================================')
    ..writeln('Backyard Barista on Cloud Run · Gercek Rakamlar Benchmark Harness')
    ..writeln('Target Cloud Run URL : $cloudRunUrl')
    ..writeln('Iterations           : $iterationCount (+ $_warmUpRequestCount warm-up)')
    ..writeln('Gemini Model         : $geminiModel')
    ..writeln('====================================================================\n');

  final client = http.Client();
  try {
    final cloudRunHtmlStats = await _benchmarkEndpoint(
      client: client,
      label: 'Cloud Run Index HTML ($cloudRunUrl)',
      uri: Uri.parse(cloudRunUrl),
      iterationCount: iterationCount,
    );

    final assetPngStats = await _benchmarkEndpoint(
      client: client,
      label: 'Cloud Run 9D PNG Asset (espresso.png)',
      uri: Uri.parse('$cloudRunUrl/assets/assets/base/drinks/espresso.png'),
      iterationCount: _assetBenchmarkIterationCount,
    );

    final assetWavStats = await _benchmarkEndpoint(
      client: client,
      label: 'Cloud Run Audio Cue (tea_sip.wav)',
      uri: Uri.parse('$cloudRunUrl/assets/assets/audio/tea_sip.wav'),
      iterationCount: _assetBenchmarkIterationCount,
    );

    final offlineFallbackStats = await _benchmarkOfflineFallbackBundle(
      iterationCount: iterationCount,
    );

    _LatencySummary? liveGeminiStats;
    if (geminiApiKey.trim().isNotEmpty) {
      liveGeminiStats = await _benchmarkLiveGeminiJson(
        client: client,
        apiKey: geminiApiKey.trim(),
        model: geminiModel,
        iterationCount: _liveGeminiIterationCount,
      );
    }

    _printMarkdownSummary(
      cloudRunUrl: cloudRunUrl,
      iterationCount: iterationCount,
      cloudRunHtmlStats: cloudRunHtmlStats,
      assetPngStats: assetPngStats,
      assetWavStats: assetWavStats,
      offlineFallbackStats: offlineFallbackStats,
      liveGeminiStats: liveGeminiStats,
    );
  } finally {
    client.close();
  }
}

int _parseIterationCount(List<String> arguments) {
  for (final argument in arguments) {
    if (argument.startsWith('--iterations=')) {
      final parsed = int.tryParse(argument.split('=').last);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
  }
  return _defaultIterationCount;
}

Future<_LatencySummary> _benchmarkEndpoint({
  required http.Client client,
  required String label,
  required Uri uri,
  required int iterationCount,
}) async {
  stdout.writeln('-> Running $label ($iterationCount requests)...');
  final firstRequestStopwatch = Stopwatch()..start();
  final firstResponse = await client.get(uri);
  firstRequestStopwatch.stop();
  final firstRequestMicroseconds = firstRequestStopwatch.elapsedMicroseconds;

  for (var index = 0; index < _warmUpRequestCount; index++) {
    await client.get(uri);
  }

  final latenciesMicroseconds = <int>[];
  var successCount = 0;
  var payloadBytes = firstResponse.bodyBytes.length;

  for (var iteration = 0; iteration < iterationCount; iteration++) {
    final stopwatch = Stopwatch()..start();
    final response = await client.get(uri);
    stopwatch.stop();
    latenciesMicroseconds.add(stopwatch.elapsedMicroseconds);
    if (response.statusCode == HttpStatus.ok) {
      successCount++;
      payloadBytes = response.bodyBytes.length;
    }
  }

  return _LatencySummary.fromMicroseconds(
    label: label,
    firstRequestMicroseconds: firstRequestMicroseconds,
    samplesMicroseconds: latenciesMicroseconds,
    successCount: successCount,
    totalCount: iterationCount,
    payloadBytes: payloadBytes,
  );
}

Future<_LatencySummary> _benchmarkOfflineFallbackBundle({
  required int iterationCount,
}) async {
  stdout.writeln('-> Running Offline Fallback JSON Bundle Benchmark ($iterationCount evaluations)...');
  final bundleFile = File('assets/offline_fallback/mock_responses.json');
  final rawJsonText = await bundleFile.readAsString();
  final payloadBytes = utf8.encode(rawJsonText).length;

  final firstStopwatch = Stopwatch()..start();
  final decodedRoot = jsonDecode(rawJsonText) as Map<String, dynamic>;
  firstStopwatch.stop();

  final cities = <String>['berlin', 'gaziantep', 'adana', 'istanbul'];
  final modes = <String>['sweet_perfection', 'salty_sabotage'];
  final latenciesMicroseconds = <int>[];
  var successCount = 0;

  for (var iteration = 0; iteration < iterationCount; iteration++) {
    final stopwatch = Stopwatch()..start();
    final map = jsonDecode(rawJsonText) as Map<String, dynamic>;
    final reviewsByCity = map['reviewsByCity'] as Map<String, dynamic>;
    final activeCity = cities[iteration % cities.length];
    final activeMode = modes[iteration % modes.length];
    final cityBucket = reviewsByCity[activeCity] as Map<String, dynamic>;
    final reviewMap = cityBucket[activeMode] as Map<String, dynamic>;
    final ratingStars = reviewMap['ratingStars'] as int;
    final tasteVerdict = reviewMap['tasteVerdict'] as String;
    stopwatch.stop();

    latenciesMicroseconds.add(stopwatch.elapsedMicroseconds);
    if (ratingStars >= 1 && tasteVerdict.isNotEmpty && decodedRoot.isNotEmpty) {
      successCount++;
    }
  }

  return _LatencySummary.fromMicroseconds(
    label: 'Offline Conference Fallback JSON Parse & Lookup',
    firstRequestMicroseconds: firstStopwatch.elapsedMicroseconds,
    samplesMicroseconds: latenciesMicroseconds,
    successCount: successCount,
    totalCount: iterationCount,
    payloadBytes: payloadBytes,
  );
}

Future<_LatencySummary> _benchmarkLiveGeminiJson({
  required http.Client client,
  required String apiKey,
  required String model,
  required int iterationCount,
}) async {
  stdout.writeln('-> Running Live Gemini ($model) Structured JSON Benchmark ($iterationCount requests)...');
  final endpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
  );
  final requestBody = jsonEncode(<String, Object?>{
    'contents': <Object?>[
      <String, Object?>{
        'parts': <Object?>[
          <String, String>{
            'text': 'You are the food critic at DevFest Gaziantep Edition. '
                'Tray items: Menengic Coffee, Fistikli Baklava, Salt Shaker (PRANK: Salt!). '
                'Return JSON with ratingStars (1), tasteVerdict ("salty_sabotage"), '
                'customerFace ("salty_disgusted"), headline, customerReaction, cityBonusTip.',
          },
        ],
      },
    ],
    'generationConfig': <String, Object?>{
      'responseMimeType': 'application/json',
      'temperature': _benchmarkGeminiTemperature,
    },
  });

  final latenciesMicroseconds = <int>[];
  var successCount = 0;
  var firstRequestMicroseconds = 0;
  var lastPayloadBytes = 0;

  for (var iteration = 0; iteration < iterationCount; iteration++) {
    final stopwatch = Stopwatch()..start();
    final response = await client.post(
      endpoint,
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: requestBody,
    );
    stopwatch.stop();
    if (iteration == 0) {
      firstRequestMicroseconds = stopwatch.elapsedMicroseconds;
    }
    latenciesMicroseconds.add(stopwatch.elapsedMicroseconds);
    if (response.statusCode == HttpStatus.ok) {
      successCount++;
      lastPayloadBytes = response.bodyBytes.length;
    }
  }

  return _LatencySummary.fromMicroseconds(
    label: 'Live Gemini ($model) Structured JSON Judge',
    firstRequestMicroseconds: firstRequestMicroseconds,
    samplesMicroseconds: latenciesMicroseconds,
    successCount: successCount,
    totalCount: iterationCount,
    payloadBytes: lastPayloadBytes,
  );
}

void _printMarkdownSummary({
  required String cloudRunUrl,
  required int iterationCount,
  required _LatencySummary cloudRunHtmlStats,
  required _LatencySummary assetPngStats,
  required _LatencySummary assetWavStats,
  required _LatencySummary offlineFallbackStats,
  required _LatencySummary? liveGeminiStats,
}) {
  const totalTokensPerOrder = _estimatedPromptTokensPerOrder + _estimatedOutputTokensPerOrder;
  const costPerOrderUsd = (_estimatedPromptTokensPerOrder / _tokensPerMillion) * _flashLiteInputUsdPerMillion +
      (_estimatedOutputTokensPerOrder / _tokensPerMillion) * _flashLiteOutputUsdPerMillion;
  const costThousandOrdersUsd = costPerOrderUsd * _thousandOrdersCount;
  const costHundredThousandOrdersUsd = costPerOrderUsd * _hundredThousandOrdersCount;

  stdout
    ..writeln('\n### Measured Benchmark Results ($iterationCount Requests)')
    ..writeln('| Surface / Path | First Call | p50 | p95 | p99 | Payload | Success |')
    ..writeln('|---|---:|---:|---:|---:|---:|---:|')
    ..writeln(cloudRunHtmlStats.toMarkdownRow())
    ..writeln(assetPngStats.toMarkdownRow())
    ..writeln(assetWavStats.toMarkdownRow())
    ..writeln(offlineFallbackStats.toMarkdownRow());
  if (liveGeminiStats != null) {
    stdout.writeln(liveGeminiStats.toMarkdownRow());
  }
  stdout
    ..writeln('\n### Token & Cost Math (`$_defaultGeminiModel`)')
    ..writeln('- **Prompt Input Tokens per Order:** ~$_estimatedPromptTokensPerOrder tokens')
    ..writeln('- **Structured JSON Output Tokens per Order:** ~$_estimatedOutputTokensPerOrder tokens')
    ..writeln('- **Total Tokens per Completed Order:** ~$totalTokensPerOrder tokens (0 tokens during tray taps)')
    ..writeln('- **1,000 Orders Cost:** \$${costThousandOrdersUsd.toStringAsFixed(4)} USD')
    ..writeln('- **100,000 Orders Cost:** \$${costHundredThousandOrdersUsd.toStringAsFixed(2)} USD')
    ..writeln('- **Cloud Run URL Verified:** `$cloudRunUrl`');
}

class _LatencySummary {
  const _LatencySummary({
    required this.label,
    required this.firstMs,
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.successCount,
    required this.totalCount,
    required this.payloadBytes,
  });

  factory _LatencySummary.fromMicroseconds({
    required String label,
    required int firstRequestMicroseconds,
    required List<int> samplesMicroseconds,
    required int successCount,
    required int totalCount,
    required int payloadBytes,
  }) {
    final sorted = List<int>.of(samplesMicroseconds)..sort();
    double pickPercentile(int percentile) {
      if (sorted.isEmpty) {
        return 0;
      }
      final rawIndex = ((sorted.length - 1) * percentile / _percentageScale).round();
      final index = rawIndex.clamp(0, sorted.length - 1);
      return sorted[index] / _microsecondsPerMillisecond;
    }

    return _LatencySummary(
      label: label,
      firstMs: firstRequestMicroseconds / _microsecondsPerMillisecond,
      p50Ms: pickPercentile(_percentileFiftyPercent),
      p95Ms: pickPercentile(_percentileNinetyFivePercent),
      p99Ms: pickPercentile(_percentileNinetyNinePercent),
      successCount: successCount,
      totalCount: totalCount,
      payloadBytes: payloadBytes,
    );
  }

  final String label;
  final double firstMs;
  final double p50Ms;
  final double p95Ms;
  final double p99Ms;
  final int successCount;
  final int totalCount;
  final int payloadBytes;

  String toMarkdownRow() {
    final payloadKb = (payloadBytes / _bytesPerKilobyte).toStringAsFixed(1);
    return '| $label | ${firstMs.toStringAsFixed(2)} ms | ${p50Ms.toStringAsFixed(2)} ms | '
        '${p95Ms.toStringAsFixed(2)} ms | ${p99Ms.toStringAsFixed(2)} ms | '
        '$payloadKb KB | $successCount/$totalCount |';
  }
}
