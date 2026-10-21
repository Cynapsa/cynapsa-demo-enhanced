# Enhanced Maps agent

This is an ordinary FastAPI/LangGraph app (`app:app`) with POST `/maps` and a wildcard POST handler. It uses the Google Places API and a LiteLLM-compatible model. The application imports no Cynapsa SDK: `cynapsa run` supplies the mesh connection and invokes the ASGI lifespan and routes without opening an application HTTP listener.

The wire mesh ID is `demo_enhanced_cynapsa_demo`. Keep this role's enrollment token, Google Places key, LiteLLM key, and GitHub build token in ignored `.env`, `.private/`, or a cloud secret store. Do not copy the regular demo's profile or tokens. `DEMO_ORCHESTRATOR_AGENT_ID` maps the authenticated sender to `http://orchestrator-enhanced.local` for HTTP-style request metadata and readable logs. The CLI profile ID is `demo-enhanced-maps`.

For a local role image, fill `.env` from `.env.example` and run `./run.sh --build`, then `./run.sh`. Use `./run.sh --force-enroll` only after stopping the old instance and providing a valid grant. The image builds SDK/Core from their `demo-enhanced` branches; inspect `/opt/cynapsa/source-revisions` in the container to verify exact commits. The GCP worker pool is `cynapsa-demo-enhanced-maps` in project `aztm-amesh`, region `us-central1`; rebuilding locally does not redeploy it.

The app logs `[cynapsa]` request/response content and the CLI logs confirmed mesh events. Model/Places HTTP access logs are suppressed below WARNING. Do not use private prompts if full request-body logging is inappropriate. The public HTTP mode requires `DEMO_HTTP_ACCESS_KEY`; the default Cynapsa mode accepts only mesh traffic.
