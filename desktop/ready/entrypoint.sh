#!/bin/sh
set -eu

# The image contains only this demo's non-secret IDs in demo.env. The three
# credential files are already at the paths consumed by start-files/client.
set -a
. /opt/cynapsa-enhanced/demo.env
set +a

export DEMO_ORCHESTRATOR_ORIGIN=${DEMO_ORCHESTRATOR_ORIGIN:-http://orchestrator-enhanced.local}
export LITELLM_BASE_URL=${LITELLM_BASE_URL:-https://litellm.eladrave.com}
export LITELLM_MODEL=${LITELLM_MODEL:-chatgpt/gpt-5.6-terra-high}

exec /usr/local/sbin/cynapsa-desktop-entrypoint "$@"
