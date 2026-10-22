#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
compose=(docker compose --project-directory "$root/ready" -f "$root/ready/compose.yaml")
"${compose[@]}" pull desktop
"${compose[@]}" up -d desktop

echo 'Graphical desktop: https://localhost:18443/'
echo 'Files and Client open in separate idle terminals; type ./run.sh in each.'
echo 'To print the private noVNC login URL, run:'
echo '  docker exec -it cynapsa-demo-enhanced-published-desktop-1 remote-browser-credentials'
