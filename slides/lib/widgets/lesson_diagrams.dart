import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';

/// The pictures of the five rule slides. Each rule is told as one drawing the speaker can point at:
/// which values get through, which states can exist, who has the last word, how long we wait and
/// where the key lives. Every block draws its own dark plate, like the lesson blocks.

const double _plateRadius = 18;
const double _plateBorderOpacity = 0.55;
const double _gap = 18;

/// A titled dark plate holding one part of a diagram.
class DiagramPanel extends StatelessWidget {
  const DiagramPanel({required this.label, required this.accentColor, required this.child, this.tag, super.key});

  static const double _padding = 22;
  static const double _labelSize = 20;
  static const double _tagSize = 18;
  static const double _headerGap = 14;

  final String label;
  final Color accentColor;
  final Widget child;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_plateRadius),
        border: Border.all(color: accentColor.withValues(alpha: _plateBorderOpacity), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: DeckFonts.mono,
                    fontSize: _labelSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: accentColor,
                  ),
                ),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: DeckColors.surfaceInset,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accentColor.withValues(alpha: _plateBorderOpacity)),
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      fontFamily: DeckFonts.sans,
                      fontSize: _tagSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: _headerGap),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// One square picture from `assets/cafe/` with rounded corners.
class _CafePicture extends StatelessWidget {
  const _CafePicture(this.assetFileName, {required this.size});

  static const double _cornerRadius = 14;

  final String assetFileName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cornerRadius),
      child: Image.asset('assets/cafe/$assetFileName', width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// A row of filled and empty stars, as the review card of the game shows them.
class _StarRow extends StatelessWidget {
  const _StarRow({required this.filled, required this.color});

  static const int _total = 5;
  static const double _starSize = 30;

  final int filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < _total; index++)
          Icon(
            index < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: _starSize,
            color: index < filled ? color : DeckColors.mutedText,
          ),
      ],
    );
  }
}

/// One station of a flow: a picture or an icon, a name and one short line.
class _FlowNode extends StatelessWidget {
  const _FlowNode({required this.title, required this.line, required this.accentColor, required this.visual});

  static const double _padding = 14;
  static const double _titleSize = 26;
  static const double _lineSize = 22;
  static const double _visualGap = 10;

  final String title;
  final String line;
  final Color accentColor;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_plateRadius),
        border: Border.all(color: accentColor.withValues(alpha: _plateBorderOpacity), width: 1.5),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            const SizedBox(height: _visualGap),
            Text(
              title,
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _titleSize,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            Text(
              line,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _lineSize,
                height: 1.25,
                color: DeckColors.offWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The arrow between two stations, with an optional word on it.
class _FlowArrow extends StatelessWidget {
  const _FlowArrow({this.color = DeckColors.mutedText, this.label, this.isBlocked = false});

  static const double _width = 96;
  static const double _iconSize = 52;
  static const double _labelSize = 18;

  final Color color;
  final String? label;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isBlocked ? Icons.block_rounded : Icons.arrow_forward_rounded, size: _iconSize, color: color),
          if (label != null)
            Text(
              label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: _labelSize,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

/// A round icon plate used where a station has no picture.
class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, {required this.color});

  static const double _size = 96;
  static const double _iconSize = 54;
  static const double _fillOpacity = 0.16;

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(color: color.withValues(alpha: _fillOpacity), shape: BoxShape.circle),
      child: Icon(icon, size: _iconSize, color: color),
    );
  }
}

/// The upright word at the start of a lane ("ÖNCE", "SONRA").
class _LaneLabel extends StatelessWidget {
  const _LaneLabel(this.text, {required this.color});

  static const double _width = 64;
  static const double _fontSize = 22;

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(_plateRadius),
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: _fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Rule 1: the same salted tray twice. Before, the model's answer went straight to the screen.
/// After, a guard stands between the model and the screen.
class GuardFlowDiagram extends StatelessWidget {
  const GuardFlowDiagram({super.key});

