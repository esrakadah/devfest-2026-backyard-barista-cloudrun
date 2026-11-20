import 'package:backyard_barista_deck/deck_language.dart';
import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';

class BanaUlasinSlide extends FlutterDeckSlideWidget {
  const BanaUlasinSlide({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/bana-ulasin',
            title: isTurkishDeck ? '16. Bana ulaşın' : '16. Find me',
            footer: FlutterDeckFooterConfiguration(showFooter: false),
            speakerNotes: isTurkishDeck
                ? 'BEAT  [28:15 - 28:45] Kapanış ve fuaye daveti. Bu slayt konuşma bittikten sonra ekranda açık kalsın.\n'
                    'SAY   "${isIzmirDeck ? "Yazılarım, açık kaynak kodlar ve iletişim bilgilerim ekrandaki QR kodda, yani esratech.com adresinde. Beni dinlediğiniz ve oyuna katıldığınız için çok teşekkür ederim İzmir, fuayede görüşmek üzere!" : "Yazılarım, kodlarım ve iletişim bilgilerim ekrandaki QR kodda, esratech.com adresinde. Ayrı bir soru-cevap süremiz yok ama hemen dışarıda, fuayede olacağım; gelin tanışalım, kodu ve mimariyi konuşalım. Çok teşekkürler Konya!"}"\n'
                    'HOLD  Gülümse, salona el salla, bu slaytı ekranda bırakarak HDMI kablosunu sökmeden önce sahne ekibinin işaretini bekle.\n'
                    'NEXT  Son ana slayt (yedek slaytlar: /demo-hiccup ve /generate-vs-decide).'
                : 'BEAT  Closing.\n'
                    'SAY   "My articles and how to reach me are behind this QR code. Thank you!"\n'
                    'HOLD  Leave this slide on screen after the questions.\n'
                    'NEXT  Last slide.',
          ),
        );

  static const double _qrHeight = 440;
  static const double _qrPadding = 24;

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (isCandleTheme) const Positioned(left: 60, right: 60, top: 34, child: CandleRow(clearCenter: true)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  isTurkishDeck ? 'Bana ulaşın' : 'Find me',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.display,
                    fontSize: DeckTypeScale.header,
                    fontWeight: FontWeight.w800,
                    color: DeckColors.offWhite,
                  ),
                ),
                const SizedBox(height: 40),
                DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(_qrPadding),
                    child: Image.asset(
                      'assets/images/esratech_qr.png',
                      height: _qrHeight,
                      filterQuality: FilterQuality.none,
                      semanticLabel: isTurkishDeck ? 'esratech.com için QR kod' : 'QR code for esratech.com',
                    ),
                  ),
                ),
                if (isTurkishDeck) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Şakayı model yazsın, kararı kodunuz versin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: DeckFonts.display,
                      fontSize: DeckTypeScale.title,
                      fontWeight: FontWeight.w700,
                      color: DeckColors.googleYellow,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Text(
                  isTurkishDeck ? (isIzmirDeck ? 'Teşekkürler İzmir!' : 'Teşekkürler Konya!') : 'Thank you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.display,
                    fontSize: DeckTypeScale.header,
                    fontWeight: FontWeight.w800,
                    color: DeckColors.offWhite,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  isTurkishDeck
                      ? (isIzmirDeck
                          ? 'esratech.com · @esrakadah · DevFest İzmir 2026'
                          : 'esratech.com · @esrakadah · Flutter & Dart GDE, kendi görüşlerim')
                      : 'esratech.com · @esrakadah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: DeckFonts.sans,
                    fontSize: DeckTypeScale.bodyLarge,
                    color: DeckColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
