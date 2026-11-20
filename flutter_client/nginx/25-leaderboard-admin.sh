#!/bin/sh
# Starts the internal leaderboard admin/state sidecar on 127.0.0.1:8081 before nginx begins serving.
(
  while true; do
    python3 /opt/barista/admin_api.py
    sleep 1
  done
) &
