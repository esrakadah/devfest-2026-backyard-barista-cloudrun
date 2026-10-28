// Renders the desktop 2x2 cafe counter with real bundled GoogleSans fonts and 9D PNG assets
// to ../docs/visuals/game-counter-desktop.png.
//
// Run from flutter_client/: flutter test tool/export_counter_screenshot_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:backyard_barista_cloudrun/main.dart';
import 'package:backyard_barista_cloudrun/services/cafe_judge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadBundledFonts() async {
  final manifestJson = await rootBundle.loadString('FontManifest.json');
  final manifest = (jsonDecode(manifestJson) as List<dynamic>).cast<Map<String, dynamic>>();
  for (final family in manifest) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<void> _precacheImages(WidgetTester tester) async {
  final elements = find.byType(Image).evaluate().toList();
  await tester.runAsync(() async {
    for (final element in elements) {
      final widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
  });
}

void main() {
  testWidgets('export desktop 2x2 cafe counter screenshot', (tester) async {
    await _loadBundledFonts();
    tester.view.physicalSize = const Size(1400, 1140);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final cityController = CityEditionController(remoteConfigCityCode: 'gaziantep');
    final judgeService = CafeJudgeService(
      clock: () => DateTime.utc(2026, 11, 15, 14),
      forceOfflineMode: true,
    );

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: BackyardBaristaApp(
          cityController: cityController,
          judgeService: judgeService,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _precacheImages(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ingredient_card_menengic_coffee')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ingredient_card_baklava')));
    await tester.pumpAndSettle();

    final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1.5));
    final bytes = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    final outFile = File('../docs/visuals/game-counter-desktop.png');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
