#!/usr/bin/env python3
"""Empties the hall leaderboard of one event, so the next round starts from zero.

Run from the repo root on a machine where `gcloud auth login` was done with the project owner:

    python3 tool/reset_leaderboard.py prova        # the rehearsal board
    python3 tool/reset_leaderboard.py konya-2026   # the stage board

The script lists the players, shows the first three and deletes nothing until the event id is typed
again. Players write without signing in and the rules forbid them to delete, so this is the only way
to clear a board. Phones that are still playing notice the missing row on their next tray and start
a fresh three minutes; players whose time was already over reload the page to join again.
"""

import json
import re
import subprocess
import sys
import urllib.error
import urllib.request

PROJECT = "devfest-backyard-barista-2026"
API_ROOT = "https://firestore.googleapis.com/v1/"
DOCUMENTS_ROOT = f"projects/{PROJECT}/databases/(default)/documents"
EVENT_ID_PATTERN = re.compile(r"^[a-z0-9-]{1,32}$")
PAGE_SIZE = 300
DELETES_PER_COMMIT = 300
REQUEST_TIMEOUT_SECONDS = 30
PREVIEW_ROWS = 3


def call(method, url, token, body=None):
    request = urllib.request.Request(
        url,
        data=None if body is None else json.dumps(body).encode(),
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "x-goog-user-project": PROJECT,
        },
    )
    with urllib.request.urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:
        return json.loads(response.read() or b"{}")


def list_players(event_id, token):
    players = []
    page_token = ""
    while True:
        url = f"{API_ROOT}{DOCUMENTS_ROOT}/events/{event_id}/players?pageSize={PAGE_SIZE}"
        if page_token:
            url += f"&pageToken={page_token}"
        page = call("GET", url, token)
        players.extend(page.get("documents", []))
        page_token = page.get("nextPageToken", "")
        if not page_token:
            return players


def score_of(player):
    return int(player.get("fields", {}).get("score", {}).get("integerValue", "0"))


def name_of(player):
    return player.get("fields", {}).get("name", {}).get("stringValue", "?")


def main():
    if len(sys.argv) != 2 or not EVENT_ID_PATTERN.match(sys.argv[1]):
        sys.exit("usage: python3 tool/reset_leaderboard.py <event-id>   (for example: prova, konya-2026)")
    event_id = sys.argv[1]
    token = subprocess.check_output(["gcloud", "auth", "print-access-token"], text=True).strip()

    try:
        players = list_players(event_id, token)
    except urllib.error.URLError as error:
        sys.exit(f"Could not read the board: {error}. Nothing was deleted.")

    if not players:
        print(f"The board of '{event_id}' is already empty.")
        return

    print(f"Board '{event_id}' in {PROJECT}: {len(players)} players.")
    for player in sorted(players, key=score_of, reverse=True)[:PREVIEW_ROWS]:
        print(f"  {score_of(player):>6}  {name_of(player)}")
    typed = input(f"This deletes all {len(players)} players and cannot be undone. Type '{event_id}' to delete: ")
    if typed.strip() != event_id:
        print("Nothing was deleted.")
        return

    deleted = 0
    for start in range(0, len(players), DELETES_PER_COMMIT):
        batch = players[start : start + DELETES_PER_COMMIT]
        call("POST", f"{API_ROOT}{DOCUMENTS_ROOT}:commit", token, {"writes": [{"delete": player["name"]} for player in batch]})
        deleted += len(batch)
        print(f"  deleted {deleted} of {len(players)}")
    print(f"The board of '{event_id}' is empty.")


if __name__ == "__main__":
    main()
