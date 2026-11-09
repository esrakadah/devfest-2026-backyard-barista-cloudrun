import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/custom_svg_items.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/models/customer_order_ticket.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/cafe_sound_controller.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_character_animations.dart';
import 'package:backyard_barista_cloudrun/ui/city_settings_drawer.dart';
import 'package:flutter/material.dart';

const double _counterCardRadius = 18;
const double _ingredientImageSize = 70;
const double _trayItemImageSize = 42;
const double _customerAvatarSize = 76;
const double _mobileShelfBreakpointWidth = 420;
const double _desktopSplitBreakpointWidth = 980;
const double _maxDesktopContentWidth = 1360;
const double _gridSpacing = 12;
const double _uniformCounterCardHeight = 166;
const double _awningScallopHeight = 14;
const double _awningTopBandHeightRatio = 0.55;
const double _photoCornerRadius = 14;
const int _pranksterRoundPoints = 30;
const int _incompleteRoundPoints = 15;
const int _baristaRoundPoints = 50;
const Duration _cardScaleDuration = Duration(milliseconds: 180);

/// Cozy DevFest Arcade Cafe Scene built with pure Flutter declarative widgets
/// (`LayoutBuilder`, `Stack`, `AnimatedScale`, `AnimatedSwitcher`, `CustomPaint`, and `Image.asset`)
/// and `GoogleSans` typography.
class CafeCounterScreen extends StatefulWidget {
  const CafeCounterScreen({
    required this.cityController,
    required this.judgeService,
    super.key,
  });

  final CityEditionController cityController;
  final CafeJudgeService judgeService;

  @override
  State<CafeCounterScreen> createState() => _CafeCounterScreenState();
}

class _CafeCounterScreenState extends State<CafeCounterScreen> {
  final List<CafeIngredient> _selectedTray = <CafeIngredient>[];
  final CafeSoundController _soundController = CafeSoundController();
  bool _includeRoundTwoCustomItems = true;
  bool _isEvaluatingOrder = false;
  bool _isCrewSippingTea = false;
  bool _isCustomerSippingTea = false;
  int _activeTicketIndex = 0;
  int _playerOneBaristaScore = 0;
  int _playerTwoPastryScore = 0;
  int _tipJarTotal = 0;
  CafeReview? _latestReview;

  @override
  void initState() {
    super.initState();
    widget.cityController.addListener(_handleCityChanged);
  }

  @override
  void dispose() {
    widget.cityController.removeListener(_handleCityChanged);
    super.dispose();
  }

