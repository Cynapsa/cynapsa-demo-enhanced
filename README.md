# Cynapsa Demo Enhanced

This is a separate four-identity demo on the `demo-enhanced` mesh. It does not
replace `cynapsa-demo` or reuse its agent installations.

```text
Client (Mac desktop image) --Cynapsa /ask--> Orchestrator (AWS ECS)
                                               |--Cynapsa /maps--> Maps (GCP Cloud Run worker pool)
                                               +--Cynapsa /files--> Files (same Mac desktop image)
```

All four apps are ordinary HTTP-library code launched through `cynapsa run`.
Maps, Orchestrator, and Files use FastAPI and LangGraph; Client is an
interactive Requests program. The CLI supplies enrollment, peer mapping,
the socketless ASGI bridge, and Cynapsa RPC without an application HTTP listener.
The wire mesh ID is `demo_enhanced_cynapsa_demo` (the portal display name is
`demo-enhanced`). Enrollment determines each agent's own identity. Peer IDs
are in [`desktop/.env.example`](desktop/.env.example) and the per-agent
`.env.example` files; they are not credentials.

Each role maps the HTTP-style origins it needs to Cynapsa peer IDs. The SDK
uses the receiver's own map in reverse to present
an authenticated sender in `request.state.cynapsa_sender` (first URL wins if
several target one ID). These origins are local aliases, not network servers.
The bridge also provides the verified peer ID as
`request.state.cynapsa_sender_id` and, when mapped, the HTTP alias as
`request.state.cynapsa_sender_http_origin`. The demo logs the friendly name,
verified Cynapsa ID, and mapped HTTP origin together. Plain HTTP requests
have no verified Cynapsa ID and are logged without one.
The apps log `[cynapsa]` request, response, and confirmed mesh-event lines;
ordinary model and Places HTTP access logs are reduced to warnings.

## Run Files and Client on an Apple Silicon Mac

