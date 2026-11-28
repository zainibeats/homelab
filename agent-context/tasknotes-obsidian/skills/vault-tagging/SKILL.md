---
name: vault-tagging
description: Use when adding, changing, or auditing tags on notes in the Obsidian vault, when a note needs topic tags so it clusters in Graph View, or when asked which tag to use for a topic. Do not use for task schema, statuses, or PARA filing; those belong to the tasknotes and inbox-processing skills.
---

# Vault Tagging

Tags make Graph View show thematic clusters and cross-cutting links that folders hide. Each note gets a few basic topic tags, chosen from the vocabulary below or tags the vault already uses.

## Steps

1. **Read the note.** Read its frontmatter and body. Don't rewrite the body.
2. **Collect existing tags.** Run this from the vault root and skim the output for topics that match the note. It reads the inline `tags: [a, b]` form that AGENTS.md specifies:
   ```bash
   rg --no-filename '^tags:' --glob '*.md' . | rg -o '[a-z0-9][a-z0-9-]*' | grep -vx 'tags' | sort | uniq -c | sort -rn | head -80
   ```
   Also check body hashtags with `rg -o '#[a-z0-9-]+' --glob '*.md' . | sort | uniq -c | sort -rn | head -40`, so you reuse the same spelling.
3. **Pick 1 to 4 tags.**
   - Use the basic vocabulary below. Don't add product or technology tags unless the user asks.
   - Add a second tag when the note crosses themes, e.g. `homelab` and `networking`.
   - Reuse an existing tag whenever one fits. Propose a new tag only when the user agrees.
   - Tag only topics. Don't tag people or specific devices as entities.
   - Shopping tasks get `shopping` plus one domain tag: `hardware` (peripherals, adapters, computing gear), `homelab` or `networking` (servers, switches, patch panels), `security`, or `home` or `personal` (household and everyday items).
4. **Write the tags to frontmatter** as a YAML list, using the method AGENTS.md allows (`printf`):
   ```yaml
   tags: [homelab, networking]
   ```
5. **Verify.** Re-read the frontmatter. Confirm the `tags:` key is present once, the list is valid YAML, and every tag appears in the step 2 output or was approved by the user.

## Task notes

Task notes use the same `tags:` field. Keep `task` in the list, and add topic tags as usual. Schema rules are in the `tasknotes` skill.

## Tag vocabulary

The basic tags to use. Reuse these before creating anything new.

**System tags** (tooling depends on them; never rename or remove):
- `task`: TaskNotes requires it on every task note.
- `archived`: TaskNotes adds it when archiving.

**Topic tags:**
`career`, `dev`, `entertainment`, `hardware`, `health`, `home`, `homelab`, `linux`, `networking`, `personal`, `security`, `shopping`, `storage`, `utility`, `work`

**More tags exist.** This list is deliberately short. To see the full set in the vault, call the TaskNotes MCP tool `tasknotes_get_filter_options`. Use a tag beyond this list only if the user asks for it.

## Audit (when asked)

- List notes with no `tags:` key: `rg --files-without-match '^tags:' --glob '*.md' .`
- List tags used once. These are candidates to merge into an existing tag, but only change them with user approval.
