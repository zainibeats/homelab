# Inbox Processing Skill

This skill is designed to manage the "quick capture" flow in the `0-Inbox/` folder. It helps the user transition from raw notes to structured tasks or information within the vault.

## Description
The Inbox Processing skill analyzes quick captures to determine if they belong to existing tasks, notes, or need to be created as new tasks/notes. It prioritizes finding existing relevant content before suggesting new creations.

## Dependencies / Related Skills
- **TaskNotes Obsidian**: This skill is designed to work in tandem with the [TaskNotes Obsidian context](../tasknotes-obsidian/README.md), specifically utilizing its `tasknotes` tools and the TaskNotes MCP server.

## Key Features
- **Capture Identification**: Scans all files in `@0-Inbox/` to identify primary intent.
- **Context Matching**: Searches for existing tasks and notes using `tasknotes_query_tasks` and filesystem searches.
- **Action Recommendation**: Proposes specific actions (append to existing, create new) with user confirmation.
- **Safety**: Never performs writes without explicit user approval.

## Usage
To use this skill, you can ask the agent to:
- "Process the inbox"
- "Look through my inbox"
- "Check for new tasks or notes in my 0-Inbox"

For a full breakdown of the workflow and rules, see [SKILL.md](SKILL.md).
