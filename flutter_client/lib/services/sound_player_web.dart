import 'dart:js_interop';

import 'package:web/web.dart' as web;

const double _defaultCafeSoundVolume = 0.85;

/// Plays bundled `.wav` assets inside Chrome, Mobile Safari, and WebViews using HTMLAudioElement.
Future<void> playPlatformCafeCue(String assetPath) async {
  try {
    final resolvedAssetUrl = 'assets/$assetPath';
    final audioElement = web.HTMLAudioElement()
      ..src = resolvedAssetUrl
      ..volume = _defaultCafeSoundVolume;
    await audioElement.play().toDart;
  } on Object {
    // Ignore autoplay restrictions before first user gesture.
  }
}
