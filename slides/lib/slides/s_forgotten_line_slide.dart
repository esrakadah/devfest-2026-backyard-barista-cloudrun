import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 3, the bug: three loose fields and the one reset that forgot a line.
class ForgottenLineSlide extends FlutterDeckSlideWidget {
  const ForgottenLineSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/forgotten-line',
            title: '16. Kural 3, hata: unutulan satır',
            speakerNotes: 'BEAT  [16:45 - 18:00] Kural 3, hata. Üç değişken, üç sıfırlama yeri, bir unutulan satır.\n'
                'SAY   "Solda siparişin eski hali: üç ayrı değişken, yani kodun bilgi tuttuğu üç ayrı kutu. Jüri düşünüyor mu, kaçıncı tepsi, son karar ne. Ortadaki bir sayaç: cevap geldiğinde sayı değişmişse cevap eski tepsiye aittir, atılır. Siparişi sıfırlayan üç yer var: Temizle, şehir değiştir, Sıradaki Müşteri. Her biri üç değişkeni de hatırlamak zorunda. Bu hata daha önce bir kez düzeltildi; düzeltme iki yeri kapattı, üçüncüyü unuttu. Sarı satır, unutulan satırın olması gereken yer. Sağda oyuncunun gördüğü: boş tepsiye beş yıldız. Bunu bir testle kanıtladım: test kırmızı yandı."\n'
                'HOLD  Soldaki üç değişkeni parmakla say, sarı satırda dur. Sonra sağdaki kart.\n'
                'NEXT  "Çözüm, unutulan satırı eklemek değil."',
          ),
        );

  static const double _tileTitleSize = 40;
  static const double _tileLineSize = 30;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 3 / 5 · HATA',
          title: 'Üç değişken, üç sıfırlama yeri, bir unutulan satır',
          act: StoryAct.underTheHood,
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: 'ÖNCE',
              filePathLabel: 'cafe_counter_screen.dart · sadeleştirildi',
              accentColor: DeckColors.googleRed,
              lines: [
                CodeLine('bool _isEvaluatingOrder = false;'),
                CodeLine('int _trayGeneration = 0;'),
                CodeLine('CafeReview? _latestReview;'),
                CodeLine(''),
                CodeLine('void _advanceToNextCustomer() {'),
                CodeLine('  _selectedTray.clear();'),
                CodeLine('  _latestReview = null;'),
                CodeLine.pointAt('  // _trayGeneration++ burada yok'),
                CodeLine('}'),
              ],
            ),
            right: DeckFeatureCard(
              badge: 'OYUNCU NE GÖRDÜ',
              title: 'Boş tepsiye 5 yıldız',
              talkTitleFontSize: _tileTitleSize,
              talkBulletFontSize: _tileLineSize,
              accentColor: DeckColors.googleRed,
              bullets: [
                "Servis Et'e bas, hemen Sıradaki Müşteri'ye bas.",
                'Yeni müşteri geldi, tepsi boş (0/3).',
                'Yine de 5 yıldızlı kart çıktı.',
                'İki oyuncuya +50 puan, ekip Lv.2 oldu.',
              ],
              footerText: 'main 408f1c6 · ekran testiyle yakalandı',
            ),
            proof: ProofStrip.failing(
              testName: 'a verdict that arrives after Next Customer is dropped',
              outcome: 'kırmızı',
            ),
          ),
        );
      },
    );
  }
}
