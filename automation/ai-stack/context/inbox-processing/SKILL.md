---
name: inbox-processing
description: "Parse and process notes in the 0-Inbox folder. This skill analyzes quick captures to determine if they belong to existing tasks, notes, or need to be created as new tasks/notes. It prioritizes finding existing relevant content before suggesting new creations."
metadata:
  version: "1.0"
---

# Inbox Processing

This skill is designed to manage the "quick capture" flow in the `0-Inbox/` folder. It helps the user transition from raw notes to structured tasks or information within the vault.

---

## Core Workflow

When a user asks to "process the inbox" or "look through my inbox":

### 1. Capture Identification
- Scan all files in `@0-Inbox/`.
- For each file, identify the primary "intent" or "content" (e.g., a to-do item, a piece of information, a project idea, a request).

### 2. Context Matching
- **Search for existing tasks:** Use `tasknotes_query_tasks` to find tasks with similar keywords, projects, or contexts.
- **Search for existing notes:** Use `grep` or filesystem searches to find existing notes that contain related information.
- **Analyze Relationships:** If a note in the inbox mentions a specific project (e.g., "AWS setup"), prioritize checking the `projects:` linkage in TaskNotes.

### 3. Action Recommendation
For each item identified in the inbox, propose one of the following:
- **Append to Existing Task:** "This seems like it belongs in the task [[Task Name]]. Should I add it as a checklist item or a note in the body?"
- **Append to Existing Note:** "This looks like information for your [[Note Name]] note. Should I append it there?"
- **Create New Task:** "This is a new action item. I propose creating a task: `[Suggested Title]` with `priority: normal` and `projects: [[Project]]`. Should I proceed?"
- **Create New Note:** "This is a significant piece of information. I propose creating a new note named `[Suggested Name]` in the appropriate folder. Should I proceed?"

### 4. Execution & Confirmation
- **NEVER** perform any writes (creating tasks, notes, or editing files) without explicit user confirmation.
- Present a summary of proposed actions to the user.
- Wait for the user to say "Yes", "Go ahead", or "Proceed" for each action.
- **Final Cleanup:** Once all proposed actions for the inbox have been completed, ask the user for permission to clear out the `0-Inbox/` folder.

---

## Rules & Best Practices

- **Conciseness:** Keep the summary of findings brief and actionable.
- **Granularity:** Break down large captures into multiple tasks if they represent distinct actions.
- **PARA Alignment:** When creating new tasks, ensure they are linked to the correct PARA folder via the `projects:` field.
- **Tagging:** Use relevant topic tags (e.g., `#aws`, `#dev`) for new tasks to ensure they appear in the correct Graph View clusters.
- **TaskNotes Synergy:** Always prefer using the `tasknotes` skill tools for task creation and updates to ensure consistency with the TaskNotes plugin.

## Examples

**User:** "Look through my inbox and find an existing note or a task that it could be added to. if not, then just create a new task(s) and/or note(s) but make sure to ask me before you make any changes"

**Agent:**
1. Reads `@0-Inbox/`.
2. Identifies "Need to update the terraform script for the staging environment."
3. Searches tasks for "terraform" and "staging".
4. Finds task: `Tasks/Update staging terraform.md`.
5. **Response:** "I found a task: `Update staging terraform.md`. Should I add the note 'Need to update the terraform script' to its checklist?"
6. Identifies "Idea for a new home lab dashboard using Grafana."
7. Searches for "Grafana" or "dashboard".
8. Finds no relevant tasks/notes.
9. **Response:** "I also found a new idea: 'Idea for a new home lab dashboard using Grafana'. I propose creating a new task: `Create home lab dashboard` with `projects: [[HomeLab]]`. Should I proceed?"
