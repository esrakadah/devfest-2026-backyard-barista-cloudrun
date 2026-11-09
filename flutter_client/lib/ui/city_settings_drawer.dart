import 'package:backyard_barista_cloudrun/config/city_edition_controller.dart';
import 'package:flutter/material.dart';

const double _sheetCornerRadius = 24;
const double _sheetPadding = 20;

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
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
          ),
          padding: const EdgeInsets.all(_sheetPadding),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.cloud_sync_rounded, color: Color(0xFF6D4C41)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'DevFest City Edition Switcher (3-Layer Config)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Active Layer: ${controller.activeSourceLayer.displayLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5D4037),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                for (final edition in controller.allEditions)
                  Card(
                    elevation: edition.editionId == activeEdition.editionId ? 3 : 0,
                    color: edition.editionId == activeEdition.editionId
                        ? const Color(0xFFFFEFE0)
                        : const Color(0xFFF5EFEA),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      key: Key('city_option_${edition.editionId.code}'),
                      leading: Text(
                        edition.flagEmoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                      title: Text(
                        '${edition.cityName} (${edition.eventTitle})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${edition.cafeSubtitle} · ${edition.signatureSpecialty}',
                      ),
                      trailing: edition.editionId == activeEdition.editionId
                          ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32))
                          : const Icon(Icons.radio_button_unchecked),
                      onTap: () {
                        controller.selectManualOverride(edition.editionId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      controller.clearManualOverride();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset to Firebase Remote Config Default'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
