# Repo Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the homelab repo into the layout in the spec (top-level `terraform/`, `ansible/`, `ai-agents/`, `networking/`, `monitoring/`), standardize naming and READMEs, and keep every deployment working.

**Architecture:** Pure file moves and text edits, one task per move group. Each task starts with a failing check and ends when every check passes. Directory moves use `git mv`, which renames the folder on disk (ignored and untracked files travel with it) while staging only tracked files. Compose `name:` is pinned before any move so volume names never change.

**Tech Stack:** git, Docker Compose v2, Ansible, Terraform, Markdown, bash, Python 3 (stdlib only).

**Spec:** `docs/repo-restructure-design.md`

## Global Constraints

- Work on branch `restructure`. Never push. Never commit to `main`.
- Commit messages: one-line Conventional Commits subject only. No body, no `Co-Authored-By` (user preference, overrides any default attribution).
- Never stage `DOCS-AUDIT.md`, any `dev-box/` folder, `dashboard.example.json`, the `.claude` symlink, or any `.env`/tfstate/tfvars/live inventory file.
- Never run `git add -A` or `git add .`. Stage explicit paths only. `git mv` stages moves by itself.
- Stage each new file (`git add <path>`) as soon as it is written. `check_tree.sh` reports unstaged new files as unexpected.
- After Task 1, no task changes any compose `name:` value.
- Do not stop or touch the running `syncthing` stack (`storage/syncthing`, running on this machine).
- `infrastructure/netbird-client/netbird/` contains a root-owned folder. Moving its parent with `git mv` works without root (the parent is owned by the user). If any `git mv` fails with "Permission denied", stop and ask the user.
- Helper scripts live in `$CHECKS=/tmp/restructure-checks` (not in the repo). Their full source is in the Appendix. If `/tmp` was cleared, recreate them from the Appendix before continuing.
- Every command runs from the repo root: `cd /home/cheyenne/repos/homelab`.

## Review Focus

1. **Live files becoming visible to git after a move** (secrets: `.env`, inventories, tfvars). Expect them to stay ignored. Pinned by `check_tree.sh` (no unexpected untracked files, ignored count unchanged) in every move task.
2. **Compose project name changing** (named volumes look empty after redeploy). Expect identical names before and after. Pinned by the Task 1 name assertion and the `check_compose.sh name` baseline diff in every later task.
3. **Terraform state lost or left behind on move.** Expect byte-identical state at the new path. Pinned by the checksum check in Task 2.
4. **Ansible copying from a wrong relative path.** Expect every `src:` that points into the repo to resolve. Pinned by the path existence checks in Task 3.
5. **Broken links or stale path text in docs.** Expect every relative link to resolve and no old path to remain. Pinned by `check_links.py` and the old-path `git grep` in every move task.

## File Map

| Task | Creates | Moves | Modifies |
| --- | --- | --- | --- |
| 0 | — | — | audit edits already in the working tree; adds `docs/` |
| 1 | — | — | 28 compose files (`name:` line) |
| 2 | `terraform/README.md` | `infrastructure/terraform` → `terraform` | `infrastructure/README.md`, `README.md`, READMEs with Terraform paths |
| 3 | — | 3 Ansible folders → `ansible/`, `.yaml` → `.yml` | `.gitignore`, `ansible.cfg`, two `setup` playbooks, Ansible READMEs, `automation/README.md`, `README.md` |
| 4 | `ai-agents/README.md` | `automation/ai-stack/context` → `ai-agents` | `automation/README.md`, `automation/ai-stack/README.md`, `README.md` |
| 5 | `networking/README.md` | 5 stacks → `networking/` | `infrastructure/README.md`, `README.md`, gaming compose comments, `netbird-client/.env.example` |
| 6 | `monitoring/README.md` | 3 stacks → `monitoring/` | `.gitignore`, `infrastructure/README.md`, `README.md` |
| 7 | 2 Homepage READMEs | Homepage instances flattened | `infrastructure/README.md` |
| 8 | — | `matrix`, `wiki-js` → `utilities/` | `infrastructure/README.md`, `utilities/README.md`, `README.md` |
| 9 | — | — | `.gitignore` |
| 10 | — | 6 example files renamed | references to them |
| 11 | — | — | `README.md` (host map, organization) |
| 12–14 | — | — | every stack README, `ansible/` and `ai-agents/` READMEs, `DOCS-AUDIT.md` ticks |
| 15 | — | — | none (final verification + handoff) |

---

### Task 0: Branch, commit audit edits, set up checks, record baselines

**Files:**
- Commit (already modified): `automation/ai-stack/README.md`, `automation/ai-stack/open-webui/.env.example`, `automation/ai-stack/open-webui/docker-compose.yml`, `automation/ai-stack/ollama/models/.env.example` (deleted), `automation/ai-stack/ollama/.env.example` (new), `infrastructure/gitea/README.md`, `utilities/neko/.env.example`, `utilities/neko/README.md`
- Commit (new): `docs/repo-restructure-design.md`, `docs/repo-restructure-plan.md`
- Create (outside repo): `/tmp/restructure-checks/*`

**Interfaces:**
- Produces: `$CHECKS/{fix_links.py,check_links.py,check_compose.sh,check_tree.sh,check_readme.py}`; baselines `$CHECKS/compose-path.baseline`, `$CHECKS/ignored.baseline`.

- [ ] **Step 1: Confirm starting state**

Run: `git status --short && git branch --show-current`
Expected: branch `main`; modified/untracked files exactly as listed under **Files** plus `docs/`, `.agents/settings.local.json`, `.claude`, `DOCS-AUDIT.md`, `infrastructure/monitoring/dashboard.example.json`, `infrastructure/terraform/aws/ollama-aws-hybrid/dev-box/`. If anything else is modified, stop and ask the user.

- [ ] **Step 2: Create the branch**

```bash
git switch -c restructure
```

- [ ] **Step 3: Review and commit the audit edits in three commits**

```bash
git diff -- automation/ai-stack utilities/neko infrastructure/gitea
git add automation/ai-stack/README.md automation/ai-stack/open-webui/.env.example automation/ai-stack/open-webui/docker-compose.yml automation/ai-stack/ollama/models/.env.example automation/ai-stack/ollama/.env.example
git commit -m "fix(ai-stack): make web search configurable and correct env docs"
git add utilities/neko/.env.example utilities/neko/README.md
git commit -m "docs(neko): align env variables with compose"
git add infrastructure/gitea/README.md
git commit -m "docs(gitea): correct ssh port and routing docs"
```

- [ ] **Step 4: Commit the spec and plan**

```bash
git add docs/repo-restructure-design.md docs/repo-restructure-plan.md
git commit -m "docs: add repo restructure design and plan"
```

- [ ] **Step 5: Install the helper scripts**

```bash
mkdir -p /tmp/restructure-checks
export CHECKS=/tmp/restructure-checks
```

Write each script from the Appendix to `$CHECKS/<name>`, then `chmod +x $CHECKS/*`.

- [ ] **Step 6: Record baselines and confirm checks pass on the untouched tree**

```bash
$CHECKS/check_compose.sh path > $CHECKS/compose-path.baseline
$CHECKS/check_tree.sh | tee $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
```

Expected: `check_tree.sh` exits 0 (only allowlisted untracked files) and prints `ignored=<N>`; `check_links.py` exits 0 with no output. `compose-path.baseline` has 32 lines (some `FAIL` lines are normal: they need gitignored `.env` files).

---

### Task 1: Pin compose project names

**Files:**
- Modify: every `docker-compose*.yml` without a top-level `name:` (28 files). Already pinned, leave alone: `infrastructure/matrix`, `infrastructure/monitoring-oci`, `infrastructure/netbird-server` (`netbird`), `storage/immich`.

**Interfaces:**
- Produces: `$CHECKS/compose-name.baseline`, used by every later task.

- [ ] **Step 1: Write the name assertion**

