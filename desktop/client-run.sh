#!/bin/sh
set -eu

# The desktop launcher handles user-facing flags before the locked root helper.
# That helper receives no arguments, so none can be silently lost at relaunch.
for option in "$@"; do
  case "$option" in
    --force-enroll) export DEMO_FORCE_ENROLL=1 ;;
    --silent|--quiet) export DEMO_CLIENT_QUIET=1 ;;
    *) echo 'usage: ./run.sh [--force-enroll] [--silent]' >&2; exit 64 ;;
  esac
done

# sudo normally resets the environment. Keep only the non-secret settings the
# Client's Cynapsa CLI and HTTP app need; enrollment stays in the mounted file.
exec sudo --preserve-env=\
DEMO_MESH_ID,DEMO_ORCHESTRATOR_AGENT_ID,DEMO_MAPS_AGENT_ID,DEMO_FILES_AGENT_ID,\
DEMO_ORCHESTRATOR_ORIGIN,DEMO_MAPS_ORIGIN,DEMO_FILES_ORIGIN,\
DEMO_CONVERSATION_ID,DEMO_CLIENT_QUIET,DEMO_FORCE_ENROLL,CYNAPSA_CORE_LIBRARY \
  /opt/cynapsa-enhanced/start-client.sh
