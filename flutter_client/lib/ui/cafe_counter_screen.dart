import 'dart:math' as math;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/custom_svg_items.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/models/customer_order_ticket.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/cafe_sound_controller.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_controller.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_character_animations.dart';
import 'package:backyard_barista_cloudrun/ui/city_settings_drawer.dart';
import 'package:backyard_barista_cloudrun/ui/nfc_tag_writer_sheet.dart';
import 'package:backyard_barista_cloudrun/ui/subway_barista_flame_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const double _counterCardRadius = 20;
const double _trayItemImageSize = 42;
const double _customerAvatarSize = 76;
const double _maxDesktopContentWidth = 1360;
const double _awningScallopHeight = 12;
const double _awningTopBandHeightRatio = 0.55;
const double _photoCornerRadius = 14;
const double _wideArenaBreakpoint = 700;
const double _wideRunwayStageHeight = 264;
const double _compactRunwayStageHeight = 200;
const double _wideRunnerAvatarSize = 98;
const double _compactRunnerAvatarSize = 74;
const int _pointsPerCrewLevel = 100;
const int _pranksterRoundPoints = 30;
const int _incompleteRoundPoints = 15;
const int _baristaRoundPoints = 50;
const Duration _cardScaleDuration = Duration(milliseconds: 160);

/// Subway Surfers-inspired 3-Lane Arcade Cafe Scene powered by Flame (`SubwayBaristaFlameGame`),
/// Lottie animations, and `GoogleSans` typography.
class CafeCounterScreen extends StatefulWidget {
  const CafeCounterScreen({
    required this.cityController,
    required this.judgeService,
    this.nfcController,
    super.key,
  });

  final CityEditionController cityController;
  final CafeJudgeService judgeService;

  /// Injected in tests; the screen creates and owns a Web NFC controller otherwise.
  final NfcTagController? nfcController;

  @override
  State<CafeCounterScreen> createState() => _CafeCounterScreenState();
}

class _CafeCounterScreenState extends State<CafeCounterScreen> {
  final List<CafeIngredient> _selectedTray = <CafeIngredient>[];
  final CafeSoundController _soundController = CafeSoundController();
  late final SubwayBaristaFlameGame _flameGame;
  bool _includeRoundTwoCustomItems = true;
  bool _isEvaluatingOrder = false;
  bool _isCrewSippingTea = false;
  bool _isCustomerSippingTea = false;
  int _activeTicketIndex = 0;
  int _playerOneBaristaScore = 0;
  int _playerTwoPastryScore = 0;
  int _tipJarTotal = 0;
  CafeReview? _latestReview;
  late final NfcTagController _nfcController = widget.nfcController ?? NfcTagController();

  @override
  void initState() {
    super.initState();
    _flameGame = SubwayBaristaFlameGame(
      initialCityId: widget.cityController.activeCityId,
      onLaneTapped: _handleFlameLaneTapped,
      onSwipeServeRequested: _serveOrder,
    )..paused = isRunningInAutomatedWidgetTest;
    widget.cityController.addListener(_handleCityChanged);
    _nfcController.onIngredientTapped = _placeIngredientFromTag;
  }

  @override
  void dispose() {
    widget.cityController.removeListener(_handleCityChanged);
    _nfcController.onIngredientTapped = null;
    if (widget.nfcController == null) {
      _nfcController.dispose();
    }
    super.dispose();
  }

  void _syncFlameStage() {
    _flameGame.syncArcadeState(
      cityId: widget.cityController.activeCityId,
      selectedTray: _selectedTray,
      latestReview: _latestReview,
      isSippingTea: _isCrewSippingTea || _isCustomerSippingTea,
    );
  }

