import 'package:backyard_barista_cloudrun/data/custom_svg_items.dart';
import 'package:flutter/foundation.dart';

/// Station category on the 2-player cafe counter.
enum IngredientCategory {
  drink(
    '☕ Player 1: Espresso & Coffee Bar',
    '☕ Oyuncu 1: Kahve & İçecek Barı',
  ),
  food(
    '🥐 Player 2: Glass Pastry Vitrine',
    '🥐 Oyuncu 2: Cam Tatlı Vitrini',
  ),
  toppingOrPrank(
    '🧂 Sweet or Salty? Twin Condiment Jars',
    '🧂 Tatlı mı Tuzlu mu? İkiz Kavanozlar',
  );

  const IngredientCategory(this.titleEn, this.titleTr);

  final String titleEn;
  final String titleTr;

  String localizedTitle(String languageCode) => languageCode == 'en' ? titleEn : titleTr;
}

/// Represents a single tap-to-add item on the Backyard Barista counter.
/// Uses either one of the 14 pre-generated 9D studio PNGs (`assetPath`) or an on-the-fly
/// Gemini/Antigravity generated vector graphic (`customVectorKind`).
@immutable
class CafeIngredient {
  const CafeIngredient({
    required this.id,
    required this.titleEn,
    required this.titleTr,
    required this.subtitleEn,
    required this.subtitleTr,
    required this.category,
    required this.isPrankItem,
    required this.prankKind,
    this.isHotDrink = false,
    this.assetPath,
    this.customVectorKind,
  });

  final String id;
  final String titleEn;
  final String titleTr;
  final String subtitleEn;
  final String subtitleTr;
  final IngredientCategory category;
  final bool isPrankItem;
  final String prankKind;
  final bool isHotDrink;
  final String? assetPath;
  final CustomVectorArtworkKind? customVectorKind;

  String localizedTitle(String languageCode) {
    return languageCode == 'en' ? titleEn : titleTr;
  }

  String localizedSubtitle(String languageCode) {
    return languageCode == 'en' ? subtitleEn : subtitleTr;
  }
}

/// Pre-wired catalog of the 9 counter PNG items (plus 3 customer face PNGs and 2 Round-2 custom PNGs = 14 studio 9D PNGs total)
/// with on-the-fly vector graphic fallbacks generated with Antigravity.
class IngredientsCatalog {
  const IngredientsCatalog._();

  static const List<CafeIngredient> baseItems = <CafeIngredient>[
    // 1. Drinks (3 base PNGs)
    CafeIngredient(
      id: 'espresso',
      titleEn: 'Double Espresso',
      titleTr: 'Çift Shot Espresso',
      subtitleEn: 'Velvety Crema · 92°C',
      subtitleTr: 'Kadife Krema · 92°C',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      isHotDrink: true,
      assetPath: 'assets/base/drinks/espresso.png',
    ),
    CafeIngredient(
      id: 'milk',
      titleEn: 'Steamed Milk',
      titleTr: 'Köpüklü Süt',
      subtitleEn: 'Silky Microfoam · 65°C',
      subtitleTr: 'İpeksi Süt Köpüğü · 65°C',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      isHotDrink: true,
      assetPath: 'assets/base/drinks/milk.png',
    ),
    CafeIngredient(
      id: 'menengic_coffee',
      titleEn: 'Menengiç Pistachio Coffee',
      titleTr: 'Menengiç Kahvesi',
      subtitleEn: 'Roasted Terebinth · Copper Cup',
      subtitleTr: 'Kavrulmuş Menengiç · Bakır Fincan',
      category: IngredientCategory.drink,
      isPrankItem: false,
      prankKind: 'none',
      isHotDrink: true,
      assetPath: 'assets/base/drinks/menengic_coffee.png',
    ),

    // 2. Simple Foods (3 base PNGs)
    CafeIngredient(
      id: 'croissant',
      titleEn: 'Butter Croissant',
      titleTr: 'Tereyağlı Kruvasan',
      subtitleEn: 'Flaky Golden Layers',
      subtitleTr: 'Çıtır Katmanlı Hamur',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/croissant.png',
    ),
    CafeIngredient(
      id: 'san_sebastian',
      titleEn: 'San Sebastian Cheesecake',
      titleTr: 'San Sebastian Cheesecake',
      subtitleEn: 'Caramelized Basque Crust',
      subtitleTr: 'Karamelize Yanık Üst Katman',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/san_sebastian.png',
    ),
    CafeIngredient(
      id: 'baklava',
      titleEn: 'Pistachio Baklava',
      titleTr: 'Fıstıklı Baklava',
      subtitleEn: '40 Phyllo Layers · Boz Pistachio',
      subtitleTr: '40 Kat Yufka · Boz Fıstık',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/baklava.png',
    ),

    // 3. Toppings & Stealth Pranks (Twin glass jars with zero red spoiler badges!)
    CafeIngredient(
      id: 'sugar_jar',
      titleEn: 'Sweet Sugar (Şeker)',
      titleTr: 'Tatlı Şeker Kavanozu',
      subtitleEn: '2-Hole Rose Lid · Fine Crystals',
      subtitleTr: '2 Delikli Kapak · Beyaz Kristal',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/toppings_pranks/sugar_jar.png',
    ),
    CafeIngredient(
      id: 'salt_shaker',
      titleEn: 'Salt Shaker (Tuz!)',
      titleTr: 'Tuzluk (Şeker İkizi)',
      subtitleEn: '3-Hole Silver Lid · White Crystals',
      subtitleTr: '3 Delikli Kapak · Beyaz Kristal',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'salt',
      assetPath: 'assets/base/toppings_pranks/salt_shaker.png',
    ),
    CafeIngredient(
      id: 'chili_sauce',
      titleEn: 'Red Glaze / Chili Sauce',
      titleTr: 'Kırmızı Sos (Acı Biber)',
      subtitleEn: 'Looks Like Berry Glaze · Scoville!',
      subtitleTr: 'Çilek Sosu Görünümlü · Acı!',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'chili',
      assetPath: 'assets/base/toppings_pranks/chili_sauce.png',
    ),
  ];

  /// Round 2 items generated with 9D photorealistic studio photography + vector fallback.
  static const List<CafeIngredient> roundTwoCustomItems = <CafeIngredient>[
    CafeIngredient(
      id: 'custom_katmer_roll',
      titleEn: 'AI Custom: Katmer Roll',
      titleTr: 'AI Özel: Fıstıklı Katmer Sarma',
      subtitleEn: 'Crispy Phyllo · Kaymak & Pistachio',
      subtitleTr: 'Çıtır Yufka · Kaymak & Boz Fıstık',
      category: IngredientCategory.food,
      isPrankItem: false,
      prankKind: 'none',
      assetPath: 'assets/base/foods/katmer_roll.png',
      customVectorKind: CustomVectorArtworkKind.pistachioKatmerRoll,
    ),
    CafeIngredient(
      id: 'custom_isot_pepper',
      titleEn: 'AI Flakes: İsot Pepper',
      titleTr: 'AI Özel: İsot Biberi',
      subtitleEn: 'Smoky Urfa Chili Flakes',
      subtitleTr: 'İsli Urfa & Antep İsotu',
      category: IngredientCategory.toppingOrPrank,
      isPrankItem: true,
      prankKind: 'chili',
      assetPath: 'assets/base/toppings_pranks/isot_pepper.png',
      customVectorKind: CustomVectorArtworkKind.isotPepperShaker,
    ),
  ];

  static CafeIngredient? findById(String id) {
    for (final item in <CafeIngredient>[...baseItems, ...roundTwoCustomItems]) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

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
