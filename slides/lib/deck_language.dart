/// Compile-time language and city switches for the Backyard Barista deck.
///
/// English is the default (`--dart-define=DECK_LANG=en`).
/// Run or build with `--dart-define=DECK_LANG=tr` for the Turkish main-hall talk deck
/// (defaults to `DECK_CITY=konya` for DevFest Konya 2026; pass `--dart-define=DECK_CITY=izmir`
/// for DevFest İzmir 2026).
const String _deckLanguage = String.fromEnvironment('DECK_LANG', defaultValue: 'en');

/// True when the deck runs with `--dart-define=DECK_LANG=tr`.
const bool isTurkishDeck = _deckLanguage == 'tr';

/// Active Turkish tour stop (`konya` on 21 Nov 2026, `izmir` on 5 Dec 2026).
const String deckCity = String.fromEnvironment('DECK_CITY', defaultValue: 'konya');

/// True when the Turkish deck targets DevFest İzmir (`--dart-define=DECK_CITY=izmir`).
const bool isIzmirDeck = deckCity == 'izmir';
