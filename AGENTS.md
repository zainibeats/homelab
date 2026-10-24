# AGENTS.md

## Rules to Follow
- **Conciseness:** Be brief and direct unless asked for detail.
- **Verification:** Always verify the success of a command/tool before proceeding.
- **Context First:** Prioritize project files and `agentmemory` over general knowledge.
- **Ambiguity:** Ask for clarification immediately if user intent is unclear.
- **Safety:** Do not perform destructive operations (deleting files, overwriting large configs) without confirming the current state first.
- **Transparency:** If unsure about a specific path or dependency, point it out rather than guessing.
- **Conventions:** Follow [`docs/CONVENTIONS.md`](./docs/CONVENTIONS.md) when adding, moving, or documenting stacks (layout, compose `name:`, example files, `.gitignore`, README template).
- **Secrets:** Never commit secrets, tokens, or `.env` contents (Cloudflare API tokens, Authentik credentials, etc.) — check `.gitignore` covers them before staging changes, and flag if any appear already tracked. Never read token files or credentials in live config (e.g. `cloudflare-dns-token`, `ddclient.conf`); the user creates and edits them.
- **Deployed clones:** hosts run stacks straight from their clone. Never run `git stash`, `checkout`, `reset`, `switch` or `clean` in one; see [Deploying](./docs/CONVENTIONS.md#deploying).
- **Root-owned live files:** don't edit them with sudo. Write `<file>.new`, show the diff, and let the user copy it in.
- **Commits:** one Conventional Commits subject line. No body and no trailers (`Co-Authored-By`, session links).

## Workflow
1. **Analyze:** Read the necessary files and gather context before suggesting any changes.
2. **Plan:** Provide a high-level plan of the changes you intend to make. Wait for user approval if the change is significant.
3. **Execute:** Perform changes in small, logical increments.
4. **Verify:** After each major step, run a command (lint, test, or grep) to confirm the change worked as expected.

## External Knowledge & Resources
- **Obsidian Vault:** Located at `obsidian-vault/` (Symlinked; only on machines that have the vault).
  - This vault is ignored by git and contains extensive documentation, project plans, task tracking, and a prompt library.
  - Key areas include:
    - `1-Projects`: Specific project goals
    - `2-Areas/Homelab`: Infrastructure plans, reports, and overview docs.
    - `TaskNotes`: Current tasks and to-do lists.
  - When looking for project history, deep technical plans, or specific prompt styles, check this vault first.
