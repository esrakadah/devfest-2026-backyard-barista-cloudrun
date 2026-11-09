import 'package:backyard_barista_cloudrun/services/nfc_platform_stub.dart'
    if (dart.library.js_interop) 'package:backyard_barista_cloudrun/services/nfc_platform_web.dart';

/// Reads and writes NDEF tags. Web NFC exists only in Chrome on Android, so every other
/// platform gets [UnsupportedNfcTagPlatform].
abstract class NfcTagPlatform {
  const NfcTagPlatform();

  bool get isSupported;

  /// Starts listening for tags and throws when the browser refuses (permission denied,
  /// NFC switched off). Must be called from a user gesture on the web.
  /// [onRecordText] receives each decoded record of a tag that was touched, and
  /// [onReadError] fires when a tag was detected but could not be read.
  Future<void> startScan({
    required void Function(String recordText) onRecordText,
    required void Function() onReadError,
  });

  /// Writes a single URL record to the next tag that touches the phone.
  Future<void> writeUrl(String url);
}

class UnsupportedNfcTagPlatform extends NfcTagPlatform {
  const UnsupportedNfcTagPlatform();

  @override
  bool get isSupported => false;

  @override
  Future<void> startScan({
    required void Function(String recordText) onRecordText,
    required void Function() onReadError,
  }) async {
    throw UnsupportedError('NFC is not available in this browser.');
  }

  @override
  Future<void> writeUrl(String url) async {
    throw UnsupportedError('NFC is not available in this browser.');
  }
}

NfcTagPlatform createNfcTagPlatform() => createPlatformNfcTagPlatform();
