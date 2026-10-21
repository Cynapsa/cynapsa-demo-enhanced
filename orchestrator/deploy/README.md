# Enhanced Orchestrator deployment (AWS)

This is the **enhanced** Orchestrator, not the regular demo's ECS service.
It runs as ECS service `demo-enhanced-orchestrator` in cluster
`cynapsa-demo-enhanced`, region `us-east-1`, with one Fargate task. Its ECR
repository is `cynapsa-demo-enhanced-orchestrator`. The checked-in
[`aws-task-definition-enhanced.json`](aws-task-definition-enhanced.json) records
the task shape, peer IDs, and secret **references**, not secret values.
The 2026-10-21 rollout uses task definition
`cynapsa-demo-enhanced-orchestrator:3` and image digest
`sha256:4b9f0572850b7e1f15e90240075eff6a9e91cd78ce2c212f2ecfcf2d57159286`.
The new task reported a ready session and available mesh connectivity. No
paid end-to-end model call was made in this rollout.

The application is ordinary FastAPI/LangGraph code. The default image
command uses `cynapsa run --config /tmp/cynapsa-private/cynapsa.json -- app:app`
on the `demo_enhanced_cynapsa_demo` mesh, with no app HTTP listener.
`DEMO_MAPS_AGENT_ID`, `DEMO_FILES_AGENT_ID`, and `DEMO_CLIENT_AGENT_ID`
configure peer mappings and readable sender labels. The profile ID is
`demo-enhanced-orchestrator`. The task's EFS access point holds installation
state, while `/var/lib/cynapsa-memory` is task-local SQLite chat memory.
There must be one writer; restarting the task can reset chat history.

The image's SDK and Go Core come from their pinned `demo-enhanced` branches.
Read `/opt/cynapsa/source-revisions` in the image for exact commits. For this
rollout they are Go Core `0c3eaf27c6ed6f47bb716d1b134c237c6a91bcf5`
and SDK `14cff50c0aa564c5a54498e8d54af467007c28bc`.
To deploy, build and push a `linux/amd64` image, update only its immutable image
URI in the task definition, register a new revision, and update the service.
Preserve its EFS mount, secrets, roles, networking, and one-task count. This
single-installation service uses stop-before-start deployment
(`minimumHealthyPercent=0`, `maximumPercent=100`) with the deployment circuit
breaker enabled. Availability Zone rebalancing is disabled because ECS does
not permit it with `maximumPercent=100`. Do not restore overlapping deployment
while tasks share one installation state. Record the previous task definition
for rollback. Check the new task and CloudWatch
`/ecs/cynapsa-demo-enhanced-orchestrator` before
sending test traffic. The app prints `[cynapsa]` request/response content;
CLI network events are on, so use demo-only data.

```sh
aws ecs describe-services --region us-east-1 --cluster cynapsa-demo-enhanced --services demo-enhanced-orchestrator
aws ecs describe-task-definition --region us-east-1 --task-definition cynapsa-demo-enhanced-orchestrator
aws ecs register-task-definition --region us-east-1 --cli-input-json file://orchestrator/deploy/aws-task-definition-enhanced.json
aws ecs update-service --region us-east-1 --cluster cynapsa-demo-enhanced --service demo-enhanced-orchestrator --task-definition NEW_TASK_DEFINITION
```

Replace `NEW_TASK_DEFINITION` with the newly registered revision. Never run
the regular demo's enrollment grant or agent profile in this service.
