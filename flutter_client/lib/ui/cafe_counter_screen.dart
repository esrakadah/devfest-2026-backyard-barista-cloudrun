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
const double _ingredientImageSize = 68;
const double _trayItemImageSize = 46;
const double _customerAvatarSize = 76;
const double _mobileBreakpointWidth = 620;
const double _gridSpacing = 12;
const double _desktopCardWidth = 178;
const double _awningScallopHeight = 14;
const double _awningTopBandHeightRatio = 0.55;
const double _photoCornerRadius = 14;
const int _pranksterRoundPoints = 30;
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
      _latestReview = null;
    });
  }

  List<CustomerOrderTicket> get _ticketsForActiveCity =>
      CustomerOrderTicket.ticketsForCity(widget.cityController.activeCityId);

  CustomerOrderTicket get _currentOrderTicket {
    final tickets = _ticketsForActiveCity;
    return tickets[_activeTicketIndex % tickets.length];
  }

  void _toggleIngredient(CafeIngredient ingredient) {
    final isRemoving = _selectedTray.any((existing) => existing.id == ingredient.id);
    setState(() {
      if (isRemoving) {
        _selectedTray.removeWhere((existing) => existing.id == ingredient.id);
      } else {
        _selectedTray.add(ingredient);
      }
    });
    if (!isRemoving && ingredient.isPrankItem) {
      _soundController.play(CafeSoundCue.stealthWink);
    } else {
      _soundController.play(CafeSoundCue.tapPop);
    }
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
    });
    _soundController.play(CafeSoundCue.nextChime);
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
    setState(() {
      _isEvaluatingOrder = false;
      _latestReview = review;
      _tipJarTotal += review.cityBonusTip;
      if (review.isPrankCaught) {
        _playerTwoPastryScore += _pranksterRoundPoints;
      } else {
        _playerOneBaristaScore += _baristaRoundPoints;
        _playerTwoPastryScore += _baristaRoundPoints;
      }
    });
    _soundController.play(
      review.isPrankCaught ? CafeSoundCue.saltyBuzzer : CafeSoundCue.sweetFanfare,
    );
  }

  void _openCityEditionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                child: FilledButton.tonalIcon(
                  key: const Key('city_edition_switcher_button'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: const Color(0xFFC85A32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _openCityEditionSheet,
                  icon: Text(
                    activeEdition.flagEmoji,
                    style: const TextStyle(fontSize: 15),
                  ),
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
                    final availableContentWidth = constraints.maxWidth - 32;
                    final isMobileViewport = constraints.maxWidth < _mobileBreakpointWidth;
                    final cardWidth = isMobileViewport
                        ? ((availableContentWidth - _gridSpacing) / 2).clamp(
                            120.0,
                            _desktopCardWidth,
                          )
                        : _desktopCardWidth;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _ScoreboardAndConfigBar(
                            cityEdition: activeEdition,
                            sourceLayer: widget.cityController.activeSourceLayer,
                            playerOneScore: _playerOneBaristaScore,
                            playerTwoScore: _playerTwoPastryScore,
                            tipJarTotal: _tipJarTotal,
                            includeRoundTwoItems: _includeRoundTwoCustomItems,
                            onToggleRoundTwoItems: (enabled) {
                              setState(() {
                                _includeRoundTwoCustomItems = enabled;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          CafeCrewCharacterStage(
                            languageCode: languageCode,
                            selectedTray: _selectedTray,
                            latestReview: latestReview,
                            playerOneScore: _playerOneBaristaScore,
                            playerTwoScore: _playerTwoPastryScore,
                            onTapCharacterEmote: () {
                              _soundController.play(CafeSoundCue.tapPop);
                            },
                          ),
                          const SizedBox(height: 14),
                          _CustomerOrderStage(
                            ticket: currentTicket,
                            totalTickets: totalTickets,
                            languageCode: languageCode,
                            selectedTray: _selectedTray,
                            latestReview: latestReview,
                            onNextCustomer: _advanceToNextCustomer,
                            onTapCustomerCharacter: () {
                              _soundController.play(CafeSoundCue.tapPop);
                            },
                          ),
                          const SizedBox(height: 16),
                          for (final category in IngredientCategory.values) ...<Widget>[
                            _CafeStationShelf(
                              category: category,
                              languageCode: languageCode,
                              ingredients: IngredientsCatalog.itemsForCategory(
                                category,
                                includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                              ),
                              selectedTray: _selectedTray,
                              requestedIngredientIds: currentTicket.requestedIngredientIds,
                              cardWidth: cardWidth,
                              onToggleIngredient: _toggleIngredient,
                            ),
                            const SizedBox(height: 14),
                          ],
                          _InteractiveWoodenTray(
                            selectedTray: _selectedTray,
                            languageCode: languageCode,
                            isEvaluating: _isEvaluatingOrder,
                            onRemoveIngredient: _toggleIngredient,
                            onServeOrder: _serveOrder,
                            onClearTray: _clearTray,
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
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
                          ),
                        ],
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
      canvas.drawRect(
        Rect.fromLTWH(x, 0, currentWidth, size.height * _awningTopBandHeightRatio),
        paint,
      );
      canvas.drawArc(
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
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.tipJarTotal,
    required this.includeRoundTwoItems,
    required this.onToggleRoundTwoItems,
  });

  final CityEditionConfig cityEdition;
  final CityConfigSourceLayer sourceLayer;
  final int playerOneScore;
  final int playerTwoScore;
  final int tipJarTotal;
  final bool includeRoundTwoItems;
  final ValueChanged<bool> onToggleRoundTwoItems;

  @override
  Widget build(BuildContext context) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${cityEdition.flagEmoji} ${cityEdition.eventTitle}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF2C1A12),
                ),
              ),
              Text(
                sourceLayer.displayLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _ScorePill(
                icon: Icons.coffee_rounded,
                label: 'P1 Barista: $playerOneScore',
                backgroundColor: const Color(0xFFEFE5DC),
                textColor: const Color(0xFF3E2723),
              ),
              _ScorePill(
                icon: Icons.bakery_dining_rounded,
                label: 'P2 Pastry: $playerTwoScore',
                backgroundColor: const Color(0xFFFCE8E0),
                textColor: const Color(0xFF8D3218),
              ),
              _ScorePill(
                icon: Icons.savings_rounded,
                label: 'Tips: +$tipJarTotal pts',
                backgroundColor: const Color(0xFFE6F4EA),
                textColor: const Color(0xFF137333),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Round 2 AI SVGs:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  Switch(
                    key: const Key('round_two_custom_items_switch'),
                    value: includeRoundTwoItems,
                    onChanged: onToggleRoundTwoItems,
                  ),
                ],
              ),
            ],
          ),
        ],
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
    required this.selectedTray,
    required this.latestReview,
    required this.onNextCustomer,
    required this.onTapCustomerCharacter,
  });

  final CustomerOrderTicket ticket;
  final int totalTickets;
  final String languageCode;
  final List<CafeIngredient> selectedTray;
  final CafeReview? latestReview;
  final VoidCallback onNextCustomer;
  final VoidCallback onTapCustomerCharacter;

  CafeCharacterMood get _customerMood {
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
          // Animated Arched Customer Cafe Window + Lottie Aura
          AnimatedCafeCharacterAvatar(
            key: const Key('customer_arch_character_avatar'),
            portraitAssetPath: _activeCustomerPortraitAsset,
            mood: _customerMood,
            avatarSize: _customerAvatarSize,
            borderColor: windowBorderColor,
            badgeEmoji: ticket.characterBadgeEmoji,
            isArchedWindow: true,
            onTapCharacter: onTapCustomerCharacter,
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
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
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
                  const SizedBox(height: 4),
                  Text(
                    '"${ticket.localizedBubble(languageCode)}"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ticket.requestedIngredientIds.map((requestedIngredientId) {
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
    required this.cardWidth,
    required this.onToggleIngredient,
  });

  final IngredientCategory category;
  final String languageCode;
  final List<CafeIngredient> ingredients;
  final List<CafeIngredient> selectedTray;
  final List<String> requestedIngredientIds;
  final double cardWidth;
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _shelfSurfaceColor,
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: _shelfBorderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            category.localizedTitle(languageCode),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF2C1A12),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: _gridSpacing,
            runSpacing: _gridSpacing,
            children: ingredients.map((ingredient) {
              final isSelected = selectedTray.any((item) => item.id == ingredient.id);
              final isRequestedOnTicket = requestedIngredientIds.contains(ingredient.id);
              return _IngredientCounterCard(
                ingredient: ingredient,
                languageCode: languageCode,
                isSelected: isSelected,
                isRequestedOnTicket: isRequestedOnTicket,
                cardWidth: cardWidth,
                onTap: () => onToggleIngredient(ingredient),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Individual counter card with ZERO red `PRANK!` spoiler badge so Salt and Sugar look like true twins!
class _IngredientCounterCard extends StatelessWidget {
  const _IngredientCounterCard({
    required this.ingredient,
    required this.languageCode,
    required this.isSelected,
    required this.isRequestedOnTicket,
    required this.cardWidth,
    required this.onTap,
  });

  final CafeIngredient ingredient;
  final String languageCode;
  final bool isSelected;
  final bool isRequestedOnTicket;
  final double cardWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? const Color(0xFF137333)
        : isRequestedOnTicket
            ? const Color(0xFFC85A32)
            : const Color(0xFFD7CCC8);
    final backgroundColor = isSelected ? const Color(0xFFE6F4EA) : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1.0,
      duration: _cardScaleDuration,
      child: InkWell(
        key: Key('ingredient_card_${ingredient.id}'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : (isRequestedOnTicket ? 1.8 : 1.2),
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4),
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
              const SizedBox(height: 6),
              Text(
                ingredient.localizedTitle(languageCode),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF2C1A12),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ingredient.localizedSubtitle(languageCode),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF795548),
                ),
              ),
            ],
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

/// Step 3 of the Cafe Loop: Interactive Wooden Serving Tray with lace doily & stealth wink badge.
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

  @override
  Widget build(BuildContext context) {
    final hasStealthPrankOnTray = selectedTray.any((item) => item.isPrankItem);

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
          // Lace Paper Doily inner tray mat
          Container(
            padding: const EdgeInsets.all(14),
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
                    const Icon(Icons.room_service_rounded, color: Color(0xFF4E342E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedTray.isEmpty
                            ? (languageCode == 'en'
                                ? 'Interactive Wooden Tray: Tap drinks, pastries & sugar to plate them here!'
                                : 'Canlı Ahşap Tepsi: İçecek, tatlı ve şekeri (veya gizlice tuzu!) tepsiye dizin!')
                            : 'Tray (${selectedTray.length}): '
                                '${selectedTray.map((item) => item.localizedTitle(languageCode)).join(' + ')}',
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
                        onPressed: onClearTray,
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                if (selectedTray.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: selectedTray.map((item) {
                      return InkWell(
                        onTap: () => onRemoveIngredient(item),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD7CCC8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _IngredientArtwork(
                                ingredient: item,
                                size: _trayItemImageSize,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  item.localizedTitle(languageCode),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('serve_order_button'),
            onPressed: selectedTray.isEmpty || isEvaluating ? null : onServeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E8E3E),
              disabledBackgroundColor: const Color(0xFF8D7B70),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isEvaluating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              languageCode == 'en' ? 'Serve Order & Ask Gemini Judge!' : 'Siparişi Servis Et & Gemini Jürisine Sor!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
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
    final cardColor = isSabotage ? const Color(0xFFFFF0F0) : const Color(0xFFECFDF3);
    final borderColor = isSabotage ? const Color(0xFFC5221F) : const Color(0xFF137333);

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
            badgeEmoji: isSabotage ? '🧂💥' : '🌟😍',
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
                        color: isSabotage ? const Color(0xFFFCE8E6) : const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSabotage ? const Color(0xFFF28B82) : const Color(0xFF81C995),
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
                      'City Edition: ${cityEdition.flagEmoji} ${cityEdition.cityName} · '
                      'Tip: +${currentReview.cityBonusTip} pts · '
                      'Source: ${currentReview.isFromLiveGemini ? "Live Gemini 3.5 Flash-Lite" : "Offline JSON Schema"}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4E342E)),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onNextCustomer,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        languageCode == 'en' ? 'Serve Next Customer' : 'Sıradaki Müşteriye Geç',
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