  void _handleFlameLaneTapped(int laneIndex) {
    final targetCategory = switch (laneIndex) {
      0 => IngredientCategory.drink,
      1 => IngredientCategory.food,
      _ => IngredientCategory.toppingOrPrank,
    };
    final itemsInLane = IngredientsCatalog.itemsForCategory(
      targetCategory,
      includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
    );
    if (itemsInLane.isEmpty) {
      setState(() {});
      return;
    }
    final currentInLane = _selectedTray.where((item) => item.category == targetCategory).firstOrNull;
    if (currentInLane == null) {
      _toggleIngredient(itemsInLane.first);
      return;
    }
    final currentIndex = itemsInLane.indexWhere((item) => item.id == currentInLane.id);
    final nextItem = itemsInLane[(currentIndex + 1) % itemsInLane.length];
    _toggleIngredient(nextItem);
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
      _syncFlameStage();
    });
  }

  List<CustomerOrderTicket> get _ticketsForActiveCity =>
      CustomerOrderTicket.ticketsForCity(widget.cityController.activeCityId);

  CustomerOrderTicket get _currentOrderTicket {
    final tickets = _ticketsForActiveCity;
    return tickets[_activeTicketIndex % tickets.length];
  }

  int get _crewLevel => 1 + ((_playerOneBaristaScore + _playerTwoPastryScore) ~/ _pointsPerCrewLevel);

  static const Set<String> _coffeeGrindIds = <String>{
    'espresso',
    'menengic_coffee',
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
      _syncFlameStage();
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
      _syncFlameStage();
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

  /// A tag tap only ever adds: holding the salt sticker twice must not take the salt back off.
  void _placeIngredientFromTag(CafeIngredient ingredient) {
    if (!mounted) {
      return;
    }
    final languageCode = widget.cityController.activeEdition.defaultLanguage;
    final ingredientTitle = ingredient.localizedTitle(languageCode);
    final isRoundTwoItem = IngredientsCatalog.roundTwoCustomItems.any((item) => item.id == ingredient.id);
    final isEnglish = languageCode == 'en';
    final String tapMessage;
    if (isRoundTwoItem && !_includeRoundTwoCustomItems) {
      tapMessage = isEnglish
          ? 'NFC: $ingredientTitle is a Round 2 item, switch Round 2 on first.'
          : 'NFC: $ingredientTitle 2. tur ürünü, önce 2. turu aç.';
    } else if (_selectedTray.any((existing) => existing.id == ingredient.id)) {
      tapMessage = isEnglish ? 'NFC: $ingredientTitle is already on the tray.' : 'NFC: $ingredientTitle zaten tepside.';
    } else {
      _toggleIngredient(ingredient);
      tapMessage = isEnglish ? 'NFC: $ingredientTitle added.' : 'NFC: $ingredientTitle eklendi.';
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('nfc_tap_snackbar'),
          content: Text(tapMessage),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _openNfcTagWriterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (sheetContext) => NfcTagWriterSheet(
        nfcController: _nfcController,
        languageCode: widget.cityController.activeEdition.defaultLanguage,
        appBaseUri: Uri.base,
      ),
    );
  }

  void _clearTray() {
    setState(() {
      _selectedTray.clear();
      _latestReview = null;
      _syncFlameStage();
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
      _syncFlameStage();
    });
    _soundController.play(CafeSoundCue.nextChime);
  }

  void _triggerCustomerTeaSip() {
    setState(() {
      _isCustomerSippingTea = true;
      _syncFlameStage();
    });
    _soundController.play(CafeSoundCue.teaSip);
  }

  void _handleCustomerTeaSipCompleted() {
    if (!mounted || !_isCustomerSippingTea) {
      return;
    }
    setState(() {
      _isCustomerSippingTea = false;
      _syncFlameStage();
    });
  }

  void _triggerCrewTeaSip() {
    setState(() {
      _isCrewSippingTea = true;
      _syncFlameStage();
    });
    _soundController.play(CafeSoundCue.teaSip);
  }

  void _handleCrewTeaSipCompleted() {
    if (!mounted || !_isCrewSippingTea) {
      return;
    }
    setState(() {
      _isCrewSippingTea = false;
      _syncFlameStage();
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
      _syncFlameStage();
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

        return Scaffold(
          backgroundColor: const Color(0xFF0B101B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E1525),
            foregroundColor: const Color(0xFFF3E5C8),
            elevation: 0,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Backyard Barista on Cloud Run',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    color: Color(0xFFF3E5C8),
                  ),
                ),
                Text(
                  '${activeEdition.cafeSubtitle} · ${activeEdition.signatureSpecialty}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              _NfcCounterMenuButton(
                nfcController: _nfcController,
                languageCode: languageCode,
                onOpenTagWriter: _openNfcTagWriterSheet,
              ),
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
                  color: const Color(0xFFD4AF37),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
                child: FilledButton.tonalIcon(
                  key: const Key('city_edition_switcher_button'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: const Color(0xFF7A1C1C),
                    foregroundColor: const Color(0xFFF3E5C8),
                    side: const BorderSide(color: Color(0xFFC59B27), width: 1.2),
                  ),
                  onPressed: _openCityEditionSheet,
                  icon: CityFlagBadge(editionId: activeEdition.editionId),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${activeEdition.cityName} Edition',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Full-bleed Universal Studios Hogsmeade Village, Hogwarts Express 5972 & Hogwarts Castle World Backdrop
              Positioned.fill(
                child: Image.asset(
                  CafeCharacterAssets.hogsmeadeUniversalStage,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.15),
                  errorBuilder: (context, error, stackTrace) {
                    return const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0xFF0B101B), Color(0xFF151E30)],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Subtle atmospheric Hogsmeade twilight vignette so HUD glass panels and golden text pop cleanly
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xB8090E1A),
                        Color(0x4D0B1220),
                        Color(0x330B1220),
                        Color(0xCC090E1A),
                      ],
                      stops: <double>[0, 0.28, 0.65, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: MagicalHogsmeadeAtmosphereOverlay(
                  platedItemCount: _selectedTray.length,
                  isSippingTea: _isCrewSippingTea || _isCustomerSippingTea,
                  hasActiveReview: latestReview != null,
                  isSabotageReview: latestReview?.isPrankCaught ?? false,
                ),
              ),
              Column(
                children: <Widget>[
                  const _ScallopedAwningEdge(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
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
                          onTriggerFiveSecondTeaSip: _triggerCrewTeaSip,
                          onSipTeaCompleted: _handleCrewTeaSipCompleted,
                          onTapCharacterEmote: _triggerCrewTeaSip,
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
                          onTriggerFiveSecondTeaSip: _triggerCustomerTeaSip,
                          onSipTeaCompleted: _handleCustomerTeaSipCompleted,
                          onTapCustomerCharacter: _triggerCustomerTeaSip,
                        );

                        final drinkItems = IngredientsCatalog.itemsForCategory(
                          IngredientCategory.drink,
                          includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                        );
                        final foodItems = IngredientsCatalog.itemsForCategory(
                          IngredientCategory.food,
                          includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                        );
                        final prankItems = IngredientsCatalog.itemsForCategory(
                          IngredientCategory.toppingOrPrank,
                          includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                        );

                        final flameRunwayStageWidget = _SubwayFlameRunwayStage(
                          flameGame: _flameGame,
                          languageCode: languageCode,
                          selectedTray: _selectedTray,
                          drinkItems: drinkItems,
                          foodItems: foodItems,
                          prankItems: prankItems,
                          onQuickDashLane: (int laneIndex) => _flameGame.dashToLane(laneIndex),
                          onSelectLaneIngredient: (int laneIndex, CafeIngredient ingredient) {
                            _flameGame.dashToLane(laneIndex, triggerCallback: false);
                            _toggleIngredient(ingredient);
                          },
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

                        return Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: _maxDesktopContentWidth),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  scoreboardWidget,
                                  const SizedBox(height: 6),
                                  soundboardWidget,
                                  const SizedBox(height: 8),
                                  customerStageWidget,
                                  const SizedBox(height: 8),
                                  flameRunwayStageWidget,
                                  const SizedBox(height: 8),
                                  woodenTrayWidget,
                                  const SizedBox(height: 8),
                                  reviewSwitcherWidget,
                                  const SizedBox(height: 8),
                                  crewStageWidget,
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
            ],
          ),
        );
      },
    );
  }
}

