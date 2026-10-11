# MCP servers for the AI capstone

The capstone (challenge 06) uses **Model Context Protocol (MCP)** servers so Copilot custom agents can act against Azure and GitHub.

The functional configuration lives in **[`../../.vscode/mcp.json`](../../.vscode/mcp.json)** (loaded automatically by VS Code Copilot agent mode in the Codespace).

| Server | Transport | What it gives the agents |
|---|---|---|
| **Azure MCP** (`@azure/mcp`) | stdio via `npx` | Query/operate Azure: resource graph, Monitor/Log Analytics, storage, AKS, role assignments, best practices, and more. |
| **GitHub MCP** (hosted) | HTTP (`https://api.githubcopilot.com/mcp/`) | Issues, pull requests, repo contents, code search — used to open gap-remediation issues and read evidence. |

## Using MCP in the Codespace (VS Code)

1. Open **Copilot Chat** and switch to **Agent** mode.
2. Click the **tools** (🔧) icon — the `azure` and `github` MCP servers appear.
3. Authenticate when prompted (Azure uses your `az login`; GitHub uses your Codespace identity).
4. Pick a custom agent from [`../agents`](../agents/) and ask it to act.

## Using MCP from the GitHub Copilot CLI

The devcontainer installs the Copilot CLI (`@github/copilot`). The Azure and GitHub MCP servers are also available to many CLI-based agent hosts; see each host's MCP configuration docs. For the classroom we standardise on **VS Code agent mode** for a consistent experience.

> [!TIP]
> The Azure MCP server starts on demand — no install step. The first call may take a few seconds while `npx` fetches it.
