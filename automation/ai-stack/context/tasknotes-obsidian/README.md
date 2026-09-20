# TaskNotes / Obsidian Context

This directory is a [Claude Code](https://claude.com/claude-code) context bundle for working with a separate Obsidian vault — a personal "Second Brain" (PARA-organized) that uses the [TaskNotes](https://tasknotes.dev/) plugin for task management. The vault itself lives outside this repo (synced via Syncthing); these files are the reference material an agent reads before touching it.

It isn't deployed by any Docker Compose file in `ai-stack/` — it's kept here for version control alongside the rest of the AI tooling in this repo. See [Deployment layout](#deployment-layout) below for where each file actually needs to live to take effect.

## Contents

- **`AGENTS.md`** — vault-specific design notes: the PARA folder structure, TaskNotes' role within it, and the tagging strategy used to drive Obsidian's Graph View.
- **`skills/`** — a portable Claude Code skill (`tasknotes`) for creating, querying, and updating tasks. It probes the environment (MCP server, HTTP API, or direct filesystem access) and routes to whichever is available, with full schema/CLI/API details in `skills/references/`. Pulled from [vanillaflava/tasknotes-skill](https://github.com/vanillaflava/tasknotes-skill), not authored in this repo.
- **`.mcp.json`** — registers the TaskNotes MCP server (`http://localhost:8080/mcp`, `lifecycle: lazy`) as a project-scoped MCP server. The TaskNotes plugin's MCP Server toggle (Settings → TaskNotes → Integrations) must be enabled for the server to actually respond; see `skills/references/tasknotes-help.md` for setup and troubleshooting. If the agent tool and Obsidian are on the same machine, a local firewall may still need an allow rule for port 8080 from `127.0.0.1` before the connection succeeds.

## Deployment layout

This directory is the source copy kept for version control — it isn't read in place. To actually take effect, its contents are placed into the Obsidian vault (the project root, e.g. `/mnt/backup/syncthing/notes/obsidian-tasknotes`) matching each agent tool's own layout convention:

| Source (here) | Deployed to (vault root) |
|---|---|
| `AGENTS.md` | `AGENTS.md` |
| `.mcp.json` | `.mcp.json` |
| `skills/` | `.claude/skills/tasknotes-obsidian/` (Claude Code), `.pi/skills/tasknotes-obsidian/` (Pi), or the equivalent skills directory for whichever agent tool is in use |

`AGENTS.md` and `.mcp.json` are read from the project root regardless of tool; only the skill needs a tool-specific subdirectory, and the skill folder name (`tasknotes-obsidian`) doesn't need to match the `name:` in `skills/SKILL.md` frontmatter (`tasknotes`) — tools key off the frontmatter, not the folder name.
