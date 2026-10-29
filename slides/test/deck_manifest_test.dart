import 'dart:io';

import 'package:backyard_barista_deck/plugins/presenter_menu_plugin.dart';
import 'package:backyard_barista_deck/slides/slides.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locked 16-slide main running order + 1 backup slide (`/demo-hiccup`).
const List<String> expectedRunningOrder = [
  '/title',
  '/sweet-or-salty',
  '/workshop-contract',
  '/ai-studio-pipeline',
  '/meet-antigravity',
  '/pure-flutter-widgets',
  '/real-numbers-latency',
  '/real-numbers-cost',
  '/room-quota-trap',
  '/multi-city-remote-config',
  '/salt-sugar-mechanic',
  '/hybrid-asset-pipeline',
  '/live-build-dashboard',
  '/architecture-recap',
  '/gde-artifacts-tour',
  '/winner-podium-closing',
  '/demo-hiccup',
];

void main() {
  group('the Backyard Barista deck manifest', () {
    test('has exactly 16 main slides and 1 backup slide', () {
      expect(mainSlides.length, 16);
      expect(backupSlides.length, 1);
      expect(deckSlides.length, 17);
    });

    test('every slide declares a configuration with a route', () {
      for (final slide in deckSlides) {
        final configuration = slide.configuration;
        expect(configuration, isNotNull, reason: '${slide.runtimeType} has no configuration');
        expect(configuration!.route, startsWith('/'), reason: '${slide.runtimeType} route does not start with /');
        expect(configuration.route.length, greaterThan(1), reason: '${slide.runtimeType} has an empty slug');
      }
    });

    test('routes are unique', () {
      final routes = deckSlides.map((slide) => slide.configuration!.route).toList();
      expect(routes.toSet().length, routes.length, reason: 'duplicate route: ${_duplicates(routes)}');
    });

    test('the running order is locked', () {
      expect(deckSlides.map((slide) => slide.configuration!.route).toList(), expectedRunningOrder);
    });

    test('every slide carries speaker notes', () {
      final blank = deckSlides
          .where((slide) => (slide.configuration?.speakerNotes ?? '').trim().isEmpty)
          .map((slide) => slide.configuration?.route ?? slide.runtimeType.toString())
          .toList();
      expect(blank, isEmpty, reason: 'no notes on: ${blank.join(', ')}');
    });

    test('speaker notes follow the strict BEAT, SAY, HOLD, NEXT shape and contain no em-dashes', () {
      for (final slide in deckSlides) {
        final route = slide.configuration!.route;
        final notes = slide.configuration!.speakerNotes;
        final noteLines = notes.split('\n');
        for (final keyword in ['BEAT', 'SAY', 'HOLD', 'NEXT']) {
          expect(
            noteLines.any((line) => line.startsWith(keyword)),
            isTrue,
            reason: '$route has no line starting with $keyword',
          );
        }
        expect(notes.contains('—'), isFalse, reason: '$route speakerNotes contains an em-dash');
        expect(notes.contains('–'), isFalse, reason: '$route speakerNotes contains an en-dash');
      }
    });

    test('every slide class is named after its route', () {
      for (final slide in deckSlides) {
        final className = slide.runtimeType.toString();
        expect(_routeFor(className), slide.configuration!.route, reason: '$className does not match its route');
      }
    });

    test('every slide class lives in the file its name implies', () {
      final fileNames = Directory(
        'lib/slides',
      ).listSync(recursive: true).whereType<File>().map((file) => file.uri.pathSegments.last).toSet();
      for (final slide in deckSlides) {
        final className = slide.runtimeType.toString();
        expect(fileNames, contains(_fileNameFor(className)), reason: '$className is not in ${_fileNameFor(className)}');
      }
    });

    test('slideNumberForRoute is one-based and agrees with the order', () {
      expect(slideNumberForRoute('/title'), 1);
      expect(slideNumberForRoute('/gde-artifacts-tour'), 15);
      expect(slideNumberForRoute('/winner-podium-closing'), 16);
      expect(slideNumberForRoute('/demo-hiccup'), 17);
      expect(slideNumberForRoute('/does-not-exist'), isNull);
    });
  });

  group('the presenter menu', () {
    test('every section jumps to a slide that exists', () {
      for (final section in presenterSections) {
        expect(
          slideNumberForRoute(section.route),
          isNotNull,
          reason: '"${section.label}" points at ${section.route}, which is not in the deck',
        );
      }
    });

    test('sections are offered in running order', () {
      final numbers = presenterSections.map((section) => slideNumberForRoute(section.route)!).toList();
      expect(numbers, orderedEquals(List<int>.from(numbers)..sort()));
    });
  });
}

List<String> _duplicates(List<String> values) {
  final seen = <String>{};
  return values.where((value) => !seen.add(value)).toList();
}

List<String> _words(String className) {
  final stem = className.endsWith('Slide') ? className.substring(0, className.length - 'Slide'.length) : className;
  return RegExp('[A-Z][a-z]*|[0-9]+').allMatches(stem).map((match) => match.group(0)!.toLowerCase()).toList();
}

String _routeFor(String className) => '/${_words(className).join('-')}';

String _fileNameFor(String className) => 's_${_words(className).join('_')}_slide.dart';
