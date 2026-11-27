# Obsidian Vault

Design notes for the Obsidian vault (`~/obsidian-vault`). Task schema and CLI/API details live in the `tasknotes` skill. The tagging workflow lives in the `vault-tagging` skill.

## Structure (PARA)

- **0-Inbox**: raw captures (see `inbox-processing` skill)
- **1-Projects**: active goals with end dates
- **2-Areas**: ongoing responsibilities
- **3-Resources**: reference material
- **4-Archives**: completed or inactive items
- **TaskNotes/** (not PARA): `Tasks/` holds task notes; `Views/` holds `.base` view definitions

## Tasks

- Task notes live in `TaskNotes/Tasks/`. Link them to PARA with the `projects:` wikilink field; never move them into PARA folders.
- Use the default statuses (`open`, `in-progress`, `done`) and priorities (`low`, `normal`, `high`). If unsure, match the values already in the vault.
- `dateCreated` and `dateModified` use full ISO 8601 with offset, e.g. `2026-05-31T10:49:12.895-07:00`.

## Tagging

Tags exist to reveal thematic clusters and cross-cutting links in Graph View, which folders cannot show. Full workflow: `vault-tagging` skill.

- Put tags in frontmatter `tags:`, not body hashtags.
- Use the basic tags listed in the `vault-tagging` skill and reuse existing ones. Add a new tag only when asked.
- Task notes and regular notes share the same `tags:` field. Task notes also need `task`.
- Topic tags only; don't track people or hardware as entities.

## Rules

- Keep responses concise.
- Synthesize and organize rather than transcribing verbatim, unless the user asks for verbatim text.
- Ask when intent is ambiguous.
- Frontmatter-only task edits (status, priority, due date) are routine. Ask before rewriting a task body or deleting a task file.
- Ask before moving notes or tasks out of `4-Archives/` or `TaskNotes/Archive/`, or before adding significant new information to them.
- Don't invent status or priority values.
- Make task changes through the `tasknotes` skill and its MCP server, not manual file edits.
- You may improve an existing helper script in place. Don't create new scripts.

## Common Phrase Aliases

| Phrase | Folder |
|---|---|
| "check my inbox" | `0-Inbox/` |
| "show projects" | `1-Projects/` |
| "list tasks" | `TaskNotes/Tasks/` |
| "open resources" | `3-Resources/` |

## Style

- Use commas, colons, or restructured sentences instead of em dashes.
