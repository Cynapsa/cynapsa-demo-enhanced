#!/usr/bin/env bash
set -Eeuo pipefail

install -d -m 0755 /run/dbus
install -d -o codex -g codex -m 0700 /run/codex-desktop
install -d -o root -g codex -m 0750 /run/remote-browser
install -d -m 0700 /var/lib/codex-desktop-persistent

# Named volumes preserve the existing desktop and both separate Cynapsa profiles.
chown codex:codex /home/codex
chmod 0700 /home/codex
install -d -o codex -g codex -m 0700 \
  /home/codex/Desktop \
  /home/codex/Projects \
  /home/codex/Projects/enhanced-files \
  /home/codex/.config \
  /home/codex/.config/autostart \
  /home/codex/.local \
  /home/codex/.local/share

machine_id_file=/var/lib/codex-desktop-persistent/machine-id
if [[ ! -s "${machine_id_file}" ]]; then
  dbus-uuidgen >"${machine_id_file}"
  chmod 0600 "${machine_id_file}"
fi
install -o root -g root -m 0444 "${machine_id_file}" /etc/machine-id

# The previous full image created this specific Codex autostart entry. Preserve
# it as a disabled file, leaving other desktop settings and user files intact.
codex_autostart=/home/codex/.config/autostart/codex.desktop
if [[ -f "${codex_autostart}" ]] && \
   grep -Fqx 'Exec=/usr/local/sbin/run-codex-desktop' "${codex_autostart}"; then
  mv -- "${codex_autostart}" "${codex_autostart}.disabled.$(date +%s)"
fi

install -o codex -g codex -m 0644 \
  /opt/cynapsa-enhanced/autostart/files-terminal.desktop \
  /home/codex/.config/autostart/cynapsa-files-terminal.desktop
install -o codex -g codex -m 0644 \
  /opt/cynapsa-enhanced/autostart/client-terminal.desktop \
  /home/codex/.config/autostart/cynapsa-client-terminal.desktop

files_directory=/home/codex/Projects/enhanced-files
sample_file="${files_directory}/demo-location.txt"
for bundled_file in /opt/cynapsa-enhanced/sample-data/*.txt; do
  destination="${files_directory}/${bundled_file##*/}"
  if [[ ! -e "${destination}" && ! -L "${destination}" ]]; then
    install -o codex -g codex -m 0644 "${bundled_file}" "${destination}"
  fi
done
if [[ ! -e /home/codex/Desktop/Files-Database && \
      ! -L /home/codex/Desktop/Files-Database ]]; then
  runuser -u codex -- ln -s "${files_directory}" \
    /home/codex/Desktop/Files-Database
fi
if [[ ! -e /home/codex/Desktop/demo-location.txt && \
      ! -L /home/codex/Desktop/demo-location.txt ]]; then
  runuser -u codex -- ln -s "${sample_file}" \
    /home/codex/Desktop/demo-location.txt
fi

/opt/codex-desktop/remote-browser/prepare-credentials.sh
exec /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
