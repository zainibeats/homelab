# TaskNotes / Obsidian Context

This directory is an AI agent context bundle for working with a separate personal Obsidian vault (PARA-organized) that uses the [TaskNotes](https://tasknotes.dev/) plugin for task management. The vault itself lives outside this repo (synced via Syncthing); these files are the reference material an agent reads before touching it.

It isn't deployed by any Docker Compose file. It's kept here for version control alongside the rest of the AI tooling in this repo. See [Deployment layout](#deployment-layout) below for where each file actually needs to live to take effect.

## Who uses this

Two kinds of agent touch the vault, and this bundle is for only one of them. See the [diagram](../README.md) in the `agent-context` README.

| | Works in | Reads this bundle? | Writes to the vault? |
|---|---|---|---|
| **Agent A** (repo agent) | `homelab/` | No | No. It reads notes through the `obsidian-vault/` symlink and may at most drop a new capture into `0-Inbox/`. |
| **Agent B** (vault agent) | the vault | Yes: `AGENTS.md`, `.mcp.json`, and every skill below | Yes, through the skills, asking first where the rules say so |

The inbox is the handoff: Agent A leaves a capture in `0-Inbox/`, and Agent B later turns it into tasks and notes with the `inbox-processing` skill. `AGENTS.md` and the skills here are written for Agent B only.

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

`AGENTS.md` is read from the project root by most agent tools (Pi, Cursor, Codex, OpenCode, and Claude Code when there is no `CLAUDE.md`). Gemini CLI needs `AGENTS.md` added to `context.fileName` in its settings. Skills need a tool-specific directory, and `.agents/skills/` is the documented project location for Pi.

`.mcp.json` is a narrower case. Claude Code reads it natively. Pi has no built-in MCP support, so it needs the community `pi-mcp-adapter` package, which also reads a project-root `.mcp.json`. Other tools use their own files: `.cursor/mcp.json`, `.codex/config.toml`, `.gemini/settings.json`, `opencode.jsonc`. The `lifecycle` field is a `pi-mcp-adapter` option, and `lazy` is already its default.

Copy each folder under `skills/` as a sibling, since tools only discover `<skills-dir>/<name>/SKILL.md` one level deep.

The `.agents/` folder in the vault is the vault agent's own config. It is separate from this repo's `.agents/`, which configures the agent working on the homelab.

### Installing and updating

This repo is the source of truth. Make changes here and redeploy; edits made only to the deployed copy in the vault are overwritten the next time you copy.

Copy (re-run after any change here):

```bash
VAULT=~/obsidian-vault
cd ~/repos/homelab/agent-context/tasknotes-obsidian
cp AGENTS.md .mcp.json "$VAULT"/
mkdir -p "$VAULT/.agents/skills"
rsync -a --delete skills/ "$VAULT/.agents/skills/"
```

`--delete` removes skills from the vault that no longer exist here, so don't keep other skills in `$VAULT/.agents/skills/`. Drop it if you do.

Or symlink the skills so updates here apply immediately:

```bash
mkdir -p "$VAULT/.agents/skills"
ln -sfn ~/repos/homelab/agent-context/tasknotes-obsidian/skills/* "$VAULT/.agents/skills/"
```

The vault is synced with Syncthing, and a symlink points at a path that exists only on this machine. On other synced devices it will be broken, so use the copy method if you open the vault anywhere else.

### Vendored skill

`skills/tasknotes/` is a vendored copy of [vanillaflava/tasknotes-skill](https://github.com/vanillaflava/tasknotes-skill) (MIT, license included), unmodified. It is currently at upstream v5.0 (commit `f603ed9`, 2026-11-26) and targets TaskNotes plugin 5.0.x. To update, copy upstream's `tasknotes/` folder over it, and update the version and commit above. The other three skills are authored here.
