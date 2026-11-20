import 'package:backyard_barista_cloudrun/services/leaderboard_service.dart';
import 'package:flutter/material.dart';

const Color _leaderboardGold = Color(0xFFD4AF37);
const Color _leaderboardCream = Color(0xFFF3E5C8);
const Color _leaderboardMutedCream = Color(0xFFC9B086);
const Color _leaderboardPanel = Color(0xFF0F172A);
const Color _leaderboardPillBackground = Color(0xFF1B2440);
const Color _leaderboardBorder = Color(0xFFC59B27);

/// What the player picked in [LeaderboardNameDialog].
enum LeaderboardNameChoice { joined, playsWithoutLeaderboard }

/// Asks for the name the winners are called to the stage by. Registers it on [leaderboardService] itself, so
/// the dialog only closes with a name the service accepted.
class LeaderboardNameDialog extends StatefulWidget {
  const LeaderboardNameDialog({
    required this.leaderboardService,
    required this.languageCode,
    super.key,
  });

  final LeaderboardService leaderboardService;
  final String languageCode;

  @override
  State<LeaderboardNameDialog> createState() => _LeaderboardNameDialogState();
}

class _LeaderboardNameDialogState extends State<LeaderboardNameDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.leaderboardService.suggestedPlayerName ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _join() {
    if (widget.leaderboardService.registerPlayer(_nameController.text)) {
      Navigator.of(context).pop(LeaderboardNameChoice.joined);
    }
  }

  void _playWithoutLeaderboard() {
    widget.leaderboardService.playWithoutLeaderboard();
    Navigator.of(context).pop(LeaderboardNameChoice.playsWithoutLeaderboard);
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = widget.languageCode == 'en';
    return AlertDialog(
      backgroundColor: _leaderboardPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _leaderboardBorder, width: 1.6),
      ),
      title: Text(
        isEnglish ? 'Your player name?' : 'Kullanıcı adın?',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: _leaderboardCream,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isEnglish
                ? 'The winners are called to the stage by this name. You get 3 minutes from your first tray.'
                : 'Kazananlar sahneye bu isimle çağrılacak. İlk tepsinden itibaren 3 dakikan var.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: _leaderboardMutedCream,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const Key('leaderboard_name_field'),
            controller: _nameController,
            autofocus: true,
            maxLength: LeaderboardService.maxPlayerNameLength,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _leaderboardCream,
            ),
            cursorColor: _leaderboardGold,
            decoration: InputDecoration(
              hintText: isEnglish ? 'Player name' : 'Kullanıcı adı',
              hintStyle: const TextStyle(color: _leaderboardMutedCream),
              counterStyle: const TextStyle(color: _leaderboardMutedCream),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _leaderboardBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _leaderboardGold, width: 2),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _join(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('leaderboard_skip_button'),
          onPressed: _playWithoutLeaderboard,
          child: Text(
            isEnglish ? 'Play without a name' : 'İsimsiz oyna',
            style: const TextStyle(color: _leaderboardMutedCream),
          ),
        ),
        FilledButton(
          key: const Key('leaderboard_start_button'),
          style: FilledButton.styleFrom(
            backgroundColor: _leaderboardGold,
            foregroundColor: _leaderboardPanel,
          ),
          onPressed: LeaderboardService.normalizePlayerName(_nameController.text) == null ? null : _join,
          child: Text(
            isEnglish ? 'Start' : 'Başla',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

/// The player's place in the hall leaderboard: the name, then the time left, then the final score.
class LeaderboardStatusPill extends StatelessWidget {
  const LeaderboardStatusPill({
    required this.leaderboardService,
    required this.languageCode,
    super.key,
  });

  final LeaderboardService leaderboardService;
  final String languageCode;

  /// The pill text, or null while the player has no name or plays without the leaderboard.
  static String? labelFor(
    LeaderboardService leaderboardService, {
    required String languageCode,
  }) {
    final playerName = leaderboardService.playerName;
    if (playerName == null) {
      return null;
    }
    final pointsSuffix = languageCode == 'en' ? ' pts' : 'p';
    return switch (leaderboardService.phase) {
      LeaderboardPhase.awaitingName || LeaderboardPhase.optedOut => null,
      LeaderboardPhase.ready => playerName,
      LeaderboardPhase.running => '$playerName · ${_formatCountdown(leaderboardService.remaining)}',
      LeaderboardPhase.finished => '$playerName · ${leaderboardService.score}$pointsSuffix',
    };
  }

  static String _formatCountdown(Duration remaining) {
    final wholeSeconds = (remaining.inMilliseconds / Duration.millisecondsPerSecond).ceil();
    final minutes = wholeSeconds ~/ Duration.secondsPerMinute;
    final seconds = wholeSeconds % Duration.secondsPerMinute;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final label = labelFor(leaderboardService, languageCode: languageCode);
    if (label == null) {
      return const SizedBox.shrink();
    }
    return Container(
      key: const Key('leaderboard_status_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _leaderboardPillBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _leaderboardGold, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.leaderboard_rounded,
            size: 14,
            color: _leaderboardGold,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: _leaderboardCream,
            ),
          ),
        ],
      ),
    );
  }
}
