#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ ${1:-} == --build ]]; then
  "$root/build.sh"
  shift
fi
[[ $# == 0 ]] || { echo 'usage: ./run.sh [--build]' >&2; exit 64; }
[[ -f $root/.env ]] || cp "$root/.env.example" "$root/.env"
for name in files_enrollment_token client_enrollment_token litellm_api_key; do
  [[ -s $root/../.private/$name ]] || {
    echo "Missing .private/$name; run desktop/prepare-local-secrets.sh first." >&2
    exit 78
  }
done
docker compose --project-directory "$root" -f "$root/compose.yaml" up -d desktop
echo 'The desktop opens two idle terminals: Files agent and Client.'
echo 'Each terminal opens in its role directory; type ./run.sh when ready.'
echo 'You can also start the interactive client from this Mac with: ./client.sh'
echo 'Graphical desktop: https://localhost:18443/'
echo 'Run docker exec -it cynapsa-demo-enhanced-desktop-desktop-1 remote-browser-credentials in a trusted terminal for its private one-click URL.'
