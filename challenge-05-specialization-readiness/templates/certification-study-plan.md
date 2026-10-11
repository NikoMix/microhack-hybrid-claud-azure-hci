# Template — Certification mapping & study plan (B.3.1)

> Reusable template for evidencing team **certifications** for **Module B control B.3.1
> (Certifications)**: a coverage matrix, a lab-to-exam objective mapping, and a per-person
> study plan. Machine-readable companion:
> [`certification-coverage-matrix.csv`](./certification-coverage-matrix.csv).

> [!IMPORTANT]
> The **exact required certifications** and the **number of certified individuals** are set in
> the **current Microsoft-issued Advanced Specialization requirements PDF** and can change. The
> exams below are the *typical* hybrid-infrastructure set — confirm the authoritative list and
> required counts in the PDF. Do **not** assert a required headcount; leave every
> `[PLACEHOLDER — see official Module B control PDF]`.

> [!WARNING]
> Some Windows Server hybrid exams have published change/retirement timelines. Always confirm
> current exam availability and replacement paths on each linked official exam page before
> committing a study plan.

## Typical hybrid-infrastructure certifications

| Exam | Title | Why it matters for Azure Local / Arc |
| --- | --- | --- |
| [AZ-800](https://learn.microsoft.com/credentials/certifications/exams/az-800/) | Administering Windows Server Hybrid Core Infrastructure | Core hybrid administration: AD DS, Arc, Windows Admin Center, Azure Monitor, Update Manager. |
| [AZ-801](https://learn.microsoft.com/credentials/certifications/exams/az-801/) | Configuring Windows Server Hybrid Advanced Services | Security, high availability, disaster recovery, and migration of hybrid workloads. |
| [AZ-104](https://learn.microsoft.com/credentials/certifications/exams/az-104/) | Microsoft Azure Administrator | The Azure control-plane foundation the whole lab assumes (≈ entry skill level). |
| [AZ-305](https://learn.microsoft.com/credentials/certifications/exams/az-305/) | Designing Microsoft Azure Infrastructure Solutions | Architecture depth: identity/governance, business continuity, and infrastructure design. |

## Coverage matrix

Mark each cell **Held** / **In progress** / **Gap**. Keep transcript evidence as a Microsoft
Learn transcript share link (not a screenshot of personal data).

| Person (ref) | Role | AZ-104 | AZ-800 | AZ-801 | AZ-305 | Transcript evidence | Target date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Engineer-1 | Hybrid infrastructure engineer | Held | In progress | Gap | Gap | `[PLACEHOLDER — link]` | `[PLACEHOLDER — yyyy-mm]` |
| Engineer-2 | Cloud operations engineer | Held | Gap | Gap | Gap | `[PLACEHOLDER — link]` | `[PLACEHOLDER — yyyy-mm]` |
| Architect-1 | Solutions architect | Held | Gap | Gap | In progress | `[PLACEHOLDER — link]` | `[PLACEHOLDER — yyyy-mm]` |

## Certification summary (verify against the PDF — do not invent)

| Field | Value |
| --- | --- |
| Required certifications | `[PLACEHOLDER — see official Module B control PDF]` |
| Required number of certified individuals | `[PLACEHOLDER — see official Module B control PDF]` |
| Distinct certified individuals evidenced | `[PLACEHOLDER — count Held rows]` |
| Requirement met? | `[PLACEHOLDER — Yes / No, after PDF check]` |

## Lab → exam objective domain mapping

Each microhack challenge reinforces specific exam skill domains. Use this to argue that the
hands-on lab is genuine, current exam-aligned preparation.

| Challenge | Reinforces (exam · skill domain) |
| --- | --- |
| [01 — Arc foundations](../../challenge-01-arc-foundations/) | AZ-800 · *Manage Windows Servers and workloads in a hybrid environment* (Azure Arc) · AZ-801 · *Migrate servers and workloads* |
| [02 — Observability](../../challenge-02-observability/) | AZ-800 · *Manage Windows Servers and workloads in a hybrid environment* (Monitor, Update Manager) · AZ-104 · *Monitor and maintain Azure resources* |
| [03 — Resiliency](../../challenge-03-resiliency/) | AZ-801 · *Implement disaster recovery* + *Secure Windows Server* · AZ-305 · *Design business continuity solutions* |
| [04 — AKS on Arc](../../challenge-04-aks-arc/) | AZ-104 · *Deploy and manage Azure compute resources* (containers) · AZ-305 · *Design infrastructure solutions* |
| [05 — Readiness](./) | AZ-305 · *Design identity, governance, and monitoring solutions* (governance & audit framing) |

## Per-person study plan

Duplicate this block per person with a **Gap** or **In progress** cell.

### Person: `<ref>` — target exam: `<AZ-xxx>`

- **Current status:** `[Held / In progress / Gap]`
- **Target date:** `[PLACEHOLDER — yyyy-mm]`
- **Official study guide:** `<link the matching aka.ms study guide from the exam page>`
- **Key skill domains to close:** `<list the 2–3 weakest domains for this person>`
- **Microsoft Learn paths:** `<add the learning paths from the exam page>`
- **Practice:** complete the matching lab challenge(s) from the mapping table above.
- **Checkpoint:** book the exam only after a practice assessment ≥ the published passing bar.

## Exam skill domains (current at authoring time — confirm on each exam page)

> [!NOTE]
> Skill domains are summarized from the official exam pages and are periodically revised.
> Treat the linked exam page and its `aka.ms` study guide as authoritative.

### AZ-800 — Administering Windows Server Hybrid Core Infrastructure

- Deploy and manage Active Directory Domain Services in on-premises and cloud environments.
- Manage Windows Servers and workloads in a hybrid environment.
- Manage virtual machines and containers.
- Implement and manage an on-premises and hybrid networking infrastructure.
- Manage storage and file services.

### AZ-801 — Configuring Windows Server Hybrid Advanced Services

- Secure Windows Server on-premises and hybrid infrastructures.
- Implement and manage Windows Server high availability.
- Implement disaster recovery.
- Migrate servers and workloads.
- Monitor and troubleshoot Windows Server environments.

### AZ-104 — Microsoft Azure Administrator

- Manage Azure identities and governance.
- Implement and manage storage.
- Deploy and manage Azure compute resources.
- Implement and manage virtual networking.
- Monitor and maintain Azure resources.

### AZ-305 — Designing Microsoft Azure Infrastructure Solutions

- Design identity, governance, and monitoring solutions.
- Design business continuity solutions.
- Design data storage solutions.
- Design infrastructure solutions.

## References

- [Microsoft Certifications — browse all](https://learn.microsoft.com/credentials/browse/)
- [Windows Server Hybrid Administrator Associate](https://learn.microsoft.com/credentials/certifications/windows-server-hybrid-administrator/)
- [Azure Solutions Architect Expert](https://learn.microsoft.com/credentials/certifications/azure-solutions-architect/)
- [Share your Microsoft Learn transcript](https://learn.microsoft.com/credentials/support/transcript-sharing)
