import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/custom_svg_items.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/models/cafe_review.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/ui/city_settings_drawer.dart';
import 'package:flutter/material.dart';

const double _counterCardRadius = 16;
const double _ingredientImageSize = 56;
const double _customerAvatarSize = 72;
const Duration _cardScaleDuration = Duration(milliseconds: 180);

/// Main 2-Player Tap-to-Serve Cafe Counter screen built with pure Flutter declarative widgets
/// (`Stack`, `AnimatedScale`, `AnimatedSwitcher`, `CustomPaint`, and `Image.asset`).
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
  bool _includeRoundTwoCustomItems = true;
  bool _isEvaluatingOrder = false;
  CafeReview? _latestReview;

  void _toggleIngredient(CafeIngredient ingredient) {
    setState(() {
      if (_selectedTray.any((existing) => existing.id == ingredient.id)) {
        _selectedTray.removeWhere((existing) => existing.id == ingredient.id);
      } else {
        _selectedTray.add(ingredient);
      }
    });
  }

  void _clearTray() {
    setState(() {
      _selectedTray.clear();
      _latestReview = null;
    });
  }

  Future<void> _serveOrder() async {
    if (_selectedTray.isEmpty || _isEvaluatingOrder) {
      return;
    }
    setState(() {
      _isEvaluatingOrder = true;
    });

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
    });
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

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          appBar: AppBar(
            backgroundColor: const Color(0xFF4E342E),
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Backyard Barista on Cloud Run ☕🥐🧂',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${activeEdition.cafeSubtitle} · ${activeEdition.signatureSpecialty}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFFCCBC)),
                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: FilledButton.tonalIcon(
                  key: const Key('city_edition_switcher_button'),
                  onPressed: _openCityEditionSheet,
                  icon: Text(
                    activeEdition.flagEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  label: Text('${activeEdition.cityName} Edition ▾'),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _ArchitectureBanner(
                  cityEdition: activeEdition,
                  sourceLayer: widget.cityController.activeSourceLayer,
                  includeRoundTwoItems: _includeRoundTwoCustomItems,
                  onToggleRoundTwoItems: (enabled) {
                    setState(() {
                      _includeRoundTwoCustomItems = enabled;
                    });
                  },
                ),
                const SizedBox(height: 16),
                for (final category in IngredientCategory.values) ...<Widget>[
                  Text(
                    category.sectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3E2723),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: IngredientsCatalog.itemsForCategory(
                      category,
                      includeRoundTwoCustomItems: _includeRoundTwoCustomItems,
                    ).map((ingredient) {
                      final isSelected = _selectedTray.any((item) => item.id == ingredient.id);
                      return _IngredientCounterCard(
                        ingredient: ingredient,
                        languageCode: languageCode,
                        isSelected: isSelected,
                        onTap: () => _toggleIngredient(ingredient),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],
                _TrayAndServeBar(
                  selectedTray: _selectedTray,
                  languageCode: languageCode,
                  isEvaluating: _isEvaluatingOrder,
                  onServeOrder: _serveOrder,
                  onClearTray: _clearTray,
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _latestReview != null
                      ? _CustomerReviewCard(
                          key: ValueKey<DateTime>(_latestReview?.evaluatedAt ?? DateTime.utc(2026)),
                          review: _latestReview,
                          cityEdition: activeEdition,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArchitectureBanner extends StatelessWidget {
  const _ArchitectureBanner({
    required this.cityEdition,
    required this.sourceLayer,
    required this.includeRoundTwoItems,
    required this.onToggleRoundTwoItems,
  });

  final CityEditionConfig cityEdition;
  final CityConfigSourceLayer sourceLayer;
  final bool includeRoundTwoItems;
  final ValueChanged<bool> onToggleRoundTwoItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFE0),
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: const Color(0xFFD7CCC8)),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                sourceLayer.displayLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Round 2 AI Custom SVG Items:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
    );
  }
}

class _IngredientCounterCard extends StatelessWidget {
  const _IngredientCounterCard({
    required this.ingredient,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final CafeIngredient ingredient;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? (ingredient.isPrankItem ? const Color(0xFFC62828) : const Color(0xFF2E7D32))
        : const Color(0xFFD7CCC8);
    final backgroundColor =
        isSelected ? (ingredient.isPrankItem ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9)) : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1.0,
      duration: _cardScaleDuration,
      child: InkWell(
        key: Key('ingredient_card_${ingredient.id}'),
        borderRadius: BorderRadius.circular(_counterCardRadius),
        onTap: onTap,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_counterCardRadius),
            border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: _IngredientArtwork(ingredient: ingredient),
                  ),
                  if (ingredient.isPrankItem)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRANK!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ingredient.localizedTitle(languageCode),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientArtwork extends StatelessWidget {
  const _IngredientArtwork({required this.ingredient});

  final CafeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    final vectorKind = ingredient.customVectorKind;
    if (vectorKind != null) {
      return CustomVectorIngredientGraphic(
        artworkKind: vectorKind,
      );
    }

    final assetPath = ingredient.assetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: _ingredientImageSize,
        height: _ingredientImageSize,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.local_cafe, size: _ingredientImageSize, color: Color(0xFF6D4C41));
        },
      );
    }

    return const Icon(Icons.local_cafe, size: _ingredientImageSize, color: Color(0xFF6D4C41));
  }
}

