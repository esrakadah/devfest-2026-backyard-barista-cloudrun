import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:backyard_barista_cloudrun/services/nfc_tag_platform.dart';
import 'package:web/web.dart' as web;

/// package:web has no Web NFC bindings yet, so these mirror the W3C Web NFC spec
/// (https://w3c.github.io/web-nfc/) for the members this game uses.
@JS('NDEFReader')
extension type _NdefReader._(JSObject _) implements JSObject {
  external _NdefReader();

  external JSPromise<JSAny?> scan();
  external JSPromise<JSAny?> write(JSAny message);
  external JSFunction? get onreading;
  external set onreading(JSFunction? handler);
  external JSFunction? get onreadingerror;
  external set onreadingerror(JSFunction? handler);
}

extension type _NdefReadingEvent._(JSObject _) implements JSObject {
  external _NdefMessage get message;
}

extension type _NdefMessage._(JSObject _) implements JSObject {
  external JSArray<_NdefRecord> get records;
}

extension type _NdefRecord._(JSObject _) implements JSObject {
  external String get recordType;
  external String? get encoding;
  external JSDataView? get data;
}

NfcTagPlatform createPlatformNfcTagPlatform() => _WebNfcTagPlatform();

class _WebNfcTagPlatform extends NfcTagPlatform {
  _NdefReader? _scanningReader;

  @override
  bool get isSupported => globalContext.has('NDEFReader');

  @override
  Future<void> startScan({
    required void Function(String recordText) onRecordText,
    required void Function() onReadError,
  }) async {
    final reader = _scanningReader ??= _NdefReader();
    reader
      ..onreading = (_NdefReadingEvent event) {
        for (final record in event.message.records.toDart) {
          final recordText = _decodeRecord(record);
          if (recordText != null) {
            onRecordText(recordText);
          }
        }
      }.toJS
      ..onreadingerror = (JSAny? _) {
        onReadError();
      }.toJS;
    await reader.scan().toDart;
  }

  @override
  Future<void> writeUrl(String url) async {
    final message = <String, Object>{
      'records': <Map<String, String>>[
        <String, String>{'recordType': 'url', 'data': url},
      ],
    }.jsify()!;
    await _NdefReader().write(message).toDart;
  }

  String? _decodeRecord(_NdefRecord record) {
    final recordData = record.data;
    if (recordData == null || (record.recordType != 'url' && record.recordType != 'text')) {
      return null;
    }
    return web.TextDecoder(record.encoding ?? 'utf-8').decode(recordData);
  }
}
