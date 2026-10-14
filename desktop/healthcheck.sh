#!/usr/bin/env bash
set -Eeuo pipefail

for service in dbus desktop-session remote-browser-gateway x11vnc novnc enhanced-local-gui; do
  supervisorctl status "${service}" | grep -Eq "^[^[:space:]]+[[:space:]]+RUNNING([[:space:]]|$)"
done
pgrep -u 10001 -x Xvfb >/dev/null
curl --fail --silent --show-error --max-time 5 \
  http://127.0.0.1:8443/healthz | grep -qx ready
curl --fail --silent --show-error --max-time 5 --insecure \
  https://localhost:9443/healthz | grep -qx ready
