---
name: docs-health-check
description: Audit and repair project documentation (README.md, .env.example, and similar docs) so it accurately reflects the current codebase — verifying directory structures, configuration files, installation steps, and internal links against what's actually on disk. Use this skill whenever the user asks for a "documentation health check" or "docs audit," asks whether docs are "up to date," "accurate," or "in sync" with the code, or asks you to review/update a README against the real project state.
---

# Documentation Health Check

Audit project documentation against the real state of the code, and fix any drift you find.

## Workflow

1. **Scope the audit** — identify which directory or set of related directories to check, based on what the user asked for.
2. **Map the real structure** — run `find <dir>` or `ls -R <dir>` to get the actual filesystem layout.
3. **Compare structure to docs** — check whether the parent README's described directory structure matches what you found in step 2.
4. **Audit configuration files** — compare `docker-compose.yml` (ports, environment variables, volume paths) and `.env.example` variables against what the README describes.
5. **Verify install/usage steps** — confirm documented commands and configuration steps correspond to what's actually in the current files; check that referenced flags, paths, and variable names still exist rather than skimming visually.
6. **Check internal links** — scan README files for relative links (e.g. `./path/to/file`) and confirm each target exists.
7. **Report findings before editing** — list every inconsistency found, with the specific mismatch (e.g., "README says port 80, docker-compose.yml uses 8080"). Ask the user before making changes, unless they've already asked you to fix issues outright.
8. **Apply fixes** — update the documentation to match the current state of the project, preserving its existing tone and formatting.
9. **Re-verify** — after editing, re-run the relevant checks (steps 2–6) to confirm nothing was missed and no new inconsistency was introduced.

## Rules

- Match technical details exactly — ports, paths, env var names, and commands must reflect the current files, not what the docs used to say.
- Flag any configuration option present in the code but undocumented, not just documentation that's wrong.
- Preserve the existing documentation's tone, structure, and formatting when editing — don't rewrite style unless asked.
- Never call a command "correct" without checking it against the current environment/config.

## Example

**User:** "Do a documentation health check on `/home/cheyenne/repos/homelab/`."

**Response:**
1. Scope: the homelab repo.
2. Run `ls -R` / `find` to map the real structure.
3. Compare the README's described layout against it.
4. Compare `docker-compose.yml` against the README's claims.
5. Report:
   > Found 3 inconsistencies:
   > - README lists port 80, but docker-compose.yml uses 8080.
   > - `database/` directory exists but isn't in the "Directory Structure" section.
   > - The nginx install command is outdated for the current OS version.
   >
   > Want me to fix these?
