import 'dart:async';

import 'package:backyard_barista_cloudrun/services/sound_player_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/sound_player_web.dart'
    if (dart.library.io) 'package:backyard_barista_cloudrun/services/sound_player_io.dart';

/// Distinct arcade cafe sound effect cues played during the 3-step Backyard Barista loop.
enum CafeSoundCue {
  tapPop('assets/audio/tap_pop.wav'),
  stealthWink('assets/audio/stealth_wink.wav'),
  serveBell('assets/audio/serve_bell.wav'),
  sweetFanfare('assets/audio/sweet_fanfare.wav'),
  saltyBuzzer('assets/audio/salty_buzzer.wav'),
  nextChime('assets/audio/next_chime.wav'),
  teaSip('assets/audio/tea_sip.wav');

  const CafeSoundCue(this.assetPath);

  final String assetPath;
}

/// Plays cozy cafe sound effects (`tap_pop`, `stealth_wink`, `serve_bell`, `sweet_fanfare`,
/// `salty_buzzer`, `next_chime`, `tea_sip`) and tactile haptics across Web, iOS, Android, and macOS,
/// with an in-app mute toggle for workshop halls.
class CafeSoundController {
  CafeSoundController({bool initialMuted = false}) : _isMuted = initialMuted;

  bool _isMuted;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void play(CafeSoundCue cue) {
    if (_isMuted) {
      return;
    }
    unawaited(playPlatformCafeCue(cue.assetPath));
  }
}