```bash
cat > $CHECKS/assert_names.sh <<'EOF'
#!/usr/bin/env bash
# Every compose file's name: must equal its ORIGINAL folder name (netbird-server -> netbird).
status=0
for f in $(git ls-files '*docker-compose*.yml'); do
  n=$(sed -n 's/^name:[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$f" | head -1)
  want=$(basename "$(dirname "$f")")
  [ "$f" = infrastructure/netbird-server/docker-compose.yml ] && want=netbird
  [ "$n" = "$want" ] || { echo "MISMATCH $f: '$n' != '$want'"; status=1; }
done
exit $status
EOF
chmod +x $CHECKS/assert_names.sh
```

- [ ] **Step 2: Run it to verify it fails**

Run: `$CHECKS/assert_names.sh | wc -l`
Expected: `28` mismatch lines, exit 1.

- [ ] **Step 3: Insert `name:` at the top of each unpinned file**

```bash
for f in $(git ls-files '*docker-compose*.yml'); do
  grep -q '^name:' "$f" && continue
  sed -i "1i name: $(basename "$(dirname "$f")")\n" "$f"
done
```

Spot-check: `head -3 infrastructure/homepage/admin-instance/docker-compose.yml infrastructure/monitoring/docker-compose.example.yml`
Expected: `name: admin-instance` and `name: monitoring`, each followed by a blank line.

- [ ] **Step 4: Run the checks to verify they pass**

```bash
$CHECKS/assert_names.sh
$CHECKS/check_compose.sh path | diff $CHECKS/compose-path.baseline -
```

Expected: no output from either, both exit 0.

- [ ] **Step 5: Record the name-keyed baseline**

```bash
$CHECKS/check_compose.sh name > $CHECKS/compose-name.baseline
grep -c . $CHECKS/compose-name.baseline; grep UNPINNED $CHECKS/compose-name.baseline
```

Expected: `32`, and no `UNPINNED` lines.

- [ ] **Step 6: Commit**

```bash
git add $(git ls-files -m '*docker-compose*.yml')
git commit -m "chore(compose): pin project names"
```

---

### Task 2: Move Terraform to the top level

**Files:**
- Move: `infrastructure/terraform/` → `terraform/`
- Create: `terraform/README.md`
- Modify: `infrastructure/README.md`, `README.md`, `automation/ollama-aws-hybrid/README.md`, `gaming/README.md`, `automation/ansible/gaming/README.md`, Terraform READMEs (links)

**Interfaces:**
- Consumes: `$CHECKS/compose-name.baseline`, `$CHECKS/ignored.baseline`
- Produces: Terraform at `terraform/<provider>/<name>/`

- [ ] **Step 1: Record state checksums and write the failing check**

```bash
(cd infrastructure/terraform && find . \( -name 'terraform.tfstate*' -o -name terraform.tfvars \) -type f -print0 | xargs -0 sha256sum) > $CHECKS/tfstate.sha
wc -l < $CHECKS/tfstate.sha
(cd terraform && sha256sum -c $CHECKS/tfstate.sha)
```

Expected: a nonzero count, then the `cd terraform` check fails (`No such file or directory`).

- [ ] **Step 2: Move**

```bash
git mv infrastructure/terraform terraform
test ! -e infrastructure/terraform && echo moved
```

- [ ] **Step 3: Fix links and path text**

```bash
python3 $CHECKS/fix_links.py infrastructure/terraform=terraform
git grep -lz 'infrastructure/terraform/' -- ':!docs' | xargs -0 -r sed -i 's#infrastructure/terraform/#terraform/#g'
```

- [ ] **Step 4: Create `terraform/README.md` and move the section out of `infrastructure/README.md`**

`terraform/README.md`:

```markdown
# Terraform

Terraform configurations, grouped by provider. Run them from a workstation or a control node. State is local to each folder (`terraform.tfstate`, gitignored), so run each configuration from one machine only.

- **[Azure Jump Server](./azure/jump-server/README.md)** - Terraform-managed Azure Linux jump server for SSH access to other cloud resources
- **[OCI Free Tier Host](./oci/free-tier-host/README.md)** - Reusable Terraform configuration for a single OCI Free Tier host
- **[Ollama AWS Hybrid](./aws/ollama-aws-hybrid/README.md)** - Terraform-managed AWS EC2 host for the hybrid Ollama deployment
- **[Proxmox Debian VM](./proxmox/debian-vm/README.md)** - Terraform configurations for Proxmox VM management
```

Run `git add terraform/README.md`.

In `infrastructure/README.md`, delete the whole `### Infrastructure as Code (Terraform)` heading and its four bullets.

In `README.md`, replace the Infrastructure bullet under `## Project Organization` and add a Terraform bullet after it:

```markdown
- **[Infrastructure](./infrastructure/README.md)** - Networking, proxy, VPN, monitoring, dashboards, version control, and container management
- **[Terraform](./terraform/README.md)** - Terraform configurations for cloud and Proxmox hosts
```

- [ ] **Step 5: Run the checks**

```bash
(cd terraform && sha256sum -c --quiet $CHECKS/tfstate.sha) && echo state-ok
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
git grep -n 'infrastructure/terraform' -- ':!docs'
```

Expected: `state-ok`; `check_tree.sh` exit 0 and `ignored=` equals the baseline; no broken links; no compose diff; no grep hits.

- [ ] **Step 6: Commit**

```bash
git add terraform/README.md infrastructure/README.md README.md
git add -u
git status --short | grep -v '^R ' 
git commit -m "refactor(terraform): move terraform configs to top level"
```

`git add -u` stages only modifications to tracked files. Before committing, confirm the `grep -v '^R '` output lists only `M`/`A` entries for the files edited in this task.

---

### Task 3: Consolidate Ansible under `ansible/`

**Files:**
- Move: `automation/ansible/README.md` → `ansible/README.md`; `automation/ansible/gaming/` → `ansible/gaming/`; `automation/ansible/server-admin/` → `ansible/server-admin/`; `automation/ollama-aws-hybrid/ansible/` → `ansible/ollama-aws-hybrid/`
- Rename: `ansible/gaming/playbooks/{deploy,setup,teardown,verify-host}.yaml` → `.yml`; `ansible/ollama-aws-hybrid/{deploy,setup,teardown,verify-host,open-webui-ec2-instance.example}.yaml` → `.yml`
- Modify: `.gitignore`, `ansible/ollama-aws-hybrid/ansible.cfg`, `ansible/gaming/playbooks/setup.yml:10`, `ansible/ollama-aws-hybrid/setup.yml:19,33`, `ansible/README.md`, `ansible/gaming/README.md`, `automation/ollama-aws-hybrid/README.md`, `automation/README.md`, `README.md`

**Interfaces:**
- Produces: playbooks at `ansible/<set>/...yml`; inventory example `ansible/server-admin/inventory/example.hosts.yml` (renamed in Task 10).

- [ ] **Step 1: Write the failing path checks**

```bash
cat > $CHECKS/assert_ansible_paths.sh <<'EOF'
#!/usr/bin/env bash
status=0
for p in \
  ansible/gaming/playbooks/../../../gaming/minecraft/docker-compose.yml \
  ansible/gaming/playbooks/../../../gaming/palworld/docker-compose.yml \
  ansible/gaming/playbooks/../../../gaming/valheim/docker-compose.yml \
  ansible/ollama-aws-hybrid/../../automation/ollama-aws-hybrid/docker-compose.yml \
  ansible/ollama-aws-hybrid/../../automation/ollama-aws-hybrid/config/traefik.yml \
  ansible/ollama-aws-hybrid/deploy.yml ansible/ollama-aws-hybrid/setup.yml \
  ansible/ollama-aws-hybrid/teardown.yml ansible/ollama-aws-hybrid/verify-host.yml \
  ansible/ollama-aws-hybrid/open-webui-ec2-instance.example.yml \
  ansible/gaming/playbooks/deploy.yml ansible/gaming/playbooks/setup.yml \
  ansible/gaming/playbooks/teardown.yml ansible/gaming/playbooks/verify-host.yml \
  ansible/server-admin/playbooks/update-packages.yml ansible/README.md; do
  [ -e "$p" ] || { echo "MISSING $p"; status=1; }
done
grep -q 'playbook_dir }}/../../../gaming/' ansible/gaming/playbooks/setup.yml 2>/dev/null || { echo "gaming setup path not updated"; status=1; }
grep -q 'playbook_dir }}/../../automation/ollama-aws-hybrid/docker-compose.yml' ansible/ollama-aws-hybrid/setup.yml 2>/dev/null || { echo "hybrid compose src not updated"; status=1; }
grep -q 'playbook_dir }}/../../automation/ollama-aws-hybrid/config/traefik.yml' ansible/ollama-aws-hybrid/setup.yml 2>/dev/null || { echo "hybrid traefik src not updated"; status=1; }
grep -q 'inventory = ./open-webui-ec2-instance.yml' ansible/ollama-aws-hybrid/ansible.cfg 2>/dev/null || { echo "hybrid ansible.cfg not updated"; status=1; }
git grep -nE '\.\./\.\./\.\./\.\./' -- ansible && { echo "stale 4-level path"; status=1; }
exit $status
EOF
chmod +x $CHECKS/assert_ansible_paths.sh
```

