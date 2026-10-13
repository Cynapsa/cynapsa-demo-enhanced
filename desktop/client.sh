#!/usr/bin/env bash
set -Eeuo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
docker compose --project-directory "$root" -f "$root/compose.yaml" \
  exec desktop /opt/cynapsa-enhanced/start-client.sh
