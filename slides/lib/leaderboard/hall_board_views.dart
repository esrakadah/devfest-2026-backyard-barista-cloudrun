import 'dart:async';

import 'package:backyard_barista_deck/leaderboard/hall_board.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/lesson_diagrams.dart';
import 'package:flutter/material.dart';

/// What the hall plays for, best place first.
@immutable
class HallPrize {
  const HallPrize({required this.place, required this.name, required this.icon, required this.color});

  final int place;
  final String name;
  final IconData icon;
  final Color color;
}

const Color _silver = Color(0xFFD5DBE3);
const Color _bronze = Color(0xFFE0A46E);

const List<HallPrize> hallPrizes = <HallPrize>[
  HallPrize(place: 1, name: 'Dash', icon: Icons.flutter_dash, color: DeckColors.googleYellow),
  HallPrize(place: 2, name: 'Google Cloud gözlük', icon: Icons.wb_sunny_rounded, color: _silver),
  HallPrize(place: 3, name: 'Sticker seti', icon: Icons.auto_awesome_mosaic_rounded, color: _bronze),
];

Color _placeColor(int place) {
  for (final prize in hallPrizes) {
    if (prize.place == place) {
      return prize.color;
    }
  }
  return DeckColors.mutedText;
}

/// The live board of the hall: the first ten players on the left, the prizes on the right. While
/// [isFrozen] is false it follows Firestore; once frozen it keeps the standing it had.
class HallBoardView extends StatefulWidget {
  const HallBoardView({required this.isFrozen, this.board, super.key});

  final bool isFrozen;

  /// Injected in tests; the slides share [HallBoard.instance].
  final HallBoard? board;

  @override
  State<HallBoardView> createState() => _HallBoardViewState();
}

class _HallBoardViewState extends State<HallBoardView> {
  static const double _gap = 18;

  late final HallBoard _board = widget.board ?? HallBoard.instance;

  @override
  void initState() {
    super.initState();
    _board.watch();
    _applyFrozenAfterFrame();
  }

  @override
  void didUpdateWidget(HallBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFrozen != widget.isFrozen) {
      _applyFrozenAfterFrame();
    }
  }

  /// The board notifies its listeners, which must not happen while this widget is building.
  void _applyFrozenAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.isFrozen) {
        _board.freeze();
      } else {
        _board.unfreeze();
      }
    });
  }

  @override
  void dispose() {
    _board.unwatch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _board,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: DiagramPanel(
                label: widget.isFrozen ? 'SÜRE DOLDU · SON DURUM' : 'CANLI · İLK $_visibleRows',
                tag: _statusTag(),
                accentColor: widget.isFrozen ? DeckColors.googleYellow : DeckColors.googleGreen,
                child: HallBoardTable(entries: _board.entries, hasAnswer: _board.hasAnswer),
              ),
            ),
            const SizedBox(width: _gap),
            const Expanded(
              flex: 4,
              child: DiagramPanel(
                label: 'ÖDÜLLER',
                tag: 'KAPANIŞTA SAHNEDE',
                accentColor: DeckColors.googleYellow,
                child: HallPrizeList(),
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusTag() {
    if (widget.isFrozen) {
      return 'TABLO DONDU';
    }
    if (_board.isLastFetchFailed) {
      return 'BAĞLANTI BEKLENİYOR';
    }
    return '3 DAKİKA · PUANI KOD VERİR';
  }
}

const int _visibleRows = 10;

/// The first ten players as rows: place, name, rounds and score.
class HallBoardTable extends StatelessWidget {
  const HallBoardTable({required this.entries, required this.hasAnswer, super.key});

  static const double _rowGap = 6;
  static const double _rowRadius = 10;
  static const double _placeWidth = 64;
  static const double _placeSize = 28;
  static const double _nameSize = 28;
  static const double _roundsSize = 19;
  static const double _scoreSize = 30;
  static const double _emptySize = 30;
  static const double _podiumFillOpacity = 0.14;
  static const int _podiumPlaces = 3;

  final List<HallBoardEntry> entries;
  final bool hasAnswer;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          hasAnswer ? 'İlk puanı bekliyoruz. QR kodu okutun!' : 'Tablo sahnede canlı açılır.',
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: _emptySize,
            fontWeight: FontWeight.w600,
            color: DeckColors.offWhite,
          ),
        ),
      );
    }
    final visible = entries.take(_visibleRows).toList();
    return Column(
      children: [
        for (var index = 0; index < _visibleRows; index++) ...[
          Expanded(child: index < visible.length ? _row(index + 1, visible[index]) : const SizedBox.shrink()),
          if (index < _visibleRows - 1) const SizedBox(height: _rowGap),
        ],
      ],
    );
  }

  Widget _row(int place, HallBoardEntry entry) {
    final isOnPodium = place <= _podiumPlaces;
    final placeColor = _placeColor(place);
    return Container(
      key: ValueKey<String>('hall-board-row-$place'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isOnPodium ? placeColor.withValues(alpha: _podiumFillOpacity) : DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_rowRadius),
        border: Border.all(color: isOnPodium ? placeColor : DeckColors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _placeWidth,
            child: Text(
              '$place.',
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _placeSize,
                fontWeight: FontWeight.w700,
                color: placeColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hallBoardDisplayName(entry.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _nameSize,
                fontWeight: FontWeight.w600,
                color: DeckColors.offWhite,
              ),
            ),
          ),
          Text(
            '${entry.rounds} tur',
            style: const TextStyle(fontFamily: DeckFonts.mono, fontSize: _roundsSize, color: DeckColors.mutedText),
          ),
          const SizedBox(width: 20),
          Text(
            '${entry.score}',
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: _scoreSize,
              fontWeight: FontWeight.w700,
              color: DeckColors.googleYellow,
            ),
          ),
        ],
      ),
    );
  }
}

