---
name: conventional-commits
description: Write git commit messages following the Conventional Commits specification. Use this whenever creating a commit, drafting a commit message, staging and committing changes, or when the user asks to "commit this" or "write a commit message" — even if they don't say "conventional commits" explicitly.
---

# Conventional Commits

Every commit message is a single line (see [CONVENTIONS](../../../docs/CONVENTIONS.md#commits)):

```
<type>(<optional scope>): <short summary>
```

## Types
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `style` — formatting/whitespace, no code logic change
- `refactor` — code change that neither fixes a bug nor adds a feature
- `perf` — performance improvement
- `test` — adding or correcting tests
- `build` — build system or dependency changes
- `ci` — CI/CD config changes
- `chore` — maintenance, no production code change
- `revert` — reverts a previous commit

## Rules
1. **Summary line**: imperative mood ("add", not "added"/"adds"), lowercase after the colon, no trailing period. Aim for ≤50 chars, 72 hard cap.
2. **Scope** (optional): lowercase, names the affected module/area, in parentheses right after the type — e.g. `fix(api): ...`. Check `git log --oneline -20` for scopes already in use before inventing a new one.
3. **No body and no footers or trailers** (`Co-Authored-By`, session links, `Fixes #123`). Anything the summary can't say belongs in the docs or the PR.
4. **Breaking changes**: mark with `!` after the type/scope (`feat!:` or `feat(api)!:`).
5. **One logical change per commit.** If staged changes span multiple unrelated types, tell the user and suggest splitting into separate commits rather than picking one type arbitrarily.

## Examples
```
feat(auth): add password reset flow

fix(api): handle null response from user endpoint

refactor(db): extract query builder into separate module

docs: update README with setup instructions

feat(cli)!: remove deprecated --legacy flag
```

## Workflow
1. Run `git diff --staged` (fall back to `git diff` if nothing is staged) to see the actual change.
2. Pick the single most accurate `type`. If the diff mixes types (e.g. a feature plus unrelated formatting), flag it and ask whether to split the commit.
3. Write the summary in imperative mood.
4. Never fabricate a scope or breaking-change marker that isn't backed by the diff or the user's input.
