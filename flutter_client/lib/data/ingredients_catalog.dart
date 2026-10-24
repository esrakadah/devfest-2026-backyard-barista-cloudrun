import 'package:backyard_barista_cloudrun/data/custom_svg_items.dart';
import 'package:flutter/foundation.dart';

/// Station category on the 2-player cafe counter.
enum IngredientCategory {
  drink('Drinks / İçecekler (Player 1)'),
  food('Simple Foods / Tatlılar (Player 2)'),
  toppingOrPrank('Sugar vs. Salt & Pranks / Şeker & Tuzak Malzemeler');

  const IngredientCategory(this.sectionTitle);

  final String sectionTitle;
}

/// Represents a single tap-to-add item on the Backyard Barista counter.
/// Uses either one of the 12 pre-generated GitHub PNGs (`assetPath`) or an on-the-fly
/// Gemini/Antigravity generated vector graphic (`customVectorKind`).
@immutable
class CafeIngredient {
  const CafeIngredient({
    required this.id,
    required this.titleEn,
    required this.titleTr,
    required this.category,
    required this.isPrankItem,
    required this.prankKind,
    this.assetPath,
    this.customVectorKind,
  });

  final String id;
  final String titleEn;
  final String titleTr;
  final IngredientCategory category;
  final bool isPrankItem;
  final String prankKind;
  final String? assetPath;
  final CustomVectorArtworkKind? customVectorKind;

  String localizedTitle(String languageCode) {
    return languageCode == 'en' ? titleEn : titleTr;
  }
}

/// Pre-wired catalog of the 9 counter PNG items (plus 3 customer face PNGs = 12 base PNGs total)
/// and the 2 Round-2 custom vector items generated on the fly with Antigravity.
class IngredientsCatalog {
  const IngredientsCatalog._();

  static const List<CafeIngredient> baseItems = <CafeIngredient>[
    // 1. Drinks (3 base PNGs)
    CafeIngredient(
      id: 'espresso',
      titleEn: 'Double Espresso',
      titleTr: 'Çift Shot Espresso',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/drinks/espresso.png',
    ),
    CafeIngredient(
      id: 'milk',
      titleEn: 'Steamed Milk',
      titleTr: 'Köpüklü Süt',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/drinks/milk.png',
    ),
    CafeIngredient(
      id: 'menengic_coffee',
      titleEn: 'Menengiç Pistachio Coffee',
      titleTr: 'Menengiç Kahvesi',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/drinks/menengic_coffee.png',
    ),

    // 2. Simple Foods (3 base PNGs)
    CafeIngredient(
      id: 'croissant',
      titleEn: 'Butter Croissant',
      titleTr: 'Tereyağlı Kruvasan',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/croissant.png',
    ),
    CafeIngredient(
      id: 'san_sebastian',
      titleEn: 'San Sebastian Cheesecake',
      titleTr: 'San Sebastian Cheesecake',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/san_sebastian.png',
    ),
    CafeIngredient(
      id: 'baklava',
      titleEn: 'Pistachio Baklava',
      titleTr: 'Fıstıklı Baklava',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/baklava.png',
    ),

    // 3. Toppings & Pranks (3 base PNGs: Sugar sits right next to Salt and Chili!)
    CafeIngredient(
      id: 'sugar_jar',
      titleEn: 'Sweet Sugar (Şeker)',
      titleTr: 'Tatlı Şeker Kavanozu',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/toppings_pranks/sugar_jar.png',
    ),
    CafeIngredient(
      id: 'salt_shaker',
      titleEn: 'Salt Shaker (Tuz!)',
      titleTr: 'Tuzluk (Şeker Tuzağı!)',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'salt',
      assetPath: 'assets/base/toppings_pranks/salt_shaker.png',
    ),
    CafeIngredient(
      id: 'chili_sauce',
      titleEn: 'Hot Chili Sauce (Acı Sos!)',
      titleTr: 'Acı Biber Sosu (Tuzak!)',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'chili',
      assetPath: 'assets/base/toppings_pranks/chili_sauce.png',
    ),
  ];

  /// Round 2 items generated on the fly as inline vector widgets (zero external file dependency).
  static const List<CafeIngredient> roundTwoCustomItems = <CafeIngredient>[
    CafeIngredient(
      id: 'custom_katmer_roll',
      titleEn: 'AI Custom: Katmer Roll',
      titleTr: 'AI Özel: Fıstıklı Katmer Sarma',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      customVectorKind: CustomVectorArtworkKind.pistachioKatmerRoll,
    ),
    CafeIngredient(
      id: 'custom_isot_pepper',
      titleEn: 'AI Prank: İsot Pepper',
      titleTr: 'AI Tuzak: İsot Biberi',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'chili',
      customVectorKind: CustomVectorArtworkKind.isotPepperShaker,
    ),
  ];

  static List<CafeIngredient> itemsForCategory(
    IngredientCategory category, {
    required bool includeRoundTwoCustomItems,
  }) {
    final combined = <CafeIngredient>[
      ...baseItems,
      if (includeRoundTwoCustomItems) ...roundTwoCustomItems,
    ];
    return combined.where((ingredient) => ingredient.category == category).toList();
  }
}
