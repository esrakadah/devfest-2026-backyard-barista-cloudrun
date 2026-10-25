import 'package:backyard_barista_deck/theme.dart';
import 'package:backyard_barista_deck/widgets/deck_cards.dart';
import 'package:flutter/material.dart';

/// The screen the audience sees when something throws on stage or when conference Wi-Fi drops.
class DemoHiccupScreen extends StatelessWidget {
  const DemoHiccupScreen({required this.message, super.key});

  static const double _iconSize = 80;
  static const double _titleSize = 56;
  static const double _messageSize = 28;
  static const double _padding = 36;
  static const double _gap = 18;

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DeckColors.navy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: DeckCard(
              padding: const EdgeInsets.all(40),
              backgroundColor: DeckColors.surfaceElevated,
              borderColor: DeckColors.googleRed.withValues(alpha: 0.55),
              accentStripeColor: DeckColors.googleRed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_tethering_error, color: DeckColors.googleRed, size: _iconSize),
                      SizedBox(width: 14),
                      PillTag(
                        label: 'DETERMINISTIC OFFLINE FALLBACK READY',
                        color: DeckColors.googleYellow,
                        icon: Icons.bolt,
                      ),
                    ],
                  ),
                  const SizedBox(height: _gap),
                  const Text(
                    'Demo Hiccup · Offline Fallback Ready',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: DeckFonts.sans,
                      color: DeckColors.offWhite,
                      fontSize: _titleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: _gap),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DeckColors.surfaceInset,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: DeckColors.outlineLight),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: DeckFonts.mono,
                        color: DeckColors.googleYellow,
                        fontSize: _messageSize,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
