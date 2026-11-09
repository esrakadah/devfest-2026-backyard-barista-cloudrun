import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';

/// The five acts of the talk. Every `SlideFrame` names its act, and the strip in its header
/// shows the audience where they are in the story.
enum StoryAct {
  hook('HOOK', DeckColors.googleYellow),
  tools('TOOLS', DeckColors.halftoneBlue),
  realNumbers('GERÇEK RAKAMLAR', DeckColors.googleRed),
  underTheHood('UNDER THE HOOD', DeckColors.googleGreen),
  buildAndShip('BUILD & SHIP', DeckColors.googleBlue);

  const StoryAct(this.label, this.color);

  final String label;
  final Color color;
}

/// A compact progress strip: past acts filled and dim, the current act lit, future acts outlined.
class StoryArcStrip extends StatelessWidget {
  const StoryArcStrip({required this.current, super.key});

  static const double _segmentGap = 8;
  static const double _labelSize = 13;
  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 6;
  static const double _radius = 999;
  static const double _pastOpacity = 0.35;

  final StoryAct current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final act in StoryAct.values) ...[
          if (act.index > 0) const SizedBox(width: _segmentGap),
          _ArcSegment(act: act, current: current),
        ],
      ],
    );
  }
}

class _ArcSegment extends StatelessWidget {
  const _ArcSegment({required this.act, required this.current});

  final StoryAct act;
  final StoryAct current;

  @override
  Widget build(BuildContext context) {
    final isCurrent = act == current;
    final isPast = act.index < current.index;
    return Opacity(
      opacity: isPast ? StoryArcStrip._pastOpacity : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: StoryArcStrip._horizontalPadding,
          vertical: StoryArcStrip._verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isCurrent || isPast ? act.color : Colors.transparent,
          borderRadius: BorderRadius.circular(StoryArcStrip._radius),
          border: Border.all(color: isCurrent || isPast ? act.color : DeckColors.outlineLight, width: 1.5),
        ),
        child: Text(
          '${act.index + 1} · ${act.label}',
          style: TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: StoryArcStrip._labelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: isCurrent || isPast ? DeckColors.navy : DeckColors.mutedText,
          ),
        ),
      ),
    );
  }
}
