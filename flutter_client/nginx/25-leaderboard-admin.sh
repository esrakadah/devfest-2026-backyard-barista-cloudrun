#!/bin/sh
# Starts the internal leaderboard admin/state sidecar on 127.0.0.1:8081 and waits up to 3s for it
# to bind before nginx starts accepting Cloud Run requests, preventing cold-start 502 responses.
(
  while true; do
    python3 /opt/barista/admin_api.py
    sleep 1
  done
) &

python3 -c '
import socket, time
for _ in range(30):
    try:
        with socket.create_connection(("127.0.0.1", 8081), timeout=0.2):
            break
    except OSError:
        time.sleep(0.1)
'
