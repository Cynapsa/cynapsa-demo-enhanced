#!/bin/sh
set -eu

# Keep one Files installation active even if the terminal is opened twice.
if [ "${1:-}" != --locked ]; then
  exec flock -n -E 75 /run/cynapsa-enhanced-files.lock "$0" --locked
fi
shift

export CYNAPSA_STATE_DIRECTORY=/home/codex/.local/share/cynapsa-enhanced/files
export DEMO_PRIVATE_DIRECTORY=/tmp/cynapsa-enhanced-files-private
export DEMO_SECRET_SOURCE_DIRECTORY=/tmp/cynapsa-enhanced-files-secrets
export DEMO_APP_DIRECTORY=/opt/cynapsa-enhanced/files
export DEMO_FILES_DIRECTORY=/home/codex/Projects/enhanced-files
install -d -o codex -g codex -m 0700 "$DEMO_FILES_DIRECTORY"
install -d -o codex -g codex -m 0700 "$DEMO_SECRET_SOURCE_DIRECTORY"
install -o codex -g codex -m 0600 \
  /opt/cynapsa-enhanced/secrets/files/enrollment_token \
  "$DEMO_SECRET_SOURCE_DIRECTORY/enrollment_token"
install -o codex -g codex -m 0600 \
  /opt/cynapsa-enhanced/secrets/files/litellm_api_key \
  "$DEMO_SECRET_SOURCE_DIRECTORY/litellm_api_key"
exec runuser -u codex -- /opt/cynapsa-enhanced/files/entrypoint.sh
