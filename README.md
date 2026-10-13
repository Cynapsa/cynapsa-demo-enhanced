# Cynapsa Demo Enhanced

This is a separate four-identity demo on the `demo-enhanced` mesh. It does not
replace `cynapsa-demo` or reuse its agent installations.

```text
Client (Mac desktop image) --Cynapsa /ask--> Orchestrator (AWS ECS)
                                               |--Cynapsa /maps--> Maps (GCP Cloud Run worker pool)
                                               +--Cynapsa /files--> Files (same Mac desktop image)
```

The client and Files app are ordinary HTTP code launched through `cynapsa run`.
The orchestrator and Maps app use native Cynapsa. The orchestrator, Maps, and
Files agents use LangGraph; the client is an interactive Requests program.
The wire mesh ID is `demo_enhanced_cynapsa_demo` (the portal display name is
`demo-enhanced`). Enrollment determines each agent's own identity. Peer IDs
are in [`desktop/.env.example`](desktop/.env.example) and the per-agent
`.env.example` files; they are not credentials.

## Run Files and Client on an Apple Silicon Mac

The local image derives from the pinned
[`eladrave/codex-desktop-container`](https://github.com/eladrave/codex-desktop-container)
source. This deployment uses its container desktop but does **not** enroll
Tailscale or expose its GUI on a host port. Cynapsa works without Tailscale;
the upstream full installer only needs it for remote desktop access.

Prerequisites: Docker Desktop, a GitHub token with read access to the private
SDK and Go Core repositories, the four enrollment grants, and a LiteLLM key.
`desktop/build.sh` fetches SDK/Core `main` during the Files image build and
records their commits in `/opt/cynapsa/source-revisions`. The pinned upstream
desktop commit is `2a1c0063f7246658e44c046651a970e08ca210f9`.

```sh
cd desktop
./prepare-local-secrets.sh /path/to/agents-info.txt /path/to/litellm_api_key
cp .env.example .env
# Set CYNAPSA_GITHUB_TOKEN in ../files/.env or in your shell; do not commit it.
./run.sh --build
./client.sh
```

The preparation script writes ignored, mode-`0600` files under `../.private/`.
It never copies tokens or the LLM key into an image. On this machine those
files have already been prepared; `./run.sh` starts the existing local image
without rebuilding. The Files agent starts automatically under Supervisor;
`./client.sh` starts the interactive client inside the same container.

Put documents for the Files agent in
`/home/codex/Projects/enhanced-files` inside the desktop container. The
container's home volume persists them and both Cynapsa installation profiles.
Only put data there that you are comfortable sending to the model: demo
request/response logs contain full content without redaction. Inspect status
with `docker compose -f compose.yaml ps` and logs with
`docker compose -f compose.yaml logs -f desktop`. Stop with
`docker compose -f compose.yaml down`; this preserves volumes. The source
desktop image includes a Tailscale daemon but it is not enrolled in a tailnet.

## Other deployments

The enhanced Maps worker is `cynapsa-demo-enhanced-maps` in GCP project
`aztm-amesh`, region `us-central1`. The enhanced orchestrator is ECS service
`demo-enhanced-orchestrator` in cluster `cynapsa-demo-enhanced`, AWS region
`us-east-1`. Both use separate enrollment secrets and image names. The AWS
task definition is in
[`orchestrator/deploy/aws-task-definition-enhanced.json`](orchestrator/deploy/aws-task-definition-enhanced.json).
These resources have their own identities and do not replace the original
demo's workers. Check live service status before assuming readiness.

Each of the four role directories still has its own Docker build and runner,
so a role can also be run independently. Do not run two containers from the
same installation profile simultaneously. After mesh removal and re-addition,
use a valid enrollment grant and `--force-enroll` to replace the revoked
installation.
