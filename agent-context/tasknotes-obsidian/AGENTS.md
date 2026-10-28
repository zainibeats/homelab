# Design Document: Obsidian Second Brain

## Overview
Architectural overview and tagging strategy for the Obsidian "Second Brain" vault (`/mnt/backup/syncthing/notes/obsidian-vault`). Task management is handled by the **TaskNotes** plugin in `TaskNotes/`. For task schema, CLI, and API details, refer to the `tasknotes` skill.

## Organizational Structure
Uses the **PARA method**:

*   **0-Inbox**: Raw/unprocessed captures.
*   **1-Projects**: Active goals with end dates (e.g., Learning Goals).
*   **2-Areas**: Ongoing responsibilities (e.g., Dev, Homelab).
*   **3-Resources**: Reference material (e.g., CCNA, Prompt Library).
*   **4-Archives**: Completed/inactive items.

**`TaskNotes/`** (auto-managed, not part of PARA):
*   **Tasks/**: Individual task notes.
*   **Views/**: `.base` view definitions (Kanban, Calendar, etc.).

## Task Model (TaskNotes)
Uses **default settings**: statuses (`open`, `in-progress`, `done`), priorities (`low`, `normal`, `high`), and `tags: [task]`. Verify via existing tasks if uncertain. Refer to the `tasknotes` skill for full schema/syntax.

**Timestamps:** `dateCreated`/`etc.` use full ISO 8601 with offset (e.g., `2026-05-31T10:49:12.895-07:00`). Match this format.

**PARA Linkage:** Tasks reside in `TaskNotes/Tasks/`. Use the `projects:` field (`[[wikilink]]` to `1-Projects/` or `2-Areas/`) to link them to PARA. Do not move task files into PARA folders manually.

### Tag Synergy
Task `tags:` and note `tags:` are identical. Using granular topic tags (e.g., `#aws`) ensures tasks appear in their respective Graph View clusters and remain filterable by tag without extra effort. Prefer existing topic tags over task-specific ones.

## Tagging Strategy & Graph View Goals

The primary objective for implementing tags is to enhance the **Graph View** to reveal hidden relationships and structural clusters that folder-based organization alone cannot show.

### Tagging Format
Tags should be implemented in the **YAML frontmatter** using the `tags:` key (e.g., `tags: [aws, terraform]`), following the format used at the top of `AGENTS.md`. Do not use hashtags within the body text unless referring to them as examples.

### Core Principles
1.  **Thematic Clustering**: Tags should be used to group notes into distinct thematic "islands" in the graph view (e.g., grouping all AI-related notes together, even if they reside in different folders like `Dev/ideas` and `Resources/blog notes`).
2.  **Granularity**: Use specific technology and topic-based tags rather than broad categories. Instead of just `#dev`, use `#terraform`, `#ansible`, `#docker`, and `#kubernetes`.
3.  **Multi-dimensional Linking (Multi-tagging)**: Notes should often carry multiple tags to represent cross-cutting relationships. A note on "Automating AWS with Terraform" should contain both `#aws` and `#terraform` to ensure it appears in both thematic clusters in the graph.
4.  **No Entity Tracking (Current Scope)**: The current focus is on topical/technological themes rather than tracking specific entities like people or hardware components.

### Identified Primary Themes for Tagging
Based on initial inspection, the following domains are prime candidates for granular tagging:
*   **AI & LLMs**: `#ai`, `#llm`, `#prompt-engineering`, `#agentic-workflows`.
*   **DevOps & Infrastructure as Code (IaC)**: `#terraform`, `#ansible`, `#docker`, `#kubernetes`, `#ci-cd`.
*   **Networking & Homelab**: `#networking`, `#homelab`, `#netbird`, `#vpn`, `#rsync`, `#proxmox`.
*   **Cloud Services**: `#aws`, `#oci`.
*   **Career & Learning**: `#career-development`, `#learning-python`, `#ccna`, `#wgu`.
*   **Linux/System Administration**: `#linux`, `#fedora`, `#kde`, `#bash`.

## Future Evolution
As the vault grows, this design document will be updated to reflect new themes, shifts in organizational methodology, or changes in how information is synthesized.

---

## Rules to follow
- You may use the printf bash command to add/edit tags
- Always keep your responses concise to the user
- Prioritize organizing and synthesizing information over verbatim transcription; only use word-for-word text when explicitly instructed.
- Ask clarifying questions if the user's intent is ambiguous
- If something, such as editing a shell script that is being used as a test or tool, would be better off edited to your preference, go ahead and change it. For example, if you think the script can be more efficient with a different approach, go ahead and change that script for yourself. Do not make entire new scripts.
- Frontmatter-only edits to a task (status, priority, due date) are routine; don't rewrite a task's body or delete a task file without asking first.
- Always ask before moving notes or tasks out of the Archive (`@4-Archives/` or `@TaskNotes/Archive/`) or adding significant new information to them.
- Don't invent status or priority values for a task — match whatever the vault is already using.
- Prefer using the MCP server (via the tasknotes skill) for all TaskNotes interactions; avoid manual file edits to maintain consistency and leverage version control.

## Common Phrase Aliases

- **“check my inbox”** → `@0-Inbox/`
- **“show projects”**   → `@1-Projects/`
- **“list tasks”**      → `@TaskNotes/Tasks/`
- **“open resources”**  → `@3-Resources/`

- For full TaskNotes CLI/API/schema details, see the `tasknotes` skill rather than duplicating that reference here.
