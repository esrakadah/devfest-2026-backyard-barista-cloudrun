import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads every font family in the test asset bundle (GoogleSansFlex, RobotoMono, MaterialIcons).
///
/// Without this, widget tests lay text out in the wide Ahem test font, which overflows layouts that fit
/// with the real fonts on stage. Loading the real fonts makes overflow checks match the projector.
Future<void> loadDeckFonts() async {
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
