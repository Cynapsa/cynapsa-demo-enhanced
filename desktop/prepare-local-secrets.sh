#!/usr/bin/env bash
set -Eeuo pipefail
set +x

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_file=${1:?Pass the agents-info.txt path}
litellm_file=${2:?Pass the existing LiteLLM key file path}
[[ -f $source_file && -s $litellm_file ]] || { echo 'Missing enrollment or LLM key file.' >&2; exit 78; }
install -d -m 0700 "$root/.private"

extract_token() {
  local label=$1 destination=$2
  local temporary_token
  temporary_token=$(mktemp)
  chmod 0600 "$temporary_token"
  awk -v wanted="$label:" '
    $0 == wanted {
      if (getline <= 0 || $0 !~ /^export Cynapsa_TOKEN="[A-Za-z0-9._-]+"$/) exit 1
      sub(/^export Cynapsa_TOKEN="/, "")
      sub(/"$/, "")
      print
      found++
    }
    END { if (found != 1) exit 1 }
  ' "$source_file" > "$temporary_token" || {
    rm -f -- "$temporary_token"
    return 1
  }
  install -m 0600 "$temporary_token" "$destination"
  rm -f -- "$temporary_token"
  [[ -s $destination ]] || { echo "Missing $label token." >&2; exit 78; }
}

extract_token Files-enhanced "$root/.private/files_enrollment_token"
extract_token Client-enhanced "$root/.private/client_enrollment_token"
extract_token Maps-enhanced "$root/.private/maps_enrollment_token"
extract_token Orchestrator-enhanced "$root/.private/orchestrator_enrollment_token"
install -m 0600 "$litellm_file" "$root/.private/litellm_api_key"
echo 'Local desktop secrets prepared in ignored .private/ files.'