class _TrayAndServeBar extends StatelessWidget {
  const _TrayAndServeBar({
    required this.selectedTray,
    required this.languageCode,
    required this.isEvaluating,
    required this.onServeOrder,
    required this.onClearTray,
  });

  final List<CafeIngredient> selectedTray;
  final String languageCode;
  final bool isEvaluating;
  final VoidCallback onServeOrder;
  final VoidCallback onClearTray;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0D4),
        borderRadius: BorderRadius.circular(_counterCardRadius),
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
                      ? 'Tap drinks, foods, and sugar (or sneak salt!) onto the tray'
                      : 'Tray (${selectedTray.length}): ${selectedTray.map((item) => item.localizedTitle(languageCode)).join(' + ')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (selectedTray.isNotEmpty)
                TextButton(
                  key: const Key('clear_tray_button'),
                  onPressed: onClearTray,
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('serve_order_button'),
            onPressed: selectedTray.isEmpty || isEvaluating ? null : onServeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerReviewCard extends StatelessWidget {
  const _CustomerReviewCard({
    required this.review,
    required this.cityEdition,
    super.key,
  });

  final CafeReview? review;
  final CityEditionConfig cityEdition;

  @override
  Widget build(BuildContext context) {
    final currentReview = review;
    if (currentReview == null) {
      return const SizedBox.shrink();
    }

    final isSabotage = currentReview.isPrankCaught;
    final cardColor = isSabotage ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final borderColor = isSabotage ? const Color(0xFFC62828) : const Color(0xFF2E7D32);

    return Container(
      key: const Key('customer_review_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_counterCardRadius),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            currentReview.customerFace.assetPath,
            width: _customerAvatarSize,
            height: _customerAvatarSize,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                isSabotage ? Icons.sentiment_very_dissatisfied : Icons.sentiment_very_satisfied,
                size: _customerAvatarSize,
                color: borderColor,
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '★' * currentReview.ratingStars + '☆' * (maxCafeRatingStars - currentReview.ratingStars),
                      key: const Key('review_stars_text'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        '${currentReview.ratingStars}/$maxCafeRatingStars · ${currentReview.tasteVerdict}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currentReview.headline,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  currentReview.customerReaction,
                  key: const Key('review_reaction_text'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'City Edition: ${cityEdition.flagEmoji} ${cityEdition.cityName} · '
                  'Tip: +${currentReview.cityBonusTip} pts · '
                  'Source: ${currentReview.isFromLiveGemini ? "Live Gemini 3.5 Flash-Lite" : "Offline JSON Schema"}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4E342E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