- [ ] **Step 2: Run it to verify it fails**

Run: `$CHECKS/assert_ansible_paths.sh`
Expected: many `MISSING` lines, exit 1.

- [ ] **Step 3: Update `.gitignore` first so live files stay ignored**

In `.gitignore`, replace these three lines:

```
automation/ollama-aws-hybrid/ansible/open-webui-ec2-instance.yaml
automation/ollama-aws-hybrid/ansible/check.output
automation/ansible/server-admin/inventory/hosts.yml
```

with:

```
/ansible/ollama-aws-hybrid/open-webui-ec2-instance.yml
/ansible/ollama-aws-hybrid/check.output
/ansible/server-admin/inventory/hosts.yml
```

- [ ] **Step 4: Move and rename**

```bash
mkdir ansible
git mv automation/ansible/README.md ansible/README.md
git mv automation/ansible/gaming ansible/gaming
git mv automation/ansible/server-admin ansible/server-admin
git mv automation/ollama-aws-hybrid/ansible ansible/ollama-aws-hybrid
rmdir automation/ansible
for f in ansible/gaming/playbooks/*.yaml ansible/ollama-aws-hybrid/*.yaml; do git mv "$f" "${f%.yaml}.yml"; done
```

If `rmdir` fails, run `ls -A automation/ansible`. Ignored leftovers mean a file was outside the moved folders; stop and ask the user.

- [ ] **Step 5: Fix Ansible paths**

```bash
sed -i 's#{{ playbook_dir }}/../../../../gaming/#{{ playbook_dir }}/../../../gaming/#' ansible/gaming/playbooks/setup.yml
sed -i 's#src: \.\./docker-compose\.yml#src: "{{ playbook_dir }}/../../automation/ollama-aws-hybrid/docker-compose.yml"#; s#src: \.\./config/traefik\.yml#src: "{{ playbook_dir }}/../../automation/ollama-aws-hybrid/config/traefik.yml"#' ansible/ollama-aws-hybrid/setup.yml
sed -i 's#open-webui-ec2-instance\.yaml#open-webui-ec2-instance.yml#' ansible/ollama-aws-hybrid/ansible.cfg
```

- [ ] **Step 6: Fix docs**

```bash
python3 $CHECKS/fix_links.py automation/ansible=ansible automation/ollama-aws-hybrid/ansible=ansible/ollama-aws-hybrid
git grep -lzE '(deploy|setup|teardown|verify-host|open-webui-ec2-instance(\.example)?)\.yaml' -- ':!docs' | xargs -0 -r sed -i -E 's/(deploy|setup|teardown|verify-host|open-webui-ec2-instance(\.example)?)\.yaml/\1.yml/g'
sed -i 's#cd automation/ansible/#cd ansible/#' ansible/README.md ansible/gaming/README.md
```

Then edit by hand:

- `ansible/README.md`: change the intro list to three bullets:
  ```markdown
  - **`server-admin/`**: General server administration tasks (e.g., package updates).
  - **`gaming/`**: Deploys one game stack from `gaming/` onto the OCI game host.
  - **`ollama-aws-hybrid/`**: Prepares and deploys the [Ollama AWS Hybrid](../automation/ollama-aws-hybrid/README.md) stack on its EC2 host.
  ```
  and change "Each subdirectory (e.g., `server-admin/` and `gaming/`)" to "Each subdirectory".
- `automation/ollama-aws-hybrid/README.md`, `## Ansible` section:
  - link text `` [`ansible/`] `` → `` [`ansible/ollama-aws-hybrid/`] `` (target already fixed by `fix_links.py`)
  - `cd ansible` → `cd ../../ansible/ollama-aws-hybrid`
  - `cp ../.env.example files/runtime.env` → `cp ../../automation/ollama-aws-hybrid/.env.example files/runtime.env`
- `automation/README.md`: delete the `### Host Management` heading and its Ansible bullet; change the intro to "home automation and the AI stack."
- `README.md` `## Project Organization`: change the Automation bullet to `- **[Automation](./automation/README.md)** - Home automation and AI platforms` and add after the Terraform bullet:
  ```markdown
  - **[Ansible](./ansible/README.md)** - Playbooks for server administration, game hosts, and the Ollama AWS hybrid host
  ```

- [ ] **Step 7: Validate YAML syntax**

```bash
uv run --no-project --with pyyaml python3 -c '
import sys, yaml, glob
for f in glob.glob("ansible/**/*.yml", recursive=True):
    yaml.safe_load(open(f)); print("ok", f)'
```

Expected: `ok` for every file, no traceback.

Optional, if the network is available:

```bash
uvx --from ansible-core ansible-galaxy collection install -r ansible/gaming/requirements.yml -p $CHECKS/collections
for d in ansible/gaming/playbooks ansible/ollama-aws-hybrid; do
  for p in $d/{deploy,setup,teardown,verify-host}.yml; do
    ANSIBLE_COLLECTIONS_PATH=$CHECKS/collections uvx --from ansible-core ansible-playbook --syntax-check -i localhost, "$p"
  done
done
```

If this cannot run, note "syntax-check deferred to user" in the task report.

- [ ] **Step 8: Run the checks**

```bash
$CHECKS/assert_ansible_paths.sh
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
git grep -nE 'automation/ansible|ollama-aws-hybrid/ansible|(deploy|setup|teardown|verify-host)\.yaml' -- ':!docs'
```

Expected: all pass, `ignored=` matches the baseline, grep has no hits.

- [ ] **Step 9: Commit**

```bash
git add .gitignore README.md automation/README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(ansible): consolidate playbooks under top-level ansible"
```

---

### Task 4: Move agent context to `ai-agents/`

**Files:**
- Move: `automation/ai-stack/context/` → `ai-agents/`
- Create: `ai-agents/README.md`
- Modify: `automation/ai-stack/README.md` (`## Context / Agent Skills` section), `automation/README.md`, `README.md`

- [ ] **Step 1: Failing check**

Run: `test -f ai-agents/README.md && test -f ai-agents/tasknotes-obsidian/README.md && test ! -e automation/ai-stack/context; echo $?`
Expected: `1`

- [ ] **Step 2: Move and fix links**

```bash
git mv automation/ai-stack/context ai-agents
python3 $CHECKS/fix_links.py automation/ai-stack/context=ai-agents
```

- [ ] **Step 3: Write `ai-agents/README.md`**

```markdown
# AI Agents

Context bundles (`AGENTS.md`, skills, MCP config) for AI agents such as Claude Code that run on my machines and work on external tools like the Obsidian vault. Nothing here is deployed by a Compose stack.

This is different from [`.agents/`](../.agents/), which holds the agent configuration for working on this repository itself.

- **[TaskNotes Obsidian](./tasknotes-obsidian/README.md)** - Agent context and skills for managing TaskNotes in the Obsidian vault
- **[Inbox Processing](./inbox-processing/README.md)** - Skill for processing the Obsidian inbox
```

Before saving, read the first paragraph of `ai-agents/inbox-processing/README.md` and `ai-agents/tasknotes-obsidian/README.md` and adjust the two one-line descriptions to match. Then `git add ai-agents/README.md`.

