#!/usr/bin/env python3
"""Internal Cloud Run sidecar for hall leaderboard state, freeze, and admin reset.

Listens on 127.0.0.1:8081 behind nginx. Holds LEADERBOARD_ADMIN_KEY in process memory
(mounted from Secret Manager) and uses the Cloud Run service account token to update
or clear Firestore documents while firestore.rules keeps browser deletes forbidden.
"""

from __future__ import annotations

from datetime import datetime, timezone
import hmac
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
import re
import threading
import time
import urllib.error
import urllib.parse
import urllib.request

LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8081
EVENT_ID_PATTERN = re.compile(r"^[a-z0-9-]{1,32}$")
FIRESTORE_API_ROOT = "https://firestore.googleapis.com/v1"
METADATA_TOKEN_URL = (
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"
)
PAGE_SIZE = 300
DELETES_PER_COMMIT = 300
HTTP_TIMEOUT_SECONDS = 15
STATE_CACHE_TTL_SECONDS = 2.0
TOKEN_REFRESH_MARGIN_SECONDS = 60

_token_lock = threading.Lock()
_cached_token: str = ""
_cached_token_expiry: float = 0.0

_state_lock = threading.Lock()
_state_cache: dict[str, tuple[float, dict[str, object]]] = {}


def _project_id() -> str:
    return os.environ.get("LEADERBOARD_PROJECT", "devfest-backyard-barista-2026").strip()


def _documents_root() -> str:
    return f"projects/{_project_id()}/databases/(default)/documents"


def _expected_admin_key() -> str:
    return os.environ.get("LEADERBOARD_ADMIN_KEY", "").strip()


def _get_access_token() -> str:
    override = os.environ.get("GOOGLE_OAUTH_ACCESS_TOKEN", "").strip()
    if override:
        return override
    global _cached_token, _cached_token_expiry
    now = time.monotonic()
    with _token_lock:
        if _cached_token and now < _cached_token_expiry:
            return _cached_token
        request = urllib.request.Request(
            METADATA_TOKEN_URL,
            headers={"Metadata-Flavor": "Google"},
            method="GET",
        )
        with urllib.request.urlopen(request, timeout=5) as response:
            payload = json.loads(response.read().decode("utf-8"))
        _cached_token = str(payload["access_token"])
        expires_in = float(payload.get("expires_in", 300))
        _cached_token_expiry = now + max(10.0, expires_in - TOKEN_REFRESH_MARGIN_SECONDS)
        return _cached_token


def _firestore_call(
    method: str,
    url: str,
    token: str,
    body: dict[str, object] | None = None,
) -> dict[str, object]:
    encoded_body = None if body is None else json.dumps(body).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=encoded_body,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "x-goog-user-project": _project_id(),
        },
    )
    with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT_SECONDS) as response:
        raw = response.read()
        return json.loads(raw.decode("utf-8")) if raw else {}


def fetch_event_state(event_id: str) -> dict[str, object]:
    now = time.monotonic()
    with _state_lock:
        cached = _state_cache.get(event_id)
        if cached is not None and now - cached[0] < STATE_CACHE_TTL_SECONDS:
            return cached[1]

    token = _get_access_token()
    url = f"{FIRESTORE_API_ROOT}/{_documents_root()}/events/{event_id}"
    try:
        document = _firestore_call("GET", url, token)
        fields = document.get("fields")
        if not isinstance(fields, dict):
            fields = {}
        is_paused = bool((fields.get("isPaused") or {}).get("booleanValue", False))
        frozen_at = (fields.get("frozenAt") or {}).get("timestampValue")
        state = {
            "eventId": event_id,
            "isPaused": is_paused,
            "frozenAt": frozen_at if isinstance(frozen_at, str) else None,
        }
    except urllib.error.HTTPError as exc:
        if exc.code != HTTPStatus.NOT_FOUND:
            raise
        state = {"eventId": event_id, "isPaused": False, "frozenAt": None}

    with _state_lock:
        _state_cache[event_id] = (time.monotonic(), state)
    return state


def write_event_pause_state(event_id: str, *, is_paused: bool) -> dict[str, object]:
    token = _get_access_token()
    frozen_at = (
        datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        if is_paused
        else None
    )
    url = (
        f"{FIRESTORE_API_ROOT}/{_documents_root()}/events/{event_id}"
        "?updateMask.fieldPaths=isPaused&updateMask.fieldPaths=frozenAt"
    )
    body: dict[str, object] = {
        "fields": {
            "isPaused": {"booleanValue": is_paused},
            "frozenAt": (
                {"timestampValue": frozen_at}
                if frozen_at is not None
                else {"nullValue": None}
            ),
        }
    }
    _firestore_call("PATCH", url, token, body)
    state: dict[str, object] = {
        "eventId": event_id,
        "isPaused": is_paused,
        "frozenAt": frozen_at,
    }
    with _state_lock:
        _state_cache[event_id] = (time.monotonic(), state)
    return state


