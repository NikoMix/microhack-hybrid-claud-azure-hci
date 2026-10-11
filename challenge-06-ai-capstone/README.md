# Challenge 06 — AI Capstone: the Hybrid Cloud Copilot

> Put GitHub Copilot **custom agents + skills + MCP servers** to work on the hybrid estate
> you built today — to validate Module B evidence, generate onboarding assets, refine
> Terraform, gap-check certifications, and open remediation Issues. **AI orchestrated,
> human governed.**

## 🎯 Objectives

By the end of this challenge you will be able to:

- Use **GitHub Copilot custom agents** (`.github/agents/`) and **skills** (`.github/skills/`)
  to accelerate Azure hybrid-cloud and Module B audit work.
- Connect Copilot to live systems through **MCP servers** — the **Azure MCP** server (read
  your subscription) and the **GitHub MCP** server (open Issues).
- Drive an end-to-end "evidence → gaps → remediation" loop that a partner could reuse on a
  real Advanced Specialization engagement.

## 🧩 Module B coverage

| Control | How this challenge contributes |
|---|---|
| **B.4.1 — Audit Readiness** | The *Module B Audit Agent* + `evidence-validator` skill score the evidence package and surface gaps. |
| **B.4.2 — Partner Onboarding Assets** | The *Arc Onboarding Copilot* + `runbook-generator` skill produce reusable runbooks/onboarding packs. |
| **B.1.1 — Implementation Capability** | The *Hybrid Cloud Architect* refines the AVM Terraform and architecture artifacts. |
| **B.2.1 / B.3.1** | The `acr-eligibility-mapper` and `cert-gap-checker` skills produce the ACR mapping and certification gap analysis. |

## ⏱️ Duration & prerequisites

- **Duration:** 60–90 minutes (the capstone).
- **Prerequisites:**
  - Challenges 00–05 complete (you need a deployed estate and a draft evidence package).
  - The **azure** and **github** MCP servers started in Copilot agent mode (verified in
    [challenge-00](../challenge-00-setup/#6-wire-up-copilot-agents-skills--mcp)).

> [!NOTE]
> The AI layer here is **pure GitHub Copilot** — custom agents, skills, and MCP servers.
> There is **no standalone inference app** to deploy. Everything runs inside Copilot in
> your Codespace.

## 🛠️ Tasks

### 1. Meet your agents

Open **Copilot Chat → Agent mode** and review the three custom agents in
[`.github/agents/`](../.github/agents/):

| Agent | Use it to… |
|---|---|
| **Hybrid Cloud Architect** | explain/refine the architecture and AVM Terraform; render diagrams. |
| **Module B Audit Agent** | score readiness for B.1.1–B.4.2 and find gaps. |
| **Arc Onboarding Copilot** | generate Arc onboarding steps and reusable runbooks. |

The five skills in [`.github/skills/`](../.github/skills/) are invoked automatically when
relevant (e.g. ask to "validate my evidence package" → `evidence-validator`).

### 2. Validate the evidence package (B.4.1)

Select the **Module B Audit Agent** and prompt:

> *"Validate my Module B evidence package in `challenge-05-specialization-readiness/` and
> give me a readiness scorecard for controls B.1.1–B.4.2 with cited evidence and gaps."*

Confirm it uses the `evidence-validator` skill and produces a per-control verdict table.

### 3. Inspect the live estate via Azure MCP (B.1.1)

Select the **Hybrid Cloud Architect** and prompt:

> *"Using the Azure MCP server, list the resources in `rg-mhb-<initials>`, map them to the
> hybrid reference architecture, and render a Mermaid diagram of the current state."*

### 4. Generate onboarding assets (B.4.2)

Select the **Arc Onboarding Copilot** and prompt:

> *"Generate a reusable Azure Arc onboarding runbook for the server-to-migrate, then save
> it under `challenge-06-ai-capstone/assets/` and add it to the evidence index."*

This exercises the `runbook-generator` skill.

### 5. ACR mapping & certification gaps (B.2.1, B.3.1)

Ask the **Module B Audit Agent** (or invoke the skills directly):

> *"Map my deployed resources to candidate ACR categories, then build a certification gap
> analysis and study plan for AZ-800/AZ-801."*

### 6. Open remediation Issues via GitHub MCP (B.4.1)

Finally:

> *"For every Partial/Not-yet/Unknown gap in the scorecard, open a GitHub Issue with the
> matching `module-b` label, acceptance criteria, and a suggested owner."*

Confirm the agent uses the **github** MCP server and that the Issues appear in the repo.

## ✅ Success criteria

- [ ] All three custom agents are selectable and respond in character.
- [ ] The **Module B Audit Agent** produced a readiness scorecard citing real artifacts.
- [ ] The **Azure MCP** server returned live resources from your subscription.
- [ ] A reusable onboarding runbook was generated and added to the evidence index.
- [ ] An ACR mapping table and a certification gap/study plan were produced.
- [ ] At least one **GitHub Issue** was opened via the GitHub MCP server for a real gap.

## 🧹 Cleanup

No new Azure resources are created here. Proceed to end-of-day teardown via
**[docs/teardown.md](../docs/teardown.md)** (`task destroy:base`).

## 📚 References

- [About custom agents (GitHub Copilot)](https://docs.github.com/copilot/customizing-copilot)
- [Use MCP servers in VS Code](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Azure MCP Server](https://github.com/Azure/azure-mcp)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Hybrid Cloud Infrastructure with Microsoft Azure Local — Advanced Specialization](https://learn.microsoft.com/partner-center/membership/advanced-specializations)
