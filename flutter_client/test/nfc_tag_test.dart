import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_controller.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_payload.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_platform.dart';
import 'package:backyard_barista_cloudrun/ui/cafe_counter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNfcTagPlatform extends NfcTagPlatform {
  _FakeNfcTagPlatform({this.refuseScan = false});

  final bool refuseScan;
  final List<String> writtenUrls = <String>[];
  void Function(String recordText)? deliverRecord;

  @override
  bool get isSupported => true;

  @override
  Future<void> startScan({
    required void Function(String recordText) onRecordText,
    required void Function() onReadError,
  }) async {
    if (refuseScan) {
      throw StateError('NotAllowedError');
    }
    deliverRecord = onRecordText;
  }

  @override
  Future<void> writeUrl(String url) async {
    writtenUrls.add(url);
  }
}

void main() {
  final saltShaker = IngredientsCatalog.findById('salt_shaker')!;
  final liveGameUri = Uri.parse('https://backyard-barista-389486729482.europe-west3.run.app/?city=adana');

  group('NFC tag payload', () {
    test('tag URL keeps the game origin and carries only the ingredient id', () {
      expect(
        nfcTagUrlForIngredient(saltShaker, appBaseUri: liveGameUri),
        'https://backyard-barista-389486729482.europe-west3.run.app/?tap=salt_shaker',
      );
    });

    test('URL records and barista: text records both resolve to the ingredient', () {
      expect(ingredientFromNfcRecord('https://example.run.app/?tap=salt_shaker')?.id, 'salt_shaker');
      expect(ingredientFromNfcRecord(' barista:espresso ')?.id, 'espresso');
    });

    test('foreign tags such as a conference badge are ignored', () {
      expect(ingredientFromNfcRecord('https://www.linkedin.com/in/esratech'), isNull);
      expect(ingredientFromNfcRecord('https://example.run.app/?tap=unknown_item'), isNull);
    });
  });

  group('NfcTagController', () {
    test('a tag held still fires once, a second tap after the window fires again', () async {
      var currentTime = DateTime.utc(2026, 11, 28, 15, 20);
      final tappedIds = <String>[];
      final controller = NfcTagController(platform: _FakeNfcTagPlatform(), clock: () => currentTime)
        ..onIngredientTapped = (ingredient) => tappedIds.add(ingredient.id);

      controller.handleRecordText('barista:salt_shaker');
      currentTime = currentTime.add(const Duration(milliseconds: 400));
      controller.handleRecordText('barista:salt_shaker');
      currentTime = currentTime.add(nfcDuplicateTapWindow);
      controller.handleRecordText('barista:salt_shaker');

      expect(tappedIds, <String>['salt_shaker', 'salt_shaker']);
    });

    test('a refused scan reports failed instead of throwing', () async {
      final controller = NfcTagController(platform: _FakeNfcTagPlatform(refuseScan: true));
      await controller.startScanning();
      expect(controller.status, NfcScanStatus.failed);
      expect(controller.lastErrorMessage, contains('NotAllowedError'));
    });

    test('the default platform in tests has no NFC, so the controls stay hidden', () {
      expect(NfcTagController().isSupported, isFalse);
    });

    test('writing a tag writes the ingredient URL', () async {
      final platform = _FakeNfcTagPlatform();
      await NfcTagController(platform: platform).writeTag(saltShaker, appBaseUri: liveGameUri);
      expect(platform.writtenUrls.single, endsWith('/?tap=salt_shaker'));
    });
  });

  testWidgets('tapping the salt tag puts salt on the tray, and holding it again keeps it there', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var currentTime = DateTime.utc(2026, 11, 28, 15, 20);
    final platform = _FakeNfcTagPlatform();
    final nfcController = NfcTagController(platform: platform, clock: () => currentTime);

    await tester.pumpWidget(
      MaterialApp(
        home: CafeCounterScreen(
          cityController: CityEditionController(remoteConfigCityCode: 'adana'),
          judgeService: CafeJudgeService(clock: () => currentTime, forceOfflineMode: true),
          nfcController: nfcController,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('nfc_counter_menu_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nfc_start_scanning_item')));
    await tester.pumpAndSettle();
    expect(nfcController.status, NfcScanStatus.scanning);

    platform.deliverRecord!('https://example.run.app/?tap=salt_shaker');
    await tester.pump();
    expect(find.textContaining('eklendi.'), findsOneWidget);

    currentTime = currentTime.add(nfcDuplicateTapWindow);
    platform.deliverRecord!('https://example.run.app/?tap=salt_shaker');
    await tester.pump();
    expect(find.textContaining('zaten tepside'), findsOneWidget);
  });
}
