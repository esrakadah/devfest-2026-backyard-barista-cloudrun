import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:backyard_barista_deck/widgets/lesson_blocks.dart';
import 'package:backyard_barista_deck/widgets/lesson_layouts.dart';
import 'package:backyard_barista_deck/widgets/story_arc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

/// Lesson 3, the fix: one sealed type and a reset that is a single assignment.
class SealedOrderSlide extends FlutterDeckSlideWidget {
  const SealedOrderSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/sealed-order',
            title: '13. Kural 3, çözüm: sealed OrderState',
            speakerNotes:
                'BEAT  [16:45 - 18:15] Kural 3, çözüm. Tek tip, tek atama. Dosyanın hâlâ büyük olduğunu söyle.\n'
                'SAY   "Solda yeni kalıp: üç değişken yerine tek bir OrderState. Boşta, jüride ya da servis edildi. Kart sadece servis edildi halinin içinde yaşıyor; sipariş boştaysa gösterecek kart yok. Sağda sarı satır: sıfırlamak artık tek bir atama. Unutulacak ikinci satır kalmadı. Geç gelen cevap ne oluyor? Alttaki satır soruyor: bu cevap hâlâ beklediğim siparişe mi ait? Değilse çöpe. Dürüst olayım: bu ekran dosyası hâlâ 2.600 satırdan uzun; dosyayı düzeltmedim, durumu düzelttim. Eve götüreceğiniz cümle: aynı bilgiyi üç yerde tutarsanız biri unutulur; tek yerde tutun."\n'
                'HOLD  Soldaki üç sınıf, sağdaki sarı satır, test adı. "Dürüst olayım" cümlesinde ekrana değil salona bak.\n'
                'NEXT  "Buraya kadar cevap hep geldi. Ya hiç gelmezse?"',
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) {
        return const SlideFrame(
          eyebrow: 'KURAL 3 / 5 · ÇÖZÜM',
          title: 'Tek tip, tek atama',
          act: StoryAct.underTheHood,
          child: LessonCodeBody(
            left: LessonCodeCard(
              label: 'TİP · ÜÇ HAL, DÖRDÜNCÜSÜ YOK',
              filePathLabel: 'order_state.dart · sadeleştirildi',
              accentColor: DeckColors.googleGreen,
              lines: [
                CodeLine('sealed class OrderState {}'),
                CodeLine(''),
                CodeLine('final class OrderIdle'),
                CodeLine('    extends OrderState {}'),
                CodeLine('final class OrderEvaluating'),
                CodeLine('    extends OrderState {}'),
                CodeLine('final class OrderServed'),
                CodeLine('    extends OrderState {'),
                CodeLine('  final CafeReview review;'),
                CodeLine('}'),
              ],
            ),
            right: LessonCodeCard(
              label: 'SIFIRLAMA · TEK SATIR',
              filePathLabel: 'cafe_counter_screen.dart · sadeleştirildi',
              accentColor: DeckColors.googleGreen,
              lines: [
                CodeLine('void _advanceToNextCustomer() {'),
                CodeLine.pointAt('  _order = const OrderIdle();'),
                CodeLine('  _selectedTray.clear();'),
                CodeLine('}'),
                CodeLine(''),
                CodeLine.comment('// geç gelen cevap: hâlâ aynı sipariş mi?'),
                CodeLine('if (!identical(_order, evaluatingOrder)) {'),
                CodeLine('  return;'),
                CodeLine('}'),
              ],
            ),
            proof: ProofStrip(
              testName: 'a verdict that arrives after Next Customer is dropped',
              outcome: 'kırmızıydı, artık yeşil',
            ),
            advanced: 'açık kalan: cafe_counter_screen.dart hâlâ 2.670 satır ve 22 sınıf; düzelen dosya değil, durum',
          ),
        );
      },
    );
  }
}
