# Grading checkpoints

Use this consolidated sheet to verify progress and tie hands-on work back to
Module B evidence. Keep answers concise; the goal is confidence, not a formal
exam.

## Challenge 00 — Setup

### Success criteria

- Codespace is open and toolchain is available.
- Azure CLI is logged into the intended subscription.
- `ARM_SUBSCRIPTION_ID` is set.
- Naming convention is understood: `rg-mhb-<initials>` and `*-mhb-<initials>-<challenge>`.
- Base environment is deployed or validated with `task deploy:base`.

### Checkpoint questions

**Q1. Why use Codespaces for this Train-the-Trainer lab?**

A: It gives every pupil the same workstation and toolchain, making delivery
repeatable and reducing local setup variance.

**Q2. Why does each pupil need Owner on the subscription?**

A: Provider registration, RBAC, Arc, Defender, and resiliency services may
require subscription-level actions.

## Challenge 01 — Arc foundations

### Success criteria

- Server-to-migrate VM exists.
- Connected Machine agent / `azcmagent` is installed.
- Arc-enabled server resource appears in Azure.
- Pupil can show agent status and resource metadata.
- Pupil can explain the Azure Local classroom simulation.

### Checkpoint questions

**Q1. What changes when a server becomes Arc-enabled?**

A: It becomes an Azure resource that can be governed, inventoried, extended, and
attached to Azure management services.

**Q2. Which Module B control does this most directly evidence?**

A: B.1.1 Azure Local implementation capability, because it shows hybrid assets
managed through the Azure control plane.

## Challenge 02 — Observability

### Success criteria

- Log Analytics workspace is available.
- Azure Monitor signal or heartbeat is visible for the Arc server.
- Pupil can run or interpret a basic KQL query.
- Azure Update Manager posture or assessment is discussed or shown.
- A reusable runbook/evidence note is captured.

### Checkpoint questions

**Q1. Why is observability part of a migration story?**

A: It proves the migrated estate can be operated consistently after onboarding,
not merely moved.

**Q2. How does Update Manager support customer operations?**

A: It centralizes update assessment and maintenance planning across hybrid
machines.

## Challenge 03 — Resiliency

### Success criteria

- Backup or Recovery Services components are identified or configured.
- Azure Site Recovery readiness or replication concepts are understood.
- Defender for Cloud / Defender for Servers Plan 2 is reviewed in a trial or short lab window where allowed.
- Pupil knows which resources create lingering cost.
- Pupil can explain cleanup requirements.

### Checkpoint questions

**Q1. Why are Backup and ASR discussed separately?**

A: Backup protects recoverable data points; ASR supports disaster recovery and
workload failover patterns.

**Q2. Why must Defender and ASR be cost-guarded during class?**

A: Plans, protected items, and replication can incur ongoing charges if left
enabled.

## Challenge 04 — AKS on Arc

### Success criteria

- Kubernetes cluster is reachable with `kubectl`.
- Cluster is connected to Azure as Arc-enabled Kubernetes where the challenge requires.
- Flux GitOps configuration is applied or interpreted.
- Pupil can show reconciliation status or relevant Azure resource.
- Pupil can explain the relationship to AKS enabled by Azure Arc.

### Checkpoint questions

**Q1. What problem does GitOps solve in the hybrid story?**

A: It applies desired state consistently to distributed clusters and creates an
auditable change path.

**Q2. Why use a lightweight cluster in class?**

A: It safely demonstrates the Azure Arc and GitOps operating model without
requiring physical Azure Local hardware.

## Challenge 05 — Specialization readiness

### Success criteria

- Pupil maps lab artifacts to B.1.1-B.4.2.
- Pupil identifies evidence gaps without inventing thresholds.
- Pupil can discuss ACR performance and customer diversity at a business-outcome level.
- Pupil understands certification readiness must be checked against current official requirements.
- Pupil drafts or reviews onboarding/audit assets.

### Checkpoint questions

**Q1. Where should exact Module B thresholds be verified?**

A: In the current Microsoft-issued Advanced Specialization requirements PDF.

**Q2. What is the difference between doing the lab and being audit ready?**

A: The lab creates sample capability evidence; audit readiness requires current
requirements, customer proof, eligible services, certifications, and documented
processes.

## Challenge 06 — AI capstone

### Success criteria

- Pupil opens or uses GitHub Copilot Chat with the repo context.
- Custom agents, skills, or MCP servers are used where available.
- Copilot helps validate evidence, generate runbooks, refine IaC, gap-check readiness, or open issues.
- Pupil reviews AI output critically.
- No secrets or customer confidential data are pasted into prompts.

### Checkpoint questions

**Q1. What is the role of Copilot in the capstone?**

A: It accelerates evidence review and artifact drafting; it does not replace
human accountability.

**Q2. What should become a GitHub Issue?**

A: Any evidence gap, cleanup risk, IaC improvement, missing runbook, or
specialization-readiness action that needs follow-up.

## Trainer scoring guide

| Status | Meaning | Action |
| --- | --- | --- |
| Green | Artifact exists and pupil can explain the Module B link | Move on or make them a table helper. |
| Yellow | Artifact partly exists or explanation is weak | Give one targeted fix or ask a peer to help. |
| Red | Blocked by access, quota, policy, or broken deployment | Use proctor support or trainer demo mode. |

Do not require every pupil to complete every optional Azure configuration.
Require every pupil to understand the evidence story and cleanup responsibility.