- [ ] **Step 4: Update the other docs**

- `automation/ai-stack/README.md`: replace the whole `## Context / Agent Skills` section with:
  ```markdown
  ## Agent Context

  Claude Code context bundles and skills moved to [`ai-agents/`](../../ai-agents/README.md).
  ```
- `ai-agents/tasknotes-obsidian/README.md`: change "It isn't deployed by any Docker Compose file in `ai-stack/`" to "It isn't deployed by any Docker Compose file".
- `automation/README.md`: delete the `[Context & Skills]` bullet, and change "LLM inference (models and interfaces), agentic context, and hybrid cloud setups" to "LLM inference (models and interfaces) and hybrid cloud setups".
- `README.md` `## AI Agents` section: add a bullet:
  ```markdown
  - **[ai-agents](./ai-agents/README.md)** - Agent context and skills for tools outside this repo (e.g. the Obsidian vault).
  ```

- [ ] **Step 5: Run the checks**

```bash
test -f ai-agents/README.md && test -f ai-agents/tasknotes-obsidian/README.md && test ! -e automation/ai-stack/context; echo $?
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
git grep -n 'ai-stack/context' -- ':!docs'
```

Expected: `0`, tree OK with matching ignored count, no broken links, no grep hits.

- [ ] **Step 6: Commit**

```bash
git add ai-agents/README.md README.md automation/README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(ai-agents): move agent context out of ai-stack"
```

---

### Task 5: Create `networking/`

**Files:**
- Move: `infrastructure/{traefik,ddclient,wireguard,netbird-server,netbird-client}/` → `networking/`
- Create: `networking/README.md`
- Modify: `infrastructure/README.md`, `README.md`, `gaming/{minecraft,palworld,valheim}/docker-compose.yml` (comment), `networking/netbird-client/.env.example:11`

- [ ] **Step 1: Failing check**

Run: `for s in traefik ddclient wireguard netbird-server netbird-client; do test -d networking/$s || echo "missing $s"; done`
Expected: five `missing` lines.

- [ ] **Step 2: Move and fix links**

```bash
mkdir networking
for s in traefik ddclient wireguard netbird-server netbird-client; do git mv infrastructure/$s networking/$s; done
python3 $CHECKS/fix_links.py $(for s in traefik ddclient wireguard netbird-server netbird-client; do printf 'infrastructure/%s=networking/%s ' $s $s; done)
git grep -lzE 'infrastructure/(traefik|ddclient|wireguard|netbird-server|netbird-client)' -- ':!docs' | xargs -0 -r sed -i -E 's#infrastructure/(traefik|ddclient|wireguard|netbird-server|netbird-client)#networking/\1#g'
```

The `sed` covers the comments in the three gaming compose files (`# created by networking/netbird-server or networking/netbird-client`) and `networking/netbird-client/.env.example`. It does not touch `name:` lines.

- [ ] **Step 3: Write `networking/README.md` and trim `infrastructure/README.md`**

`networking/README.md`:

```markdown
# Networking

Reverse proxy, dynamic DNS, and remote access stacks.

## Services Overview

### Networking & Proxy
- **[Traefik](./traefik/README.md)** - Edge router and reverse proxy with automated SSL via Cloudflare
- **[DDClient](./ddclient/README.md)** - Dynamic DNS updater for Cloudflare using ddclient docker image

### Remote Access
- **[WireGuard](./wireguard/README.md)** - WireGuard VPN for secure remote access to homelab and services
- **[NetBird Server](./netbird-server/README.md)** - Self-hosted NetBird control plane (management, dashboard, proxy) behind Traefik, pinned to a known installer version
- **[NetBird Client](./netbird-client/README.md)** - NetBird client for secure mesh networking with the homelab, and routing peer for the `services` network
```

Run `git add networking/README.md`.

In `infrastructure/README.md`, delete the `### Networking & Proxy` and `### Remote Access` headings and their bullets.

In `README.md` `## Project Organization`, add after the Media bullet:

```markdown
- **[Networking](./networking/README.md)** - Reverse proxy, dynamic DNS, and remote access (WireGuard, NetBird)
```

and change the Infrastructure bullet to `- **[Infrastructure](./infrastructure/README.md)** - Monitoring, dashboards, version control, and container management`.

- [ ] **Step 4: Run the checks**

```bash
for s in traefik ddclient wireguard netbird-server netbird-client; do test -d networking/$s || echo "missing $s"; done
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
git grep -nE 'infrastructure/(traefik|ddclient|wireguard|netbird)' -- ':!docs'
```

Expected: no output except `check_tree.sh`'s `ignored=` line matching the baseline.

- [ ] **Step 5: Commit**

```bash
git add networking/README.md infrastructure/README.md README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(networking): move network stacks into networking category"
```

---

### Task 6: Create `monitoring/`

**Files:**
- Move: `infrastructure/monitoring/` → `monitoring/monitoring-home/`; `infrastructure/monitoring-oci/` → `monitoring/monitoring-oci/`; `infrastructure/uptime-kuma/` → `monitoring/uptime-kuma/`
- Create: `monitoring/README.md`
- Modify: `.gitignore`, `infrastructure/README.md`, `README.md`

- [ ] **Step 1: Failing check**

Run: `git check-ignore -q --no-index monitoring/monitoring-home/docker-compose.yml; echo $?`
Expected: `1` (the new path is not ignored yet).

- [ ] **Step 2: Update `.gitignore`, then move**

In `.gitignore`, replace `**/monitoring/docker-compose.yml` with `/monitoring/monitoring-home/docker-compose.yml`.

```bash
mkdir monitoring
git mv infrastructure/monitoring monitoring/monitoring-home
git mv infrastructure/monitoring-oci monitoring/monitoring-oci
git mv infrastructure/uptime-kuma monitoring/uptime-kuma
python3 $CHECKS/fix_links.py infrastructure/monitoring-oci=monitoring/monitoring-oci infrastructure/monitoring=monitoring/monitoring-home infrastructure/uptime-kuma=monitoring/uptime-kuma
```

`monitoring-oci` must come before `monitoring` in the `fix_links.py` arguments (first prefix match wins).

- [ ] **Step 3: Fix path text**

Run: `git grep -nE 'infrastructure/(monitoring|uptime-kuma)' -- ':!docs'`
Replace each hit by hand: `infrastructure/monitoring-oci` → `monitoring/monitoring-oci`, `infrastructure/monitoring` → `monitoring/monitoring-home`, `infrastructure/uptime-kuma` → `monitoring/uptime-kuma`. Also run `git grep -n 'monitoring/prometheus' -- monitoring/monitoring-home` and change README mentions of `monitoring/prometheus/...` to `monitoring-home/prometheus/...`.

- [ ] **Step 4: Write `monitoring/README.md` and trim `infrastructure/README.md`**

```markdown
# Monitoring

Metrics, logs, and uptime monitoring.

## Services Overview

- **[Monitoring (Home)](./monitoring-home/README.md)** - Home (on-prem) monitoring stack: Prometheus, Grafana, Loki, Promtail, cAdvisor
- **[Monitoring (OCI)](./monitoring-oci/README.md)** - OCI-specific stack with NetBird access for logs and metrics: Prometheus, Grafana, Loki, Alloy
- **[Uptime Kuma](./uptime-kuma/README.md)** - Service availability monitoring with alerting for uptime and response time
```

Run `git add monitoring/README.md`.

In `infrastructure/README.md`, delete the `### Monitoring` heading and its bullets. In `README.md` `## Project Organization`, add after the Media bullet:

```markdown
- **[Monitoring](./monitoring/README.md)** - Metrics, logs, and uptime monitoring for home and OCI hosts
```

and change the Infrastructure bullet to `- **[Infrastructure](./infrastructure/README.md)** - Dashboards, version control, and container management`.

- [ ] **Step 5: Run the checks**

```bash
git check-ignore -q --no-index monitoring/monitoring-home/docker-compose.yml; echo $?
test -f monitoring/monitoring-home/dashboard.example.json && echo dashboard-moved
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
git grep -nE 'infrastructure/(monitoring|uptime-kuma)' -- ':!docs'
```

