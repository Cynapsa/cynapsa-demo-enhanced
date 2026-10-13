#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_ref=2a1c0063f7246658e44c046651a970e08ca210f9
source_dir=${CYNAPSA_DESKTOP_SOURCE:-}
temporary_source=
cleanup() { [[ -z $temporary_source ]] || rm -r -- "$temporary_source"; }
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

if ! docker image inspect cynapsa-demo-enhanced-desktop-base:2a1c0063 >/dev/null 2>&1; then
  docker buildx build --pull --platform linux/arm64 --load \
    --build-arg "VCS_REF=$source_ref" \
    --build-arg UBUNTU_BASE_IMAGE=ubuntu@sha256:ec0b1c9058e44c837a21c3f9d8a3d5e9aaa94ed28edceb18e154af5efecf0950 \
    --build-arg DESKTOP_ARCH=arm64 --build-arg INSTALL_CRD=0 \
    --build-arg CHATGPT_DEB_URL=https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_26.820.60940_arm64.deb \
    --build-arg CHATGPT_DEB_SHA256=8f4dacbff5f054a4f69c2a021f1396c57976972829a61041febac1b423f27c86 \
    --build-arg CHROME_DEB_URL=https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_152.0.7977.64-1_arm64.deb \
    --build-arg CHROME_DEB_SHA256=6ccab79a7afe1d174c89e28cf0d5a265e6e8855ff3b45c6a2151a65d7ddae9e8 \
    --build-arg TAILSCALE_BINARY_PLATFORM=linux/arm64 \
    --build-arg TAILSCALE_BINARY_ARCH=arm64 \
    --build-arg TAILSCALE_ELF_MACHINE_HEX=b700 \
    --build-arg TAILSCALE_BASE_IMAGE=tailscale/tailscale@sha256:5789311e4ab3bcf6cfb88020def1ce6c8cfebacfd6a369f06b103a8feee0eedc \
    --tag cynapsa-demo-enhanced-desktop-base:2a1c0063 "$source_dir"
fi

CYNAPSA_DEMO_FILES_IMAGE=cynapsa-demo-enhanced-files:local "$root/files/build.sh"
docker buildx build --platform linux/arm64 --load \
  --tag cynapsa-demo-enhanced-desktop:local \
  -f "$root/desktop/Dockerfile" "$root"
