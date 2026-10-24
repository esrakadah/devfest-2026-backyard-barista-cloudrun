import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DateTime fixedClock() => DateTime.utc(2026, 11, 15, 14);

  test(
    '3-Layer CityEditionController prioritizes Manual UI Override > Remote Config > Local Fallback',
    () {
      final controller = CityEditionController(remoteConfigCityCode: 'berlin');
      expect(controller.activeCityId, CityEditionId.berlin);
      expect(controller.activeSourceLayer, CityConfigSourceLayer.firebaseRemoteConfig);

      // Priority 1: Manual UI Override wins over Remote Config
      controller.selectManualOverride(CityEditionId.gaziantep);
      expect(controller.activeCityId, CityEditionId.gaziantep);
      expect(controller.activeSourceLayer, CityConfigSourceLayer.manualUiOverride);
      expect(controller.activeEdition.cityName, 'Gaziantep');

      // Clearing manual override restores Priority 2 (Firebase Remote Config)
      controller.clearManualOverride();
      expect(controller.activeCityId, CityEditionId.berlin);
      expect(controller.activeSourceLayer, CityConfigSourceLayer.firebaseRemoteConfig);
    },
  );

  testWidgets(
    'Serving sweet order gives 5 stars; sneaking stealth Salt shows wink badge & triggers 1-star sabotage',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final cityController = CityEditionController(remoteConfigCityCode: 'gaziantep');
      final judgeService = CafeJudgeService(
        clock: fixedClock,
        forceOfflineMode: true,
      );

      await tester.pumpWidget(
        BackyardBaristaApp(
          cityController: cityController,
          judgeService: judgeService,
        ),
      );

      // Verify zero red 'PRANK!' spoiler badges exist on the counter
      expect(find.text('PRANK!'), findsNothing);
      expect(find.textContaining('Ayşe Usta'), findsOneWidget);

      // 1. Tap Espresso + Baklava + Sweet Sugar
      await tester.tap(find.byKey(const Key('ingredient_card_espresso')));
      await tester.tap(find.byKey(const Key('ingredient_card_baklava')));
      await tester.tap(find.byKey(const Key('ingredient_card_sugar_jar')));
      await tester.pumpAndSettle();

      // Serve order
      final serveButton = find.byKey(const Key('serve_order_button'));
      await tester.ensureVisible(serveButton);
      await tester.pumpAndSettle();
      await tester.tap(serveButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer_review_card')), findsOneWidget);
      expect(find.textContaining('5/5 · sweet_perfection'), findsOneWidget);

      // 2. Sneak Salt Shaker (Tuz!) onto the tray: verify stealth wink badge appears
      final saltCard = find.byKey(const Key('ingredient_card_salt_shaker'));
      await tester.ensureVisible(saltCard);
      await tester.pumpAndSettle();
      await tester.tap(saltCard);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stealth_prank_wink_badge')), findsOneWidget);

      await tester.ensureVisible(serveButton);
      await tester.pumpAndSettle();
      await tester.tap(serveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('1/5 · salty_sabotage'), findsOneWidget);
      expect(find.textContaining('sınır dışı ederler'), findsOneWidget);

      // 3. Advance to Next Customer (#2 Mustafa)
      final nextCustomerButton = find.byKey(const Key('next_customer_button'));
      await tester.ensureVisible(nextCustomerButton);
      await tester.pumpAndSettle();
      await tester.tap(nextCustomerButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Mustafa'), findsOneWidget);
    },
  );

  testWidgets('Switching City Edition in Settings sheet updates flag and customer queue', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cityController = CityEditionController(remoteConfigCityCode: 'gaziantep');
    final judgeService = CafeJudgeService(
      clock: fixedClock,
      forceOfflineMode: true,
    );

    await tester.pumpWidget(
      BackyardBaristaApp(
        cityController: cityController,
        judgeService: judgeService,
      ),
    );

    // Open City Edition Switcher
    await tester.tap(find.byKey(const Key('city_edition_switcher_button')));
    await tester.pumpAndSettle();

    // Select Berlin Edition
    await tester.tap(find.byKey(const Key('city_option_berlin')));
    await tester.pumpAndSettle();

    expect(cityController.activeCityId, CityEditionId.berlin);
    expect(find.textContaining('Berlin Edition'), findsOneWidget);
    expect(find.textContaining('Lukas'), findsOneWidget);
  });

  testWidgets('Renders and plays cleanly on narrow mobile phone screen (360x780) without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cityController = CityEditionController(remoteConfigCityCode: 'gaziantep');
    final judgeService = CafeJudgeService(
      clock: fixedClock,
      forceOfflineMode: true,
    );

    await tester.pumpWidget(
      BackyardBaristaApp(
        cityController: cityController,
        judgeService: judgeService,
      ),
    );

    final saltFinder = find.byKey(const Key('ingredient_card_salt_shaker'));
    await tester.ensureVisible(saltFinder);
    await tester.pumpAndSettle();
    await tester.tap(saltFinder);
    await tester.pumpAndSettle();

    final serveFinder = find.byKey(const Key('serve_order_button'));
    await tester.ensureVisible(serveFinder);
    await tester.pumpAndSettle();
    await tester.tap(serveFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer_review_card')), findsOneWidget);
    expect(find.textContaining('1/5 · salty_sabotage'), findsOneWidget);
  });
}