/// Hidden where Web NFC does not exist (desktop, iPhone), so the stage laptop UI is unchanged.
class _NfcCounterMenuButton extends StatelessWidget {
  const _NfcCounterMenuButton({
    required this.nfcController,
    required this.languageCode,
    required this.onOpenTagWriter,
  });

  final NfcTagController nfcController;
  final String languageCode;
  final VoidCallback onOpenTagWriter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: nfcController,
      builder: (context, _) {
        if (!nfcController.isSupported) {
          return const SizedBox.shrink();
        }
        final status = nfcController.status;
        final isScanning = status == NfcScanStatus.scanning;
        final errorMessage = nfcController.lastErrorMessage;
        final isEnglish = languageCode == 'en';
        final listeningLabel = isEnglish ? 'NFC counter is listening' : 'NFC tezgâhı dinliyor';
        return PopupMenuButton<VoidCallback>(
          key: const Key('nfc_counter_menu_button'),
          tooltip: errorMessage ?? (isScanning ? listeningLabel : (isEnglish ? 'NFC counter' : 'NFC tezgâhı')),
          onSelected: (action) => action(),
          icon: Icon(
            status == NfcScanStatus.failed ? Icons.nfc_rounded : Icons.contactless_rounded,
            size: 20,
            color: switch (status) {
              NfcScanStatus.scanning => const Color(0xFF8BE28B),
              NfcScanStatus.failed => const Color(0xFFFF8A80),
              NfcScanStatus.idle || NfcScanStatus.unsupported => const Color(0xFFFFCCBC),
            },
          ),
          itemBuilder: (context) => <PopupMenuEntry<VoidCallback>>[
            PopupMenuItem<VoidCallback>(
              key: const Key('nfc_start_scanning_item'),
              enabled: !isScanning,
              value: nfcController.startScanning,
              child: Text(isScanning ? listeningLabel : (isEnglish ? 'Start NFC counter' : 'NFC tezgâhını başlat')),
            ),
            PopupMenuItem<VoidCallback>(
              key: const Key('nfc_open_writer_item'),
              value: onOpenTagWriter,
              child: Text(isEnglish ? 'Write ingredient tags' : 'Malzeme etiketlerini yaz'),
            ),
          ],
        );
      },
    );
  }
}

/// Full-Stage 3-Lane Flame Courtyard Game Arena with in-lane item pickup medallions.
class _SubwayFlameRunwayStage extends StatelessWidget {
  const _SubwayFlameRunwayStage({
    required this.flameGame,
    required this.languageCode,
    required this.selectedTray,
    required this.drinkItems,
    required this.foodItems,
    required this.prankItems,
    required this.onQuickDashLane,
    required this.onSelectLaneIngredient,
  });

  final SubwayBaristaFlameGame flameGame;
  final String languageCode;
  final List<CafeIngredient> selectedTray;
  final List<CafeIngredient> drinkItems;
  final List<CafeIngredient> foodItems;
  final List<CafeIngredient> prankItems;
  final ValueChanged<int> onQuickDashLane;
  final void Function(int laneIndex, CafeIngredient ingredient) onSelectLaneIngredient;

