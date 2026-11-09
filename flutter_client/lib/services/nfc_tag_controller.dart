import 'package:backyard_barista_cloudrun/data/ingredients_catalog.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_payload.dart';
import 'package:backyard_barista_cloudrun/services/nfc_tag_platform.dart';
import 'package:flutter/foundation.dart';

/// A tag held against the phone fires several reads in a row; ignore repeats inside this window.
const Duration nfcDuplicateTapWindow = Duration(milliseconds: 1500);

enum NfcScanStatus { unsupported, idle, scanning, failed }

/// Turns physical sticker taps (a salt shaker prop, a sugar jar) into counter ingredients.
class NfcTagController extends ChangeNotifier {
  NfcTagController({NfcTagPlatform? platform, DateTime Function()? clock})
      : _platform = platform ?? createNfcTagPlatform(),
        _clock = clock ?? DateTime.now {
    _status = _platform.isSupported ? NfcScanStatus.idle : NfcScanStatus.unsupported;
  }

  final NfcTagPlatform _platform;
  final DateTime Function() _clock;
  late NfcScanStatus _status;
  String? _lastErrorMessage;
  String? _lastIngredientId;
  DateTime? _lastIngredientTime;

  /// Called once per accepted tap; the counter screen places the ingredient on the tray.
  void Function(CafeIngredient ingredient)? onIngredientTapped;

  NfcScanStatus get status => _status;
  bool get isSupported => _status != NfcScanStatus.unsupported;
  String? get lastErrorMessage => _lastErrorMessage;

  Future<void> startScanning() async {
    if (!isSupported || _status == NfcScanStatus.scanning) {
      return;
    }
    _status = NfcScanStatus.scanning;
    _lastErrorMessage = null;
    notifyListeners();
    try {
      await _platform.startScan(onRecordText: handleRecordText, onReadError: _handleReadError);
    } on Object catch (error) {
      _status = NfcScanStatus.failed;
      _lastErrorMessage = 'NFC could not start: $error';
      notifyListeners();
    }
  }

  @visibleForTesting
  void handleRecordText(String recordText) {
    final ingredient = ingredientFromNfcRecord(recordText);
    if (ingredient == null) {
      return;
    }
    final tapTime = _clock();
    final previousTapTime = _lastIngredientTime;
    final isRepeatedRead = ingredient.id == _lastIngredientId &&
        previousTapTime != null &&
        tapTime.difference(previousTapTime) < nfcDuplicateTapWindow;
    _lastIngredientId = ingredient.id;
    _lastIngredientTime = tapTime;
    if (!isRepeatedRead) {
      onIngredientTapped?.call(ingredient);
    }
  }

  Future<void> writeTag(CafeIngredient ingredient, {required Uri appBaseUri}) {
    return _platform.writeUrl(nfcTagUrlForIngredient(ingredient, appBaseUri: appBaseUri));
  }

  void _handleReadError() {
    _lastErrorMessage = 'That tag could not be read. Hold it still for a second.';
    notifyListeners();
  }
}