  void _handleCityChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _activeTicketIndex = 0;
      _selectedTray.clear();
      _latestReview = null;
      _isCrewSippingTea = false;
      _isCustomerSippingTea = false;
    });
  }

  List<CustomerOrderTicket> get _ticketsForActiveCity =>
      CustomerOrderTicket.ticketsForCity(widget.cityController.activeCityId);

  CustomerOrderTicket get _currentOrderTicket {
    final tickets = _ticketsForActiveCity;
    return tickets[_activeTicketIndex % tickets.length];
  }

  int get _crewLevel => 1 + ((_playerOneBaristaScore + _playerTwoPastryScore) ~/ 100);

  static const Set<String> _coffeeGrindIds = <String>{
    'espresso',
    'turkish_coffee',
    'menengic_coffee',
    'dibek_coffee',
    'oat_flat_white',
  };

  void _triggerManualSoundCue(CafeSoundCue cue) {
    setState(() {
      _soundController.play(cue);
    });
  }

  void _handleRoundTwoToggle(bool enabled) {
    setState(() {
      _includeRoundTwoCustomItems = enabled;
      if (!enabled) {
        final roundTwoIds = IngredientsCatalog.roundTwoCustomItems.map((item) => item.id).toSet();
        _selectedTray.removeWhere((item) => roundTwoIds.contains(item.id));
      }
    });
    _soundController.play(CafeSoundCue.tapPop);
  }

  void _toggleIngredient(CafeIngredient ingredient) {
    final isRemoving = _selectedTray.any((existing) => existing.id == ingredient.id);
    setState(() {
      if (isRemoving) {
        _selectedTray.removeWhere((existing) => existing.id == ingredient.id);
      } else {
        // Enforce 1 item per station category (Drink, Food, Topping/Prank) so the 3-slot tray stays clean.
        _selectedTray
          ..removeWhere((existing) => existing.category == ingredient.category)
          ..add(ingredient);
      }
      if (!isRemoving && ingredient.isPrankItem) {
        _soundController.play(CafeSoundCue.stealthWink);
      } else if (!isRemoving && _coffeeGrindIds.contains(ingredient.id)) {
        _soundController.play(CafeSoundCue.coffeeGrinder);
      } else if (!isRemoving && ingredient.category == IngredientCategory.drink) {
        _soundController.play(CafeSoundCue.espressoSteam);
      } else {
        _soundController.play(CafeSoundCue.tapPop);
      }
    });
  }

  void _clearTray() {
    setState(() {
      _selectedTray.clear();
      _latestReview = null;
    });
    _soundController.play(CafeSoundCue.tapPop);
  }

  void _advanceToNextCustomer() {
    setState(() {
      final tickets = _ticketsForActiveCity;
      _activeTicketIndex = (_activeTicketIndex + 1) % tickets.length;
      _selectedTray.clear();
      _latestReview = null;
      _isCrewSippingTea = false;
      _isCustomerSippingTea = false;
    });
    _soundController.play(CafeSoundCue.nextChime);
  }

  void _triggerFiveSecondTeaSip() {
    setState(() {
      _isCrewSippingTea = true;
      _isCustomerSippingTea = true;
    });
    _soundController.play(CafeSoundCue.teaSip);
  }

  void _handleTeaSipCompleted() {
    if (!mounted || (!_isCrewSippingTea && !_isCustomerSippingTea)) {
      return;
    }
    setState(() {
      _isCrewSippingTea = false;
      _isCustomerSippingTea = false;
    });
  }

  Future<void> _serveOrder() async {
    if (_selectedTray.isEmpty || _isEvaluatingOrder) {
      return;
    }
    setState(() {
      _isEvaluatingOrder = true;
    });
    _soundController.play(CafeSoundCue.serveBell);

    final review = await widget.judgeService.evaluateOrder(
      selectedIngredients: List<CafeIngredient>.unmodifiable(_selectedTray),
      cityEdition: widget.cityController.activeEdition,
    );

    if (!mounted) {
      return;
    }
    final previousLevel = _crewLevel;
    setState(() {
      _isEvaluatingOrder = false;
      _latestReview = review;
      _tipJarTotal += review.cityBonusTip;
      if (review.isPrankCaught) {
        _playerTwoPastryScore += _pranksterRoundPoints;
      } else if (review.isIncompleteTray) {
        _playerOneBaristaScore += _incompleteRoundPoints;
        _playerTwoPastryScore += _incompleteRoundPoints;
      } else {
        _playerOneBaristaScore += _baristaRoundPoints;
        _playerTwoPastryScore += _baristaRoundPoints;
      }
      final didLevelUp = _crewLevel > previousLevel;
      if (review.isPrankCaught) {
        _soundController.play(CafeSoundCue.saltyBuzzer);
      } else if (didLevelUp) {
        _soundController.play(CafeSoundCue.levelUpFanfare);
      } else if (review.isIncompleteTray) {
        _soundController.play(CafeSoundCue.tapPop);
      } else {
        _soundController.play(CafeSoundCue.sweetFanfare);
      }
    });
  }

  void _openCityEditionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CitySettingsSheet(controller: widget.cityController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cityController,
      builder: (context, _) {
        final activeEdition = widget.cityController.activeEdition;
        final languageCode = activeEdition.defaultLanguage;
        final currentTicket = _currentOrderTicket;
        final totalTickets = _ticketsForActiveCity.length;
        final latestReview = _latestReview;
        final effectiveRequestedIds = currentTicket.effectiveRequestedIngredientIds(
          includeRoundTwoItems: _includeRoundTwoCustomItems,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8EE),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2C1A12),
            foregroundColor: const Color(0xFFFFF8EE),
            elevation: 0,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Backyard Barista on Cloud Run ☕🥐🧂',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${activeEdition.cafeSubtitle} · ${activeEdition.signatureSpecialty}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFCCBC),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                key: const Key('sound_mute_toggle_button'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: _soundController.isMuted ? 'Unmute Cafe Sounds' : 'Mute Cafe Sounds',
                onPressed: () {
                  setState(_soundController.toggleMute);
                },
                icon: Icon(
                  _soundController.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  size: 20,
                  color: const Color(0xFFFFCCBC),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                child: FilledButton.tonalIcon(
                  key: const Key('city_edition_switcher_button'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: const Color(0xFFC85A32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openCityEditionSheet,
                  icon: _CityFlagBadge(editionId: activeEdition.editionId),
                  label: Text(
                    '${activeEdition.cityName} Edition ▾',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              const _ScallopedAwningEdge(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktopSplit = constraints.maxWidth >= _desktopSplitBreakpointWidth;

                    final scoreboardWidget = _ScoreboardAndConfigBar(
                      cityEdition: activeEdition,
                      sourceLayer: widget.cityController.activeSourceLayer,
                      languageCode: languageCode,
                      playerOneScore: _playerOneBaristaScore,
                      playerTwoScore: _playerTwoPastryScore,
                      crewLevel: _crewLevel,
                      tipJarTotal: _tipJarTotal,
                      includeRoundTwoItems: _includeRoundTwoCustomItems,
                      onToggleRoundTwoItems: _handleRoundTwoToggle,
                      onOpenCitySettings: _openCityEditionSheet,
                    );

                    final soundboardWidget = _BaristaWebAudioSoundboardBar(
                      languageCode: languageCode,
                      isMuted: _soundController.isMuted,
                      lastPlayedCue: _soundController.lastPlayedCue,
                      onPlayCue: _triggerManualSoundCue,
                    );

                    final crewStageWidget = CafeCrewCharacterStage(
                      languageCode: languageCode,
                      selectedTray: _selectedTray,
                      latestReview: latestReview,
                      playerOneScore: _playerOneBaristaScore,
                      playerTwoScore: _playerTwoPastryScore,
                      isCrewSippingTea: _isCrewSippingTea,
                      onTriggerFiveSecondTeaSip: _triggerFiveSecondTeaSip,
                      onSipTeaCompleted: _handleTeaSipCompleted,
                      onTapCharacterEmote: _triggerFiveSecondTeaSip,
                    );

                    final customerStageWidget = _CustomerOrderStage(
                      ticket: currentTicket,
                      totalTickets: totalTickets,
                      languageCode: languageCode,
                      includeRoundTwoItems: _includeRoundTwoCustomItems,
                      selectedTray: _selectedTray,
                      latestReview: latestReview,
                      isCustomerSippingTea: _isCustomerSippingTea,
                      onNextCustomer: _advanceToNextCustomer,
                      onTriggerFiveSecondTeaSip: _triggerFiveSecondTeaSip,
                      onSipTeaCompleted: _handleTeaSipCompleted,
                      onTapCustomerCharacter: _triggerFiveSecondTeaSip,
                    );

                    final woodenTrayWidget = _InteractiveWoodenTray(
                      selectedTray: _selectedTray,
                      languageCode: languageCode,
                      isEvaluating: _isEvaluatingOrder,
                      onRemoveIngredient: _toggleIngredient,
                      onServeOrder: _serveOrder,
                      onClearTray: _clearTray,
                    );

                    final reviewSwitcherWidget = AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: latestReview != null
                          ? _CustomerReviewCard(
                              key: ValueKey<DateTime>(latestReview.evaluatedAt),
                              review: latestReview,
                              cityEdition: activeEdition,
                              languageCode: languageCode,
                              onNextCustomer: _advanceToNextCustomer,
                            )
                          : const SizedBox.shrink(),
                    );

                    final drinkShelfWidget = _CafeStationShelf(
                      category: IngredientCategory.drink,
                      languageCode: languageCode,
                      ingredients: IngredientsCatalog.itemsForCategory(
                        IngredientCategory.drink,
                        includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                      ),
                      selectedTray: _selectedTray,
                      requestedIngredientIds: effectiveRequestedIds,
                      onToggleIngredient: _toggleIngredient,
                    );

                    final foodShelfWidget = _CafeStationShelf(
                      category: IngredientCategory.food,
                      languageCode: languageCode,
                      ingredients: IngredientsCatalog.itemsForCategory(
                        IngredientCategory.food,
                        includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                      ),
                      selectedTray: _selectedTray,
                      requestedIngredientIds: effectiveRequestedIds,
                      onToggleIngredient: _toggleIngredient,
                    );

                    final prankShelfWidget = _CafeStationShelf(
                      category: IngredientCategory.toppingOrPrank,
                      languageCode: languageCode,
                      ingredients: IngredientsCatalog.itemsForCategory(
                        IngredientCategory.toppingOrPrank,
                        includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                      ),
                      selectedTray: _selectedTray,
                      requestedIngredientIds: effectiveRequestedIds,
                      onToggleIngredient: _toggleIngredient,
                    );

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: _maxDesktopContentWidth),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              scoreboardWidget,
                              const SizedBox(height: 10),
                              soundboardWidget,
                              const SizedBox(height: 12),
                              crewStageWidget,
                              const SizedBox(height: 12),
                              customerStageWidget,
                              const SizedBox(height: 14),
                              if (isDesktopSplit) ...<Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: drinkShelfWidget,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 4,
                                      child: foodShelfWidget,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 4,
                                      child: prankShelfWidget,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 3,
                                      child: woodenTrayWidget,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                reviewSwitcherWidget,
                              ] else ...<Widget>[
                                drinkShelfWidget,
                                const SizedBox(height: 12),
                                foodShelfWidget,
                                const SizedBox(height: 12),
                                prankShelfWidget,
                                const SizedBox(height: 14),
                                woodenTrayWidget,
                                const SizedBox(height: 14),
                                reviewSwitcherWidget,
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom-painted vector flag pill (`🇹🇷` crimson crescent / `🇩🇪` German tricolor) so desktop
/// platforms where `GoogleSans` lacks regional-indicator flag glyphs never render raw `"TR"` letters.
class _CityFlagBadge extends StatelessWidget {
  const _CityFlagBadge({required this.editionId});

  final CityEditionId editionId;

  @override
  Widget build(BuildContext context) {
    final isGermany = editionId == CityEditionId.berlin;
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(
          painter: _CityFlagPainter(isGermany: isGermany),
        ),
      ),
    );
  }
}

class _CityFlagPainter extends CustomPainter {
  const _CityFlagPainter({required this.isGermany});

  final bool isGermany;

  @override
  void paint(Canvas canvas, Size size) {
    if (isGermany) {
      final bandHeight = size.height / 3;
      canvas
        ..drawRect(
          Rect.fromLTWH(0, 0, size.width, bandHeight),
          Paint()..color = const Color(0xFF1A1A1A),
        )
        ..drawRect(
          Rect.fromLTWH(0, bandHeight, size.width, bandHeight),
          Paint()..color = const Color(0xFFD32F2F),
        )
        ..drawRect(
          Rect.fromLTWH(0, bandHeight * 2, size.width, bandHeight),
          Paint()..color = const Color(0xFFFFCA28),
        );
      return;
    }

    // Turkish Crimson Flag with white crescent & star
    final redPaint = Paint()..color = const Color(0xFFE30A17);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, redPaint);
    final center = Offset(size.width * 0.44, size.height * 0.5);
    canvas
      ..drawCircle(center, size.height * 0.30, whitePaint)
      ..drawCircle(Offset(center.dx + size.height * 0.08, center.dy), size.height * 0.24, redPaint)
      ..drawCircle(Offset(size.width * 0.67, size.height * 0.5), size.height * 0.09, whitePaint);
  }

  @override
  bool shouldRepaint(covariant _CityFlagPainter oldDelegate) => oldDelegate.isGermany != isGermany;
}

/// Decorative striped cafe awning edge painted beneath the top AppBar.
class _ScallopedAwningEdge extends StatelessWidget {
  const _ScallopedAwningEdge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _awningScallopHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _AwningScallopPainter(),
      ),
    );
  }
}

