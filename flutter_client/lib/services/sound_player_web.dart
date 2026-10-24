import 'package:web/web.dart' as web;

/// Plays bundled `.wav` assets inside Chrome, Mobile Safari, and WebViews using HTMLAudioElement.
Future<void> playPlatformCafeCue(String assetPath) async {
  try {
    final resolvedAssetUrl = 'assets/$assetPath';
    final audioElement = web.HTMLAudioElement()
      ..src = resolvedAssetUrl
      ..volume = 0.85;
    audioElement.play();
  } on Object {
    // Ignore autoplay restrictions before first user gesture.
  }
}