Expected: `0`, `dashboard-moved`, tree OK with matching ignored count, nothing else.

- [ ] **Step 6: Commit**

```bash
git add .gitignore monitoring/README.md infrastructure/README.md README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(monitoring): move monitoring stacks into monitoring category"
```

---

### Task 7: Flatten Homepage instances

**Files:**
- Move: `infrastructure/homepage/admin-instance/` → `infrastructure/homepage-admin/`; `infrastructure/homepage/public-instance/` → `infrastructure/homepage-public/`
- Create: `infrastructure/homepage-admin/README.md`, `infrastructure/homepage-public/README.md`
- Delete: `infrastructure/homepage/README.md`
- Modify: `infrastructure/README.md`

- [ ] **Step 1: Failing check**

Run: `test -f infrastructure/homepage-admin/README.md && test -f infrastructure/homepage-public/README.md && test ! -e infrastructure/homepage; echo $?`
Expected: `1`

- [ ] **Step 2: Move**

```bash
git mv infrastructure/homepage/admin-instance infrastructure/homepage-admin
git mv infrastructure/homepage/public-instance infrastructure/homepage-public
git rm -q infrastructure/homepage/README.md
ls -A infrastructure/homepage 2>/dev/null && echo "LEFTOVERS - stop and ask" || echo clean
```

- [ ] **Step 3: Write the two READMEs**

`infrastructure/homepage-public/README.md`:

```markdown
# Homepage (Public)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the public instance; the admin instance is [Homepage (Admin)](../homepage-admin/README.md).

<img src="https://assets.czaini.net/images/homepage-clip.jpg" height="75%" width="75%" />

## Ports

- `7575` - Public dashboard URL (e.g. `http://localhost:7575`).

## Volumes

- `./config:/app/config` - Holds all YAML config files (`services.yaml`, `settings.yaml`, etc.).

## Troubleshooting

If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
```

`infrastructure/homepage-admin/README.md`:

```markdown
# Homepage (Admin)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the administrator instance; the public instance is [Homepage (Public)](../homepage-public/README.md).

## Ports

- `3330` - Admin dashboard URL.

## Volumes

- `./config:/app/config` - Holds all YAML config files (`services.yaml`, `settings.yaml`, etc.).

## Troubleshooting

If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
```

(The old README's `dockerproxy` line is dropped: no such service exists. This resolves that `DOCS-AUDIT.md` item.)

Run `git add infrastructure/homepage-admin/README.md infrastructure/homepage-public/README.md`.

In `infrastructure/README.md`, replace the Homepage bullet with:

```markdown
- **[Homepage (Public)](./homepage-public/README.md)** - Public dashboard aggregating service status and APIs
- **[Homepage (Admin)](./homepage-admin/README.md)** - Administrator dashboard with Docker integration
```

- [ ] **Step 4: Run the checks**

```bash
test -f infrastructure/homepage-admin/README.md && test -f infrastructure/homepage-public/README.md && test ! -e infrastructure/homepage; echo $?
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
git grep -nE 'homepage/(admin|public)-instance|(admin|public)-instance/' -- ':!docs'
```

Expected: `0`, tree OK, no other output. (`name: admin-instance` lines are intentional and do not match this grep.)

- [ ] **Step 5: Commit**

```bash
git add infrastructure/homepage-admin/README.md infrastructure/homepage-public/README.md infrastructure/README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(homepage): flatten admin and public instances"
```

---

### Task 8: Move Matrix and Wiki.js to `utilities/`

**Files:**
- Move: `infrastructure/matrix/` → `utilities/matrix/`; `infrastructure/wiki-js/` → `utilities/wiki-js/`
- Modify: `infrastructure/README.md`, `utilities/README.md`, `README.md`

- [ ] **Step 1: Failing check**

Run: `test -d utilities/matrix && test -d utilities/wiki-js; echo $?`
Expected: `1`

- [ ] **Step 2: Move and fix**

```bash
git mv infrastructure/matrix utilities/matrix
git mv infrastructure/wiki-js utilities/wiki-js
python3 $CHECKS/fix_links.py infrastructure/matrix=utilities/matrix infrastructure/wiki-js=utilities/wiki-js
git grep -nE 'infrastructure/(matrix|wiki-js)' -- ':!docs'
```

Fix any grep hits by hand (`infrastructure/matrix` → `utilities/matrix`, same for `wiki-js`).

- [ ] **Step 3: Update category READMEs**

In `infrastructure/README.md`, delete the `### Documentation` and `### Communication` headings and their bullets. Change the intro to: "This directory contains platform services: dashboards, version control, and container management." Then confirm the remaining sections list exactly: Homepage (Public), Homepage (Admin), Watchtower, Portainer, Gitea.

Append to `utilities/README.md`:

```markdown

### Documentation

- **[Wiki.js](./wiki-js/README.md)** - Self-hosted documentation and knowledge base platform backed by PostgreSQL

### Communication

- **[Matrix](./matrix/README.md)** - Private Matrix homeserver (Synapse) with Element Web and LiveKit calls, reachable only over NetBird
```

In `README.md` `## Project Organization`, change the Utilities bullet to: `- **[Utilities](./utilities/README.md)** - General-purpose tools including file conversion, IT utilities, secret sharing, search, virtual browser, wiki, and Matrix chat`.

- [ ] **Step 4: Run the checks**

```bash
test -d utilities/matrix && test -d utilities/wiki-js; echo $?
$CHECKS/check_tree.sh; tail -1 $CHECKS/ignored.baseline
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
ls infrastructure
```

Expected: `0`; tree OK; `ls` shows only `README.md gitea homepage-admin homepage-public portainer watchtower`.

- [ ] **Step 5: Commit**

```bash
git add infrastructure/README.md utilities/README.md README.md && git add -u
git status --short | grep -v '^R '
git commit -m "refactor(utilities): move matrix and wiki-js into utilities"
```

---

### Task 9: Scope `.gitignore`

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Failing checks**

```bash
git check-ignore -q --no-index automation/ollama-aws-hybrid/config/traefik.yml; echo "hybrid-traefik ignored? $? (want 1)"
git check-ignore -q .agents/settings.local.json; echo "settings.local ignored? $? (want 0)"
```

Expected before the fix: `0` for the first (wrongly ignored), `1` for the second.

- [ ] **Step 2: Edit `.gitignore`**

Add `.agents/settings.local.json` at the end of the `# Environment and Secrets` section.

Replace these lines in `# Automation and Configuration`:

```
app.ini
traefik.yml
pi5.yml
truenas.yml
ubuntu-server-host.yml
ubuntu-server-lan.yml
ubuntu-server-remote.yml
ubuntu-server.yml
```

with:

```
**/gitea/**/app.ini
/networking/traefik/config/traefik.yml
/networking/traefik/config/dynamic/*.yml
!/networking/traefik/config/dynamic/*.example.yml
```

- [ ] **Step 3: Run the checks**

```bash
git check-ignore -q --no-index automation/ollama-aws-hybrid/config/traefik.yml; echo $?
git check-ignore -q .agents/settings.local.json; echo $?
for p in networking/traefik/config/traefik.yml networking/traefik/config/dynamic/pi5.yml networking/traefik/config/dynamic/ubuntu-server-remote.yml infrastructure/gitea/data/gitea/conf/app.ini; do git check-ignore -q --no-index "$p" && echo "ignored $p" || echo "NOT IGNORED $p"; done
for p in $(git ls-files 'networking/traefik/config/*'); do git check-ignore -q --no-index "$p" && echo "WRONGLY IGNORED $p"; done
$CHECKS/check_tree.sh
```

