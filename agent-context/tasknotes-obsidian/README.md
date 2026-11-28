# TaskNotes / Obsidian Context

This directory is an AI agent context bundle for working with a separate personal Obsidian vault (PARA-organized) that uses the [TaskNotes](https://tasknotes.dev/) plugin for task management. The vault itself lives outside this repo (synced via Syncthing); these files are the reference material an agent reads before touching it.

It isn't deployed by any Docker Compose file. It's kept here for version control alongside the rest of the AI tooling in this repo. See [Deployment layout](#deployment-layout) below for where each file actually needs to live to take effect.

## Contents

- **`AGENTS.md`** — vault-specific design notes: the PARA folder structure, TaskNotes' role within it, and the tagging strategy used to drive Obsidian's Graph View.
- **`skills/`** — agent skills, one folder per skill so each is discovered on its own.
  - **[`skills/tasknotes/`](skills/tasknotes/SKILL.md)** — creates, queries, and updates tasks. It probes the environment (MCP server, HTTP API, or direct filesystem access) and routes to whichever is available, with full schema/CLI/API details in `skills/tasknotes/references/`. Pulled from [vanillaflava/tasknotes-skill](https://github.com/vanillaflava/tasknotes-skill), not authored in this repo.
  - **[`skills/vault-tagging/`](skills/vault-tagging/SKILL.md)** — adds and audits topic tags so notes cluster in Graph View.
  - **[`skills/vault-task-cleanup/`](skills/vault-task-cleanup/SKILL.md)** — audits tasks (missing statuses, empty tasks, done tasks not yet archived, tasks with no tags or project links) and proposes Update Status / Archive / Delete / Ignore for each issue.
  - **[`skills/inbox-processing/`](skills/inbox-processing/SKILL.md)** — turns quick captures in the vault's `0-Inbox/` into tasks and notes. It looks for an existing task or note to append to first, and never writes without confirmation.
- **`.mcp.json`** — registers the TaskNotes MCP server (`http://localhost:8080/mcp`, `lifecycle: lazy`) as a project-scoped MCP server. The TaskNotes plugin's MCP Server toggle (Settings → TaskNotes → Integrations) must be enabled for the server to actually respond; see `skills/tasknotes/references/tasknotes-help.md` for setup and troubleshooting. If the agent tool and Obsidian are on the same machine, a local firewall may still need an allow rule for port 8080 from `127.0.0.1` before the connection succeeds.

## Deployment layout

This directory is the source copy kept for version control, so it isn't read in place. To actually take effect, its contents are placed into the Obsidian vault (the project root, e.g. `~/obsidian-vault`) matching each agent tool's own layout convention:

| Source (here) | Deployed to (vault root) |
|---|---|
| `AGENTS.md` | `AGENTS.md` |
| `.mcp.json` | `.mcp.json` |
| `skills/*` | your agent's skills directory, one folder per skill (e.g. `.claude/skills/` or `.agents/skills/`) |

`AGENTS.md` and `.mcp.json` are read from the project root regardless of tool; only the skills need a tool-specific directory. Copy each folder under `skills/` as a sibling, since tools only discover `<skills-dir>/<name>/SKILL.md` one level deep. `skills/tasknotes/` is the vendored upstream copy; the other three are authored here.