  @override
  Widget build(BuildContext context) {
    final isEnglish = languageCode == 'en';
    final selectedTrayCount = selectedTray.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideArena = constraints.maxWidth >= _wideArenaBreakpoint;

        final laneZeroDock = _FlameLanePickupColumn(
          laneIndex: 0,
          category: IngredientCategory.drink,
          laneTitle: isEnglish ? 'STATION 1 · PICK DRINK ☕' : '1. İSTASYON · KAHVE SEÇ ☕',
          accentColor: const Color(0xFFE08E45),
          ingredients: drinkItems,
          selectedTray: selectedTray,
          languageCode: languageCode,
          onSelectIngredient: (item) => onSelectLaneIngredient(0, item),
        );

        final laneOneDock = _FlameLanePickupColumn(
          laneIndex: 1,
          category: IngredientCategory.food,
          laneTitle: isEnglish ? 'STATION 2 · PICK PASTRY 🥮' : '2. İSTASYON · TATLI SEÇ 🥮',
          accentColor: const Color(0xFFD4AF37),
          ingredients: foodItems,
          selectedTray: selectedTray,
          languageCode: languageCode,
          onSelectIngredient: (item) => onSelectLaneIngredient(1, item),
        );

        final laneTwoDock = _FlameLanePickupColumn(
          laneIndex: 2,
          category: IngredientCategory.toppingOrPrank,
          laneTitle: isEnglish ? 'STATION 3 · SUGAR OR SALT? 🧂' : '3. İSTASYON · ŞEKER Mİ TUZ MU? 🧂',
          accentColor: const Color(0xFF4E9F6E),
          ingredients: prankItems,
          selectedTray: selectedTray,
          languageCode: languageCode,
          onSelectIngredient: (item) => onSelectLaneIngredient(2, item),
        );

        return Container(
          key: const Key('subway_barista_flame_stage'),
          decoration: BoxDecoration(
            color: const Color(0x990D1422),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x77000000),
                blurRadius: 22,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Interactive 3-Lane Universal Studios Hogsmeade & Hogwarts Castle Stage
                SizedBox(
                  height: isWideArena ? _wideRunwayStageHeight : _compactRunwayStageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Panoramic Universal Studios Hogsmeade Village + Hogwarts Express 5972 + Hogwarts Castle backdrop
                      Image.asset(
                        CafeCharacterAssets.hogsmeadeUniversalStage,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.22),
                        errorBuilder: (context, error, stackTrace) {
                          return const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[Color(0xFF0F172A), Color(0xFF1E150F)],
                              ),
                            ),
                          );
                        },
                      ),
                      GameWidget<SubwayBaristaFlameGame>(
                        game: flameGame,
                      ),
                      // 3D Generated Harry Potter Runner Character gliding across the 3 lanes
                      IgnorePointer(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutBack,
                          alignment: Alignment(
                            (flameGame.activeRunnerLane - 1) * 0.60,
                            0.36,
                          ),
                          child: _HarryPotterLaneRunnerAvatar(
                            selectedTray: selectedTray,
                            isWideArena: isWideArena,
                          ),
                        ),
                      ),
                      // Top HUD overlay inside the Flame Courtyard Stage: 3 interactive lane signs
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _RunwayLaneQuickPill(
                                laneKey: const Key('flame_lane_pill_0'),
                                label: isEnglish ? '1 · COFFEE LANE ☕' : 'HAT 1 · KAHVE ☕',
                                accentColor: const Color(0xFFE08E45),
                                backgroundColor: const Color(0xCC11192B),
                                onTap: () => onQuickDashLane(0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RunwayLaneQuickPill(
                                laneKey: const Key('flame_lane_pill_1'),
                                label: isEnglish ? '2 · PASTRY LANE 🥮' : 'HAT 2 · TATLI 🥮',
                                accentColor: const Color(0xFFD4AF37),
                                backgroundColor: const Color(0xCC11192B),
                                onTap: () => onQuickDashLane(1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RunwayLaneQuickPill(
                                laneKey: const Key('flame_lane_pill_2'),
                                label: isEnglish ? '3 · TWIN JARS 🧂' : 'HAT 3 · KAVANOZ 🧂',
                                accentColor: const Color(0xFF4E9F6E),
                                backgroundColor: const Color(0xCC11192B),
                                onTap: () => onQuickDashLane(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 10,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0F172A),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFD4AF37)),
                            ),
                            child: Text(
                              isEnglish
                                  ? '🏃‍♀️ SWIPE / TAP LANES OR PICK TOKENS BELOW ($selectedTrayCount/3)'
                                  : '🏃‍♀️ KULVARI KAYDIR VEYA ALTTAN ÜRÜN YAKALA ($selectedTrayCount/3)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF3E5C8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Integrated 3-Lane In-Game Pickup Medallion Dock directly at the foot of the 3 lanes
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xCC0E1525),
                    border: Border(
                      top: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    ),
                  ),
                  child: isWideArena
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(child: laneZeroDock),
                              const SizedBox(width: 10),
                              Expanded(child: laneOneDock),
                              const SizedBox(width: 10),
                              Expanded(child: laneTwoDock),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            laneZeroDock,
                            const SizedBox(height: 8),
                            laneOneDock,
                            const SizedBox(height: 8),
                            laneTwoDock,
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 3D Generated Harry Potter Wizard Character token gliding across the 3 Hogwarts lanes with a carved oak tray
/// and 60fps Wingardium Leviosa levitation + Lottie spell aura.
class _HarryPotterLaneRunnerAvatar extends StatefulWidget {
  const _HarryPotterLaneRunnerAvatar({
    required this.selectedTray,
    required this.isWideArena,
  });

  final List<CafeIngredient> selectedTray;
  final bool isWideArena;

  @override
  State<_HarryPotterLaneRunnerAvatar> createState() => _HarryPotterLaneRunnerAvatarState();
}

class _HarryPotterLaneRunnerAvatarState extends State<_HarryPotterLaneRunnerAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _levitationController;

  @override
  void initState() {
    super.initState();
    _levitationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (isRunningInAutomatedWidgetTest) {
      _levitationController.value = 0.5;
    } else {
      _levitationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _levitationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = widget.isWideArena ? _wideRunnerAvatarSize : _compactRunnerAvatarSize;
    final hasDrink = widget.selectedTray.any((item) => item.category == IngredientCategory.drink);
    final hasFood = widget.selectedTray.any((item) => item.category == IngredientCategory.food);
    final hasTopping = widget.selectedTray.any(
      (item) => item.category == IngredientCategory.toppingOrPrank,
    );
    final hasStealthPrank = widget.selectedTray.any((item) => item.isPrankItem);
    final platedCount = widget.selectedTray.length;
    final lottieAsset = hasStealthPrank
        ? CafeAnimationAssets.saltySpicyExplosion
        : platedCount >= 3
            ? CafeAnimationAssets.sweetCelebrationBurst
            : platedCount > 0
                ? CafeAnimationAssets.baristaBrewingPulse
                : CafeAnimationAssets.coffeeSteamLoop;

    return AnimatedBuilder(
      animation: _levitationController,
      builder: (context, child) {
        final hoverOffset = (0.5 - _levitationController.value) * 9.0;
        final auraScale = 1.0 + (_levitationController.value * 0.06);
        return Transform.translate(
          offset: Offset(0, hoverOffset),
          child: Transform.scale(
            scale: auraScale,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              SizedBox(
                width: avatarSize * 1.32,
                height: avatarSize * 1.32,
                child: Lottie.asset(
                  lottieAsset,
                  repeat: !isRunningInAutomatedWidgetTest,
                  animate: !isRunningInAutomatedWidgetTest,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: platedCount >= 3 ? const Color(0xFFFFE082) : const Color(0xFFD4AF37),
                    width: 3.2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: platedCount > 0 ? const Color(0xCCD4AF37) : const Color(0x99D4AF37),
                      blurRadius: platedCount > 0 ? 24 : 18,
                      spreadRadius: platedCount > 0 ? 4 : 2,
                    ),
                    const BoxShadow(
                      color: Color(0xAA000000),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    CafeCharacterAssets.harryPotterStageRunner,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(
                        color: Color(0xFF2B1B10),
                        child: Icon(
                          Icons.auto_fix_high_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xEE141D30),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
                  ),
                  child: Text(
                    platedCount >= 3 ? '✨ Wingardium!' : '🪄 Lumos',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFECB3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xEE11192B),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '⚡ Harry',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF3E5C8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _MiniTrayDot(isPlated: hasDrink, activeColor: const Color(0xFFE08E45)),
                  const SizedBox(width: 4),
                  _MiniTrayDot(isPlated: hasFood, activeColor: const Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  _MiniTrayDot(isPlated: hasTopping, activeColor: const Color(0xFF4E9F6E)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTrayDot extends StatelessWidget {
  const _MiniTrayDot({
    required this.isPlated,
    required this.activeColor,
  });

  final bool isPlated;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlated ? activeColor : const Color(0x38FFFFFF),
        border: Border.all(color: const Color(0xFFF3E5C8), width: 1.2),
      ),
    );
  }
}

/// Compact in-lane pickup dock aligned directly beneath one of the 3 Flame Courtyard lanes.
class _FlameLanePickupColumn extends StatelessWidget {
  const _FlameLanePickupColumn({
    required this.laneIndex,
    required this.category,
    required this.laneTitle,
    required this.accentColor,
    required this.ingredients,
    required this.selectedTray,
    required this.languageCode,
    required this.onSelectIngredient,
  });

  final int laneIndex;
  final IngredientCategory category;
  final String laneTitle;
  final Color accentColor;
  final List<CafeIngredient> ingredients;
  final List<CafeIngredient> selectedTray;
  final String languageCode;
  final ValueChanged<CafeIngredient> onSelectIngredient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC141D30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.80), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Tooltip(
              message: category.localizedTitle(languageCode),
              child: Text(
                laneTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ingredients.map((ingredient) {
              final isSelected = selectedTray.any((item) => item.id == ingredient.id);
              return _InLanePickupMedallion(
                ingredient: ingredient,
                languageCode: languageCode,
                isSelected: isSelected,
                accentColor: accentColor,
                onTap: () => onSelectIngredient(ingredient),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Compact tactile game token (`Key('ingredient_card_${ingredient.id}')`) replacing the old 166px shelf cards.
class _InLanePickupMedallion extends StatelessWidget {
  const _InLanePickupMedallion({
    required this.ingredient,
    required this.languageCode,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final CafeIngredient ingredient;
  final String languageCode;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? const Color(0xF01E4231) : const Color(0xE6182234);
    final borderColor = isSelected ? const Color(0xFFD4AF37) : accentColor.withValues(alpha: 0.72);
    final titleText = ingredient.localizedTitle(languageCode);
    final subtitleText = ingredient.localizedSubtitle(languageCode);

    return Tooltip(
      message: '$titleText · $subtitleText',
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: _cardScaleDuration,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            key: Key('ingredient_card_${ingredient.id}'),
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.0 : 1.3,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _IngredientArtwork(
                    ingredient: ingredient,
                    size: 26,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? const Color(0xFFFFEBA8) : const Color(0xFFF3E5C8),
                      ),
                    ),
                  ),
                  if (isSelected) ...<Widget>[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFFD4AF37),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunwayLaneQuickPill extends StatelessWidget {
  const _RunwayLaneQuickPill({
    required this.laneKey,
    required this.label,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final Key laneKey;
  final String label;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: laneKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accentColor, width: 1.3),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative Hogwarts / Gryffindor crimson velvet & antique gold banner valance beneath the AppBar.
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
    final crimsonVelvetPaint = Paint()..color = const Color(0xFF6E1919);
    final antiqueGoldPaint = Paint()..color = const Color(0xFFB5892E);

    var index = 0;
    for (var stripeOffsetX = 0.0; stripeOffsetX < size.width; stripeOffsetX += stripeWidth) {
      final paint = index.isEven ? crimsonVelvetPaint : antiqueGoldPaint;
      final currentWidth = (stripeOffsetX + stripeWidth > size.width) ? (size.width - stripeOffsetX) : stripeWidth;
      canvas
        ..drawRect(
          Rect.fromLTWH(stripeOffsetX, 0, currentWidth, size.height * _awningTopBandHeightRatio),
          paint,
        )
        ..drawArc(
          Rect.fromLTWH(stripeOffsetX, 0, currentWidth, size.height),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC59B27), width: 1.6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
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
                  CityFlagBadge(editionId: cityEdition.editionId),
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
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: Color(0xFFF3E5C8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E2016),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFC59B27)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFFD4AF37)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _friendlySourceBadgeLabel(isEnglish),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEAD8B8),
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
                            color: Color(0xFFC9B086),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A2912),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 5),
                      Text(
                        'Lv.$crewLevel Barista',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFFF3E5C8),
                        ),
                      ),
                    ],
                  ),
                ),
                _ScorePill(
                  icon: Icons.coffee_rounded,
                  label: isEnglish ? 'P1 Barista: $playerOneScore' : 'O1 Barista: $playerOneScore',
                  backgroundColor: const Color(0xFF381916),
                  textColor: const Color(0xFFE8C187),
                ),
                _ScorePill(
                  icon: Icons.bakery_dining_rounded,
                  label: isEnglish ? 'P2 Pastry: $playerTwoScore' : 'O2 Tatlı: $playerTwoScore',
                  backgroundColor: const Color(0xFF1A2D22),
                  textColor: const Color(0xFFA5D1B4),
                ),
                _ScorePill(
                  icon: Icons.savings_rounded,
                  label: isEnglish ? 'Tips: +$tipJarTotal pts' : 'Bahşiş: +${tipJarTotal}p',
                  backgroundColor: const Color(0xFF332512),
                  textColor: const Color(0xFFD4AF37),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 4, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                    color: includeRoundTwoItems ? const Color(0xFF1D3326) : const Color(0xFF2B1E15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: includeRoundTwoItems ? const Color(0xFFC59B27) : const Color(0xFF7D623C),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: includeRoundTwoItems ? const Color(0xFFD4AF37) : const Color(0xFFC9B086),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isEnglish ? 'Round 2 AI Menu:' : 'Tur 2 Özel Menü:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: includeRoundTwoItems ? const Color(0xFFF3E5C8) : const Color(0xFFC9B086),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 28,
                        child: FittedBox(
                          child: Switch(
                            key: const Key('round_two_custom_items_switch'),
                            value: includeRoundTwoItems,
                            activeThumbColor: const Color(0xFFF3E5C8),
                            activeTrackColor: const Color(0xFF3B7A57),
                            inactiveThumbColor: const Color(0xFFC9B086),
                            inactiveTrackColor: const Color(0xFF3D2B1F),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xB80E1525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9C7A2E)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: <Widget>[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: <Widget>[
                const Icon(Icons.graphic_eq_rounded, size: 15, color: Color(0xFFC59B27)),
                Text(
                  isTurkish ? 'Kafe Ses Efektleri:' : 'Barista Soundboard:',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEAD8B8),
                  ),
                ),
                Container(
                  key: const Key('active_web_audio_cue_badge'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1F15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF9C7A2E)),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3E5C8),
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 4,
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
      color: const Color(0xFF2B1E14),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: buttonKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF9C7A2E)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 12, color: const Color(0xFFD4AF37)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF3E5C8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF9C7A2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 1 of the Cafe Loop: Gothic Arched Customer Window + Hogwarts Parchment Order Scroll.
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
      if (currentReview.isPrankCaught) {
        return CafeCharacterMood.saltySabotageShock;
      }
      if (currentReview.isIncompleteTray) {
        return CafeCharacterMood.talkingOrder;
      }
      return CafeCharacterMood.sweetCelebration;
    }
    if (selectedTray.isNotEmpty) {
      return CafeCharacterMood.brewingActive;
    }
    return CafeCharacterMood.talkingOrder;
  }

  String get _activeCustomerPortraitAsset {
    final currentReview = latestReview;
    if (currentReview != null && (currentReview.isPrankCaught || currentReview.isIncompleteTray)) {
      return currentReview.customerFace.assetPath;
    }
    return ticket.portraitAssetPath;
  }

  @override
  Widget build(BuildContext context) {
    final currentReview = latestReview;
    final windowBorderColor = currentReview == null
        ? const Color(0xFFC59B27)
        : currentReview.isPrankCaught
            ? const Color(0xFF9E2A2B)
            : currentReview.isIncompleteTray
                ? const Color(0xFFC59B27)
                : const Color(0xFF3B7A57);
    final effectiveRequestedIds = ticket.effectiveRequestedIngredientIds(
      includeRoundTwoItems: includeRoundTwoItems,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC59B27), width: 1.8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Gothic Arched Customer Tavern Window + Lottie Aura + 5s Turkish Tea Glass Sipping
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
          const SizedBox(width: 12),
          // Hogsmeade Midnight & Gold Customer Order Scroll Overlay with Crimson Wax Seal
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xD9162032),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC59B27), width: 1.4),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Crimson Hogwarts Wax Seal emblem
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7A1C1C),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 10,
                                color: Color(0xFFF3E5C8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${languageCode == 'en' ? 'Customer' : 'Müşteri'} #${ticket.ticketNumber}/$totalTickets · '
                                '${ticket.customerName} (${ticket.localizedRole(languageCode)})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: Color(0xFFF3E5C8),
                                ),
                              ),
                            ),
                          ],
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
                                    isCustomerSippingTea ? const Color(0xFF7A1C1C) : const Color(0xFF281A14),
                                foregroundColor: const Color(0xFFF3E5C8),
                                side: const BorderSide(color: Color(0xFFC59B27)),
                              ),
                              onPressed: onTriggerFiveSecondTeaSip,
                              icon: const Icon(Icons.emoji_food_beverage_rounded, size: 14, color: Color(0xFFD4AF37)),
                              label: Text(
                                isCustomerSippingTea
                                    ? (languageCode == 'en' ? 'Sipping Tea (5s)...' : 'Çay Yudumluyor (5sn)...')
                                    : (languageCode == 'en' ? 'Sip Tea (5s)' : '5sn Çay Yudumlat'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton.icon(
                              key: const Key('next_customer_button'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: const Color(0xFFD4AF37),
                              ),
                              onPressed: onNextCustomer,
                              icon: const Icon(Icons.skip_next_rounded, size: 16),
                              label: Text(
                                languageCode == 'en' ? 'Next Customer' : 'Sıradaki Müşteri',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEAD8B8),
                    ),
                  ),
                  if (isCustomerSippingTea) ...<Widget>[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xE6381619),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        languageCode == 'en'
                            ? '"🫖 Siiip... Enjoying my hot Turkish tulip-glass tea for 5 seconds! Ohhh! ✨"'
                            : '"🫖 Hüüüp... İnce belli bardakta tavşan kanı çayımı 5 saniye keyifle yudumluyorum! Ohhh! ✨"',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF3E5C8),
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
                      final exactMatch = selectedTray.any((item) => item.id == requestedIngredientId);
                      final categoryMatch = ingredient != null
                          ? selectedTray
                              .where((item) => item.category == ingredient.category && !item.isPrankItem)
                              .firstOrNull
                          : null;
                      final isStationSatisfied = exactMatch || categoryMatch != null;
                      final displayedIngredient = exactMatch ? ingredient : (categoryMatch ?? ingredient);
                      final labelText = displayedIngredient?.localizedTitle(languageCode) ?? requestedIngredientId;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isStationSatisfied ? const Color(0xF01E4231) : const Color(0xE61E2B42),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isStationSatisfied ? const Color(0xFFD4AF37) : const Color(0xFF9C7A44),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isStationSatisfied ? Icons.check_circle_rounded : Icons.circle_outlined,
                              size: 13,
                              color: isStationSatisfied ? const Color(0xFFD4AF37) : const Color(0xFFC9B086),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                labelText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isStationSatisfied ? const Color(0xFFFFEBA8) : const Color(0xFFF3E5C8),
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
              color: Color(0x28000000),
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
              return Icon(Icons.local_cafe, size: size, color: const Color(0xFFC59B27));
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

    return Icon(Icons.local_cafe, size: size, color: const Color(0xFFC59B27));
  }
}

