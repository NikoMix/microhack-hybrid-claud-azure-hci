# Talk tracks

Use these talk tracks as the narrative spine for the day. They are intentionally
short enough to say out loud while pupils work.

## The Contoso migration story

Contoso is a regional manufacturer with a familiar estate: an ageing three-tier
application, a VMware cluster running beyond its ideal refresh window,
inconsistent patching, separate backup tools, and limited centralized evidence
for audits. The business wants modernization, but several workloads must stay
close to factories because of latency, data gravity, and operational continuity.

The target state is not "move everything overnight." The target state is a
governed hybrid platform. Azure Local provides the validated on-premises
infrastructure direction, while Azure Arc extends Azure management to servers and
Kubernetes wherever they run. Azure Monitor, Azure Update Manager, Backup, Azure
Site Recovery, Microsoft Defender for Cloud, and GitOps turn scattered
operational tasks into repeatable cloud-control-plane practices.

In the classroom, pupils do not deploy physical Azure Local hardware. Instead, a
small Azure VM stands in for a server to migrate, and a lightweight Kubernetes
cluster stands in for modern workloads on the edge. The important learning is
the operating model: discover, onboard, observe, protect, modernize, evidence,
and accelerate with GitHub Copilot.

The day ends with a partner-trainer lens. Pupils convert technical artifacts into
Module B evidence: implementation capability for B.1.1, eligible service
performance and customer diversity discussions for B.2.1 and B.2.2,
certification readiness for B.3.1, audit readiness for B.4.1, and reusable
onboarding assets for B.4.2.

> [!NOTE]
> Do not invent specialization thresholds. When customers ask about exact counts,
> revenue, certifications, or audit evidence requirements, point to the current
> Microsoft-issued Advanced Specialization requirements PDF.

## Challenge 00 — Setup

**Why it matters:** A partner delivery motion must be repeatable. Codespaces
gives every trainer the same workstation, while each pupil's Azure subscription
proves they can operate in a real control plane.

**Say:** "Before Contoso trusts us with hybrid modernization, we need a clean,
repeatable delivery environment. Today, Codespaces is our engineering workstation
and Azure is our customer control plane. If we can make setup predictable, we can
make the rest of the engagement teachable."

**Module B outcome:** establishes the delivery asset pattern that supports B.4.2
partner onboarding assets.

## Challenge 01 — Arc foundations

**Why it matters:** Azure Local becomes more valuable when it is governed through
Azure. Arc onboarding is the bridge between existing servers and the Azure
operating model.

**Say:** "This server may look ordinary, but once the Connected Machine agent is
installed, it becomes part of Contoso's Azure inventory. That is the first shift:
from hidden infrastructure to governed hybrid resources."

**Module B outcome:** demonstrates B.1.1 implementation capability through
Arc-enabled server onboarding and management.

## Challenge 02 — Observability

**Why it matters:** Customers do not buy hybrid platforms to create new blind
spots. They need inventory, health, logs, update posture, and repeatable runbooks.

**Say:** "Arc gets the server into the control plane; Monitor and Update Manager
make it operable. This is where a migration project starts to look like a
managed service rather than a one-time deployment."

**Module B outcome:** supports B.1.1 operations capability, B.2.1 eligible
service discussion, and B.4.2 onboarding/runbook assets.

## Challenge 03 — Resiliency

**Why it matters:** Hybrid credibility depends on recoverability and security
posture. Backup, disaster recovery, and Defender for Cloud show customers how
protected the estate is after onboarding.

**Say:** "Contoso does not only ask whether the workload runs. They ask whether
it can be recovered, audited, and defended. Today we connect the migrated server
to the Azure services that answer those questions."

**Module B outcome:** reinforces B.1.1 and B.2.1 with resiliency services, while
producing reusable B.4.2 operational assets.

## Challenge 04 — AKS enabled by Azure Arc

**Why it matters:** Azure Local is not only a place to run legacy workloads. It is
also a platform for modern workloads near the edge, managed consistently through
Azure Arc and GitOps.

**Say:** "The same control-plane idea applies to Kubernetes. We connect the
cluster, apply desired state with Flux, and show how platform teams can manage
edge workloads without inventing a separate process for every site."

**Module B outcome:** demonstrates B.1.1 hybrid implementation breadth and
contributes to B.2.1 service performance discussion.

## Challenge 05 — Specialization readiness

**Why it matters:** Technical labs only matter to Module B if they become
evidence. Partners need to understand what to collect, how to explain it, and
where their gaps are.

**Say:** "Now we step out of engineer mode and into trainer/auditor mode. Which
artifacts from the morning prove capability? Which are reusable onboarding
assets? Which gaps become actions before a real specialization review?"

**Module B outcome:** directly addresses B.2.1, B.2.2, B.3.1, B.4.1, and B.4.2
evidence readiness.

## Challenge 06 — AI capstone

**Why it matters:** GitHub Copilot custom agents, skills, and MCP servers can
reduce the friction of evidence review, runbook creation, IaC refinement, and
issue generation. They do not replace human accountability.

**Say:** "The capstone is not AI theater. We ask Copilot to inspect the same
evidence a trainer or consultant would inspect, draft the artifacts we need, and
flag gaps for human review. The partner remains responsible for the final answer."

**Module B outcome:** connects all controls by accelerating evidence validation,
onboarding assets, and audit readiness through human-governed AI.

## Closing talk track

"Contoso's journey today started with an unmanaged server and ended with a
governed hybrid story: Arc inventory, monitoring, update posture, resiliency,
security, Kubernetes GitOps, and an AI-assisted evidence package. As trainers,
your job is to help partners retell that story with their own customers, their
own proof, and the current Microsoft specialization requirements in hand."
