# Trainer notes — Challenge 06 · AI Capstone

## Timing

| Segment | Minutes | Notes |
|---|---|---|
| Intro: agents/skills/MCP model | 10 | Frame it: AI orchestrated, human governed. Show the files. |
| Evidence validation (B.4.1) | 15 | The "wow" moment — a scorecard from their own artifacts. |
| Live estate via Azure MCP (B.1.1) | 15 | Show the MCP tool call + the Mermaid diagram render. |
| Onboarding runbook (B.4.2) | 15 | Generates a reusable, parameterized asset. |
| ACR + cert gaps (B.2.1/B.3.1) | 10 | Two quick skill invocations. |
| Open Issues via GitHub MCP | 10 | Close the loop: gaps become tracked work. |
| Debrief / Train-the-Trainer | 10 | How to extend agents/skills for their own practice. |

**Total:** 75–85 min. Flex the last two segments if running late.

## Talk track

> "You've spent the day building a hybrid estate and the evidence to prove your Module B
> capability. Now we let Copilot *operate on it*. These aren't generic chatbots — they're
> **custom agents** with a role, **skills** that encode our exact playbooks, and **MCP
> servers** that connect them to your live Azure subscription and this GitHub repo. The
> human stays in control: the agents propose, you approve. This is the repeatable motion a
> partner brings to every Advanced Specialization engagement."

## Live demo script

1. Open `.github/agents/module-b-audit-agent.agent.md` on the projector — show the
   frontmatter (`tools: [... azure/*, github/*]`) and the role prompt. Explain how the file
   *is* the agent.
2. Switch to Copilot agent mode, pick **Module B Audit Agent**, run the evidence-validation
   prompt from the README. Narrate the `evidence-validator` skill triggering.
3. Pick **Hybrid Cloud Architect**, run the Azure MCP estate query — pause on the tool
   approval prompt to make the "human governed" point. Show the rendered Mermaid diagram.
4. Pick **Arc Onboarding Copilot**, generate the runbook, show it written into `assets/`.
5. Run the "open Issues for gaps" prompt; switch to the repo Issues tab and show them land.
6. Debrief: open one skill file and show how trivially a trainer can add their own.

## Common pitfalls

- **MCP server not started.** If a tool call fails, open the tools (🔧) picker and confirm
  `azure` and `github` are running. Azure MCP starts on first use via `npx` — the first
  call is slow.
- **Azure MCP auth.** It uses the pupil's `az login` context. If it returns nothing, check
  `az account show` points at the right subscription.
- **Agent not listed.** The workspace must be trusted and opened at the repo root so
  `.github/agents/` is discovered. Reload the window if needed.
- **GitHub MCP permissions.** Opening Issues needs the Codespace's GitHub identity to have
  write on the repo. For forks, pupils open Issues on their own fork.
- **Over-trusting output.** Reinforce: agents are explicitly told **not** to fabricate
  Module B thresholds. Always confirm numbers against the official requirements PDF.

## Checkpoint questions & answers

1. **Q:** What are the three building blocks of this capstone and what does each do?
   **A:** **Custom agents** (role + system prompt in `.github/agents/`), **skills**
   (reusable task playbooks in `.github/skills/`), and **MCP servers** (live connectors —
   Azure MCP to read the subscription, GitHub MCP to open Issues).
2. **Q:** Why is "human governed" essential here for audit work?
   **A:** The agents propose evidence verdicts and changes, but a person approves tool
   calls and confirms thresholds against the official PDF — preserving accountability and
   preventing fabricated or unverified audit claims.

## Reset between cohorts

- Close/delete Issues the cohort created (or use a labelled, archived demo repo).
- Remove generated artifacts under `challenge-06-ai-capstone/assets/` if you want a clean
  slate: `git clean -nd challenge-06-ai-capstone/assets` (review, then drop `-n`).
- No Azure resources are created by this challenge, so teardown is covered by
  [docs/teardown.md](../docs/teardown.md).