/// Step 3 of the Cafe Loop: Carved Oak & Brass Serving Tray with 3D Crimson-Wax & Gold Serve Button.
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
        color: const Color(0xCC0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Hogsmeade Dark Obsidian & Brass inner tray mat with 3 dedicated station coasters
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xD9162032),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC59B27), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.room_service_rounded, color: Color(0xFFD4AF37), size: 20),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFFF3E5C8),
                        ),
                      ),
                    ),
                    if (hasStealthPrankOnTray)
                      Container(
                        key: const Key('stealth_prank_wink_badge'),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF381916),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFD4AF37)),
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
                          foregroundColor: const Color(0xFFD4AF37),
                        ),
                        onPressed: onClearTray,
                        child: Text(
                          isEnglish ? 'Clear' : 'Temizle',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
                        emptySubtitle: isEnglish ? 'Tap Coffee Lane' : 'Kahve Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.drink),
                        languageCode: languageCode,
                        accentColor: const Color(0xFFE08E45),
                        onRemoveIngredient: onRemoveIngredient,
                      ),
                      _TrayStationSlotCoaster(
                        slotIcon: Icons.bakery_dining_rounded,
                        emptyTitle: isEnglish ? '2. Pastry Slot' : '2. Tatlı Yeri',
                        emptySubtitle: isEnglish ? 'Tap Pastry Lane' : 'Tatlı Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.food),
                        languageCode: languageCode,
                        accentColor: const Color(0xFFD4AF37),
                        onRemoveIngredient: onRemoveIngredient,
                      ),
                      _TrayStationSlotCoaster(
                        slotIcon: Icons.science_rounded,
                        emptyTitle: isEnglish ? '3. Twin Jar Slot' : '3. Kavanoz Yeri',
                        emptySubtitle: isEnglish ? 'Sugar or Salt?' : 'Şeker / Tuz Seçilmedi',
                        ingredient: _itemForCategory(IngredientCategory.toppingOrPrank),
                        languageCode: languageCode,
                        accentColor: const Color(0xFF4E9F6E),
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
          // Chunky 3D Crimson-Wax & Antique Gold Game Action Button
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: isTrayEmpty ? const Color(0xFF17100B) : const Color(0xFF420D0D),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              key: const Key('serve_order_button'),
              onPressed: isTrayEmpty || isEvaluating ? null : onServeOrder,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A1C1C),
                disabledBackgroundColor: const Color(0xFF332419),
                foregroundColor: const Color(0xFFF3E5C8),
                disabledForegroundColor: const Color(0xFFB8A282),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isTrayEmpty ? const Color(0xFF7D623C) : const Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
              icon: isEvaluating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF3E5C8)),
                    )
                  : Icon(
                      isTrayEmpty ? Icons.auto_fix_high_rounded : Icons.room_service_rounded,
                      color: const Color(0xFFD4AF37),
                    ),
              label: Text(
                isTrayEmpty
                    ? (isEnglish
                        ? 'Select Items Above to Serve & Ask Gemini Judge'
                        : 'Önce Raflardan Ürün Seçin · Siparişi Servis Et & Gemini Jürisine Sor!')
                    : (isEnglish ? 'Serve Order & Ask Gemini Judge!' : 'Siparişi Servis Et & Gemini Jürisine Sor!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFFF3E5C8),
                ),
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
    required this.accentColor,
    required this.onRemoveIngredient,
  });

  final IconData slotIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final CafeIngredient? ingredient;
  final String languageCode;
  final Color accentColor;
  final ValueChanged<CafeIngredient> onRemoveIngredient;

  @override
  Widget build(BuildContext context) {
    final platedItem = ingredient;
    if (platedItem == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xE61D2A40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.72), width: 1.3),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: _trayItemImageSize,
              height: _trayItemImageSize,
              decoration: BoxDecoration(
                color: const Color(0xCC11192B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.65)),
              ),
              child: Icon(slotIcon, size: 20, color: accentColor),
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    emptySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC9B086),
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
          color: const Color(0xF01E4231),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      height: 1.15,
                      color: Color(0xFFF3E5C8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.close_rounded, size: 15, color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }
}

