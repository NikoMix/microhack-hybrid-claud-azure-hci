# Agenda

This agenda expands the canonical one-day schedule in the root [README](../README.md).
Keep the headline block start times aligned with that source of truth, and use the
notes here to pace delivery inside each block.

> [!NOTE]
> Timings assume a 09:00 start, a room that already has Wi-Fi and projection
> working, and pupils opening GitHub Codespaces during the setup block. Adjust
> only the micro-timings; keep the challenge order intact.

## Compact timing table

| Time | Duration | Block | Challenge | Module B controls |
| --- | ---: | --- | --- | --- |
| 09:00 | 20 min | Welcome, Contoso story, architecture orientation | — | All controls context |
| 09:20 | 45 min | Setup and foundations | [00 — Setup](../challenge-00-setup/) | B.4.2 enablement assets |
| 10:05 | 70 min | On-prem to Azure-managed hybrid with Azure Local and Arc | [01 — Arc foundations](../challenge-01-arc-foundations/) | B.1.1 |
| 11:15 | 15 min | Break and checkpoint catch-up | 01/02 bridge | B.1.1 |
| 11:30 | 75 min | Hybrid observability and lifecycle | [02 — Observability](../challenge-02-observability/) | B.1.1, B.2.1, B.4.2 |
| 12:45 | 15 min | Evidence checkpoint and lunch handoff | 02 checkpoint | B.4.1, B.4.2 |
| 13:00 | 60 min | Lunch, optional lab support | — | — |
| 14:00 | 60 min | Hybrid resiliency: Backup, DR, and security | [03 — Resiliency](../challenge-03-resiliency/) | B.1.1, B.2.1, B.4.2 |
| 15:00 | 10 min | Break | — | — |
| 15:10 | 50 min | Modern workloads with AKS enabled by Azure Arc and GitOps | [04 — AKS on Arc](../challenge-04-aks-arc/) | B.1.1, B.2.1 |
| 16:00 | 35 min | Specialization readiness: ACR, diversity, certs, audit | [05 — Readiness](../challenge-05-specialization-readiness/) | B.2.1, B.2.2, B.3.1, B.4.1, B.4.2 |
| 16:35 | 40 min | AI capstone: the Hybrid Cloud Copilot | [06 — AI capstone](../challenge-06-ai-capstone/) | All controls |
| 17:15 | 15 min | Debrief, teardown, Train-the-Trainer wrap | — | B.4.1, B.4.2 |
| 17:30 | — | Close | — | — |

## Minute-by-minute run sheet

### 09:00-09:20 — Welcome, Contoso story, architecture orientation

- 09:00-09:05 — Welcome, safety briefing, cost guardrails, same-day teardown commitment.
- 09:05-09:10 — Position the course: Module B capability evidence, not a certification bootcamp.
- 09:10-09:15 — Tell the Contoso migration story from [talk tracks](talk-tracks.md).
- 09:15-09:20 — Walk the architecture in [architecture](architecture/README.md) and set expectations for the simulated on-prem server.

**What good looks like:** pupils can explain why Azure Arc is the control-plane
bridge to Azure Local, and why the lab uses a normal Azure VM as the
server-to-migrate stand-in.

### 09:20-10:05 — Challenge 00 setup and foundations

- 09:20-09:25 — Open Codespaces and explain the devcontainer toolchain.
- 09:25-09:35 — Azure login, subscription selection, environment variables.
- 09:35-09:45 — Toolchain smoke test with `task setup`, `az version`, and `terraform version`.
- 09:45-10:00 — Deploy or validate the base environment with `task deploy:base`.
- 10:00-10:05 — Quick checkpoint: resource group naming and region.

**What good looks like:** each pupil has a Codespace, is signed in with Owner
access, and has a resource group named `rg-mhb-<initials>` in `swedencentral` or
a trainer-approved alternate region.

### 10:05-11:15 — Challenge 01 Arc foundations

- 10:05-10:10 — Mini-demo: Arc resource, Connected Machine agent, and Azure Local relationship.
- 10:10-10:30 — Prepare the Linux VM and identity used for onboarding.
- 10:30-10:50 — Install and connect `azcmagent`; discuss the Azure VM IMDS-block technique when simulating a non-Azure machine.
- 10:50-11:05 — Inspect Azure Arc-enabled server inventory and extensions.
- 11:05-11:15 — Checkpoint questions and evidence capture.

