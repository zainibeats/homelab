# Agent Context

Context for AI agents (`AGENTS.md` bundles, skills, MCP config) that run on my machines and work on things outside this repo, like the Obsidian vault. Nothing here is deployed by a Compose stack.

In this repo, `obsidian-vault/` is a gitignored symlink to that same vault, so an agent working on the repo and an agent working in the vault see the same files.

```mermaid
flowchart TD
    vault["Obsidian vault<br/>(e.g. ~/obsidian-vault)"]
    link["homelab/obsidian-vault<br/>(gitignored symlink)"]
    bundle["agent-context/tasknotes-obsidian<br/>AGENTS.md, .mcp.json, skills"]
    a["Agent A<br/>works on the homelab repo"]
    b["Agent B<br/>works in the vault"]

    link -->|points to| vault
    bundle -.->|copied into the vault root| vault
    a -->|reads notes via| link
    b -->|uses vault as project root| vault
```

This is different from [`.agents/`](../.agents/), which holds the agent configuration for working on this repository itself.

- **[TaskNotes Obsidian](./tasknotes-obsidian/README.md)** - Context bundle for the Obsidian vault and its TaskNotes task management
