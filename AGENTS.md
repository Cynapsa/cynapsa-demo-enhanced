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

Topology: Client and Files run inside the pinned local desktop image;
Orchestrator runs in its own AWS ECS service; Maps runs in its own GCP Cloud Run
worker pool. Cynapsa carries inter-agent RPC. The desktop container does not
join Tailscale or publish a GUI port; that is intentional for local-only use.

Files is a supervised process. The interactive Client starts via
`desktop/client.sh`, which executes inside the already-running desktop
container. The Files data directory and two separate Cynapsa profiles are on
the desktop home volume. Never copy one role's profile to another role.

Each role's Dockerfile fetches SDK/Core `main` with a BuildKit GitHub-token
secret. Existing images do not automatically update when those branches
change. Rebuild and verify `/opt/cynapsa/source-revisions` before claiming a
new SDK/Core version is present. The desktop image copies the SDK/Core runtime
from its freshly built Files image, so its Client and Files processes have the
same runtime revisions.

When diagnosing failures, verify the four mesh memberships, cloud worker
readiness, separate enrollment profiles, current peer IDs, and Cynapsa logs.
Native `send` is not proof of remote delivery; use an RPC result to verify
end-to-end operation. Do not expose token contents during debugging.
