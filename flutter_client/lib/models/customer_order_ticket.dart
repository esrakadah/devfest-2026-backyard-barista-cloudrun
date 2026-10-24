import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:flutter/foundation.dart';

/// Character portrait asset paths bundled under `assets/base/characters/` and `assets/base/customers/`.
class CafeCharacterAssets {
  const CafeCharacterAssets._();

  static const String baristaPlayerOne = 'assets/base/characters/barista_p1.png';
  static const String pastryChefPlayerTwo = 'assets/base/characters/pastry_chef_p2.png';
  static const String customerAyseUsta = 'assets/base/characters/customer_ayse_usta.png';
  static const String customerMustafa = 'assets/base/characters/customer_mustafa.png';
  static const String customerLukas = 'assets/base/characters/customer_lukas.png';
  static const String customerDeniz = 'assets/base/characters/customer_deniz.png';
  static const String customerZeynepHappy = 'assets/base/customers/customer_happy.png';
}

/// Represents a single customer order in the 3-step cafe game loop, paired with a distinct animated character profile.
@immutable
class CustomerOrderTicket {
  const CustomerOrderTicket({
    required this.ticketNumber,
    required this.customerName,
    required this.customerRoleEn,
    required this.customerRoleTr,
    required this.orderBubbleEn,
    required this.orderBubbleTr,
    required this.requestedIngredientIds,
    required this.portraitAssetPath,
    required this.characterBadgeEmoji,
  });

  final int ticketNumber;
  final String customerName;
  final String customerRoleEn;
  final String customerRoleTr;
  final String orderBubbleEn;
  final String orderBubbleTr;
  final List<String> requestedIngredientIds;
  final String portraitAssetPath;
  final String characterBadgeEmoji;

  String localizedRole(String languageCode) => languageCode == 'en' ? customerRoleEn : customerRoleTr;

  String localizedBubble(String languageCode) => languageCode == 'en' ? orderBubbleEn : orderBubbleTr;

