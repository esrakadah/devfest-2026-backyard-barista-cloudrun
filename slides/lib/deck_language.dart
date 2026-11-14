/// The language the slides and speaker notes are written in.
///
/// English is the default. Run or build with `--dart-define=DECK_LANG=tr` for
/// the Turkish deck (DevFest Gaziantep and the other stages in Türkiye).
const String _deckLanguage = String.fromEnvironment('DECK_LANG', defaultValue: 'en');

/// True when the deck runs with `--dart-define=DECK_LANG=tr`.
///
/// A compile-time constant, so `isTurkishDeck ? 'Türkçe' : 'English'` stays
/// valid inside `const` widgets and slide configurations.
const bool isTurkishDeck = _deckLanguage == 'tr';