Expected: `1`, `0`, four `ignored` lines, no `WRONGLY IGNORED` lines. `check_tree.sh` exits 0 with `ignored=` one higher than the baseline (`settings.local.json` is now ignored).

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore(gitignore): scope live config ignores to their paths"
```

---

### Task 10: Standardize example file names

**Files:**
- Rename:
  - `ansible/server-admin/inventory/example.hosts.yml` → `hosts.example.yml`
  - `networking/ddclient/ddclient.conf.example` → `ddclient.example.conf`
  - `networking/netbird-server/config.yaml.example` → `config.example.yaml`
  - `utilities/matrix/element/config.json.example` → `config.example.json`
  - `utilities/matrix/homeserver.yaml.template` → `homeserver.example.yaml`
  - `networking/wireguard/templates/minecraft-server-example.conf` → `minecraft-server.conf`
- Modify: every file that references the old names

- [ ] **Step 1: Failing check**

```bash
OLD='example\.hosts\.yml|ddclient\.conf\.example|config\.yaml\.example|config\.json\.example|homeserver\.yaml\.template|minecraft-server-example\.conf'
git grep -nE "$OLD" -- ':!docs'
```

Expected: hits in READMEs (and possibly a compose file or the NetBird script). Save the list.

- [ ] **Step 2: Rename**

```bash
git mv ansible/server-admin/inventory/example.hosts.yml ansible/server-admin/inventory/hosts.example.yml
git mv networking/ddclient/ddclient.conf.example networking/ddclient/ddclient.example.conf
git mv networking/netbird-server/config.yaml.example networking/netbird-server/config.example.yaml
git mv utilities/matrix/element/config.json.example utilities/matrix/element/config.example.json
git mv utilities/matrix/homeserver.yaml.template utilities/matrix/homeserver.example.yaml
git mv networking/wireguard/templates/minecraft-server-example.conf networking/wireguard/templates/minecraft-server.conf
```

- [ ] **Step 3: Update references**

```bash
git grep -lzE "$OLD" -- ':!docs' | xargs -0 -r sed -i -E 's/example\.hosts\.yml/hosts.example.yml/g; s/ddclient\.conf\.example/ddclient.example.conf/g; s/config\.yaml\.example/config.example.yaml/g; s/config\.json\.example/config.example.json/g; s/homeserver\.yaml\.template/homeserver.example.yaml/g; s/minecraft-server-example\.conf/minecraft-server.conf/g'
git diff -U0 | grep -E '^[-+][^-+]'
```

Read the diff. If `networking/netbird-server/getting-started-v0.79.0.sh` changed, revert that file (`git checkout -- <file>`): it is a pinned upstream installer and must stay byte-identical. Adjust the README text around it by hand instead.

- [ ] **Step 4: Run the checks**

```bash
git grep -nE "$OLD" -- ':!docs' ':!networking/netbird-server/getting-started-*.sh'
for p in ansible/server-admin/inventory/hosts.example.yml networking/ddclient/ddclient.example.conf networking/netbird-server/config.example.yaml utilities/matrix/element/config.example.json utilities/matrix/homeserver.example.yaml; do git check-ignore -q --no-index "$p" && echo "WRONGLY IGNORED $p"; done
python3 $CHECKS/check_links.py
$CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline -
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add -u
git status --short | grep -v '^R '
git commit -m "chore: standardize example file names"
```

---

### Task 11: Root README host map and organization

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Ask the user which host runs each stack**

Hosts to offer: NAS (TrueNAS Scale), Application Server (Ubuntu), Raspberry Pi, GPU Compute Node (Proxmox), Oracle (OCI), Azure jump server, AWS EC2 (ollama-aws-hybrid, ephemeral), workstation/desktop (e.g. `storage/syncthing` runs on this machine). Ask for every stack listed by `git ls-files '*/docker-compose*.yml' | cut -d/ -f1-2 | sort -u`. Record the answers in `$CHECKS/hosts.txt` as `<category>/<stack> <host>` lines; Tasks 12–14 reuse them.

- [ ] **Step 2: Add the host map**

Add after the `### Cloud Instances` table in `README.md`:

```markdown
### Host Map

| Host | Stacks |
| --- | --- |
| <host> | [<stack>](./<category>/<stack>/README.md), ... |
```

One row per host from `$CHECKS/hosts.txt`, stacks alphabetical, every stack exactly once.

- [ ] **Step 3: Rewrite `## Project Organization`**

```markdown
## Project Organization

Compose stacks are grouped by job, one folder per stack. Provisioning code (run from a workstation or control node) lives in its own top-level folders.

**Compose stacks**
- **[Automation](./automation/README.md)** - Home automation and AI platforms
- **[Gaming](./gaming/README.md)** - Game server stacks and runtime documentation
- **[Infrastructure](./infrastructure/README.md)** - Dashboards, version control, and container management
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Monitoring](./monitoring/README.md)** - Metrics, logs, and uptime monitoring for home and OCI hosts
- **[Networking](./networking/README.md)** - Reverse proxy, dynamic DNS, and remote access (WireGuard, NetBird)
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Utilities](./utilities/README.md)** - General-purpose tools including file conversion, IT utilities, secret sharing, search, virtual browser, wiki, and Matrix chat

**Provisioning**
- **[Terraform](./terraform/README.md)** - Terraform configurations for cloud and Proxmox hosts
- **[Ansible](./ansible/README.md)** - Playbooks for server administration, game hosts, and the Ollama AWS hybrid host

**Conventions**
- Every compose file pins `name:`, so renaming a folder never renames its volumes.
- Example files are `<file>.example.<ext>` (env files: `.env.example`, `<name>.env.example`; Terraform: `terraform.tfvars.example`). Copy them without `.example` and fill them in; the live copies are gitignored.
```

Also change the Watchtower link in `## Automatic Updates` only if `check_links.py` reports it (Watchtower did not move).

- [ ] **Step 4: Run the checks**

```bash
python3 $CHECKS/check_links.py
for s in $(git ls-files '*/docker-compose*.yml' | cut -d/ -f1-2 | sort -u); do grep -q "(./$s/README.md)" README.md || echo "not in host map: $s"; done
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add host map and update project organization"
```

---

### Task 12: Stack READMEs — networking, monitoring, infrastructure

**Files:**
- Modify: `README.md` of every stack under `networking/`, `monitoring/`, `infrastructure/`; `DOCS-AUDIT.md` (tick items, never stage)

**Interfaces:**
- Consumes: `$CHECKS/hosts.txt` from Task 11

- [ ] **Step 1: Run the README check to see it fail**

Run: `python3 $CHECKS/check_readme.py networking monitoring infrastructure`
Expected: failures for every stack (missing **Runs on:**, wrong sections, undocumented variables).

- [ ] **Step 2: Rewrite each stack README to the template**

For each stack the check lists, in order:

1. Read the stack's compose file(s), every `*.env.example` in the stack, the current README, and every unchecked `DOCS-AUDIT.md` item for that stack (search by stack name; audit paths use the old locations).
2. Rewrite the README in this exact shape, keeping all accurate existing content (move it into the matching section; do not drop facts or images):

   ```markdown
   # <Service>

   <One-paragraph overview: what it is and why it's in the lab.>

   **Runs on:** <host from $CHECKS/hosts.txt>

   ## Prerequisites
   ## Setup
   ## Configuration
   ## Routing & Ports
   ## Data & Backups
   ## Troubleshooting
   ```

   - **Setup:** `cp .env.example .env` and every other `.example` copy the stack needs, then `docker compose up -d`.
   - **Configuration:** one bullet per variable in the stack's `*.env.example` files, formatted `` - `VAR` - description ``.
   - **Routing & Ports:** Traefik hostnames from compose labels, external networks (and which stack creates them), published ports.
   - **Data & Backups:** each bind mount and named volume, and what to back up.
   - An empty section gets one line, e.g. `None.` or `No known issues.`
3. Where the README and compose disagree, the compose file is correct, unless `DOCS-AUDIT.md` marks the item **Decision** or says "Verify". For those, stop and ask the user.
4. Tick the resolved item in `DOCS-AUDIT.md` (`- [x]`).

- [ ] **Step 3: Run the checks**

```bash
python3 $CHECKS/check_readme.py networking monitoring infrastructure
python3 $CHECKS/check_links.py
```

Expected: `all stack READMEs OK`; no broken links.

- [ ] **Step 4: Commit (one commit per category)**

```bash
git add networking/*/README.md && git commit -m "docs(networking): standardize stack readmes"
git add monitoring/*/README.md && git commit -m "docs(monitoring): standardize stack readmes"
git add infrastructure/*/README.md && git commit -m "docs(infrastructure): standardize stack readmes"
```

