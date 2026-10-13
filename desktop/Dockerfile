# syntax=docker/dockerfile:1.7

# Build the enhanced Files runtime from this repository first. Its image
# contains the SDK and Go Core fetched from their main branches.
ARG FILES_IMAGE=cynapsa-demo-enhanced-files:local
ARG DESKTOP_BASE=cynapsa-demo-enhanced-desktop-base:2a1c0063
FROM ${FILES_IMAGE} AS files-runtime
FROM ${DESKTOP_BASE}

ENV CYNAPSA_CORE_LIBRARY=/opt/cynapsa/libcynapsacore.so \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Ubuntu 24.04 and the Linux/arm64 Files image are ABI-compatible. Copying
# the already-built runtime keeps SDK/Core revisions identical on both agents.
COPY --from=files-runtime /usr/local/ /usr/local/
COPY --from=files-runtime /opt/cynapsa/ /opt/cynapsa/
RUN python -m pip install --no-cache-dir 'requests>=2.31,<3' \
    && install -d -o codex -g codex -m 0755 \
      /opt/cynapsa-enhanced/files /opt/cynapsa-enhanced/client \
    && install -d -o codex -g codex -m 0700 \
      /home/codex/Projects/enhanced-files \
    && install -d -m 0700 \
      /opt/cynapsa-enhanced/secrets/files \
      /opt/cynapsa-enhanced/secrets/client

COPY files/app.py files/llm.py files/tools.py files/workflow.py files/runtime.py files/entrypoint.sh /opt/cynapsa-enhanced/files/
COPY client/app.py client/entrypoint.sh /opt/cynapsa-enhanced/client/
COPY desktop/start-files.sh desktop/start-client.sh /opt/cynapsa-enhanced/
COPY desktop/files-supervisor.conf /etc/supervisor/conf.d/enhanced-files.conf
RUN chmod 0755 /opt/cynapsa-enhanced/start-files.sh \
      /opt/cynapsa-enhanced/start-client.sh \
      /opt/cynapsa-enhanced/files/entrypoint.sh \
      /opt/cynapsa-enhanced/client/entrypoint.sh \
    && chown -R codex:codex \
      /opt/cynapsa-enhanced/files \
      /opt/cynapsa-enhanced/client
