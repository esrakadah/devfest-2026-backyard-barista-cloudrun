import 'dart:io';

import 'package:flutter/services.dart';

/// Plays bundled `.wav` assets on macOS (`afplay`) and triggers native system sound on mobile/IO,
/// while remaining a clean no-op inside `flutter test`.
Future<void> playPlatformCafeCue(String assetPath) async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return;
  }
  try {
    await SystemSound.play(SystemSoundType.click);
    if (Platform.isMacOS) {
      final candidateFile = File(assetPath);
      if (candidateFile.existsSync()) {
        await Process.start('afplay', <String>[candidateFile.path]);
      }
    }
  } on Object {
    // Ignore audio errors on headless runners.
  }
}