**What good looks like:** the server appears as an Arc-enabled server, pupils can
find agent status, resource ID, tags, and explain why this supports B.1.1
implementation capability.

### 11:15-11:30 — Break and recovery window

Use this as a hard stop for the front of the room and a soft recovery window for
anyone still onboarding Arc. Pair fast finishers with slower tables.

**What good looks like:** no pupil starts observability without an Arc resource or
a trainer-approved shared demo target.

### 11:30-12:45 — Challenge 02 observability and lifecycle

- 11:30-11:40 — Explain Log Analytics, Azure Monitor, Azure Update Manager, and Arc Insights as operations evidence.
- 11:40-12:05 — Configure monitoring, collect heartbeat/log evidence, and run basic KQL.
- 12:05-12:20 — Use Azure Update Manager assessment views and discuss maintenance windows.
- 12:20-12:35 — Convert observations into a reusable onboarding/runbook asset.
- 12:35-12:45 — Checkpoint and lunch handoff.

**What good looks like:** pupils can show an Azure Monitor signal for the Arc
server and describe how Update Manager reduces operational variance across
customer estates.

### 12:45-14:00 — Evidence checkpoint and lunch

- 12:45-13:00 — Capture screenshots or exported evidence while the trainer answers blockers.
- 13:00-14:00 — Lunch. Keep one trainer or proctor available for subscription and quota issues.

**What good looks like:** by 14:00, most pupils have completed Challenges 00-02;
anyone behind is paired or moved to trainer demo mode.

### 14:00-15:00 — Challenge 03 resiliency

- 14:00-14:08 — Frame Backup, Azure Site Recovery, and Defender for Cloud as customer trust controls.
- 14:08-14:25 — Configure backup vault or Recovery Services components and discuss soft-delete.
- 14:25-14:40 — Walk Azure Site Recovery readiness and replication concepts.
- 14:40-14:50 — Enable or review Microsoft Defender for Cloud / Defender for Servers Plan 2 in a trial or short lab window.
- 14:50-15:00 — Checkpoint and cost reminder.

**What good looks like:** pupils understand which resiliency resources can create
lingering cost, can identify protection status, and can articulate the Module B
evidence value without claiming fabricated numeric thresholds.

### 15:10-16:00 — Challenge 04 AKS enabled by Azure Arc and GitOps

- 15:10-15:18 — Explain AKS enabled by Azure Arc, Arc-enabled Kubernetes, and why k3s/kind is a classroom proxy.
- 15:18-15:35 — Connect the Kubernetes cluster to Azure Arc.
- 15:35-15:48 — Apply Flux GitOps and validate reconciliation.
- 15:48-16:00 — Checkpoint: operational model and customer workload modernization discussion.

**What good looks like:** pupils see a connected Kubernetes resource, Flux
configuration status, and can explain where Azure Local would host the production
workload.

### 16:00-16:35 — Challenge 05 specialization readiness

- 16:00-16:08 — Translate lab evidence into Module B control evidence.
- 16:08-16:18 — Discuss ACR performance, customer diversity, and certification readiness without inventing thresholds.
- 16:18-16:28 — Build a gap list and onboarding asset outline.
- 16:28-16:35 — Checkpoint: evidence package completeness.

**What good looks like:** pupils can map each lab artifact to B.1.1-B.4.2 and
know where to verify exact current requirements in the official Advanced
Specialization requirements PDF.

### 16:35-17:15 — Challenge 06 AI capstone

- 16:35-16:42 — Demo GitHub Copilot custom agents, skills, and MCP servers.
- 16:42-17:00 — Pupils use agents to validate evidence, generate runbooks, gap-check, and open issues.
- 17:00-17:10 — Share best prompts and human-review guardrails.
- 17:10-17:15 — Capstone checkpoint.

**What good looks like:** the AI assistant accelerates evidence review and
runbook drafting, but the pupil remains accountable for accuracy, security, and
customer-specific judgment.

### 17:15-17:30 — Debrief, teardown, Train-the-Trainer wrap

- 17:15-17:20 — Run teardown commands and highlight manual cleanup paths.
- 17:20-17:25 — Collect feedback and identify which parts trainers will adapt.
- 17:25-17:30 — Final subscription-clean verification and close.

**What good looks like:** pupils leave with no intended lab resources running, a
clear Module B story, and a plan to adapt the day for their own partner audience.
