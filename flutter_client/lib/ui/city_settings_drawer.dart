import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:flutter/material.dart';

const double _sheetCornerRadius = 24;
const double _sheetPadding = 20;
const double _flagBadgeWidth = 24;
const double _flagBadgeHeight = 16;

/// Custom-painted vector flag pill (`🇹🇷` crimson crescent / `🇩🇪` German tricolor) so desktop
/// platforms where `GoogleSans` lacks regional-indicator flag glyphs never render raw `"TR"` letters.
class CityFlagBadge extends StatelessWidget {
  const CityFlagBadge({
    required this.editionId,
    super.key,
  });

  final CityEditionId editionId;

  @override
  Widget build(BuildContext context) {
    final isGermany = editionId == CityEditionId.berlin;
    return Container(
      width: _flagBadgeWidth,
      height: _flagBadgeHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.85)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(
          painter: _CityFlagPainter(isGermany: isGermany),
        ),
      ),
    );
  }
}

class _CityFlagPainter extends CustomPainter {
  const _CityFlagPainter({required this.isGermany});

  final bool isGermany;

  @override
  void paint(Canvas canvas, Size size) {
    if (isGermany) {
      final bandHeight = size.height / 3;
      canvas
        ..drawRect(
          Rect.fromLTWH(0, 0, size.width, bandHeight),
          Paint()..color = const Color(0xFF1A1A1A),
        )
        ..drawRect(
          Rect.fromLTWH(0, bandHeight, size.width, bandHeight),
          Paint()..color = const Color(0xFFD32F2F),
        )
        ..drawRect(
          Rect.fromLTWH(0, bandHeight * 2, size.width, bandHeight),
          Paint()..color = const Color(0xFFFFCA28),
        );
      return;
    }

    // Turkish Crimson Flag with white crescent & star
    final redPaint = Paint()..color = const Color(0xFFE30A17);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, redPaint);
    final center = Offset(size.width * 0.44, size.height * 0.5);
    canvas
      ..drawCircle(center, size.height * 0.30, whitePaint)
      ..drawCircle(Offset(center.dx + size.height * 0.08, center.dy), size.height * 0.24, redPaint)
      ..drawCircle(Offset(size.width * 0.67, size.height * 0.5), size.height * 0.09, whitePaint);
  }

  @override
  bool shouldRepaint(covariant _CityFlagPainter oldDelegate) => oldDelegate.isGermany != isGermany;
}

/// Bottom sheet / drawer that lets Esra or workshop attendees inspect the 3-Layer City Edition
/// hierarchy and switch between `Berlin`, `Gaziantep`, `Adana`, and `Istanbul` in one tap.
class CitySettingsSheet extends StatelessWidget {
  const CitySettingsSheet({
    required this.controller,
    super.key,
  });

  final CityEditionController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final activeEdition = controller.activeEdition;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E150F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
            border: Border.all(color: const Color(0xFFC59B27), width: 1.8),
          ),
          padding: const EdgeInsets.all(_sheetPadding),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.cloud_sync_rounded, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'DevFest City Edition Switcher (3-Layer Config)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF3E5C8),
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Active Layer: ${controller.activeSourceLayer.displayLabel}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final edition in controller.allEditions)
                    Card(
                      elevation: edition.editionId == activeEdition.editionId ? 3 : 0,
                      color: edition.editionId == activeEdition.editionId
                          ? const Color(0xFF382315)
                          : const Color(0xFF281B12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: edition.editionId == activeEdition.editionId
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF6E5326),
                          width: edition.editionId == activeEdition.editionId ? 1.8 : 1.0,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        key: Key('city_option_${edition.editionId.code}'),
                        leading: CityFlagBadge(editionId: edition.editionId),
                        title: Text(
                          '${edition.cityName} (${edition.eventTitle})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF3E5C8),
                          ),
                        ),
                        subtitle: Text(
                          '${edition.cafeSubtitle} · ${edition.signatureSpecialty}',
                          style: const TextStyle(
                            color: Color(0xFFC9B086),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: edition.editionId == activeEdition.editionId
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFFD4AF37))
                            : const Icon(Icons.radio_button_unchecked, color: Color(0xFF8C6B32)),
                        onTap: () {
                          controller.selectManualOverride(edition.editionId);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Simulate Live Firebase Remote Config Push (Priority 2: active_city_id):',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFFEAD8B8),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final edition in controller.allEditions)
                        ActionChip(
                          key: Key('remote_config_chip_${edition.editionId.code}'),
                          backgroundColor: const Color(0xFF2B1E14),
                          side: const BorderSide(color: Color(0xFF9C7A2E)),
                          avatar: CityFlagBadge(editionId: edition.editionId),
                          label: Text(
                            'RC: ${edition.editionId.code}',
                            style: const TextStyle(
                              color: Color(0xFFF3E5C8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            controller
                              ..clearManualOverride()
                              ..applyRemoteConfigCity(edition.editionId);
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                      ),
                      onPressed: () {
                        controller.clearManualOverride();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text(
                        'Reset to Firebase Remote Config Default',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