/// Hogwarts Wax-Sealed Gemini Verdict Scroll Card with "Next Customer" progression.
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
        ? const Color(0xEB2A1417)
        : isIncomplete
            ? const Color(0xEB261E12)
            : const Color(0xEB12281D);
    final borderColor = isSabotage
        ? const Color(0xFF9E2A2B)
        : isIncomplete
            ? const Color(0xFFD4AF37)
            : const Color(0xFF3B7A57);

    return Container(
      key: const Key('customer_review_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedCafeCharacterAvatar(
            key: const Key('review_verdict_character_avatar'),
            portraitAssetPath: currentReview.customerFace.assetPath,
            mood: isSabotage
                ? CafeCharacterMood.saltySabotageShock
                : isIncomplete
                    ? CafeCharacterMood.talkingOrder
                    : CafeCharacterMood.sweetCelebration,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    Container(
                      key: const Key('review_verdict_badge'),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        '${currentReview.ratingStars}/$maxCafeRatingStars · '
                        '${currentReview.localizedVerdictLabel(languageCode)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF3E5C8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentReview.headline,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFF3E5C8)),
                ),
                const SizedBox(height: 6),
                Text(
                  currentReview.customerReaction,
                  key: const Key('review_reaction_text'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEAD8B8)),
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
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC9B086)),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: borderColor,
                        foregroundColor: const Color(0xFFF3E5C8),
                      ),
                      onPressed: onNextCustomer,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        isEnglish ? 'Serve Next Customer' : 'Sıradaki Müşteriye Geç',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
