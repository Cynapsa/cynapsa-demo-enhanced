#!/bin/sh
set -eu

# Translate the user-facing flag into the setting consumed by the Files
# entrypoint before the locked root helper restarts itself.
case "${1:-}" in
  --force-enroll) export DEMO_FORCE_ENROLL=1; shift ;;
  '') ;;
  *) echo 'usage: ./run.sh [--force-enroll]' >&2; exit 64 ;;
esac
[ "$#" -eq 0 ] || { echo 'usage: ./run.sh [--force-enroll]' >&2; exit 64; }

# Preserve only non-secret settings; enrollment and the model key are copied
# from read-only mounts by start-files.sh after sudo.
exec sudo --preserve-env=\
DEMO_MESH_ID,DEMO_ORCHESTRATOR_AGENT_ID,DEMO_CLIENT_AGENT_ID,DEMO_MAPS_AGENT_ID,\
DEMO_ORCHESTRATOR_ORIGIN,DEMO_CLIENT_ORIGIN,DEMO_MAPS_ORIGIN,\
LITELLM_BASE_URL,LITELLM_MODEL,DEMO_FORCE_ENROLL,\
CYNAPSA_CORE_LIBRARY \
  /opt/cynapsa-enhanced/start-files.sh
