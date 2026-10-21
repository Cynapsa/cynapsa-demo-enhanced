# Enhanced Maps deployment (GCP)

This is the **enhanced** Maps agent, not the regular demo's Maps worker.
It runs as Cloud Run worker pool `cynapsa-demo-enhanced-maps` in project
`aztm-amesh`, region `us-central1`, with one instance and no public app HTTP
listener. Its Docker image is stored at
`us-central1-docker.pkg.dev/aztm-amesh/cynapsa-v2/cynapsa-demo-enhanced-maps`.
The 2026-10-21 rollout uses revision `cynapsa-demo-enhanced-maps-00004-chs`
and image digest
`sha256:1fda9ad7709d86739a3107a3d1e94e1dfb70f71cbe3d4b5eb586a9f201b96ff6`.
The pool reported Ready with one instance; startup logs showed an available
mesh connection. No paid end-to-end model/Places call was made in this rollout.

The application is ordinary FastAPI code. The default image command uses
`cynapsa run --config /tmp/cynapsa-private/cynapsa.json -- app:app` to run it
over the `demo_enhanced_cynapsa_demo` mesh. `DEMO_ORCHESTRATOR_AGENT_ID` maps the
peer to `http://orchestrator-enhanced.local` for HTTP-style request metadata.
The worker uses the `demo-enhanced-maps` profile; its enrollment grant and
model/Google Places API keys come from GCP Secret Manager bindings, never the
image. It needs egress to the mesh server, model gateway, and Places API.

The image's SDK and Go Core come from their pinned `demo-enhanced` branches.
Read `/opt/cynapsa/source-revisions` in the image to see their exact commits.
For this rollout they are Go Core `0c3eaf27c6ed6f47bb716d1b134c237c6a91bcf5`
and SDK `14cff50c0aa564c5a54498e8d54af467007c28bc`.
Changing a branch alone does not update a running worker: build and push a new
`linux/amd64` image, then point the worker pool at that image. Preserve the
existing environment, secret bindings, service account, and one-instance
setting. Check readiness and startup logs before sending test traffic. The
app prints `[cynapsa]` request/response content; CLI network events are on.
Do not send confidential data through this full-content demo log.

```sh
gcloud run worker-pools describe cynapsa-demo-enhanced-maps --project aztm-amesh --region us-central1
gcloud run worker-pools update cynapsa-demo-enhanced-maps --project aztm-amesh --region us-central1 --image IMAGE_DIGEST
```

Replace `IMAGE_DIGEST` with the pushed immutable Artifact Registry image URI.
For rollback, record the previous image URI before updating. Re-enrollment
may be required after a new ephemeral instance starts; keep the enhanced
grant valid and do not run two instances with the same installation profile.

The historical regular-demo GCP deployment notes are retained separately only
for comparison; they are not instructions for this worker.
