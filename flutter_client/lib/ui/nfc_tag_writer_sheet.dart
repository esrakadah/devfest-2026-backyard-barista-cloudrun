import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_controller.dart';
import 'package:flutter/material.dart';

/// Programs blank NTAG stickers for the props on the stage table: pick an ingredient,
/// then hold a tag against the back of the phone.
class NfcTagWriterSheet extends StatefulWidget {
  const NfcTagWriterSheet({
    required this.nfcController,
    required this.languageCode,
    required this.appBaseUri,
    super.key,
  });

  final NfcTagController nfcController;
  final String languageCode;
  final Uri appBaseUri;

  @override
  State<NfcTagWriterSheet> createState() => _NfcTagWriterSheetState();
}

class _NfcTagWriterSheetState extends State<NfcTagWriterSheet> {
  String? _writingIngredientId;
  String? _statusText;

  bool get _isEnglish => widget.languageCode == 'en';

  Future<void> _writeTag(CafeIngredient ingredient) async {
    final ingredientTitle = ingredient.localizedTitle(widget.languageCode);
    setState(() {
      _writingIngredientId = ingredient.id;
      _statusText = _isEnglish
          ? 'Hold a tag to the phone to write "$ingredientTitle"…'
          : '"$ingredientTitle" için etiketi telefonun arkasına tut…';
    });
    try {
      await widget.nfcController.writeTag(ingredient, appBaseUri: widget.appBaseUri);
      if (!mounted) {
        return;
      }
      setState(
        () => _statusText = _isEnglish
            ? '"$ingredientTitle" written. Stick it on the prop.'
            : '"$ingredientTitle" yazıldı. Etiketi objeye yapıştır.',
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _statusText = _isEnglish ? 'Writing failed: $error' : 'Yazılamadı: $error');
    } finally {
      if (mounted) {
        setState(() => _writingIngredientId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allIngredients = <CafeIngredient>[...IngredientsCatalog.baseItems, ...IngredientsCatalog.roundTwoCustomItems];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _isEnglish ? 'Write ingredient tags' : 'Malzeme etiketlerini yaz',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _statusText ??
                  (_isEnglish
                      ? 'Pick an ingredient, then hold a blank tag to the back of the phone.'
                      : 'Bir malzeme seç, sonra boş bir etiketi telefonun arkasına tut.'),
              key: const Key('nfc_writer_status_text'),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final ingredient in allIngredients)
                    ListTile(
                      key: Key('nfc_write_${ingredient.id}'),
                      dense: true,
                      enabled: _writingIngredientId == null,
                      leading: Icon(ingredient.isPrankItem ? Icons.warning_amber_rounded : Icons.nfc_rounded),
                      title: Text(ingredient.localizedTitle(widget.languageCode)),
                      subtitle: Text(ingredient.category.localizedTitle(widget.languageCode)),
                      trailing: _writingIngredientId == ingredient.id
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                      onTap: () => _writeTag(ingredient),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
