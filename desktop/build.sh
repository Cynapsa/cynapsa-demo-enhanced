#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_ref=2a1c0063f7246658e44c046651a970e08ca210f9
source_dir=${CYNAPSA_DESKTOP_SOURCE:-}
temporary_source=
cleanup() {
  # The Git clone contains read-only pack files; remove only our mktemp directory.
  [[ -z $temporary_source ]] || rm -rf -- "$temporary_source"
}
trap cleanup EXIT
if [[ -z $source_dir ]]; then
  temporary_source=$(mktemp -d)
  git clone --quiet https://github.com/eladrave/codex-desktop-container.git "$temporary_source"
  git -C "$temporary_source" checkout --quiet --detach "$source_ref"
  source_dir=$temporary_source
fi
[[ $(git -C "$source_dir" rev-parse HEAD) == "$source_ref" ]] || {
  echo "Desktop source must be at $source_ref" >&2
  exit 78
}

CYNAPSA_DEMO_FILES_IMAGE=cynapsa-demo-enhanced-files:local "$root/files/build.sh"
docker buildx build --platform linux/arm64 --load \
  --build-context "upstream=$source_dir" \
  --tag cynapsa-demo-enhanced-desktop:slim-local \
  -f "$root/desktop/Dockerfile" "$root"
