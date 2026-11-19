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
                "BEAT  [BACKUP · Konya, 45 sn] Slayt 11'den Stage Navigator ile gelinir (Slayt 18). Aynı jüri, iki API: üretmek mi, karar vermek mi?\n"
                'SAY   "Bizim jüri iki iş yapıyor. Birincisi esprili yorumu yazmak: bu bir üretim işi, metin lazım. İkincisi tatlı mı tuzlu mu demek: bu ise kapalı uçlu bir karar. Bugün ikisini tek generateContent çağrısında yapıyoruz. Google\'ın yeni Decisions API\'si kararı ayrı soruyor: metin üretmiyor, her seçenek için kalibre edilmiş olasılık döndürüyor ve çıktı token\'ı sıfır. Henüz Dart SDK\'sı yok, package:http ile düz REST çağrısı yeterli. Bu oyuna bağlamadım çünkü tuz kontrolünü zaten Dart kodumuz kesin olarak yapıyor; ama kuralla yazamadığınız sınıflandırmalarda mutlaka deneyin."\n'
                "HOLD  Önce soldaki 'tasteVerdict' satırını, sonra sağdaki 'type': 'choice' satırını göster. Gecikme rakamı söyleme. [Fact (aistudio.google.com/docs/decisions-api, 13 Nov 2026): gemini-decision-1; noul, choice, score; 1 to 1,000 questions per request; output tokens always 0, only input tokens billed; SDKs: Python, JS 3.2+, REST; v1beta only].\n"
                'NEXT  "Kaldığımız yere dönelim." (Stage Navigator ile 12. slayt.)',
          ),
        );

  static const double _columnGap = 24;
  static const double _chipGap = 14;
  static const double _rowGap = 16;

  static const String _generateSnippet = '''
// ${isTurkishDeck ? 'Bugün: tek çağrı hem espriyi hem kararı yazıyor' : 'Today: one call writes the joke AND the verdict'}
POST v1beta/models/gemini-3.5-flash-lite:generateContent
'generationConfig': {
  'responseMimeType': 'application/json',
  'responseSchema': {            // CafeReview
    'tasteVerdict': STRING,      // ${isTurkishDeck ? 'karar' : 'the decision'}
    'ratingStars': INTEGER,
    'customerFace': STRING,
    'headline': STRING,          // ${isTurkishDeck ? 'espri' : 'the joke'}
    'customerReaction': STRING,  // ${isTurkishDeck ? 'espri' : 'the joke'}
    'cityBonusTip': INTEGER,
  },
}
// ${isTurkishDeck ? 'Dart kararı yine de tuz ve acı bayraklarıyla' : 'Dart still checks the verdict against the'}
// ${isTurkishDeck ? 'karşılaştırır (_verdictMatchesPranks)' : 'salt and chili flags (_verdictMatchesPranks)'}''';

  static const String _decideSnippet = '''
// ${isTurkishDeck ? 'Öneri: kararı ayrı sor (oyunda yok)' : 'Proposal: ask the decision on its own (not in the game)'}
// ${isTurkishDeck ? 'Dart SDK yok: package:http ile düz REST' : 'No Dart SDK: plain REST from package:http'}
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
// ${isTurkishDeck ? 'answers.taste_verdict: seçim, olasılıklar, güven' : 'answers.taste_verdict: choice, probabilities, confidence'}''';

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
              ? 'Espri için metin üretmek gerekir. Tatlı mı tuzlu mu ise sabit bir listeden seçilen bir karardır.'
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
                      label: isTurkishDeck ? 'noul (evet/hayır) · choice · score' : 'noul (yes/no) · choice · score',
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
                      value: isTurkishDeck ? "0 çıktı token'ı" : '0 Output Tokens',
                      label: isTurkishDeck ? "YALNIZCA GİRDİ TOKEN'I ÜCRETLİ" : 'Only Input Tokens Billed',
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