  static const double _trayPictureSize = 96;
  static const double _facePictureSize = 104;
  static const double _trayPictureGap = 8;
  static const int _wrongStars = 5;
  static const int _rightStars = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _lane(isGuarded: false)),
        const SizedBox(height: _gap),
        Expanded(child: _lane(isGuarded: true)),
      ],
    );
  }

  Widget _lane({required bool isGuarded}) {
    final laneColor = isGuarded ? DeckColors.googleGreen : DeckColors.googleRed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LaneLabel(isGuarded ? 'SONRA' : 'ÖNCE', color: laneColor),
        const SizedBox(width: _gap),
        const Expanded(
          flex: 5,
          child: _FlowNode(
            title: 'Tepsi',
            line: 'Tatlı sipariş, içinde gizli tuz',
            accentColor: DeckColors.googleYellow,
            visual: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CafePicture('espresso.png', size: _trayPictureSize),
                SizedBox(width: _trayPictureGap),
                _CafePicture('baklava.png', size: _trayPictureSize),
                SizedBox(width: _trayPictureGap),
                _CafePicture('salt_shaker.png', size: _trayPictureSize),
              ],
            ),
          ),
        ),
        const Center(child: _FlowArrow()),
        const Expanded(
          flex: 4,
          child: _FlowNode(
            title: 'Gemini',
            line: 'Tuzu kaçırırsa:\n"5 yıldız, tatlı!"',
            accentColor: DeckColors.googleBlue,
            visual: _IconBadge(Icons.auto_awesome, color: DeckColors.googleBlue),
          ),
        ),
        if (isGuarded) ...[
          const Center(child: _FlowArrow()),
          const Expanded(
            flex: 4,
            child: _FlowNode(
              title: 'Guard (kod)',
              line: 'Tepside tuz var.\nKarar uymuyor.',
              accentColor: DeckColors.googleGreen,
              visual: _IconBadge(Icons.shield_rounded, color: DeckColors.googleGreen),
            ),
          ),
          const Center(child: _FlowArrow(color: DeckColors.googleGreen, label: 'cevap atılır', isBlocked: true)),
        ] else
          const Center(child: _FlowArrow(color: DeckColors.googleRed, label: 'kontrol yok')),
        Expanded(
          flex: 4,
          child: _FlowNode(
            title: isGuarded ? 'Ekranda 1 yıldız' : 'Ekranda 5 yıldız',
            line: isGuarded ? 'Hazır yanıt devrede' : 'Tuzlu tepsi ödül aldı',
            accentColor: laneColor,
            visual: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CafePicture(
                  isGuarded ? 'customer_salty_disgusted.png' : 'customer_happy.png',
                  size: _facePictureSize,
                ),
                const SizedBox(width: _trayPictureGap),
                _StarRow(filled: isGuarded ? _rightStars : _wrongStars, color: laneColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One value a model may send back, and what happened to it before and after the enum.
@immutable
class _VerdictCase {
  const _VerdictCase(this.value, {required this.isOnTheList, this.note});

  final String value;
  final bool isOnTheList;
  final String? note;
}

/// Rule 2: the closed list as three faces, and the same five answers checked against a String and
/// against the enum.
class ClosedListDiagram extends StatelessWidget {
  const ClosedListDiagram({super.key});

  static const double _faceSize = 168;
  static const double _faceNameSize = 28;
  static const double _faceValueSize = 17;
  static const double _captionSize = 26;
  static const double _valueSize = 25;
  static const double _noteSize = 18;
  static const double _cellSize = 23;
  static const double _columnHeadSize = 19;
  static const double _resultColumnWidth = 232;
  static const double _rowGap = 8;
  static const double _rowRadius = 10;
  static const double _rowFillOpacity = 0.12;
  static const double _rowBorderOpacity = 0.4;
  static const double _cellIconSize = 26;

  static const List<_VerdictCase> _cases = [
    _VerdictCase('"sweet_perfection"', isOnTheList: true),
    _VerdictCase('"salty_sabotage"', isOnTheList: true),
    _VerdictCase('"spicy_chaos"', isOnTheList: true),
    _VerdictCase('"sweet_perfction"', isOnTheList: false, note: 'yazım hatası'),
    _VerdictCase('"bence güzeldi"', isOnTheList: false, note: 'serbest metin'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 5,
          child: DiagramPanel(
            label: 'KAPALI LİSTE · enum TasteVerdict',
            tag: '3 KARAR',
            accentColor: DeckColors.googleGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _VerdictFace('customer_happy.png', name: 'Tatlı', value: 'sweet_perfection'),
                    _VerdictFace('customer_salty_disgusted.png', name: 'Tuzlu', value: 'salty_sabotage'),
                    _VerdictFace('customer_shocked.png', name: 'Acı', value: 'spicy_chaos'),
                  ],
                ),
                Text(
                  'Model bu üç yüzden birini seçer.\nDördüncü yüz yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _captionSize,
                    fontWeight: FontWeight.w600,
                    color: DeckColors.offWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          flex: 7,
          child: DiagramPanel(
            label: 'MODELDEN GELEN KARAR',
            tag: 'ÖNCE: KODDA 21 YERDE ELLE YAZILI METİN',
            accentColor: DeckColors.googleYellow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Spacer(),
                    _ColumnHead('ÖNCE · String', color: DeckColors.googleRed),
                    _ColumnHead('SONRA · enum', color: DeckColors.googleGreen),
                  ],
                ),
                const SizedBox(height: _rowGap),
                for (final verdictCase in _cases) ...[
                  Expanded(child: _caseRow(verdictCase)),
                  if (verdictCase != _cases.last) const SizedBox(height: _rowGap),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _caseRow(_VerdictCase verdictCase) {
    final rowColor = verdictCase.isOnTheList ? DeckColors.googleGreen : DeckColors.googleRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: rowColor.withValues(alpha: _rowFillOpacity),
        borderRadius: BorderRadius.circular(_rowRadius),
        border: Border.all(color: rowColor.withValues(alpha: _rowBorderOpacity)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    verdictCase.value,
                    style:
                        const TextStyle(fontFamily: DeckFonts.mono, fontSize: _valueSize, color: DeckColors.offWhite),
                  ),
                  if (verdictCase.note != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      verdictCase.note!,
                      style: TextStyle(
                        fontFamily: DeckFonts.sans,
                        fontSize: _noteSize,
                        fontWeight: FontWeight.w700,
                        color: rowColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _resultCell(
            icon: verdictCase.isOnTheList ? Icons.check_circle_rounded : Icons.warning_rounded,
            text: verdictCase.isOnTheList ? 'geçti' : 'yine geçti',
            color: verdictCase.isOnTheList ? DeckColors.offWhite : DeckColors.googleRed,
          ),
          _resultCell(
            icon: verdictCase.isOnTheList ? Icons.check_circle_rounded : Icons.block_rounded,
            text: verdictCase.isOnTheList ? 'geçti' : 'reddedildi',
            color: DeckColors.googleGreen,
          ),
        ],
      ),
    );
  }

  Widget _resultCell({required IconData icon, required String text, required Color color}) {
    return SizedBox(
      width: _resultColumnWidth,
      child: Row(
        children: [
          Icon(icon, size: _cellIconSize, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style:
                TextStyle(fontFamily: DeckFonts.sans, fontSize: _cellSize, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _ColumnHead extends StatelessWidget {
  const _ColumnHead(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ClosedListDiagram._resultColumnWidth,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: DeckFonts.mono,
          fontSize: ClosedListDiagram._columnHeadSize,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _VerdictFace extends StatelessWidget {
  const _VerdictFace(this.assetFileName, {required this.name, required this.value});

  final String assetFileName;
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CafePicture(assetFileName, size: ClosedListDiagram._faceSize),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: ClosedListDiagram._faceNameSize,
            fontWeight: FontWeight.w700,
            color: DeckColors.offWhite,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: DeckFonts.mono,
            fontSize: ClosedListDiagram._faceValueSize,
            color: DeckColors.googleGreen,
          ),
        ),
      ],
    );
  }
}

/// Progressive reveal steps of [OrderStateDiagram] on `/order-state-rule`.
enum OrderStateStep {
  /// Step 1: all five variable combinations are shown neutrally so the hall can spot the invalid ones.
  allCombinations,

  /// Step 2: the three valid combinations turn green and the two impossible ones light up red.
  invalidHighlighted,

  /// Step 3: impossible combinations are crossed out as unrepresentable and the three sealed states appear.
  sealedStates;

  /// Maps the 1-based `stepNumber` from `FlutterDeckSlideStepsBuilder` to an [OrderStateStep].
  factory OrderStateStep.fromStepNumber(int stepNumber) => switch (stepNumber) {
        <= 1 => OrderStateStep.allCombinations,
        2 => OrderStateStep.invalidHighlighted,
        _ => OrderStateStep.sealedStates,
      };
}

/// One combination the three old variables could hold.
@immutable
class _OrderCombination {
  const _OrderCombination(this.variables, this.meaning, {required this.makesSense});

  final String variables;
  final String meaning;
  final bool makesSense;
}

/// Rule 3: what the three loose variables allowed, next to the three states the sealed class allows.
class OrderStateDiagram extends StatelessWidget {
  const OrderStateDiagram({this.step = OrderStateStep.sealedStates, super.key});

  final OrderStateStep step;

  static const double _variablesSize = 23;
  static const double _meaningSize = 23;
  static const double _rowGap = 8;
  static const double _rowRadius = 10;
  static const double _rowFillOpacity = 0.12;
  static const double _invalidHighlightFillOpacity = 0.2;
  static const double _rowBorderOpacity = 0.4;
  static const double _invalidHighlightBorderOpacity = 0.75;
  static const double _blockedTintOpacity = 0.85;
  static const double _rowIconSize = 28;
  static const double _stateNameSize = 28;
  static const double _stateTypeSize = 19;
  static const double _stateIconSize = 44;
  static const double _stateArrowSize = 34;
  static const double _closingSize = 24;
  static const double _waitingPromptSize = 25;
  static const double _waitingIconSize = 52;

  static const List<_OrderCombination> _combinations = [
    _OrderCombination('jüride: hayır · kart: yok', 'Boşta', makesSense: true),
    _OrderCombination('jüride: evet  · kart: yok', 'Jüride', makesSense: true),
    _OrderCombination('jüride: hayır · kart: var', 'Servis edildi', makesSense: true),
    _OrderCombination('jüride: evet  · kart: var', 'Jüride ama kart ekranda?', makesSense: false),
    _OrderCombination('yeni müşteri · tepsi boş · kart: var', 'Boş tepsiye 5 yıldız!', makesSense: false),
  ];

  String get _leftTag => switch (step) {
        OrderStateStep.allCombinations => '5 KOMBİNASYON',
        OrderStateStep.invalidHighlighted => '2 SAÇMA DURUM YAZILABİLİYORDU',
        OrderStateStep.sealedStates => 'SEALED İLE 2 SAÇMA DURUM YAZILAMAZ',
      };

  Color get _leftAccent => switch (step) {
        OrderStateStep.allCombinations => DeckColors.googleYellow,
        OrderStateStep.invalidHighlighted => DeckColors.googleRed,
        OrderStateStep.sealedStates => DeckColors.googleGreen,
      };

  @override
  Widget build(BuildContext context) {
    final showsSealedPanel = step == OrderStateStep.sealedStates;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: DiagramPanel(
            label: 'ÖNCE · ÜÇ AYRI DEĞİŞKEN',
            tag: _leftTag,
            accentColor: _leftAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final combination in _combinations) ...[
                  Expanded(child: _combinationRow(combination)),
                  if (combination != _combinations.last) const SizedBox(height: _rowGap),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          flex: 5,
          child: DiagramPanel(
            label: 'SONRA · sealed class OrderState',
            tag: showsSealedPanel ? '3 HAL' : 'BİRAZDAN',
            accentColor: showsSealedPanel ? DeckColors.googleGreen : DeckColors.mutedText,
            child: showsSealedPanel ? const _SealedOrderStatePanel() : _waitingRightPanel(),
          ),
        ),
      ],
    );
  }

  Widget _waitingRightPanel() {
    final isRedStep = step == OrderStateStep.invalidHighlighted;
    final accent = isRedStep ? DeckColors.googleRed : DeckColors.googleYellow;
    final prompt = isRedStep
        ? 'Kod bu iki kırmızı satırı engellemiyor:\nbir unutulan sıfırlama satırı yetiyor.'
        : 'Üç ayrı değişken bu beş satırın\nhepsine izin veriyor.\nHangileri gerçekte olmamalı?';
    final icon = isRedStep ? Icons.error_outline_rounded : Icons.help_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: DeckColors.surfaceInset,
        borderRadius: BorderRadius.circular(_plateRadius),
        border: Border.all(color: DeckColors.outline, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: _waitingIconSize, color: accent),
          ),
          const SizedBox(height: 22),
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _waitingPromptSize,
              fontWeight: FontWeight.w600,
              height: 1.38,
              color: DeckColors.offWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _combinationRow(_OrderCombination combination) {
    switch (step) {
      case OrderStateStep.allCombinations:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: DeckColors.surfaceElevated,
            borderRadius: BorderRadius.circular(_rowRadius),
            border: Border.all(color: DeckColors.outlineLight.withValues(alpha: _rowBorderOpacity)),
          ),
          child: Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: _rowIconSize, color: DeckColors.googleYellow),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    combination.variables,
                    style: const TextStyle(
                      fontFamily: DeckFonts.mono,
                      fontSize: _variablesSize,
                      color: DeckColors.offWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                combination.meaning,
                style: const TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: _meaningSize,
                  fontWeight: FontWeight.w600,
                  color: DeckColors.mutedText,
                ),
              ),
            ],
          ),
        );

      case OrderStateStep.invalidHighlighted:
        final isValid = combination.makesSense;
        final rowColor = isValid ? DeckColors.googleGreen : DeckColors.googleRed;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: rowColor.withValues(alpha: isValid ? _rowFillOpacity : _invalidHighlightFillOpacity),
            borderRadius: BorderRadius.circular(_rowRadius),
            border: Border.all(
              color: rowColor.withValues(alpha: isValid ? _rowBorderOpacity : _invalidHighlightBorderOpacity),
              width: isValid ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                size: _rowIconSize,
                color: rowColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    combination.variables,
                    style: const TextStyle(
                      fontFamily: DeckFonts.mono,
                      fontSize: _variablesSize,
                      color: DeckColors.offWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                combination.meaning,
                style: TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: _meaningSize,
                  fontWeight: FontWeight.w700,
                  color: rowColor,
                ),
              ),
            ],
          ),
        );

      case OrderStateStep.sealedStates:
        if (combination.makesSense) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: DeckColors.googleGreen.withValues(alpha: _rowFillOpacity),
              borderRadius: BorderRadius.circular(_rowRadius),
              border: Border.all(color: DeckColors.googleGreen.withValues(alpha: _rowBorderOpacity)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: _rowIconSize, color: DeckColors.googleGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      combination.variables,
                      style: const TextStyle(
                        fontFamily: DeckFonts.mono,
                        fontSize: _variablesSize,
                        color: DeckColors.offWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  combination.meaning,
                  style: const TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: _meaningSize,
                    fontWeight: FontWeight.w700,
                    color: DeckColors.googleGreen,
                  ),
                ),
              ],
            ),
          );
        }

        final blockedColor = DeckColors.googleRed.withValues(alpha: _blockedTintOpacity);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: DeckColors.surfaceInset,
            borderRadius: BorderRadius.circular(_rowRadius),
            border: Border.all(color: DeckColors.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.block_rounded, size: _rowIconSize, color: blockedColor),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    combination.variables,
                    style: TextStyle(
                      fontFamily: DeckFonts.mono,
                      fontSize: _variablesSize,
                      color: DeckColors.mutedText,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: blockedColor,
                      decorationThickness: 2.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'YAZILAMAZ',
                style: TextStyle(
                  fontFamily: DeckFonts.mono,
                  fontSize: _meaningSize - 2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: blockedColor,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _SealedOrderStatePanel extends StatelessWidget {
  const _SealedOrderStatePanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _OrderStateChip(Icons.storefront_rounded, name: 'Boşta', type: 'OrderIdle')),
        Icon(Icons.arrow_downward_rounded, size: OrderStateDiagram._stateArrowSize, color: DeckColors.googleGreen),
        Expanded(child: _OrderStateChip(Icons.hourglass_top_rounded, name: 'Jüride', type: 'OrderEvaluating')),
        Icon(Icons.arrow_downward_rounded, size: OrderStateDiagram._stateArrowSize, color: DeckColors.googleGreen),
        Expanded(
          child: _OrderStateChip(Icons.reviews_rounded, name: 'Servis edildi', type: 'OrderServed + kart'),
        ),
        SizedBox(height: 10),
        Text(
          'Dördüncü hal yok: yazmaya kalkarsan derlenmez.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DeckFonts.sans,
            fontSize: OrderStateDiagram._closingSize,
            fontWeight: FontWeight.w600,
            color: DeckColors.offWhite,
          ),
        ),
      ],
    );
  }
}

