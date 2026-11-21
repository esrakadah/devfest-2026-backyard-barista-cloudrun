import 'package:web/web.dart' as web;

/// Reads from `localStorage`. Private windows and blocked site data throw or answer null; both mean "not stored".
String? readPlayerStorageValue(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } on Object {
    return null;
  }
}

void writePlayerStorageValue(String key, String? value) {
  try {
    if (value == null || value.isEmpty) {
      web.window.localStorage.removeItem(key);
    } else {
      web.window.localStorage.setItem(key, value);
    }
  } on Object {
    // The player still plays; a reload then starts a new leaderboard row.
  }
}
