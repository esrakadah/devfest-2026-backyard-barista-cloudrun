import 'dart:js_interop';

import 'package:web/web.dart' as web;

const double _defaultCafeSoundVolume = 0.85;

@JS('playBackyardBaristaWebAudio')
external JSBoolean? _playBackyardBaristaWebAudio(JSString cueName);

/// Triggers real-time Web Audio API procedural synthesis (`window.playBackyardBaristaWebAudio`)
/// and plays bundled `.wav` assets inside Chrome, Mobile Safari, and WebViews.
Future<void> playPlatformCafeCue(String cueName, String assetPath) async {
  try {
    final didPlaySynth = _playBackyardBaristaWebAudio(cueName.toJS)?.toDart ?? false;
    if (didPlaySynth) {
      return;
    }
  } on Object {
    // Continue to HTMLAudioElement fallback if Web Audio synth is unavailable.
  }
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
