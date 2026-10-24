import 'package:backyard_barista_deck/theme.dart';
import 'package:flutter/material.dart';

/// The screen the audience sees when something throws on stage or when conference Wi-Fi drops.
class DemoHiccupScreen extends StatelessWidget {
  const DemoHiccupScreen({required this.message, super.key});

  static const double _iconSize = 64;
  static const double _titleSize = 40;
  static const double _messageSize = 20;
  static const double _padding = 32;
  static const double _gap = 16;

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DeckColors.navy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_tethering_error, color: DeckColors.googleRed, size: _iconSize),
              const SizedBox(height: _gap),
              const Text(
                'Demo Hiccup · Offline Fallback Ready',
                style: TextStyle(
                  fontFamily: DeckFonts.sans,
                  color: DeckColors.googleYellow,
                  fontSize: _titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _gap),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: DeckFonts.mono,
                  color: DeckColors.offWhite,
                  fontSize: _messageSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
