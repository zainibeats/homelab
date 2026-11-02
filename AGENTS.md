# AGENTS.md

## Rules to Follow
- **Conciseness:** Be brief and direct unless asked for detail.
- **Verification:** Always verify the success of a command/tool before proceeding.
- **Context First:** Prioritize project files, the External Knowledge & Resources section, and `agentmemory` over general knowledge.
- **Ambiguity:** Ask for clarification immediately if user intent is unclear.
- **Safety:** Do not perform destructive operations (deleting files, overwriting large configs) without confirming the current state first.
- **Transparency:** If unsure about a specific path or dependency, point it out rather than guessing.
- **Conventions:** Follow [`docs/CONVENTIONS.md`](./docs/CONVENTIONS.md) when adding, moving, or documenting stacks (layout, compose `name:`, example files, `.gitignore`, README template).
- **Deployed clones:** hosts run stacks straight from their clone. Never run `git stash`, `checkout`, `reset`, `switch` or `clean` in one; see [Deploying](./docs/CONVENTIONS.md#deploying).
- **Root-owned live files:** don't edit them with sudo. Write `<file>.new`, show the diff, and let the user copy it in.
- **Commits:** follow [Commits](./docs/CONVENTIONS.md#commits).

## Workflow
1. **Analyze:** Read the necessary files and gather context before suggesting any changes.
2. **Plan:** Provide a high-level plan of the changes you intend to make. Wait for user approval if the change is significant.
3. **Execute:** Perform changes in small, logical increments.
4. **Verify:** After each major step, run a command (lint, test, or grep) to confirm the change worked as expected.

## External Knowledge & Resources
*Symlinked; only on machines that have it. Ignored by Git*
- **Obsidian Vault:** Located at `obsidian-vault/`
  - Contains personal notes, work-in-progress information, intended changes, and writing style preferences.
  - Key areas include:
    - `1-Projects`: Specific project goals and plans.
    - `2-Areas/Homelab`: Infrastructure plans, reports, and overview docs.
    - `TaskNotes`: Current tasks and to-do lists.
  - Use this for project history, deep technical plans, prompt styles, and tracking open tasks.

- **Private Documentation:** Located at `private-homelab-docs/`
  - Contains the "facts" and "part two" documentation for the homelab.
  - Key areas include:
    - `hardware/`: Detailed hardware specifications and inventory.
    - `network/`: Network topology and configuration details.
    - `operations/`: Operational procedures and guides.
    - `services/`: Documentation for various services (e.g., users, storage).
    - `context/`: Environment-specific details.
  - Use this as the primary source for established technical facts and operational details.