---

### Task 13: Stack READMEs — utilities, storage, media

Same procedure as Task 12, repeated here in full.

**Files:**
- Modify: `README.md` of every stack under `utilities/`, `storage/`, `media/`; `DOCS-AUDIT.md` (tick items, never stage)

- [ ] **Step 1: Run the README check to see it fail**

Run: `python3 $CHECKS/check_readme.py utilities storage media`
Expected: failures for every stack.

- [ ] **Step 2: Rewrite each stack README to the template**

For each stack the check lists:

1. Read the stack's compose file(s), every `*.env.example` in the stack, the current README, and every unchecked `DOCS-AUDIT.md` item for that stack (audit paths use the old locations, e.g. `infrastructure/matrix`, `infrastructure/wiki-js`).
2. Rewrite the README in the template shape (`# <Service>`, overview, `**Runs on:** <host>`, then `## Prerequisites`, `## Setup`, `## Configuration`, `## Routing & Ports`, `## Data & Backups`, `## Troubleshooting`), keeping all accurate existing content.
   - **Setup:** every `.example` copy, then `docker compose up -d`.
   - **Configuration:** `` - `VAR` - description `` for every variable in the stack's `*.env.example` files.
   - **Routing & Ports:** Traefik hostnames, external networks and which stack creates them, published ports.
   - **Data & Backups:** bind mounts, volumes, what to back up.
   - Empty section: one line (`None.`).
3. Compose wins over the README, except items marked **Decision** or "Verify" in `DOCS-AUDIT.md`: ask the user. Known example: the Syncthing ports item says "Verify against Syncthing docs"; check the official Syncthing firewall docs and report what you found to the user before editing.
4. Tick resolved items in `DOCS-AUDIT.md`.

- [ ] **Step 3: Run the checks**

```bash
python3 $CHECKS/check_readme.py utilities storage media
python3 $CHECKS/check_links.py
```

Expected: `all stack READMEs OK`; no broken links.

- [ ] **Step 4: Commit (one per category)**

```bash
git add utilities/*/README.md && git commit -m "docs(utilities): standardize stack readmes"
git add storage/*/README.md && git commit -m "docs(storage): standardize stack readmes"
git add media/*/README.md && git commit -m "docs(media): standardize stack readmes"
```

---

### Task 14: Stack READMEs — automation, gaming; Ansible and ai-agents audit items

**Files:**
- Modify: `README.md` of every stack under `automation/` and `gaming/`; `ansible/gaming/README.md`; `ai-agents/tasknotes-obsidian/README.md`; `DOCS-AUDIT.md` (tick items, never stage)

- [ ] **Step 1: Run the README check to see it fail**

Run: `python3 $CHECKS/check_readme.py automation gaming`
Expected: failures for every stack.

- [ ] **Step 2: Rewrite each stack README to the template**

Same rules as Task 13 Step 2 (template shape, Setup/Configuration/Routing & Ports/Data & Backups content, compose wins except **Decision**/"Verify" items, tick `DOCS-AUDIT.md`). Stack-specific notes:

- `automation/ai-stack`: one README covers both `ollama/` and `open-webui/`; document variables from both `.env.example` files. The open audit item about `OLLAMA_BASE_URL` needs the user's decision (see `DOCS-AUDIT.md`); ask before editing.
- `automation/ollama-aws-hybrid`: keep the existing `## Terraform` and `## Ansible` walkthroughs as `###` subsections under `## Setup`. Add the Gluetun/WireGuard variables listed in `DOCS-AUDIT.md` to Configuration, and move `WEBUI_SECRET_KEY` out of "Traefik requires".
- `automation/home-assistant`: backups are `./config`, not `./data`.

- [ ] **Step 3: Resolve the non-stack audit items**

- `ansible/gaming/README.md`: resolve the "Gaming Ansible" items in `DOCS-AUDIT.md`. Do not apply the stack template (it is not a stack).
- `ai-agents/tasknotes-obsidian/README.md`: resolve the TaskNotes item (`obsidian-tasknotes` vs `obsidian-vault` path). Ask the user which path is correct.

- [ ] **Step 4: Run the full checks**

```bash
python3 $CHECKS/check_readme.py
python3 $CHECKS/check_links.py
```

Expected: `all stack READMEs OK` (all categories); no broken links.

- [ ] **Step 5: Commit**

```bash
git add automation/*/README.md && git commit -m "docs(automation): standardize stack readmes"
git add gaming/*/README.md && git commit -m "docs(gaming): standardize stack readmes"
git add ansible/gaming/README.md ai-agents/tasknotes-obsidian/README.md && git commit -m "docs: resolve ansible and ai-agents audit items"
```

---

### Task 15: Final verification and handoff

**Files:** none modified.

- [ ] **Step 1: Run every check**

```bash
$CHECKS/assert_names.sh 2>/dev/null; $CHECKS/check_compose.sh name | diff $CHECKS/compose-name.baseline - && echo compose-ok
$CHECKS/assert_ansible_paths.sh && echo ansible-paths-ok
$CHECKS/check_tree.sh
python3 $CHECKS/check_links.py && echo links-ok
python3 $CHECKS/check_readme.py
git grep -nE 'infrastructure/(terraform|traefik|ddclient|wireguard|netbird|monitoring|uptime-kuma|homepage|matrix|wiki-js)|automation/ansible|ollama-aws-hybrid/ansible|ai-stack/context|(admin|public)-instance/|example\.hosts\.yml|homeserver\.yaml\.template|config\.(yaml|json)\.example|ddclient\.conf\.example|minecraft-server-example' -- ':!docs' ':!networking/netbird-server/getting-started-*.sh'
git status --short
git log --oneline main..restructure
```

Expected: `compose-ok`, `ansible-paths-ok`, tree OK, `links-ok`, `all stack READMEs OK`, no grep hits. `git status` shows only `DOCS-AUDIT.md`, `.claude`, `dev-box/`, `dashboard.example.json` as untracked. (`assert_names.sh` now reports mismatches for moved folders by design, so its output is ignored here; the compose-name diff is the real check.)

- [ ] **Step 2: Hand off to the user**

Report: the commit list, any deferred checks (Ansible syntax-check, `terraform validate`), and the Host Migration Runbook below. Do not merge or push; ask the user how to integrate the branch (superpowers:finishing-a-development-branch).

---

## Host Migration Runbook (for the user, after merging)

**Every host with a clone**, for each stack it runs that moved:

```bash
cd <repo> && git status                    # must show no modified tracked files, or the pull will abort
# Traefik hosts only: acme.json is no longer tracked, and the pull deletes the tracked copy
cp -p <old path>/letsencrypt/acme.json ~/acme.json.bak
git checkout -- <old path>/letsencrypt/acme.json
cd <repo>/<old path> && docker compose down
cd <repo> && git pull
rsync -a <old path>/ <new path>/          # .env, data dirs, live configs
cp -p ~/acme.json.bak <new path>/letsencrypt/acme.json && chmod 600 <new path>/letsencrypt/acme.json   # Traefik hosts only
cd <new path> && docker compose up -d
docker compose ls                          # project name must be unchanged
# after confirming the stack works:
rm -rf <old path>
```

`monitoring/monitoring-home` runs from a gitignored live `docker-compose.yml` copied before `name:` was pinned. Before `docker compose up -d`, add `name: monitoring` as its first line (or re-copy `docker-compose.example.yml`); otherwise the project becomes `monitoring-home`. `automation/ollama-aws-hybrid` also loses its tracked `acme.json`: on a manual deployment, back it up and restore it the same way.

Moved stacks: `infrastructure/{traefik,ddclient,wireguard,netbird-server,netbird-client}` → `networking/…`; `infrastructure/monitoring` → `monitoring/monitoring-home`; `infrastructure/{monitoring-oci,uptime-kuma}` → `monitoring/…`; `infrastructure/homepage/{admin,public}-instance` → `infrastructure/homepage-{admin,public}`; `infrastructure/{matrix,wiki-js}` → `utilities/…`. Data under root-owned folders (e.g. `netbird-client/netbird/`) needs `sudo rsync` and `sudo rm`.

