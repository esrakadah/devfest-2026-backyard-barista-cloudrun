import 'dart:async';

import 'package:backyard_barista_cloudrun/services/sound_player_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/sound_player_web.dart'
    if (dart.library.io) 'package:backyard_barista_cloudrun/services/sound_player_io.dart';

/// Distinct arcade cafe sound effect cues played during the Backyard Barista loop
/// via Web Audio API procedural synthesis and bundled `.wav` assets.
enum CafeSoundCue {
  tapPop('assets/audio/tap_pop.wav', 'Tap Pop'),
  coffeeGrinder('assets/audio/coffee_grinder.wav', 'Kahve Değirmeni · Burr Grinder'),
  espressoSteam('assets/audio/espresso_steam.wav', 'Espresso Buharı · Steam Wand'),
  stealthWink('assets/audio/stealth_wink.wav', 'Gizli Tuz · Stealth Wink'),
  serveBell('assets/audio/serve_bell.wav', 'Sipariş Zili · Order Bell'),
  sweetFanfare('assets/audio/sweet_fanfare.wav', 'Tatlı Fanfar · Sweet 5★'),
  levelUpFanfare('assets/audio/level_up.wav', 'Seviye Atlama · Level Up!'),
  saltyBuzzer('assets/audio/salty_buzzer.wav', 'Tuzlu Sabotaj · Salty Buzzer'),
  nextChime('assets/audio/next_chime.wav', 'Sıradaki Müşteri · Next Chime'),
  teaSip('assets/audio/tea_sip.wav', 'Çay Yudumu · Tea Sip');

  const CafeSoundCue(this.assetPath, this.displayLabel);

  final String assetPath;
  final String displayLabel;
}

/// Plays cozy cafe sound effects (`coffee_grinder`, `espresso_steam`, `serve_bell`,
/// `level_up`, `tap_pop`, `stealth_wink`, `sweet_fanfare`, `salty_buzzer`, `next_chime`,
/// `tea_sip`) using Web Audio API synthesis on Web and native audio on macOS/mobile,
/// with an in-app mute toggle for workshop halls.
class CafeSoundController {
  CafeSoundController({bool initialMuted = false}) : _isMuted = initialMuted;

  bool _isMuted;
  CafeSoundCue? _lastPlayedCue;
  final List<CafeSoundCue> _playedCues = <CafeSoundCue>[];

  bool get isMuted => _isMuted;

  /// Most recently played sound cue (when unmuted), displayed on the Web Audio soundboard badge.
  CafeSoundCue? get lastPlayedCue => _lastPlayedCue;

  /// Unmodifiable history of played sound cues during the session.
  List<CafeSoundCue> get playedCues => List<CafeSoundCue>.unmodifiable(_playedCues);

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void play(CafeSoundCue cue) {
    if (_isMuted) {
      return;
    }
    _lastPlayedCue = cue;
    _playedCues.add(cue);
    unawaited(playPlatformCafeCue(cue.name, cue.assetPath));
  }
}
