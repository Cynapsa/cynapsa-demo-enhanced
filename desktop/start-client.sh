#!/bin/sh
set -eu

# A second Client process using the same persisted installation is unsafe.
if [ "${1:-}" != --locked ]; then
  exec flock -n -E 75 /run/cynapsa-enhanced-client.lock "$0" --locked
fi
shift

export CYNAPSA_STATE_DIRECTORY=/home/codex/.local/share/cynapsa-enhanced/client
export DEMO_PRIVATE_DIRECTORY=/tmp/cynapsa-enhanced-client-private
export DEMO_SECRET_SOURCE_DIRECTORY=/tmp/cynapsa-enhanced-client-secrets
export DEMO_APP_DIRECTORY=/opt/cynapsa-enhanced/client
install -d -o codex -g codex -m 0700 "$DEMO_SECRET_SOURCE_DIRECTORY"
install -o codex -g codex -m 0600 \
  /opt/cynapsa-enhanced/secrets/client/enrollment_token \
  "$DEMO_SECRET_SOURCE_DIRECTORY/enrollment_token"
exec runuser -u codex -- /opt/cynapsa-enhanced/client/entrypoint.sh
