#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
image=ghcr.io/cynapsa/cynapsa-demo-enhanced-desktop:ready-20261022

for secret_name in files_enrollment_token client_enrollment_token litellm_api_key; do
  [[ -s "$root/.private/$secret_name" ]] || {
    echo "Missing .private/$secret_name" >&2
    exit 78
  }
done
docker image inspect --platform linux/arm64 cynapsa-demo-enhanced-desktop:slim-local >/dev/null

docker buildx build --platform linux/arm64 --load \
  --build-context "credentials=$root/.private" \
  --tag "$image" \
  -f "$root/desktop/ready/Dockerfile" "$root"

# The GH CLI keeps the login token in the local credential store. Never put
# it in the image or pass it as a Docker build argument.
gh auth token | docker login ghcr.io -u "$(gh api user --jq .login)" --password-stdin >/dev/null
docker push "$image"

visibility=$(gh api /orgs/Cynapsa/packages/container/cynapsa-demo-enhanced-desktop --jq .visibility)
[[ $visibility == private ]] || {
  echo "STOP: GHCR package visibility is $visibility, not private." >&2
  exit 1
}
echo "Published $image as a private GHCR package."
