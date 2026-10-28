import 'package:backyard_barista_cloudrun/services/nfc_tag_platform.dart';

/// Desktop, iOS Safari and tests: no Web NFC, so the NFC controls stay hidden.
NfcTagPlatform createPlatformNfcTagPlatform() => const UnsupportedNfcTagPlatform();
