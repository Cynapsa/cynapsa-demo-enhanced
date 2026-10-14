#!/usr/bin/env bash
set -Eeuo pipefail

credential_dir=/var/lib/codex-desktop-persistent/remote-browser
credential_file="${credential_dir}/credentials.env"
[[ "$(id -u)" == 0 ]] || exit 78
install -d -o root -g root -m 0700 "${credential_dir}"
[[ ! -L "${credential_dir}" ]] || exit 78

# Never regenerate or print the user's existing desktop credentials.
if [[ -e "${credential_file}" ]]; then
  [[ -f "${credential_file}" && ! -L "${credential_file}" ]] || exit 78
  [[ "$(stat -c '%u:%g:%a' "${credential_file}")" == '0:0:600' ]] || exit 78
  exit 0
fi

mcp_token="$(openssl rand -hex 32)"
login_token="$(openssl rand -hex 32)"
login_username=remotechrome
login_password="$(openssl rand -hex 32)"
login_password_hash="$(printf '%s\n' "${login_password}" | caddy hash-password --algorithm bcrypt)"
[[ "${login_password_hash}" =~ ^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$ ]] || exit 78

umask 077
temporary_file="$(mktemp "${credential_dir}/.credentials.XXXXXX")"
cleanup() { [[ ! -e "${temporary_file}" ]] || unlink "${temporary_file}"; }
trap cleanup EXIT
printf '%s\n' \
  "MCP_TOKEN=${mcp_token}" \
  "LOGIN_TOKEN=${login_token}" \
  "LOGIN_USERNAME=${login_username}" \
  "LOGIN_PASSWORD=${login_password}" \
  "LOGIN_PASSWORD_HASH=${login_password_hash}" \
  >"${temporary_file}"
chown root:root "${temporary_file}"
chmod 0600 "${temporary_file}"
mv -- "${temporary_file}" "${credential_file}"
trap - EXIT
