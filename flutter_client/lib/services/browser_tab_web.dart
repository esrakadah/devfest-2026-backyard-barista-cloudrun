import 'package:web/web.dart' as web;

/// Opens [url] in a new browser tab.
void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}

/// Closes this tab when it was opened from the game tab, or navigates to [fallbackGameUrl] when
/// the browser refuses to close a standalone tab.
void returnToGameTab(String fallbackGameUrl) {
  if (web.window.opener != null) {
    web.window.close();
    if (web.window.closed) {
      return;
    }
  }
  web.window.location.assign(fallbackGameUrl);
}

/// Reads from `sessionStorage` so closing the browser tab clears the admin session automatically.
String? readSessionStorageValue(String key) {
  try {
    return web.window.sessionStorage.getItem(key);
  } on Object {
    return null;
  }
}

/// Writes or clears [key] in `sessionStorage`.
void writeSessionStorageValue(String key, String? value) {
  try {
    if (value == null || value.isEmpty) {
      web.window.sessionStorage.removeItem(key);
    } else {
      web.window.sessionStorage.setItem(key, value);
    }
  } on Object {
    // Private browsing modes may block storage; in-memory state still works for the current view.
  }
}
