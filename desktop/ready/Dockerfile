# syntax=docker/dockerfile:1.7

# This image is intentionally a private, ready-to-run internal demo. The
# credentials context points to the ignored .private/ directory; it must never
# be pushed to a public registry or copied into Git.
FROM cynapsa-demo-enhanced-desktop:slim-local

COPY desktop/.env.example /opt/cynapsa-enhanced/demo.env
COPY --from=credentials --chmod=0600 files_enrollment_token /opt/cynapsa-enhanced/secrets/files/enrollment_token
COPY --from=credentials --chmod=0600 client_enrollment_token /opt/cynapsa-enhanced/secrets/client/enrollment_token
COPY --from=credentials --chmod=0600 litellm_api_key /opt/cynapsa-enhanced/secrets/files/litellm_api_key
COPY desktop/ready/entrypoint.sh /usr/local/sbin/cynapsa-ready-entrypoint

RUN chmod 0500 /usr/local/sbin/cynapsa-ready-entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/sbin/cynapsa-ready-entrypoint"]
