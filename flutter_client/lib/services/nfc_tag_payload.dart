import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';

/// Query parameter that carries the ingredient id inside an NFC tag URL record.
const String nfcTagIngredientQueryKey = 'tap';

/// Prefix for plain NDEF text records, for tags written with generic NFC apps.
const String nfcTagTextPrefix = 'barista:';

/// Builds the URL written to a sticker tag. A URL record (not a text record) means a phone
/// without Web NFC still opens the live game when it touches the tag.
String nfcTagUrlForIngredient(CafeIngredient ingredient, {required Uri appBaseUri}) {
  final gameUri = Uri(
    scheme: appBaseUri.scheme,
    host: appBaseUri.host,
    port: appBaseUri.hasPort ? appBaseUri.port : null,
    path: '/',
  );
  return gameUri.replace(queryParameters: <String, String>{nfcTagIngredientQueryKey: ingredient.id}).toString();
}

/// Resolves the counter ingredient behind a decoded NDEF record, or null when the tag
/// belongs to something else (a conference badge, a business card).
CafeIngredient? ingredientFromNfcRecord(String recordText) {
  final trimmedRecord = recordText.trim();
  if (trimmedRecord.startsWith(nfcTagTextPrefix)) {
    return IngredientsCatalog.findById(trimmedRecord.substring(nfcTagTextPrefix.length));
  }
  final recordUri = Uri.tryParse(trimmedRecord);
  final ingredientId = recordUri?.queryParameters[nfcTagIngredientQueryKey];
  if (ingredientId == null) {
    return null;
  }
  return IngredientsCatalog.findById(ingredientId);
}
