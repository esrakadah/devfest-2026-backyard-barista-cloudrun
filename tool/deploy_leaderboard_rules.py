#!/usr/bin/env python3
"""Publishes firestore/firestore.rules as the Firestore rules of the leaderboard project.

Run from the repo root on a machine where `gcloud auth login` was done with the project owner:

    python3 tool/deploy_leaderboard_rules.py

The project is a plain Google Cloud project without a Firebase app, so this talks to the Firebase
Rules API directly instead of `firebase deploy`.
"""

import json
import pathlib
import subprocess
import sys
import urllib.error
import urllib.request

PROJECT = "devfest-backyard-barista-2026"
RULES_FILE = pathlib.Path("firestore/firestore.rules")
API_ROOT = f"https://firebaserules.googleapis.com/v1/projects/{PROJECT}"
RELEASE_NAME = f"projects/{PROJECT}/releases/cloud.firestore"
REQUEST_TIMEOUT_SECONDS = 30
HTTP_CONFLICT = 409


def call(method, url, token, body):
    request = urllib.request.Request(
        url,
        data=json.dumps(body).encode(),
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "x-goog-user-project": PROJECT,
        },
    )
    with urllib.request.urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:
        return json.loads(response.read())


def main():
    if not RULES_FILE.exists():
        sys.exit(f"{RULES_FILE} not found: run this from the repo root.")
    token = subprocess.check_output(["gcloud", "auth", "print-access-token"], text=True).strip()
    source = {"files": [{"name": RULES_FILE.name, "content": RULES_FILE.read_text()}]}
    ruleset = call("POST", f"{API_ROOT}/rulesets", token, {"source": source})
    release = {"name": RELEASE_NAME, "rulesetName": ruleset["name"]}
    try:
        call("POST", f"{API_ROOT}/releases", token, release)
    except urllib.error.HTTPError as error:
        if error.code != HTTP_CONFLICT:
            raise
        call("PATCH", f"{API_ROOT}/releases/cloud.firestore", token, {"release": release})
    print(f"Published {ruleset['name']} as the Firestore rules of {PROJECT}.")


if __name__ == "__main__":
    main()
