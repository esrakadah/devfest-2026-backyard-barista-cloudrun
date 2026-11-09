import 'dart:io';

import 'package:flutter/services.dart';

Process? _activeMacOsAudioProcess;

/// Plays bundled `.wav` assets on macOS (`afplay`, killing any prior overlapping process) and
/// falls back to native system click on mobile/IO, while remaining a clean no-op inside `flutter test`.
Future<void> playPlatformCafeCue(String cueName, String assetPath) async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return;
  }
  try {
    if (Platform.isMacOS) {
      final candidatePaths = <String>[
        assetPath,
        '${File(Platform.resolvedExecutable).parent.parent.path}/Frameworks/App.framework/Resources/flutter_assets/$assetPath',
      ];
      for (final path in candidatePaths) {
        final candidateFile = File(path);
        if (candidateFile.existsSync()) {
          _activeMacOsAudioProcess?.kill();
          _activeMacOsAudioProcess = await Process.start('afplay', <String>[candidateFile.path]);
          return;
        }
      }
    }
    await SystemSound.play(SystemSoundType.click);
  } on Object {
    // Ignore audio errors on headless runners.
  }
}
