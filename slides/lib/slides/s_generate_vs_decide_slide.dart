import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class GenerateVsDecideSlide extends FlutterDeckSlideWidget {
  const GenerateVsDecideSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/generate-vs-decide',
            title: isTurkishDeck
                ? 'Yedek: üretmek mi, karar vermek mi? CafeReview ve Decisions API'
                : 'Backup: Generate or Decide? CafeReview vs Decisions API',
            speakerNotes:
                "BEAT  [BACKUP · Konya, 60 sn] Slayt 11'den Stage Navigator ile gelinir. Aynı jüri, iki API: üretmek mi, karar vermek mi?\n"
                'SAY   "Bizim jüri iki iş yapıyor. Birincisi komik yorumu yazmak: bu üretim işi, metin lazım. İkincisi tatlı mı tuzlu mu demek: bu bir karar, cevabı üç seçenekten biri. Bugün ikisini tek generateContent çağrısında yapıyoruz ve kararı JSON\'dan okuyoruz. Google\'ın Decisions API\'si kararı ayrı soruyor: metin üretmiyor, her seçenek için olasılık döndürüyor, çıktı tokenı sıfır. Dart SDK\'sı yok, package:http ile REST çağrısı yeterli. Oyuna bağlamadım, çünkü tuz kontrolünü zaten Dart yapıyor. Kodla yazamadığınız kararlarda deneyin."\n'
                "HOLD  Önce soldaki 'tasteVerdict' satırını, sonra sağdaki 'type': 'choice' satırını göster. Gecikme ve fiyat rakamı söyleme. [Fact (cafe_judge_service.dart:203, 220-241): generateContent + responseSchema; cafe_judge_service.dart:369-379: _verdictMatchesPranks]. [Fact (aistudio.google.com/docs/decisions-api, 13 Nov 2026): gemini-decision-1; noul, choice, score; 1 to 1,000 questions per request; output tokens always 0, only input tokens billed; SDK tabs Python and JavaScript (3.2+) and REST; v1beta only].\n"
                'NEXT  "Stage Navigator ile akışa dön: Konya akışında sıradaki adım canlı demo."',
          ),
        );

  static const double _columnGap = 24;
  static const double _chipGap = 14;
  static const double _rowGap = 16;

  static const String _generateSnippet = '''
// Today: one call writes the joke AND the verdict
POST v1beta/models/gemini-3.5-flash-lite:generateContent
'generationConfig': {
  'responseMimeType': 'application/json',
  'responseSchema': {            // CafeReview
    'tasteVerdict': STRING,      // the decision
    'ratingStars': INTEGER,
    'customerFace': STRING,
    'headline': STRING,          // the joke
    'customerReaction': STRING,  // the joke
    'cityBonusTip': INTEGER,
  },
}
// Dart still checks the verdict against the
// salt and chili flags (_verdictMatchesPranks)''';

  static const String _decideSnippet = '''
// Proposal: ask the decision on its own (not in the game)
// No Dart SDK: plain REST from package:http
POST v1beta/decisions
{
  'model': 'gemini-decision-1',
  'input': trayDescription,
  'questions': {
    'taste_verdict': {
      'type': 'choice',
      'instructions': 'Which verdict fits this tray?',
      'criteria': {
        'salty_sabotage': 'Salt in a sweet order.',
        'spicy_chaos': 'Chili sauce in a sweet order.',
        'sweet_perfection': 'Sweet, complete tray.',
      },
    },
  },
}
// answers.taste_verdict: choice, probabilities, confidence''';

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: isTurkishDeck ? 'KAPUTUN ALTI · ÜRETMEK Mİ, KARAR VERMEK Mİ' : 'UNDER THE HOOD · GENERATE VS DECIDE',
          title: isTurkishDeck
              ? 'Üretmek mi, karar vermek mi? Aynı jüri, iki API'
              : 'Generate or Decide? Same Judge, Two APIs',
          act: StoryAct.underTheHood,
          subtitle: isTurkishDeck
              ? 'Laf sokma için üretilmiş metin gerekir. Tatlı mı tuzlu mu ise sabit bir listeden seçilen bir karardır.'
              : 'The roast needs generated text. Sweet or salty is a decision from a fixed list.',
          accentColor: DeckColors.googleGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      value: 'gemini-decision-1',
                      label: isTurkishDeck ? 'DECISIONS API MODELİ' : 'Decisions API Model',
                      accentColor: DeckColors.googleGreen,
                    ),
                  ),
                  SizedBox(width: _chipGap),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '3 soru tipi' : '3 Question Types',
                      label: isTurkishDeck ? 'NOUL (EVET/HAYIR) · CHOICE · SCORE' : 'noul (yes/no) · choice · score',
                    ),
                  ),
                  SizedBox(width: _chipGap),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '1 ile 1.000' : '1 to 1,000',
                      label: isTurkishDeck ? 'İSTEK BAŞINA SORU' : 'Questions per Request',
                    ),
                  ),
                  SizedBox(width: _chipGap),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? '0 çıktı tokenı' : '0 Output Tokens',
                      label: isTurkishDeck ? 'YALNIZCA GİRDİ TOKENI ÜCRETLİ' : 'Only Input Tokens Billed',
                      accentColor: DeckColors.googleYellow,
                    ),
                  ),
                  SizedBox(width: _chipGap),
                  Expanded(
                    child: StatChip(
                      value: isTurkishDeck ? 'REST, Dart SDK yok' : 'REST, no Dart SDK',
                      label: isTurkishDeck ? 'PYTHON VE JS SDK · V1BETA' : 'Python & JS SDKs · v1beta',
                      accentColor: DeckColors.googleRed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _rowGap),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DeckCodeCard(
                        filePathLabel: 'flutter_client/lib/services/cafe_judge_service.dart',
                        code: _generateSnippet,
                        accentColor: DeckColors.googleYellow,
                        badgeLabel: isTurkishDeck ? 'ÜRETİM' : 'GENERATE',
                      ),
                    ),
                    SizedBox(width: _columnGap),
                    Expanded(
                      child: DeckCodeCard(
                        filePathLabel: 'aistudio.google.com/docs/decisions-api',
                        code: _decideSnippet,
                        accentColor: DeckColors.googleGreen,
                        badgeLabel: isTurkishDeck ? 'KARAR' : 'DECIDE',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
