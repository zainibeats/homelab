---
name: vault-task-cleanup
description: Use when asked to clean up, triage, tidy, or audit TaskNotes tasks. Finds tasks with missing or invalid statuses, empty open tasks, done tasks not yet archived, and tasks with no tags or project links, then asks the user to Update Status, Archive, Delete, or Ignore each one. Do not use for creating or editing single tasks; that belongs to the tasknotes skill.
---

# Vault Task Cleanup

Audit task notes and walk the user through fixing each issue. **Read-only until the user picks an action.** Never delete, move, or edit a task without an explicit choice.

Paths are relative to the vault root. Schema and access rules come from `AGENTS.md` and the `tasknotes` skill.

## Procedure

1. **Discover Conventions**: Run the `tasknotes` skill's environment probe to choose the access method (MCP, HTTP API, or files). Then confirm the conventions:
   - **Tasks folder**: `TaskNotes/Tasks/`, or `tasks_folder` in the tasknotes config.
   - **Valid statuses**: `open`, `in-progress`, `done`. Use the vault's own values if they differ, and never invent new ones.
   - **Archive convention**: `TaskNotes/Archive/` plus the `archived` tag.
   - **Categorization fields**: `tags` and `projects`. `projects` entries must be `[[wikilinks]]`.

   If anything is still unclear, ask one short question. Don't guess.

2. **Inventory**: Read every task's frontmatter and body, and report the total.

3. **Audit Statuses**: Flag tasks where `status` is missing, empty, `none`/`null`, or not a valid state (for example a typo like `in progess`). Suggest a status from context: a `completedDate` or all items checked suggests `done`; otherwise suggest `open`. Also flag `done` tasks with no `completedDate`.

4. **Identify Dead Ends**: Flag tasks that are `open` or `in-progress` with an empty body. A body is empty when nothing is left below the frontmatter except whitespace, a bare title heading, or an unfilled template.

5. **Verify Completion/Archival**: Flag `status: done` tasks that are outside `TaskNotes/Archive/` or missing the `archived` tag. Also flag the reverse case: archived tasks whose status is not `done`.

6. **Evaluate Orphaned Tasks**: Flag tasks with no topic tags (the system tags `task` and `archived` don't count) and no `projects` link. Also flag `projects` entries written as plain strings, which TaskNotes silently ignores. Use the `vault-tagging` skill to propose 1–4 topic tags based on the title and body. Mark any tag the vault doesn't already use as **new**.

7. **Propose Actions**: Group the findings by check, with a count for each, in one table:

   | # | Task | Issue | Suggested action |
   |---|------|-------|------------------|
   | 1 | [[Fix NAS alerts]] | status `none` | Update Status → `open` |
   | 2 | [[Old idea]] | empty, open | Delete |

   For each issue, offer exactly:
   - **Update Status**: state the proposed change. For orphans, this also covers adding the tags or fixing the `projects` links.
   - **Archive**: archive the task the TaskNotes way. It moves to `TaskNotes/Archive/` and gets the `archived` tag.
   - **Delete**: only suggest this for empty or clearly dead tasks.
   - **Ignore**: leave the task untouched.

   Accept answers per task or in bulk (for example `1-4 archive, 5 ignore` or "archive all done"). Use AskUserQuestion if it's available.

8. **Execute**: Apply only what the user chose, through the `tasknotes` skill and its MCP server, not manual file edits. Unanswered items count as Ignore.
   - **Update Status**: change only the targeted frontmatter keys. When the status becomes `done`, set `completedDate` to today (`YYYY-MM-DD`).
   - **Archive**: set `status: done` and `completedDate` if they're missing, then archive the task.
   - **Delete**: confirm once more, naming each task, even after a bulk approval. If deletion fails, move the file to `TaskNotes/_to_delete/`.
   - **Ignore**: no change.

9. **Verify**: Re-run steps 3–6 on the tasks you touched. Report how many were updated, archived, deleted, and ignored, plus anything that failed.

## Rules

- A task that fails several checks appears once, with all its issues listed.
- Never rewrite a task body or invent details to fill an empty task.
- Never set `done` without evidence or the user's say-so.
- Ask before un-archiving a task. Flagging it is fine.
- If unsure about a task, list it under Ignore with a note instead of acting.
