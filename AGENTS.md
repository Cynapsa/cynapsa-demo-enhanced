# Agent/operator runbook

This repository is the **enhanced** demo, separate from `Cynapsa/cynapsa-demo`.
Do not modify, stop, or reuse the original demo's containers, cloud workers,
secrets, volumes, or enrollment profiles while operating this one.

Read `README.md` first. The mesh display name is `demo-enhanced`; the wire ID
is `demo_enhanced_cynapsa_demo`. The four portal identities are Client,
Files, Maps, and Orchestrator with `-enhanced` names. Their full peer IDs are
in `desktop/.env.example` and the role `.env.example` files. Enrollment
tokens, LLM keys, and GitHub credentials must remain in ignored runtime files
or cloud secret stores, never in source, images, command-line arguments, or logs.

Topology: Client and Files are installed inside the pinned local desktop image;
Orchestrator runs in its own AWS ECS service; Maps runs in its own GCP Cloud Run
worker pool. Cynapsa carries inter-agent RPC. The desktop container does not
join Tailscale. Its authenticated GUI is published only to the Mac's
`127.0.0.1:18443` over HTTPS; do not publish it on a LAN or expose raw VNC.

Two idle terminal windows open in Xfce. The operator starts Files and Client
manually with `./run.sh` from each terminal's preselected role directory;
neither starts automatically.
`./run.sh --force-enroll` in either role terminal passes a real Cynapsa
force-enrollment request using that role's mounted enrollment token.
The Client terminal also supports `./run.sh --silent` (`--quiet` is an alias),
which suppresses diagnostic logs but leaves prompts, answers, and failures.
`desktop/client.sh` is an alternative host-terminal launcher. The desktop's
`demo-location.txt` and `Files-Database` link to the persistent Files data
directory. The two Cynapsa profiles remain separate on the home volume. Never
copy one role's profile to another role or start two instances of one role.

Each role's Dockerfile fetches SDK/Core `demo-enhanced` with a BuildKit GitHub-token
secret. Existing images do not automatically update when those branches
change. Rebuild and verify `/opt/cynapsa/source-revisions` before claiming a
new SDK/Core version is present. The desktop image copies the SDK/Core runtime
from its freshly built Files image, so its Client and Files processes have the
same runtime revisions.

All four applications use ordinary HTTP libraries under the Cynapsa CLI.
Maps, Orchestrator, and Files expose FastAPI apps; Client uses Requests.
Keep the enhanced mesh ID, profile names, peer IDs, and HTTP-origin maps
separate from the regular demo when synchronizing application logic or logs.

The slim image omits Chrome, Codex Desktop, Tailscale, guest access, and
Playwright MCP. It retains Xfce, Xvfb, noVNC, x11vnc, and the authenticated
local HTTPS gateway. The old full image and Tailscale volume remain available
for rollback and must not be deleted casually.

When diagnosing failures, verify the four mesh memberships, cloud worker
readiness, separate enrollment profiles, current peer IDs, and Cynapsa logs.
An accepted send is not proof of remote delivery; use an RPC result to verify
end-to-end operation. Do not expose token contents during debugging.
