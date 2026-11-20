import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 2, second code slide: an empty reply used to parse as 5 stars.
class EmptyReplySlide extends FlutterDeckSlideWidget {
  const EmptyReplySlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/empty-reply',
            title: '11. Kural 2, kod: boş cevap başarı değildir',
            speakerNotes: 'BEAT  [13:15 - 14:45] Kural 2, ikinci kod. Boş cevaba beş yıldız hikayesi.\n'
                'SAY   "20 Kasım\'da denedim: modelin yerine sahte, boş bir cevap koydum. Süslü parantez aç, kapa, içi boş. Oyun ne yaptı? Beş yıldız, Tatlı Mükemmellik, altında Canlı Gemini rozeti ve tam puan. Neden? Solda sarı satır: yıldız yoksa beş yıldız say. Kod her boşluğu başarıyla dolduruyordu. Sağda yeni hali: bir alan eksikse ya da yanlış türdeyse, sayı yerine yazı gibi, bu bir cevap değildir. Şema biçimi tarif eder, değerin doğru olduğunu garanti etmez; Google\'ın kendi dokümanı da değerleri uygulamanızda doğrulayın diyor. Eve götüreceğiniz cümle: boş cevap, başarı değildir."\n'
                'HOLD  Sol sarı satır, sağ sarı satır, test adı. Alttaki İngilizce alıntıyı okuma; sorulursa kaynağı göster.\n'
                'NEXT  "Buraya kadar modelin cevabıydı. Şimdi uygulamanın kendisine geçiyoruz."',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 2 / 5 · KOD',
          title: 'Boş cevap, başarı değildir',
          act: StoryAct.realNumbers,
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: 'ÖNCE · BOŞLUK BAŞARIYLA DOLUYORDU',
              filePathLabel: 'cafe_review.dart · sadeleştirildi',
              accentColor: DeckColors.googleRed,
              lines: [
                CodeLine('final parsedStars = rawStars is num'),
                CodeLine('    ? rawStars.toInt()'),
                CodeLine.pointAt('    : maxCafeRatingStars;'),
                CodeLine.comment('// yıldız yoksa: 5 yıldız'),
                CodeLine(''),
                CodeLine("tasteVerdict: json['tasteVerdict']"),
                CodeLine("    ?? 'sweet_perfection',"),
              ],
            ),
            right: LessonCodeCard(
              label: 'SONRA · EKSİK CEVAP, CEVAP DEĞİL',
              filePathLabel: 'cafe_review.dart · sadeleştirildi',
              accentColor: DeckColors.googleGreen,
              lines: [
                CodeLine('if (tasteVerdict == null ||'),
                CodeLine('    ratingStars is! int ||'),
                CodeLine('    headline is! String || ...) {'),
                CodeLine.pointAt('  return null;'),
                CodeLine('}'),
                CodeLine.comment('// null: sıradaki jüriye düş'),
              ],
            ),
            proof: ProofStrip(
              testName: 'a Gemini reply with no fields does not score a sweet tray',
              outcome: '20 Kas: kırmızıydı, artık yeşil',
            ),
            advanced: 'Google dokümanı: "always validate values in your application." '
                '(aistudio.google.com/docs/structured-output, 20 Kas 2026)',
          ),
        );
      },
    );
  }
}