class _AwningScallopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stripeWidth = 36.0;
    final terracottaPaint = Paint()..color = const Color(0xFFC85A32);
    final creamPaint = Paint()..color = const Color(0xFFFFEAD2);

    var index = 0;
    for (double x = 0; x < size.width; x += stripeWidth) {
      final paint = index.isEven ? terracottaPaint : creamPaint;
      final currentWidth = (x + stripeWidth > size.width) ? (size.width - x) : stripeWidth;
      canvas
        ..drawRect(
          Rect.fromLTWH(x, 0, currentWidth, size.height * _awningTopBandHeightRatio),
          paint,
        )
        ..drawArc(
          Rect.fromLTWH(x, 0, currentWidth, size.height),
          0,
          math.pi,
          true,
          paint,
        );
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScoreboardAndConfigBar extends StatelessWidget {
  const _ScoreboardAndConfigBar({
    required this.cityEdition,
    required this.sourceLayer,
    required this.languageCode,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.crewLevel,
    required this.tipJarTotal,
    required this.includeRoundTwoItems,
    required this.onToggleRoundTwoItems,
    required this.onOpenCitySettings,
  });

  final CityEditionConfig cityEdition;
  final CityConfigSourceLayer sourceLayer;
  final String languageCode;
  final int playerOneScore;
  final int playerTwoScore;
  final int crewLevel;
  final int tipJarTotal;
  final bool includeRoundTwoItems;
  final ValueChanged<bool> onToggleRoundTwoItems;
  final VoidCallback onOpenCitySettings;

  String _friendlySourceBadgeLabel(bool isEnglish) {
    switch (sourceLayer) {
      case CityConfigSourceLayer.manualUiOverride:
        return isEnglish ? 'Manual City Mode' : 'Manuel Şehir Seçimi';
      case CityConfigSourceLayer.firebaseRemoteConfig:
        return isEnglish ? 'Live Remote Config' : 'Canlı Remote Config';
      case CityConfigSourceLayer.bundledLocalFallback:
        return isEnglish ? 'Offline City Pack' : 'Yerel Şehir Paketi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = languageCode == 'en';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E0),
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: const Color(0xFFE0C3A8), width: 1.5),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpenCitySettings,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CityFlagBadge(editionId: cityEdition.editionId),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              cityEdition.eventTitle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF2C1A12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFE2D3),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFD2B49C)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFF6D4C41)),
                                const SizedBox(width: 4),
                                Text(
                                  _friendlySourceBadgeLabel(isEnglish),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cityEdition.cafeSubtitle} · ${cityEdition.signatureSpecialty}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6D4C41),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                key: const Key('cafe_crew_level_badge'),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5B84B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFF8C5800)),
                    const SizedBox(width: 5),
                    Text(
                      'Lv.$crewLevel Barista',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF6E4300),
                      ),
                    ),
                  ],
                ),
              ),
              _ScorePill(
                icon: Icons.coffee_rounded,
                label: isEnglish ? 'P1 Barista: $playerOneScore' : 'O1 Barista: $playerOneScore',
                backgroundColor: const Color(0xFFEFE5DC),
                textColor: const Color(0xFF3E2723),
              ),
              _ScorePill(
                icon: Icons.bakery_dining_rounded,
                label: isEnglish ? 'P2 Pastry: $playerTwoScore' : 'O2 Tatlı: $playerTwoScore',
                backgroundColor: const Color(0xFFFCE8E0),
                textColor: const Color(0xFF8D3218),
              ),
              _ScorePill(
                icon: Icons.savings_rounded,
                label: isEnglish ? 'Tips: +$tipJarTotal pts' : 'Bahşiş: +${tipJarTotal}p',
                backgroundColor: const Color(0xFFE6F4EA),
                textColor: const Color(0xFF137333),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 4, top: 2, bottom: 2),
                decoration: BoxDecoration(
                  color: includeRoundTwoItems ? const Color(0xFFE6F4EA) : const Color(0xFFF3ECE6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: includeRoundTwoItems ? const Color(0xFF34A853) : const Color(0xFFD7CCC8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: includeRoundTwoItems ? const Color(0xFF137333) : const Color(0xFF6D4C41),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isEnglish ? 'Round 2 AI Menu:' : 'Tur 2 Özel Menü:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: includeRoundTwoItems ? const Color(0xFF137333) : const Color(0xFF4E342E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        child: Switch(
                          key: const Key('round_two_custom_items_switch'),
                          value: includeRoundTwoItems,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF1E8E3E),
                          inactiveThumbColor: const Color(0xFF5D4037),
                          inactiveTrackColor: const Color(0xFFD7CCC8),
                          onChanged: onToggleRoundTwoItems,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BaristaWebAudioSoundboardBar extends StatelessWidget {
  const _BaristaWebAudioSoundboardBar({
    required this.languageCode,
    required this.isMuted,
    required this.lastPlayedCue,
    required this.onPlayCue,
  });

  final String languageCode;
  final bool isMuted;
  final CafeSoundCue? lastPlayedCue;
  final ValueChanged<CafeSoundCue> onPlayCue;

  @override
  Widget build(BuildContext context) {
    final isTurkish = languageCode == 'tr';
    final statusText = isMuted
        ? (isTurkish ? 'Ses Kapalı' : 'Muted')
        : (lastPlayedCue?.displayLabel ?? (isTurkish ? 'Ses Efektleri Hazır' : 'Soundboard Ready'));

    return Container(
      key: const Key('barista_web_audio_soundboard'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2319),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6D4C41)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: <Widget>[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              const Icon(Icons.graphic_eq_rounded, size: 16, color: Color(0xFFFFCCBC)),
              Text(
                isTurkish ? 'Kafe Ses Efektleri:' : 'Barista Soundboard:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFF8EE),
                ),
              ),
              Container(
                key: const Key('active_web_audio_cue_badge'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF563527),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF8D6E63)),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _SoundboardActionChip(
                buttonKey: const Key('sound_fx_coffee_grinder_button'),
                icon: Icons.settings_suggest_rounded,
                label: isTurkish ? 'Kahve Değirmeni' : 'Coffee Grinder',
                onTap: () => onPlayCue(CafeSoundCue.coffeeGrinder),
              ),
              _SoundboardActionChip(
                buttonKey: const Key('sound_fx_espresso_steam_button'),
                icon: Icons.air_rounded,
                label: isTurkish ? 'Espresso Buharı' : 'Espresso Steam',
                onTap: () => onPlayCue(CafeSoundCue.espressoSteam),
              ),
              _SoundboardActionChip(
                buttonKey: const Key('sound_fx_serve_bell_button'),
                icon: Icons.notifications_active_rounded,
                label: isTurkish ? 'Sipariş Zili' : 'Order Bell',
                onTap: () => onPlayCue(CafeSoundCue.serveBell),
              ),
              _SoundboardActionChip(
                buttonKey: const Key('sound_fx_level_up_button'),
                icon: Icons.emoji_events_rounded,
                label: isTurkish ? 'Seviye Atlama' : 'Level Up',
                onTap: () => onPlayCue(CafeSoundCue.levelUpFanfare),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoundboardActionChip extends StatelessWidget {
  const _SoundboardActionChip({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF513224),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: buttonKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 13, color: const Color(0xFFFFCCBC)),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFF8EE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 1 of the Cafe Loop: Live Customer Window + Speech-Bubble Order Ticket.
class _CustomerOrderStage extends StatelessWidget {
  const _CustomerOrderStage({
    required this.ticket,
    required this.totalTickets,
    required this.languageCode,
    required this.includeRoundTwoItems,
    required this.selectedTray,
    required this.latestReview,
    required this.isCustomerSippingTea,
    required this.onNextCustomer,
    required this.onTriggerFiveSecondTeaSip,
    required this.onSipTeaCompleted,
    required this.onTapCustomerCharacter,
  });

  final CustomerOrderTicket ticket;
  final int totalTickets;
  final String languageCode;
  final bool includeRoundTwoItems;
  final List<CafeIngredient> selectedTray;
  final CafeReview? latestReview;
  final bool isCustomerSippingTea;
  final VoidCallback onNextCustomer;
  final VoidCallback onTriggerFiveSecondTeaSip;
  final VoidCallback onSipTeaCompleted;
  final VoidCallback onTapCustomerCharacter;

  CafeCharacterMood get _customerMood {
    if (isCustomerSippingTea) {
      return CafeCharacterMood.sippingTeaFiveSeconds;
    }
    final currentReview = latestReview;
    if (currentReview != null) {
      return currentReview.isPrankCaught ? CafeCharacterMood.saltySabotageShock : CafeCharacterMood.sweetCelebration;
    }
    if (selectedTray.isNotEmpty) {
      return CafeCharacterMood.brewingActive;
    }
    return CafeCharacterMood.talkingOrder;
  }

  String get _activeCustomerPortraitAsset {
    final currentReview = latestReview;
    if (currentReview != null && currentReview.isPrankCaught) {
      return currentReview.customerFace.assetPath;
    }
    return ticket.portraitAssetPath;
  }

  @override
  Widget build(BuildContext context) {
    final currentReview = latestReview;
    final windowBorderColor = currentReview == null
        ? const Color(0xFFD7A86E)
        : (currentReview.isPrankCaught ? const Color(0xFFE53935) : const Color(0xFF43A047));
    final effectiveRequestedIds = ticket.effectiveRequestedIngredientIds(
      includeRoundTwoItems: includeRoundTwoItems,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF43281C), Color(0xFF2C1A12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_counterCardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Animated Arched Customer Cafe Window + Lottie Aura + 5s Turkish Tea Glass Sipping
          AnimatedCafeCharacterAvatar(
            key: const Key('customer_arch_character_avatar'),
            portraitAssetPath: _activeCustomerPortraitAsset,
            mood: _customerMood,
            avatarSize: _customerAvatarSize,
            borderColor: windowBorderColor,
            badgeEmoji: ticket.characterBadgeEmoji,
            isArchedWindow: true,
            isSippingTea: isCustomerSippingTea,
            languageCode: languageCode,
            onTapCharacter: onTapCustomerCharacter,
            onSipTeaCompleted: onSipTeaCompleted,
          ),
          const SizedBox(width: 14),
          // Speech-Bubble Order Ticket
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6CCB2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: <Widget>[
                        Text(
                          '${languageCode == 'en' ? 'Customer' : 'Müşteri'} #${ticket.ticketNumber}/$totalTickets · '
                          '${ticket.customerName} (${ticket.localizedRole(languageCode)})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            FilledButton.tonalIcon(
                              key: const Key('customer_sip_tea_5s_button'),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                backgroundColor:
                                    isCustomerSippingTea ? const Color(0xFFB71C1C) : const Color(0xFFFFE0B2),
                                foregroundColor: isCustomerSippingTea ? Colors.white : const Color(0xFF8D3218),
                              ),
                              onPressed: onTriggerFiveSecondTeaSip,
                              icon: const Icon(Icons.emoji_food_beverage_rounded, size: 14),
                              label: Text(
                                isCustomerSippingTea
                                    ? (languageCode == 'en' ? 'Sipping Tea (5s)...' : 'Çay Yudumluyor (5sn)...')
                                    : (languageCode == 'en' ? 'Sip Tea (5s)' : '5sn Çay Yudumlat'),
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton.icon(
                              key: const Key('next_customer_button'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: const Color(0xFFC85A32),
                              ),
                              onPressed: onNextCustomer,
                              icon: const Icon(Icons.skip_next_rounded, size: 16),
                              label: Text(
                                languageCode == 'en' ? 'Next Customer' : 'Sıradaki Müşteri',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${ticket.localizedBubble(languageCode, includeRoundTwoItems: includeRoundTwoItems)}"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  if (isCustomerSippingTea) ...<Widget>[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      child: Text(
                        languageCode == 'en'
                            ? '"🫖 Siiip... Enjoying my hot Turkish tulip-glass tea for 5 seconds! Ohhh! ✨"'
                            : '"🫖 Hüüüp... İnce belli bardakta tavşan kanı çayımı 5 saniye keyifle yudumluyorum! Ohhh! ✨"',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: effectiveRequestedIds.map((requestedIngredientId) {
                      final ingredient = IngredientsCatalog.findById(requestedIngredientId);
                      final isAdded = selectedTray.any((item) => item.id == requestedIngredientId);
                      final labelText = ingredient?.localizedTitle(languageCode) ?? requestedIngredientId;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdded ? const Color(0xFFE6F4EA) : const Color(0xFFF3ECE6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAdded ? const Color(0xFF34A853) : const Color(0xFFD7CCC8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isAdded ? Icons.check_circle_rounded : Icons.circle_outlined,
                              size: 13,
                              color: isAdded ? const Color(0xFF137333) : const Color(0xFF8D6E63),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                labelText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isAdded ? const Color(0xFF137333) : const Color(0xFF4E342E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 2 of the Cafe Loop: Distinct Station Shelf for Drinks, Pastries, and Twin Jars.
class _CafeStationShelf extends StatelessWidget {
  const _CafeStationShelf({
    required this.category,
    required this.languageCode,
    required this.ingredients,
    required this.selectedTray,
    required this.requestedIngredientIds,
    required this.onToggleIngredient,
  });

  final IngredientCategory category;
  final String languageCode;
  final List<CafeIngredient> ingredients;
  final List<CafeIngredient> selectedTray;
  final List<String> requestedIngredientIds;
  final ValueChanged<CafeIngredient> onToggleIngredient;

  Color get _shelfSurfaceColor {
    switch (category) {
      case IngredientCategory.drink:
        return const Color(0xFFF5EBE1);
      case IngredientCategory.food:
        return const Color(0xFFEDF6F2);
      case IngredientCategory.toppingOrPrank:
        return const Color(0xFFF6F0F8);
    }
  }

  Color get _shelfBorderColor {
    switch (category) {
      case IngredientCategory.drink:
        return const Color(0xFFD7B89C);
      case IngredientCategory.food:
        return const Color(0xFFA8D5BA);
      case IngredientCategory.toppingOrPrank:
        return const Color(0xFFD1C4E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedInShelf = selectedTray.where((item) => item.category == category).firstOrNull;
    final isEnglish = languageCode == 'en';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _shelfSurfaceColor,
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: _shelfBorderColor, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, shelfConstraints) {
          final maxShelfWidth = shelfConstraints.maxWidth;
          final itemCount = ingredients.length.clamp(1, 4);
          final columns = maxShelfWidth < _mobileShelfBreakpointWidth ? 2 : itemCount;
          final computedCardWidth = (((maxShelfWidth - (_gridSpacing * (columns - 1))) / columns) - 0.5).clamp(
            108.0,
            260.0,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    Text(
                      category.localizedTitle(languageCode),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF2C1A12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: selectedInShelf != null ? const Color(0xFFE6F4EA) : Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selectedInShelf != null ? const Color(0xFF34A853) : _shelfBorderColor,
                        ),
                      ),
                      child: Text(
                        selectedInShelf != null
                            ? '✓ ${selectedInShelf.localizedTitle(languageCode)}'
                            : (isEnglish ? 'Pick 1 item' : '1 ürün seçin'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selectedInShelf != null ? const Color(0xFF137333) : const Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: _gridSpacing,
                runSpacing: _gridSpacing,
                children: ingredients.map((ingredient) {
                  final isSelected = selectedTray.any((item) => item.id == ingredient.id);
                  return _IngredientCounterCard(
                    ingredient: ingredient,
                    languageCode: languageCode,
                    isSelected: isSelected,
                    cardWidth: computedCardWidth,
                    onTap: () => onToggleIngredient(ingredient),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Individual counter card with uniform fixed height (`166px`) and ZERO spoiler border so
/// Salt and Sugar look like true twins until plated!
class _IngredientCounterCard extends StatelessWidget {
  const _IngredientCounterCard({
    required this.ingredient,
    required this.languageCode,
    required this.isSelected,
    required this.cardWidth,
    required this.onTap,
  });

  final CafeIngredient ingredient;
  final String languageCode;
  final bool isSelected;
  final double cardWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? const Color(0xFF137333) : const Color(0xFFDECBB7);
    final backgroundColor = isSelected ? const Color(0xFFE6F4EA) : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: _cardScaleDuration,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('ingredient_card_${ingredient.id}'),
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: cardWidth,
            height: _uniformCounterCardHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.5 : 1.3,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: _IngredientArtwork(
                        ingredient: ingredient,
                        size: _ingredientImageSize,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF137333),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 34,
                  child: Center(
                    child: Text(
                      ingredient.localizedTitle(languageCode),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.15,
                        color: Color(0xFF2C1A12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 26,
                  child: Center(
                    child: Text(
                      ingredient.localizedSubtitle(languageCode),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF795548),
                      ),
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

class _IngredientArtwork extends StatelessWidget {
  const _IngredientArtwork({
    required this.ingredient,
    required this.size,
  });

  final CafeIngredient ingredient;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = ingredient.assetPath;
    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_photoCornerRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_photoCornerRadius),
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              final vectorFallback = ingredient.customVectorKind;
              if (vectorFallback != null) {
                return CustomVectorIngredientGraphic(
                  artworkKind: vectorFallback,
                  size: size,
                );
              }
              return Icon(Icons.local_cafe, size: size, color: const Color(0xFF6D4C41));
            },
          ),
        ),
      );
    }

    final vectorKind = ingredient.customVectorKind;
    if (vectorKind != null) {
      return CustomVectorIngredientGraphic(
        artworkKind: vectorKind,
        size: size,
      );
    }

    return Icon(Icons.local_cafe, size: size, color: const Color(0xFF6D4C41));
  }
}

/// Step 3 of the Cafe Loop: Interactive 3-Slot Wooden Serving Tray with lace doily & stealth wink badge.
class _InteractiveWoodenTray extends StatelessWidget {
  const _InteractiveWoodenTray({
    required this.selectedTray,
    required this.languageCode,
    required this.isEvaluating,
    required this.onRemoveIngredient,
    required this.onServeOrder,
    required this.onClearTray,
  });

  final List<CafeIngredient> selectedTray;
  final String languageCode;
  final bool isEvaluating;
  final ValueChanged<CafeIngredient> onRemoveIngredient;
  final VoidCallback onServeOrder;
  final VoidCallback onClearTray;

  CafeIngredient? _itemForCategory(IngredientCategory category) {
    for (final item in selectedTray) {
      if (item.category == category) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = languageCode == 'en';
    final hasStealthPrankOnTray = selectedTray.any((item) => item.isPrankItem);
    final isTrayEmpty = selectedTray.isEmpty;

    return Container(
      key: const Key('wooden_serving_tray'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF5D3A24), Color(0xFF3E2415)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF8D5B3C), width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Lace Paper Doily inner tray mat with 3 dedicated station coasters
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6D5C3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.room_service_rounded, color: Color(0xFF4E342E), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTrayEmpty
                            ? (isEnglish ? 'Wooden Serving Tray (0/3 Plated)' : 'Canlı Ahşap Tepsi (0/3 Ürün Dizildi)')
                            : (isEnglish
                                ? 'Wooden Tray (${selectedTray.length}/3): '
                                    '${selectedTray.map((item) => item.localizedTitle(languageCode)).join(' + ')}'
                                : 'Ahşap Tepsi (${selectedTray.length}/3): '
                                    '${selectedTray.map((item) => item.localizedTitle(languageCode)).join(' + ')}'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF2C1A12),
                        ),
                      ),
                    ),
                    if (hasStealthPrankOnTray)
                      Container(
                        key: const Key('stealth_prank_wink_badge'),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: const Text(
                          '🤫 😉',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    if (selectedTray.isNotEmpty)
                      TextButton(
                        key: const Key('clear_tray_button'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: const Color(0xFFC85A32),
                        ),
                        onPressed: onClearTray,
                        child: Text(
                          isEnglish ? 'Clear' : 'Temizle',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, trayConstraints) {
                    final isNarrowTray = trayConstraints.maxWidth < 360;
                    final slots = <Widget>[
                      _TrayStationSlotCoaster(
                        slotIcon: Icons.coffee_rounded,
                        emptyTitle: isEnglish ? '1. Drink Slot' : '1. İçecek Yeri',
                        emptySubtitle: isEnglish ? 'Tap Coffee Bar' : 'Kahve Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.drink),
                        languageCode: languageCode,
                        onRemoveIngredient: onRemoveIngredient,
                      ),
                      _TrayStationSlotCoaster(
                        slotIcon: Icons.bakery_dining_rounded,
                        emptyTitle: isEnglish ? '2. Pastry Slot' : '2. Tatlı Yeri',
                        emptySubtitle: isEnglish ? 'Tap Vitrine' : 'Tatlı Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.food),
                        languageCode: languageCode,
                        onRemoveIngredient: onRemoveIngredient,
                      ),
                      _TrayStationSlotCoaster(
                        slotIcon: Icons.grain_rounded,
                        emptyTitle: isEnglish ? '3. Twin Jar Slot' : '3. Kavanoz Yeri',
                        emptySubtitle: isEnglish ? 'Sugar or Salt?' : 'Şeker / Tuz Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.toppingOrPrank),
                        languageCode: languageCode,
                        onRemoveIngredient: onRemoveIngredient,
                      ),
                    ];

                    if (isNarrowTray) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          slots[0],
                          const SizedBox(height: 6),
                          slots[1],
                          const SizedBox(height: 6),
                          slots[2],
                        ],
                      );
                    }

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: slots[0]),
                          const SizedBox(width: 8),
                          Expanded(child: slots[1]),
                          const SizedBox(width: 8),
                          Expanded(child: slots[2]),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('serve_order_button'),
            onPressed: isTrayEmpty || isEvaluating ? null : onServeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E8E3E),
              disabledBackgroundColor: const Color(0xFF5D4037),
              foregroundColor: Colors.white,
              disabledForegroundColor: const Color(0xFFFFF8EE),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isTrayEmpty ? const Color(0xFFA1887F) : const Color(0xFF81C995),
                  width: 1.5,
                ),
              ),
            ),
            icon: isEvaluating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    isTrayEmpty ? Icons.touch_app_rounded : Icons.auto_awesome,
                    color: const Color(0xFFFFF8EE),
                  ),
            label: Text(
              isTrayEmpty
                  ? (isEnglish
                      ? 'Select Items Above to Serve & Ask Gemini Judge'
                      : 'Önce Raflardan Ürün Seçin · Siparişi Servis Et & Gemini Jürisine Sor!')
                  : (isEnglish ? 'Serve Order & Ask Gemini Judge!' : 'Siparişi Servis Et & Gemini Jürisine Sor!'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFFFF8EE),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrayStationSlotCoaster extends StatelessWidget {
  const _TrayStationSlotCoaster({
    required this.slotIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.ingredient,
    required this.languageCode,
    required this.onRemoveIngredient,
  });

  final IconData slotIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final CafeIngredient? ingredient;
  final String languageCode;
  final ValueChanged<CafeIngredient> onRemoveIngredient;

  @override
  Widget build(BuildContext context) {
    final platedItem = ingredient;
    if (platedItem == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFE4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD7CCC8)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: _trayItemImageSize,
              height: _trayItemImageSize,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE5DC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(slotIcon, size: 20, color: const Color(0xFF8D6E63)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    emptyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  Text(
                    emptySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => onRemoveIngredient(platedItem),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF34A853), width: 1.5),
        ),
        child: Row(
          children: <Widget>[
            _IngredientArtwork(
              ingredient: platedItem,
              size: _trayItemImageSize,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    platedItem.localizedTitle(languageCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.15,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.close_rounded, size: 15, color: Color(0xFF1B5E20)),
          ],
        ),
      ),
    );
  }
}

/// Stamped Gemini Verdict Receipt card with "Next Customer" progression.
class _CustomerReviewCard extends StatelessWidget {
  const _CustomerReviewCard({
    required this.review,
    required this.cityEdition,
    required this.languageCode,
    required this.onNextCustomer,
    super.key,
  });

  final CafeReview review;
  final CityEditionConfig cityEdition;
  final String languageCode;
  final VoidCallback onNextCustomer;

  @override
  Widget build(BuildContext context) {
    final currentReview = review;
    final isSabotage = currentReview.isPrankCaught;
    final isIncomplete = currentReview.isIncompleteTray;
    final isEnglish = languageCode == 'en';
    final cardColor = isSabotage
        ? const Color(0xFFFFF0F0)
        : isIncomplete
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFECFDF3);
    final borderColor = isSabotage
        ? const Color(0xFFC5221F)
        : isIncomplete
            ? const Color(0xFFE65100)
            : const Color(0xFF137333);

    return Container(
      key: const Key('customer_review_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedCafeCharacterAvatar(
            key: const Key('review_verdict_character_avatar'),
            portraitAssetPath: currentReview.customerFace.assetPath,
            mood: isSabotage ? CafeCharacterMood.saltySabotageShock : CafeCharacterMood.sweetCelebration,
            avatarSize: _customerAvatarSize,
            borderColor: borderColor,
            badgeEmoji: isSabotage ? '🧂💥' : (isIncomplete ? '🧩☕' : '🌟😍'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      '★' * currentReview.ratingStars + '☆' * (maxCafeRatingStars - currentReview.ratingStars),
                      key: const Key('review_stars_text'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                    Container(
                      key: const Key('review_verdict_badge'),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSabotage
                            ? const Color(0xFFFCE8E6)
                            : isIncomplete
                                ? const Color(0xFFFFECB3)
                                : const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSabotage
                              ? const Color(0xFFF28B82)
                              : isIncomplete
                                  ? const Color(0xFFFFB300)
                                  : const Color(0xFF81C995),
                        ),
                      ),
                      child: Text(
                        '${currentReview.ratingStars}/$maxCafeRatingStars · '
                        '${currentReview.localizedVerdictLabel(languageCode)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentReview.headline,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  currentReview.customerReaction,
                  key: const Key('review_reaction_text'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: <Widget>[
                    Text(
                      isEnglish
                          ? 'City: ${cityEdition.cityName} · Tip: +${currentReview.cityBonusTip} pts · '
                              'Judge: ${currentReview.isFromLiveGemini ? "Live Gemini 3.5 Flash-Lite" : "Offline JSON Schema"}'
                          : 'Şehir: ${cityEdition.cityName} · Bahşiş: +${currentReview.cityBonusTip}p · '
                              'Jüri: ${currentReview.isFromLiveGemini ? "Canlı Gemini 3.5 Flash-Lite" : "Yerel JSON Şeması"}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4E342E)),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onNextCustomer,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        isEnglish ? 'Serve Next Customer' : 'Sıradaki Müşteriye Geç',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
