import 'dart:async';

import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// A jump target in the presenter menu.
@immutable
class PresenterSection {
  const PresenterSection({
    required this.icon,
    required this.label,
    required this.route,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool highlighted;
}

/// The sections the presenter menu offers. Every route here must exist in [deckSlides];
/// `deck_manifest_test.dart` asserts it.
const List<PresenterSection> presenterSections = [
  PresenterSection(icon: Icons.title, label: '1. Title & City Editions', route: '/title'),
  PresenterSection(icon: Icons.emoji_events, label: '2. Workshop Lanes & Prizes', route: '/workshop-contract'),
  PresenterSection(icon: Icons.auto_awesome, label: '3. AI Studio & Antigravity', route: '/ai-studio-pipeline'),
  PresenterSection(icon: Icons.speed, label: '6. Gercek Rakamlar (Benchmarks)', route: '/real-numbers-latency'),
  PresenterSection(icon: Icons.public, label: '9. Multi-City Remote Config', route: '/multi-city-remote-config'),
  PresenterSection(icon: Icons.restaurant_menu, label: '10. Salt vs Sugar & Assets', route: '/salt-sugar-mechanic'),
  PresenterSection(icon: Icons.timer, label: '12. Live Build Dashboard', route: '/live-build-dashboard'),
  PresenterSection(icon: Icons.layers, label: '13. Architecture Recap', route: '/architecture-recap'),
  PresenterSection(icon: Icons.celebration, label: '14. Winner Podium & Badge', route: '/winner-podium-closing'),
  PresenterSection(
    icon: Icons.wifi_tethering_error,
    label: 'Demo Hiccup (Offline Backup)',
    route: '/demo-hiccup',
    highlighted: true,
  ),
];

/// Quick jumps across the talk sections, the keyboard cheat sheet and an on-stage talk timer.
class PresenterMenuPlugin extends FlutterDeckPlugin {
  PresenterMenuPlugin() : super();

  @override
  List<Widget> buildControls(BuildContext context, FlutterDeckPluginMenuItemBuilder menuItemBuilder) {
    return [
      menuItemBuilder(
        context,
        label: 'Stage Navigator & Shortcuts',
        icon: const Icon(Icons.navigation, color: DeckColors.googleYellow),
        onPressed: () {
          unawaited(
            showDialog<void>(
              context: context,
              builder: (dialogContext) => PresenterHelpDialog(deckContext: context),
            ),
          );
        },
      ),
    ];
  }
}

/// The on-stage cheat sheet and rapid navigation modal.
class PresenterHelpDialog extends StatefulWidget {
  const PresenterHelpDialog({required this.deckContext, super.key});

  final BuildContext deckContext;

  @override
  State<PresenterHelpDialog> createState() => _PresenterHelpDialogState();
}

class _PresenterHelpDialogState extends State<PresenterHelpDialog> {
  static const double _dialogWidth = 780;
  static const double _dialogPadding = 28;
  static const double _cornerRadius = 20;
  static const double _borderWidth = 1.5;
  static const double _sectionGap = 20;
  static const double _columnGap = 24;
  static const double _labelGap = 12;
  static const double _iconSize = 28;
  static const double _timerIconSize = 16;
  static const double _titleSize = 24;
  static const double _labelSize = 12;
  static const double _labelLetterSpacing = 1.5;
  static const int _secondsPerMinute = 60;
  static const int _clockDigits = 2;

  static final Stopwatch _talkStopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatElapsed() {
    final totalSeconds = _talkStopwatch.elapsed.inSeconds;
    final minutes = (totalSeconds ~/ _secondsPerMinute).toString().padLeft(_clockDigits, '0');
    final seconds = (totalSeconds % _secondsPerMinute).toString().padLeft(_clockDigits, '0');
    return '$minutes:$seconds';
  }

  void _toggleTimer() {
    setState(() {
      if (_talkStopwatch.isRunning) {
        _talkStopwatch.stop();
      } else {
        _talkStopwatch.start();
      }
    });
  }

  void _jumpTo(String route) {
    final slideNumber = slideNumberForRoute(route);
    if (slideNumber == null) return;
    Navigator.of(context).pop();
    widget.deckContext.flutterDeck.goToSlide(slideNumber);
  }

  TextStyle _labelStyle(Color color) => TextStyle(
        fontFamily: DeckFonts.sans,
        fontSize: _labelSize,
        fontWeight: FontWeight.bold,
        letterSpacing: _labelLetterSpacing,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DeckColors.navy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cornerRadius),
        side: const BorderSide(color: DeckColors.googleBlue, width: _borderWidth),
      ),
      child: Container(
        width: _dialogWidth,
        padding: const EdgeInsets.all(_dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.headset_mic, color: DeckColors.googleYellow, size: _iconSize),
                const SizedBox(width: _labelGap),
                const Text(
                  'Stage Navigator · Backyard Barista',
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _titleSize,
                    fontWeight: FontWeight.bold,
                    color: DeckColors.offWhite,
                  ),
                ),
                const Spacer(),
                _TimerBadge(
                  elapsed: _formatElapsed(),
                  running: _talkStopwatch.isRunning,
                  onToggle: _toggleTimer,
                  onReset: () => setState(_talkStopwatch.reset),
                  iconSize: _timerIconSize,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: DeckColors.mutedText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: _sectionGap),
            const Divider(color: DeckColors.outline, height: 1),
            const SizedBox(height: _sectionGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WORKSHOP & VIBE LOUNGE SECTIONS', style: _labelStyle(DeckColors.halftoneBlue)),
                      const SizedBox(height: _labelGap),
                      for (final section in presenterSections)
                        _SectionButton(section: section, onPressed: () => _jumpTo(section.route)),
                    ],
                  ),
                ),
                const SizedBox(width: _columnGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KEYBOARD CHEAT SHEET', style: _labelStyle(DeckColors.halftonePink)),
                      const SizedBox(height: _labelGap),
                      const _ShortcutPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({
    required this.elapsed,
    required this.running,
    required this.onToggle,
    required this.onReset,
    required this.iconSize,
  });

  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 6;
  static const double _cornerRadius = 12;
  static const double _gap = 6;
  static const double _fontSize = 16;

  final String elapsed;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.outline),
      ),
      child: Row(
        children: [
          Icon(running ? Icons.timer : Icons.timer_outlined, size: iconSize, color: DeckColors.googleYellow),
          const SizedBox(width: _gap),
          Text(
            elapsed,
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: _fontSize,
              fontWeight: FontWeight.bold,
              color: DeckColors.googleYellow,
            ),
          ),
          const SizedBox(width: _gap),
          GestureDetector(
            onTap: onToggle,
            child: Icon(running ? Icons.pause : Icons.play_arrow, size: iconSize, color: DeckColors.offWhite),
          ),
          const SizedBox(width: _gap),
          GestureDetector(
            onTap: onReset,
            child: Icon(Icons.refresh, size: iconSize, color: DeckColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({required this.section, required this.onPressed});

  static const double _verticalGap = 4;
  static const double _cornerRadius = 10;
  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 8;
  static const double _iconSize = 18;
  static const double _iconGap = 10;
  static const double _labelSize = 13;
  static const double _badgeSize = 12;
  static const double _badgeHorizontalPadding = 6;
  static const double _badgeVerticalPadding = 2;
  static const double _badgeRadius = 6;

  final PresenterSection section;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = section.highlighted ? DeckColors.googleRed : DeckColors.halftoneBlue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _verticalGap),
      child: Material(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_cornerRadius),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
            child: Row(
              children: [
                Icon(section.icon, size: _iconSize, color: accent),
                const SizedBox(width: _iconGap),
                Expanded(
                  child: Text(
                    section.label,
                    style: TextStyle(
                      fontFamily: DeckFonts.sans,
                      fontSize: _labelSize,
                      color: DeckColors.offWhite,
                      fontWeight: section.highlighted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _badgeHorizontalPadding,
                    vertical: _badgeVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: DeckColors.navy,
                    borderRadius: BorderRadius.circular(_badgeRadius),
                  ),
                  child: Text(
                    'Slide ${slideNumberForRoute(section.route) ?? "?"}',
                    style: const TextStyle(
                      fontFamily: DeckFonts.mono,
                      fontSize: _badgeSize,
                      color: DeckColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutPanel extends StatelessWidget {
  const _ShortcutPanel();

  static const double _padding = 14;
  static const double _cornerRadius = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_cornerRadius),
        border: Border.all(color: DeckColors.outline),
      ),
      child: const Column(
        children: [
          _ShortcutRow(keyLabel: '← / →', action: 'Previous / next slide or step'),
          _ShortcutRow(keyLabel: '.', action: 'Slide navigation drawer'),
          _ShortcutRow(keyLabel: 'M', action: 'Toggle marker tool'),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keyLabel, required this.action});

  static const double _verticalGap = 4;
  static const double _keyHorizontalPadding = 6;
  static const double _keyVerticalPadding = 2;
  static const double _keyRadius = 6;
  static const double _keySize = 12;
  static const double _actionSize = 13;
  static const double _gap = 10;

  final String keyLabel;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _verticalGap),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: _keyHorizontalPadding, vertical: _keyVerticalPadding),
            decoration: BoxDecoration(
              color: DeckColors.navy,
              borderRadius: BorderRadius.circular(_keyRadius),
              border: Border.all(color: DeckColors.outline),
            ),
            child: Text(
              keyLabel,
              style: const TextStyle(
                fontFamily: DeckFonts.mono,
                fontSize: _keySize,
                fontWeight: FontWeight.bold,
                color: DeckColors.halftonePink,
              ),
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontFamily: DeckFonts.sans, fontSize: _actionSize, color: DeckColors.offWhite),
            ),
          ),
        ],
      ),
    );
  }
}
