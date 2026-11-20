final Map<String, String> _inMemorySessionStorage = <String, String>{};

/// Opens [url] in a new browser tab on web; no-op in non-web test environments.
void openUrlInNewTab(String url) {}

/// Closes an auxiliary tab opened from the game, or navigates to [fallbackGameUrl] otherwise.
void returnToGameTab(String fallbackGameUrl) {}

/// Reads a value from per-tab session storage so a page refresh keeps an active admin session.
String? readSessionStorageValue(String key) => _inMemorySessionStorage[key];

/// Writes or removes a value in per-tab session storage.
void writeSessionStorageValue(String key, String? value) {
  if (value == null || value.isEmpty) {
    _inMemorySessionStorage.remove(key);
  } else {
    _inMemorySessionStorage[key] = value;
  }
}