  static List<CustomerOrderTicket> ticketsForCity(CityEditionId cityId) {
    switch (cityId) {
      case CityEditionId.berlin:
        return const <CustomerOrderTicket>[
          CustomerOrderTicket(
            ticketNumber: 1,
            customerName: 'Lukas',
            customerRoleEn: 'Kreuzberg Indie Dev',
            customerRoleTr: 'Kreuzberg Geliştiricisi',
            orderBubbleEn: 'One Double Espresso, a flaky Butter Croissant, and Sweet Sugar please!',
            orderBubbleTr: 'Bir Çift Shot Espresso, Tereyağlı Kruvasan ve Tatlı Şeker lütfen!',
            requestedIngredientIds: <String>['espresso', 'croissant', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerLukas,
            characterBadgeEmoji: '🧢💻',
          ),
          CustomerOrderTicket(
            ticketNumber: 2,
            customerName: 'Hannah',
            customerRoleEn: 'Cloud Run Architect',
            customerRoleTr: 'Cloud Run Mimarı',
            orderBubbleEn: 'Steamed Milk with San Sebastian Cheesecake and a touch of Sweet Sugar!',
            orderBubbleTr: 'Köpüklü Süt, San Sebastian Cheesecake ve biraz Tatlı Şeker rica ediyorum!',
            requestedIngredientIds: <String>['milk', 'san_sebastian', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerDeniz,
            characterBadgeEmoji: '🧣☁️',
          ),
          CustomerOrderTicket(
            ticketNumber: 3,
            customerName: 'Max',
            customerRoleEn: 'DevFest Stage Host',
            customerRoleTr: 'DevFest Sahne Sunucusu',
            orderBubbleEn: 'Surprise me with Menengiç Coffee, AI Custom Katmer Roll, and Sweet Sugar!',
            orderBubbleTr: 'Menengiç Kahvesi, AI Özel Katmer Sarma ve Tatlı Şeker ile enerji verin!',
            requestedIngredientIds: <String>['menengic_coffee', 'custom_katmer_roll', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerMustafa,
            characterBadgeEmoji: '🎙️⚡',
          ),
        ];

      case CityEditionId.gaziantep:
        return const <CustomerOrderTicket>[
          CustomerOrderTicket(
            ticketNumber: 1,
            customerName: 'Ayşe Usta',
            customerRoleEn: 'Şehitkamil Gourmet Critic',
            customerRoleTr: 'Şehitkamil Gurme Jüri',
            orderBubbleEn: 'Menengiç Pistachio Coffee + Pistachio Baklava + Sweet Sugar (No salt tricks!)',
            orderBubbleTr: 'Menengiç Kahvesi + Fıstıklı Baklava + Tatlı Şeker (Sakın tuz şakası yapmayın!)',
            requestedIngredientIds: <String>['menengic_coffee', 'baklava', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerAyseUsta,
            characterBadgeEmoji: '👓🟢',
          ),
          CustomerOrderTicket(
            ticketNumber: 2,
            customerName: 'Mustafa',
            customerRoleEn: 'GDG Lead & Vibe Organizer',
            customerRoleTr: 'GDG Gaziantep Organizatörü',
            orderBubbleEn: 'Double Espresso + AI Custom Katmer Roll + Sweet Sugar before the next wave!',
            orderBubbleTr: 'Çift Shot Espresso + AI Özel Katmer Sarma + Tatlı Şeker, yeni seans başlıyor!',
            requestedIngredientIds: <String>['espresso', 'custom_katmer_roll', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerMustafa,
            characterBadgeEmoji: '🎤🚀',
          ),
          CustomerOrderTicket(
            ticketNumber: 3,
            customerName: 'Zeynep',
            customerRoleEn: 'Flutter Student Builder',
            customerRoleTr: 'Flutter Öğrenci Geliştirici',
            orderBubbleEn: 'Steamed Milk + San Sebastian Cheesecake + Sweet Sugar please!',
            orderBubbleTr: 'Köpüklü Süt + San Sebastian Cheesecake + Tatlı Şeker lütfen!',
            requestedIngredientIds: <String>['milk', 'san_sebastian', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerZeynepHappy,
            characterBadgeEmoji: '🦋☕',
          ),
        ];

      case CityEditionId.adana:
        return const <CustomerOrderTicket>[
          CustomerOrderTicket(
            ticketNumber: 1,
            customerName: 'Emre',
            customerRoleEn: 'Seyhan Cloud Engineer',
            customerRoleTr: 'Seyhan Bulut Mühendisi',
            orderBubbleEn: 'Double Espresso + Pistachio Baklava + Sweet Sugar please!',
            orderBubbleTr: 'Gar Kahvesi niyetine Çift Shot Espresso + Fıstıklı Baklava + Tatlı Şeker!',
            requestedIngredientIds: <String>['espresso', 'baklava', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerMustafa,
            characterBadgeEmoji: '☀️☁️',
          ),
          CustomerOrderTicket(
            ticketNumber: 2,
            customerName: 'Selin',
            customerRoleEn: 'AI Studio Hacker',
            customerRoleTr: 'AI Studio Geliştiricisi',
            orderBubbleEn: 'Steamed Milk + Butter Croissant + Sweet Sugar!',
            orderBubbleTr: 'Buz gibi Köpüklü Süt + Tereyağlı Kruvasan + Tatlı Şeker!',
            requestedIngredientIds: <String>['milk', 'croissant', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerZeynepHappy,
            characterBadgeEmoji: '✨🤖',
          ),
          CustomerOrderTicket(
            ticketNumber: 3,
            customerName: 'Burak',
            customerRoleEn: 'DevFest Speaker',
            customerRoleTr: 'DevFest Konuşmacısı',
            orderBubbleEn: 'Menengiç Coffee + AI Custom Katmer Roll + Sweet Sugar!',
            orderBubbleTr: 'Menengiç Kahvesi + AI Özel Katmer Sarma + Tatlı Şeker lütfen!',
            requestedIngredientIds: <String>['menengic_coffee', 'custom_katmer_roll', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerLukas,
            characterBadgeEmoji: '🎤🔥',
          ),
        ];

      case CityEditionId.istanbul:
        return const <CustomerOrderTicket>[
          CustomerOrderTicket(
            ticketNumber: 1,
            customerName: 'Deniz',
            customerRoleEn: 'Galata Product Designer',
            customerRoleTr: 'Galata Ürün Tasarımcısı',
            orderBubbleEn: 'Double Espresso + Galata San Sebastian Cheesecake + Sweet Sugar!',
            orderBubbleTr: 'Çift Shot Espresso + Galata San Sebastian Cheesecake + Tatlı Şeker!',
            requestedIngredientIds: <String>['espresso', 'san_sebastian', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerDeniz,
            characterBadgeEmoji: '🎨🗼',
          ),
          CustomerOrderTicket(
            ticketNumber: 2,
            customerName: 'Kaan',
            customerRoleEn: 'Bosphorus Ferry Captain',
            customerRoleTr: 'Boğaz Vapur Kaptanı',
            orderBubbleEn: 'Menengiç Coffee + Pistachio Baklava + Sweet Sugar!',
            orderBubbleTr: 'Menengiç Kahvesi + Fıstıklı Baklava + Tatlı Şeker lütfen!',
            requestedIngredientIds: <String>['menengic_coffee', 'baklava', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerLukas,
            characterBadgeEmoji: '⛴️🌊',
          ),
          CustomerOrderTicket(
            ticketNumber: 3,
            customerName: 'Elif',
            customerRoleEn: 'GDE Mentor',
            customerRoleTr: 'GDE Mentor',
            orderBubbleEn: 'Steamed Milk + AI Custom Katmer Roll + Sweet Sugar!',
            orderBubbleTr: 'Köpüklü Süt + AI Özel Katmer Sarma + Tatlı Şeker!',
            requestedIngredientIds: <String>['milk', 'custom_katmer_roll', 'sugar_jar'],
            portraitAssetPath: CafeCharacterAssets.customerAyseUsta,
            characterBadgeEmoji: '🌟👩‍🏫',
          ),
        ];
    }
  }
}