/// The three prizes, one row each.
class HallPrizeList extends StatelessWidget {
  const HallPrizeList({super.key});

  static const double _iconSize = 64;
  static const double _placeSize = 22;
  static const double _nameSize = 32;
  static const double _noteSize = 22;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final prize in hallPrizes)
          Expanded(
            child: Row(
              children: [
                Icon(prize.icon, size: _iconSize, color: prize.color),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${prize.place}. OLANA',
                        style: TextStyle(
                          fontFamily: DeckFonts.mono,
                          fontSize: _placeSize,
                          fontWeight: FontWeight.w700,
                          color: prize.color,
                        ),
                      ),
                      Text(
                        prize.name,
                        style: const TextStyle(
                          fontFamily: DeckFonts.sans,
                          fontSize: _nameSize,
                          fontWeight: FontWeight.w700,
                          color: DeckColors.offWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const Text(
          'Kullanıcı adınızla sahneye çağıracağım.',
          style: TextStyle(fontFamily: DeckFonts.sans, fontSize: _noteSize, color: DeckColors.mutedText),
        ),
      ],
    );
  }
}

/// The closing podium. The standing is frozen when the slide opens; [revealedPlaces] counts how
/// many places are shown, third place first.
class WinnersPodiumView extends StatefulWidget {
  const WinnersPodiumView({required this.revealedPlaces, this.board, super.key});

  final int revealedPlaces;

  /// Injected in tests; the slides share [HallBoard.instance].
  final HallBoard? board;

  @override
  State<WinnersPodiumView> createState() => _WinnersPodiumViewState();
}

class _WinnersPodiumViewState extends State<WinnersPodiumView> {
  static const double _gap = 18;
  static const int _firstPlaceFlex = 10;
  static const int _secondPlaceFlex = 8;
  static const int _thirdPlaceFlex = 7;
  static const int _totalFlex = 10;

  late final HallBoard _board = widget.board ?? HallBoard.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_freezeLatestStanding());
  }

  /// A board that was never frozen is read once more, so the podium is not older than the game.
  Future<void> _freezeLatestStanding() async {
    if (!_board.isFrozen) {
      await _board.refresh();
    }
    _board.freeze();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _board,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _step(place: 2, flex: _secondPlaceFlex)),
            const SizedBox(width: _gap),
            Expanded(child: _step(place: 1, flex: _firstPlaceFlex)),
            const SizedBox(width: _gap),
            Expanded(child: _step(place: 3, flex: _thirdPlaceFlex)),
          ],
        );
      },
    );
  }

  /// Third place is revealed first, the winner last.
  bool _isRevealed(int place) => widget.revealedPlaces > hallPrizes.length - place;

  Widget _step({required int place, required int flex}) {
    final entry = place <= _board.entries.length ? _board.entries[place - 1] : null;
    final prize = hallPrizes.firstWhere((candidate) => candidate.place == place);
    return Column(
      children: [
        if (flex < _totalFlex) Spacer(flex: _totalFlex - flex),
        Expanded(
          flex: flex,
          child: _PodiumStep(prize: prize, entry: _isRevealed(place) ? entry : null, isRevealed: _isRevealed(place)),
        ),
      ],
    );
  }
}

class _PodiumStep extends StatelessWidget {
  const _PodiumStep({required this.prize, required this.entry, required this.isRevealed});

  static const double _radius = 20;
  static const double _fillOpacity = 0.14;
  static const double _placeSize = 64;
  static const double _nameSize = 48;
  static const double _scoreSize = 28;
  static const double _prizeSize = 26;
  static const double _prizeIconSize = 56;
  static const double _hiddenSize = 72;

  final HallPrize prize;
  final HallBoardEntry? entry;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) {
    final winner = entry;
    return Container(
      key: ValueKey<String>('podium-step-${prize.place}'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Color.alphaBlend(prize.color.withValues(alpha: _fillOpacity), DeckColors.surface),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: prize.color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${prize.place}.',
            style: TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _placeSize,
              fontWeight: FontWeight.w700,
              height: 1,
              color: prize.color,
            ),
          ),
          if (!isRevealed)
            Text(
              '?',
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _hiddenSize,
                fontWeight: FontWeight.w700,
                color: prize.color,
              ),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(
                    winner == null ? 'Henüz kimse yok' : hallBoardDisplayName(winner.name),
                    style: const TextStyle(
                      fontFamily: DeckFonts.sans,
                      fontSize: _nameSize,
                      fontWeight: FontWeight.w700,
                      color: DeckColors.offWhite,
                    ),
                  ),
                  if (winner != null)
                    Text(
                      '${winner.score} puan · ${winner.rounds} tur',
                      style: const TextStyle(
                        fontFamily: DeckFonts.mono,
                        fontSize: _scoreSize,
                        color: DeckColors.googleYellow,
                      ),
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(prize.icon, size: _prizeIconSize, color: prize.color),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  prize.name,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _prizeSize,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.offWhite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