def reset_event_board(event_id: str) -> dict[str, object]:
    token = _get_access_token()
    players: list[dict[str, object]] = []
    page_token = ""
    while True:
        url = (
            f"{FIRESTORE_API_ROOT}/{_documents_root()}/events/{event_id}"
            f"/players?pageSize={PAGE_SIZE}"
        )
        if page_token:
            url += f"&pageToken={urllib.parse.quote(page_token)}"
        try:
            page = _firestore_call("GET", url, token)
        except urllib.error.HTTPError as exc:
            if exc.code == HTTPStatus.NOT_FOUND:
                break
            raise
        documents = page.get("documents", [])
        if isinstance(documents, list):
            players.extend(doc for doc in documents if isinstance(doc, dict))
        next_token = page.get("nextPageToken", "")
        page_token = next_token if isinstance(next_token, str) else ""
        if not page_token:
            break

    commit_url = f"{FIRESTORE_API_ROOT}/{_documents_root()}:commit"
    for start in range(0, len(players), DELETES_PER_COMMIT):
        batch = players[start : start + DELETES_PER_COMMIT]
        writes = [
            {"delete": player["name"]}
            for player in batch
            if isinstance(player.get("name"), str)
        ]
        if writes:
            _firestore_call("POST", commit_url, token, {"writes": writes})

    state = write_event_pause_state(event_id, is_paused=False)
    return {
        **state,
        "deletedPlayers": len(players),
    }


class AdminApiHandler(BaseHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:  # noqa: A002
        return

    def _send_json(self, status: int, payload: dict[str, object]) -> None:
        raw = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def _check_admin_key(self) -> bool:
        expected = _expected_admin_key()
        if not expected:
            self._send_json(
                HTTPStatus.SERVICE_UNAVAILABLE,
                {"error": "admin_not_configured"},
            )
            return False
        provided = (self.headers.get("X-Admin-Key") or "").strip()
        if not provided or not hmac.compare_digest(
            provided.encode("utf-8"), expected.encode("utf-8")
        ):
            self._send_json(HTTPStatus.UNAUTHORIZED, {"error": "invalid_admin_key"})
            return False
        return True

    def _read_json_body(self) -> dict[str, object] | None:
        try:
            content_length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            content_length = 0
        if content_length <= 0 or content_length > 16384:
            return {}
        raw = self.rfile.read(content_length)
        try:
            decoded = json.loads(raw.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            return None
        return decoded if isinstance(decoded, dict) else None

    def do_GET(self) -> None:  # noqa: N802
        parsed = urllib.parse.urlsplit(self.path)
        if parsed.path != "/api/leaderboard/state":
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "not_found"})
            return
        params = urllib.parse.parse_qs(parsed.query)
        event_id = (params.get("event") or [""])[0].strip()
        if not EVENT_ID_PATTERN.match(event_id):
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": "invalid_event_id"})
            return
        try:
            state = fetch_event_state(event_id)
            self._send_json(HTTPStatus.OK, state)
        except Exception:  # noqa: BLE001
            self._send_json(HTTPStatus.BAD_GATEWAY, {"error": "upstream_failed"})

    def do_POST(self) -> None:  # noqa: N802
        parsed = urllib.parse.urlsplit(self.path)
        if parsed.path == "/api/leaderboard/admin/verify":
            if self._check_admin_key():
                self._send_json(HTTPStatus.OK, {"ok": True})
            return

        if parsed.path not in {
            "/api/leaderboard/admin/pause",
            "/api/leaderboard/admin/reset",
        }:
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "not_found"})
            return

        if not self._check_admin_key():
            return

        payload = self._read_json_body()
        if payload is None:
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": "invalid_json"})
            return

        raw_event_id = payload.get("eventId")
        event_id = raw_event_id.strip() if isinstance(raw_event_id, str) else ""
        if not EVENT_ID_PATTERN.match(event_id):
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": "invalid_event_id"})
            return

        try:
            if parsed.path == "/api/leaderboard/admin/pause":
                is_paused = bool(payload.get("isPaused", True))
                result = write_event_pause_state(event_id, is_paused=is_paused)
            else:
                result = reset_event_board(event_id)
            self._send_json(HTTPStatus.OK, result)
        except Exception:  # noqa: BLE001
            self._send_json(HTTPStatus.BAD_GATEWAY, {"error": "upstream_failed"})


def main() -> None:
    server = ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), AdminApiHandler)
    server.serve_forever()


if __name__ == "__main__":
    main()