The local image uses the Xfce/noVNC and authenticated-gateway scripts from
the pinned [`eladrave/codex-desktop-container`](https://github.com/eladrave/codex-desktop-container)
source. Google Chrome is installed as a normal graphical browser (open
**Applications → Web Browser** in Xfce); Codex Desktop, Tailscale, guest access, and
Playwright MCP are not installed or started. Browser updates are picked up when
the image is rebuilt. Docker blocks Chrome's nested sandbox here, so the GUI
launcher uses `--no-sandbox` inside the existing restricted container; do not
use this demo browser for sensitive browsing. Its authenticated noVNC GUI is
exposed only on this Mac at
`https://localhost:18443/` (which opens the login page). Cynapsa works
without Tailscale.

The buildable `slim-local` image contains the two apps, SDK, and Go Core, but
**not** enrollment tokens or the LiteLLM key. The local Compose setup mounts
those from ignored files. A separate **private, ready-to-run** GHCR image
contains the same desktop plus the Files and Client enrollment grants, the
LiteLLM key, and this demo's non-secret mesh/peer IDs. Anyone granted access
to that image can extract and use those credentials; never make the package
public or use it for unrelated or production identities. The cloud agents
have separate images and credentials.

All enhanced-demo image builds fetch the dedicated `demo-enhanced` branches of
`Cynapsa/cynapsagocore` and `Cynapsa/cynapsa-python-sdk`, initially copied
from their respective `main` branches. Later changes to either `main` do not
change this demo. Existing images also remain unchanged until rebuilt and
redeployed; verify their exact commits in `/opt/cynapsa/source-revisions`.

```sh
cd desktop
./run.sh
```

`./run.sh` opens the desktop with two idle terminals: one already in the Files
directory, one already in the Client directory. Open the GUI as described
below, then type `./run.sh` in the Files terminal and `./run.sh` in the Client
terminal. Neither agent joins the mesh until you start it. The AWS
Orchestrator and GCP Maps agents must also be running for the full demo to
answer questions. `./client.sh` is an alternative host-terminal launcher;
run only one Client instance at a time.
To replace a revoked installation using the mounted enrollment token, run
`./run.sh --force-enroll` in that agent's terminal instead.
In the Client terminal, use `./run.sh --quiet` to keep only the question
prompt, answers, and request failures; combine it with `--force-enroll` when
needed. `--silent` remains an alias for older enhanced-demo commands.

For a **fresh clone or another Apple Silicon Mac**, first install Docker
Desktop. Copy `desktop/.env.example` to `desktop/.env` and check the mesh and
all four peer IDs; the example values are for this demo, not new identities.
Prepare just the two local enrollment grants (Files and Client) and a LiteLLM
key with:

```sh
cd desktop
./prepare-local-secrets.sh /path/to/agents-info.txt /path/to/litellm_api_key
cp .env.example .env
# Check and edit .env for your mesh and agent identities.
# Set CYNAPSA_GITHUB_TOKEN in ../files/.env or your shell, then:
./run.sh --build
```

If only the desktop layer changed and `cynapsa-demo-enhanced-files:local`
already exists, `CYNAPSA_DEMO_REUSE_FILES_IMAGE=1 ./build.sh` rebuilds the
desktop without fetching SDK/Core again. This deliberately reuses the Files
image's existing SDK/Core version.

The grant file must contain `Files-enhanced:` and `Client-enhanced:` labels,
each followed on the next line by `export Cynapsa_TOKEN="..."`. The preparation
script writes only the two local tokens and LiteLLM key into ignored,
mode-`0600` files under `../.private/`; it does not add them to the image.
The GitHub token needs read access to the private SDK and Go Core repositories
for the build. `desktop/build.sh` fetches SDK/Core `demo-enhanced` and records their
commits in `/opt/cynapsa/source-revisions`. The pinned upstream desktop
commit is `2a1c0063f7246658e44c046651a970e08ca210f9`. The public Git
repository stores build files, not the credential files. The private GHCR
package stores the ready-to-run image.

### Run the private ready-to-run image on another Apple Silicon Mac

Install Docker Desktop and authenticate to `ghcr.io` using a GitHub account
granted read access to the private `Cynapsa/cynapsa-demo-enhanced-desktop`
package. From a checkout of this public repository, run:

```sh
cd desktop
./run-published.sh
```

The script pulls
`ghcr.io/cynapsa/cynapsa-demo-enhanced-desktop:ready-20261022` and starts the
GUI at `https://localhost:18443/`. There is no SDK/Core build, GitHub source
token, local `.env`, or local enrollment/key file to prepare. The Files and
Client terminals remain idle until you type `./run.sh` in each. To print the
one-click GUI URL, run:

```sh
docker exec -it cynapsa-demo-enhanced-published-desktop-1 remote-browser-credentials
```

The image intentionally shares the demo's Files and Client enrollment grants.
Use only one active installation per role; concurrent copies using the same
cached installation may conflict. Each Mac gets its own persistent Docker
volumes. The image tag is pinned to the bundled credentials and source
version; new releases should use a new tag rather than replacing it silently.

For maintainers only, [`desktop/ready/build-and-push.sh`](desktop/ready/build-and-push.sh)
builds this private image from the current `slim-local` image and the ignored
`.private/` files. It requires GitHub package-write access and verifies the
resulting package remains private. Do not move `.private/` into Git or change
the GHCR package visibility to public.

To open the graphical desktop, run the following in your own trusted terminal
and open the `noVNC one-click URL` it prints:

```sh
docker exec -it cynapsa-demo-enhanced-desktop-desktop-1 remote-browser-credentials
```

The URL is a full-desktop credential: keep it private and do not paste it into
chat or logs. The browser may warn about the container's locally generated
HTTPS certificate; approve it only after checking that the address is exactly
`https://localhost:18443`. The raw VNC/noVNC ports are not published, and the
local HTTPS listener exposes only `/login/*`, not the browser MCP endpoint.

The desktop has `demo-location.txt` and a `Files-Database` folder shortcut.
Both lead to the Files agent's persistent data directory at
`/home/codex/Projects/enhanced-files`. Editing the desktop file edits the same
file the agent reads. On first start, the image adds fictional people,
projects, and events text records to that directory; it never replaces an
existing record with the same name. The home volume also persists both
Cynapsa installation profiles.
Only put data there that you are comfortable sending to the model: demo
request/response logs contain full content without redaction. Inspect status
with `docker compose -f compose.yaml ps` and logs with
`docker compose -f compose.yaml logs -f desktop`. Stop with
`docker compose -f compose.yaml down`; this preserves volumes. The old
Tailscale volume and full desktop image were not deleted, but the slim desktop
does not mount or run them.

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