Also check each host for absolute paths to old folders: `crontab -l`, `systemctl list-unit-files`, shell aliases, scripts.

**Machines that run Terraform or Ansible** (other than this one): after `git pull`, move ignored leftovers:

```bash
rsync -a --remove-source-files infrastructure/terraform/ terraform/ && find infrastructure/terraform -type d -empty -delete
rsync -a --remove-source-files automation/ansible/ ansible/ && find automation/ansible -type d -empty -delete
rsync -a --remove-source-files automation/ollama-aws-hybrid/ansible/ ansible/ollama-aws-hybrid/ && find automation/ollama-aws-hybrid/ansible -type d -empty -delete
mv ansible/ollama-aws-hybrid/open-webui-ec2-instance.yaml ansible/ollama-aws-hybrid/open-webui-ec2-instance.yml 2>/dev/null
```

Then run `terraform init -backend=false && terraform validate` in each Terraform folder and `ansible-playbook --syntax-check` on each playbook.

---

## Appendix: Helper Scripts

Write each to `/tmp/restructure-checks/<name>` and `chmod +x`.

### `fix_links.py`

```python
#!/usr/bin/env python3
"""Rewrite relative Markdown links after directory moves.

Run from the repo root AFTER `git mv`:
    python3 fix_links.py OLD_DIR=NEW_DIR [OLD_DIR=NEW_DIR ...]
Paths are repo-relative, no trailing slash.
"""
import os
import re
import subprocess
import sys

MOVES = [tuple(arg.split("=", 1)) for arg in sys.argv[1:]]
LINK = re.compile(r"(\]\()([^)\s#]+)(#[^)\s]*)?(\))")


def remap(path, pairs):
    for src, dst in pairs:
        if path == src or path.startswith(src + "/"):
            return dst + path[len(src):]
    return path


def to_new(path):
    return remap(path, MOVES)


def to_old(path):
    return remap(path, [(dst, src) for src, dst in MOVES])


def main():
    files = subprocess.run(
        ["git", "ls-files", "*.md"], capture_output=True, text=True, check=True
    ).stdout.split()
    for md in files:
        new_dir = os.path.dirname(md) or "."
        old_dir = os.path.dirname(to_old(md)) or "."
        with open(md) as fh:
            text = fh.read()

        def repl(match):
            target = match.group(2)
            if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("/"):
                return match.group(0)
            old_abs = os.path.normpath(os.path.join(old_dir, target))
            new_abs = to_new(old_abs)
            if new_abs == old_abs and new_dir == old_dir:
                return match.group(0)
            rel = os.path.relpath(new_abs, new_dir)
            if target.startswith("./") and not rel.startswith("."):
                rel = "./" + rel
            if target.endswith("/") and not rel.endswith("/"):
                rel += "/"
            return match.group(1) + rel + (match.group(3) or "") + match.group(4)

        updated = LINK.sub(repl, text)
        if updated != text:
            with open(md, "w") as fh:
                fh.write(updated)
            print(f"updated {md}")


if __name__ == "__main__":
    main()
```

### `check_links.py`

```python
#!/usr/bin/env python3
"""Print every relative Markdown link that does not resolve. Exit 1 if any.

Run from the repo root. Skips docs/ (spec and plan quote old paths on purpose).
"""
import os
import re
import subprocess
import sys

LINK = re.compile(r"\]\(([^)\s#]+)(#[^)\s]*)?\)")

files = subprocess.run(
    ["git", "ls-files", "*.md"], capture_output=True, text=True, check=True
).stdout.split()
bad = 0
for md in files:
    if md.startswith("docs/"):
        continue
    with open(md) as fh:
        for lineno, line in enumerate(fh, 1):
            for target, _ in LINK.findall(line):
                if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("/"):
                    continue
                path = os.path.normpath(os.path.join(os.path.dirname(md), target))
                if not os.path.exists(path):
                    print(f"{md}:{lineno}: {target}")
                    bad += 1
sys.exit(1 if bad else 0)
```

### `check_compose.sh`

```bash
#!/usr/bin/env bash
# Print "<key> OK|FAIL" for every tracked compose file, sorted.
# Usage (from repo root): check_compose.sh path   # key = file path
#                         check_compose.sh name   # key = pinned `name:` value
mode=${1:-path}
for f in $(git ls-files '*docker-compose*.yml'); do
  if [ "$mode" = name ]; then
    key=$(sed -n 's/^name:[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$f" | head -1)
    key=${key:-"UNPINNED:$f"}
  else
    key=$f
  fi
  if docker compose -f "$f" config -q >/dev/null 2>&1; then echo "$key OK"; else echo "$key FAIL"; fi
done | sort
```

### `check_tree.sh`

```bash
#!/usr/bin/env bash
# Guard against live files becoming visible to git after a move.
# Exit 1 if any untracked, non-ignored file is outside the allowlist.
# Last line prints the ignored-entry count; compare it with the baseline.
allow='^(\.agents/settings\.local\.json|\.claude|DOCS-AUDIT\.md|docs/.*|.*/dev-box/.*|.*/dashboard\.example\.json)$'
unexpected=$(git ls-files --others --exclude-standard | grep -Ev "$allow")
status=0
if [ -n "$unexpected" ]; then
  echo "UNEXPECTED UNTRACKED FILES:"
  echo "$unexpected"
  status=1
fi
echo "ignored=$(git ls-files --others --ignored --exclude-standard --directory 2>/dev/null | wc -l)"
exit $status
```

### `check_readme.py`

```python
#!/usr/bin/env python3
"""Check stack READMEs against the template in docs/repo-restructure-design.md.

A stack is a folder directly under a category that contains a compose file at
any depth. Its README is <category>/<stack>/README.md.

Usage (from repo root): check_readme.py [category ...]   default: all categories
Exit 1 if any README fails.
"""
import glob
import os
import re
import sys

CATEGORIES = ["automation", "gaming", "infrastructure", "media",
              "monitoring", "networking", "storage", "utilities"]
SECTIONS = ["## Prerequisites", "## Setup", "## Configuration",
            "## Routing & Ports", "## Data & Backups", "## Troubleshooting"]
ENV_VAR = re.compile(r"^\s*#?\s*([A-Z][A-Z0-9_]*)=", re.M)


def stacks(category):
    found = set()
    for compose in glob.glob(f"{category}/**/docker-compose*.yml", recursive=True):
        parts = compose.split(os.sep)
        if len(parts) >= 3:
            found.add(os.path.join(parts[0], parts[1]))
    return sorted(found)


def check(stack):
    errors = []
    readme = os.path.join(stack, "README.md")
    if not os.path.exists(readme):
        return [f"{readme}: missing"]
    text = open(readme).read()
    lines = text.splitlines()
    if not lines or not lines[0].startswith("# "):
        errors.append("first line must be '# <Service>'")
    first_h2 = next((i for i, l in enumerate(lines) if l.startswith("## ")), len(lines))
    if not any(l.startswith("**Runs on:**") for l in lines[:first_h2]):
        errors.append("missing '**Runs on:**' line before the first section")
    h2 = [l.rstrip() for l in lines if l.startswith("## ")]
    if h2 != SECTIONS:
        errors.append(f"sections {h2} != {SECTIONS}")
    config = re.search(r"^## Configuration\n(.*?)(?=^## |\Z)", text, re.M | re.S)
    config_text = config.group(1) if config else ""
    examples = glob.glob(f"{stack}/**/.env.example", recursive=True) + \
        glob.glob(f"{stack}/**/*.env.example", recursive=True)
    for example in sorted(set(examples)):
        for var in sorted(set(ENV_VAR.findall(open(example).read()))):
            if f"`{var}`" not in config_text:
                errors.append(f"{var} (from {example}) not documented in Configuration")
    return [f"{readme}: {e}" for e in errors]


def main():
    categories = sys.argv[1:] or CATEGORIES
    failures = [e for c in categories for s in stacks(c) for e in check(s)]
    print("\n".join(failures) if failures else "all stack READMEs OK")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
```