class _OrderStateChip extends StatelessWidget {
  const _OrderStateChip(this.icon, {required this.name, required this.type});

  final IconData icon;
  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: DeckColors.surfaceElevated,
        borderRadius: BorderRadius.circular(_plateRadius),
        border: Border.all(color: DeckColors.googleGreen.withValues(alpha: _plateBorderOpacity), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: OrderStateDiagram._stateIconSize, color: DeckColors.googleGreen),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: DeckFonts.sans,
                fontSize: OrderStateDiagram._stateNameSize,
                fontWeight: FontWeight.w700,
                color: DeckColors.offWhite,
              ),
            ),
          ),
          Text(
            type,
            style: const TextStyle(
              fontFamily: DeckFonts.mono,
              fontSize: OrderStateDiagram._stateTypeSize,
              color: DeckColors.googleGreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// One plan of the fallback chain, drawn to scale on a shared time axis.
@immutable
class _FallbackPlan {
  const _FallbackPlan({
    required this.letter,
    required this.name,
    required this.where,
    required this.color,
    required this.limitSeconds,
    required this.limitLabel,
    this.measuredFromSeconds,
    this.measuredToSeconds,
    this.measuredLabel,
  });

  final String letter;
  final String name;
  final String where;
  final Color color;
  final double limitSeconds;
  final String limitLabel;
  final double? measuredFromSeconds;
  final double? measuredToSeconds;
  final String? measuredLabel;
}

/// Rule 4: three plans on one time axis. The outline is the limit we set, the filled part is what
/// was measured.
class FallbackTimelineDiagram extends StatelessWidget {
  const FallbackTimelineDiagram({super.key});

  static const double _axisSeconds = 22;
  static const double _labelColumnWidth = 400;
  static const double _letterSize = 46;
  static const double _nameSize = 28;
  static const double _whereSize = 20;
  static const double _barHeight = 58;
  static const double _barLabelSize = 22;
  static const double _handOverSize = 20;
  static const double _tickSize = 19;
  static const double _limitFillOpacity = 0.1;
  static const double _minimumBarWidth = 14;
  static const List<int> _tickSeconds = [0, 5, 8, 10, 15, 20];

  static const List<_FallbackPlan> _plans = [
    _FallbackPlan(
      letter: 'A',
      name: 'Canlı Gemini',
      where: 'telefonunuzda ve sahnede',
      color: DeckColors.googleBlue,
      limitSeconds: 8,
      limitLabel: 'sınır 8 sn',
      measuredFromSeconds: 1,
      measuredToSeconds: 1.8,
      measuredLabel: 'ölçüm 1,0 ile 1,8 sn',
    ),
    _FallbackPlan(
      letter: 'B',
      name: 'Yerel Gemma',
      where: 'yalnızca sahnedeki laptopta',
      color: DeckColors.googleYellow,
      limitSeconds: 15,
      limitLabel: 'sınır 15 sn',
      measuredFromSeconds: 5,
      measuredToSeconds: 8.4,
      measuredLabel: 'ölçüm 5,0 ile 8,4 sn',
    ),
    _FallbackPlan(
      letter: 'C',
      name: 'Hazır yanıtlar',
      where: 'pakette, model gerekmez',
      color: DeckColors.googleGreen,
      limitSeconds: 0.25,
      limitLabel: 'en geç 250 ms',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DiagramPanel(
      label: 'ÜÇ PLAN · AYNI ZAMAN EKSENİ',
      tag: 'ÇERÇEVE: SINIR · DOLU: ÖLÇÜM (12 TEPSİ)',
      accentColor: DeckColors.googleYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plan in _plans) ...[
            Expanded(child: _planRow(plan)),
            if (plan != _plans.last) _handOver(),
          ],
          _axis(),
        ],
      ),
    );
  }

  Widget _planRow(_FallbackPlan plan) {
    return Row(
      children: [
        SizedBox(
          width: _labelColumnWidth,
          child: Row(
            children: [
              Text(
                plan.letter,
                style: TextStyle(
                  fontFamily: DeckFonts.sans,
                  fontSize: _letterSize,
                  fontWeight: FontWeight.w700,
                  color: plan.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontFamily: DeckFonts.sans,
                        fontSize: _nameSize,
                        fontWeight: FontWeight.w700,
                        color: DeckColors.offWhite,
                      ),
                    ),
                    Text(
                      plan.where,
                      style: const TextStyle(
                        fontFamily: DeckFonts.sans,
                        fontSize: _whereSize,
                        color: DeckColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pixelsPerSecond = constraints.maxWidth / _axisSeconds;
              final limitWidth = (plan.limitSeconds * pixelsPerSecond).clamp(_minimumBarWidth, constraints.maxWidth);
              final measuredFrom = plan.measuredFromSeconds;
              final measuredTo = plan.measuredToSeconds;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: limitWidth,
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: plan.color.withValues(alpha: measuredFrom == null ? 1 : _limitFillOpacity),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: plan.color, width: 2),
                    ),
                  ),
                  if (measuredFrom != null && measuredTo != null)
                    Positioned(
                      left: measuredFrom * pixelsPerSecond,
                      child: Container(
                        width: (measuredTo - measuredFrom) * pixelsPerSecond,
                        height: _barHeight,
                        decoration: BoxDecoration(color: plan.color, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  Positioned(
                    left: limitWidth + 14,
                    child: Text(
                      plan.measuredLabel == null ? plan.limitLabel : '${plan.limitLabel} · ${plan.measuredLabel}',
                      style: TextStyle(
                        fontFamily: DeckFonts.sans,
                        fontSize: _barLabelSize,
                        fontWeight: FontWeight.w700,
                        color: plan.color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _handOver() {
    return const Row(
      children: [
        SizedBox(width: 8),
        Icon(Icons.subdirectory_arrow_right_rounded, size: 30, color: DeckColors.mutedText),
        SizedBox(width: 10),
        Text(
          'süre dolarsa ya da hata gelirse sıradaki plan',
          style: TextStyle(fontFamily: DeckFonts.sans, fontSize: _handOverSize, color: DeckColors.mutedText),
        ),
      ],
    );
  }

  Widget _axis() {
    return Padding(
      padding: const EdgeInsets.only(left: _labelColumnWidth, top: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pixelsPerSecond = constraints.maxWidth / _axisSeconds;
          return SizedBox(
            height: 34,
            child: Stack(
              children: [
                Positioned(left: 0, right: 0, top: 0, child: Container(height: 2, color: DeckColors.outlineLight)),
                for (final second in _tickSeconds)
                  Positioned(
                    left: second * pixelsPerSecond,
                    top: 4,
                    child: Text(
                      '$second sn',
                      style:
                          const TextStyle(fontFamily: DeckFonts.mono, fontSize: _tickSize, color: DeckColors.mutedText),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Rule 5: where the key lives. The wrong way puts it into the page everyone downloads; the game
/// keeps it on the server between the phone and Gemini.
class KeyProxyDiagram extends StatelessWidget {
  const KeyProxyDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LaneLabel('YANLIŞ', color: DeckColors.googleRed),
              SizedBox(width: _gap),
              Expanded(
                flex: 5,
                child: _FlowNode(
                  title: 'Tarayıcı',
                  line: 'Anahtar sayfanın içinde:\nherkes okur',
                  accentColor: DeckColors.googleRed,
                  visual: _KeyedBadge(Icons.phone_iphone_rounded, color: DeckColors.googleRed, hasKey: true),
                ),
              ),
              Center(child: _FlowArrow(color: DeckColors.googleRed)),
              Expanded(
                flex: 4,
                child: _FlowNode(
                  title: 'Gemini',
                  line: 'Fatura sizin',
                  accentColor: DeckColors.googleBlue,
                  visual: _IconBadge(Icons.auto_awesome, color: DeckColors.googleBlue),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _gap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LaneLabel('OYUNDA', color: DeckColors.googleGreen),
              SizedBox(width: _gap),
              Expanded(
                flex: 4,
                child: _FlowNode(
                  title: 'Telefonunuz',
                  line: 'Anahtar yok',
                  accentColor: DeckColors.googleYellow,
                  visual: _KeyedBadge(Icons.phone_iphone_rounded, color: DeckColors.googleYellow, hasKey: false),
                ),
              ),
              Center(child: _FlowArrow()),
              Expanded(
                flex: 4,
                child: _FlowNode(
                  title: 'Proxy',
                  line: 'Cloud Run:\nanahtarı o ekler',
                  accentColor: DeckColors.googleGreen,
                  visual: _KeyedBadge(Icons.dns_rounded, color: DeckColors.googleGreen, hasKey: true),
                ),
              ),
              Center(child: _FlowArrow(color: DeckColors.googleGreen)),
              Expanded(
                flex: 3,
                child: _FlowNode(
                  title: 'Gemini',
                  line: 'Cevap',
                  accentColor: DeckColors.googleBlue,
                  visual: _IconBadge(Icons.auto_awesome, color: DeckColors.googleBlue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// An icon plate with a small key on its corner when the key lives there.
class _KeyedBadge extends StatelessWidget {
  const _KeyedBadge(this.icon, {required this.color, required this.hasKey});

  static const double _keySize = 40;

  final IconData icon;
  final Color color;
  final bool hasKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IconBadge(icon, color: color),
        if (hasKey)
          const Positioned(
            right: -14,
            bottom: -6,
            child: Icon(Icons.vpn_key_rounded, size: _keySize, color: DeckColors.googleYellow),
          ),
      ],
    );
  }
}

/// One proof under a diagram: what checks the rule, in a few words.
class ProofChip extends StatelessWidget {
  const ProofChip({required this.label, required this.text, super.key});

  static const double _labelSize = 17;
  static const double _textSize = 22;

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: DeckColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DeckColors.googleGreen.withValues(alpha: _plateBorderOpacity), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, size: 28, color: DeckColors.googleGreen),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: DeckFonts.sans,
              fontSize: _labelSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: DeckColors.googleGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: DeckFonts.sans, fontSize: _textSize, color: DeckColors.offWhite),
            ),
          ),
        ],
      ),
    );
  }
}
