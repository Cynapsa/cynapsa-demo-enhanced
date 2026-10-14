# syntax=docker/dockerfile:1.7

# The pinned upstream source is supplied as a named build context. Only its
# Xfce/noVNC and authenticated gateway scripts are copied into this image.
ARG FILES_IMAGE=cynapsa-demo-enhanced-files:local
ARG UBUNTU_BASE_IMAGE=ubuntu@sha256:ec0b1c9058e44c837a21c3f9d8a3d5e9aaa94ed28edceb18e154af5efecf0950
ARG CADDY_BASE_IMAGE=caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d

FROM ${FILES_IMAGE} AS files-runtime
FROM ${CADDY_BASE_IMAGE} AS caddy-runtime
FROM ${UBUNTU_BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    HOME=/home/codex \
    XDG_CONFIG_HOME=/home/codex/.config \
    XDG_DATA_HOME=/home/codex/.local/share \
    CYNAPSA_CORE_LIBRARY=/opt/cynapsa/libcynapsacore.so \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash ca-certificates curl dbus dbus-x11 fonts-dejavu-core \
      fonts-noto-color-emoji jq mousepad novnc openssl procps sudo supervisor \
      thunar tini util-linux websockify xdg-utils xfce4-panel xfce4-session \
      xfce4-settings xfce4-terminal xfconf xfdesktop4 xfwm4 \
      x11-xserver-utils xauth x11vnc xvfb \
    && groupadd --gid 10001 codex \
    && useradd --uid 10001 --gid 10001 --create-home --shell /bin/bash codex \
    && printf '%s\n' 'codex ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/cynapsa-demo \
    && chmod 0440 /etc/sudoers.d/cynapsa-demo \
    && rm -rf /var/lib/apt/lists/*

COPY --from=caddy-runtime /usr/bin/caddy /tmp/caddy
RUN install -o root -g root -m 0755 /tmp/caddy /usr/bin/caddy \
    && rm -f /tmp/caddy
COPY --from=files-runtime /usr/local/ /usr/local/
COPY --from=files-runtime /opt/cynapsa/ /opt/cynapsa/
RUN python -m pip install --no-cache-dir 'requests>=2.31,<3' \
    && install -d -m 0755 /opt/codex-desktop/remote-browser \
      /opt/cynapsa-enhanced/files /opt/cynapsa-enhanced/client \
      /opt/cynapsa-enhanced/autostart \
    && install -d -m 0700 /opt/cynapsa-enhanced/secrets/files \
      /opt/cynapsa-enhanced/secrets/client \
    && ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html \
    && sed -i "s|UI.initSetting('path', 'websockify');|UI.initSetting('path', 'login/websockify');|" /usr/share/novnc/app/ui.js \
    && grep -Fq "UI.initSetting('path', 'login/websockify');" /usr/share/novnc/app/ui.js

COPY --from=upstream run-session.sh /usr/local/sbin/run-codex-session
COPY --from=upstream run-local-desktop.sh /usr/local/sbin/run-codex-local-desktop
COPY --from=upstream run-x11vnc.sh /usr/local/sbin/run-codex-x11vnc
COPY --from=upstream run-novnc.sh /usr/local/sbin/run-codex-novnc
COPY --from=upstream lib/remote-browser/Caddyfile /opt/codex-desktop/remote-browser/Caddyfile
COPY --from=upstream lib/remote-browser/run-gateway.sh /opt/codex-desktop/remote-browser/run-gateway.sh
COPY --from=upstream lib/remote-browser/remote-browser-credentials /usr/local/bin/remote-browser-credentials

COPY files/app.py files/llm.py files/tools.py files/workflow.py files/runtime.py files/entrypoint.sh /opt/cynapsa-enhanced/files/
COPY client/app.py client/entrypoint.sh /opt/cynapsa-enhanced/client/
COPY desktop/start-files.sh desktop/start-client.sh /opt/cynapsa-enhanced/
COPY desktop/files-run.sh /opt/cynapsa-enhanced/files/run.sh
COPY desktop/client-run.sh /opt/cynapsa-enhanced/client/run.sh
COPY desktop/terminal-files.sh desktop/terminal-client.sh /opt/cynapsa-enhanced/
COPY desktop/autostart/ /opt/cynapsa-enhanced/autostart/
COPY desktop/sample-data/ /opt/cynapsa-enhanced/sample-data/
COPY desktop/local-gui.caddy /opt/cynapsa-enhanced/local-gui.caddy
COPY desktop/lean-supervisord.conf /etc/supervisor/conf.d/cynapsa-desktop.conf
COPY desktop/lean-entrypoint.sh /usr/local/sbin/cynapsa-desktop-entrypoint
COPY desktop/prepare-credentials.sh /opt/codex-desktop/remote-browser/prepare-credentials.sh
COPY desktop/healthcheck.sh /usr/local/sbin/cynapsa-desktop-healthcheck

RUN chmod 0755 \
      /usr/local/sbin/run-codex-session \
      /usr/local/sbin/run-codex-local-desktop \
      /usr/local/sbin/run-codex-x11vnc \
      /usr/local/sbin/run-codex-novnc \
      /usr/local/sbin/cynapsa-desktop-entrypoint \
      /usr/local/sbin/cynapsa-desktop-healthcheck \
      /usr/local/bin/remote-browser-credentials \
      /opt/codex-desktop/remote-browser/run-gateway.sh \
      /opt/codex-desktop/remote-browser/prepare-credentials.sh \
      /opt/cynapsa-enhanced/start-files.sh \
      /opt/cynapsa-enhanced/start-client.sh \
      /opt/cynapsa-enhanced/files/run.sh \
      /opt/cynapsa-enhanced/client/run.sh \
      /opt/cynapsa-enhanced/terminal-files.sh \
      /opt/cynapsa-enhanced/terminal-client.sh \
      /opt/cynapsa-enhanced/files/entrypoint.sh \
      /opt/cynapsa-enhanced/client/entrypoint.sh \
    && rm -f /etc/supervisor/conf.d/supervisord.conf

WORKDIR /home/codex
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD ["/usr/local/sbin/cynapsa-desktop-healthcheck"]
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/cynapsa-desktop-entrypoint"]
