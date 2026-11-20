final Map<String, String> _inMemoryPlayerStorage = <String, String>{};

/// Kept in memory where there is no browser storage, so the player lasts for one run of the app.
String? readPlayerStorageValue(String key) => _inMemoryPlayerStorage[key];

void writePlayerStorageValue(String key, String value) {
  _inMemoryPlayerStorage[key] = value;
}
