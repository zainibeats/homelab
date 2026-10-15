# Repo Restructure Design

Date: 2026-10-13
Branch: `restructure`

## Goal

Make the repo better organized, more modular, and more consistent without breaking deployments.

The repo is the source of truth that deployments run from:

- **Compose stacks**: each host has a clone; `git pull` then `docker compose up -d` in the stack folder. Live `.env` files, configs, and data sit next to the compose file and are gitignored.
- **Ansible**: run from a control node (workstation, or a cloud jump/control server). Copies compose files and configs from the repo to the target host and starts containers.
- **Terraform**: run from a workstation (possibly a cloud control node). State is local.

Terraform and Ansible may run on the same machine or different ones.

## Constraints

1. Compose derives the project name from the folder name when `name:` is not set, and the project name prefixes volume and network names. Renaming a folder without a pinned `name:` makes named volumes look empty.
2. `git pull` moves tracked files only. Gitignored live files (`.env`, data dirs, `acme.json`, tfstate) stay in the old folder and must be moved by hand on every machine that has them.
3. Any clone, on any machine, must be able to run Terraform and Ansible. No absolute workstation paths in tracked files.

## Target Layout

```
ai-agents/        tasknotes-obsidian/, inbox-processing/
ansible/          gaming/, ollama-aws-hybrid/, server-admin/
terraform/        aws/ollama-aws-hybrid/, azure/jump-server/, oci/free-tier-host/, proxmox/debian-vm/
automation/       ai-stack/, home-assistant/, ollama-aws-hybrid/
gaming/           minecraft/, palworld/, valheim/                  (unchanged)
hardware/                                                          (unchanged)
infrastructure/   gitea/, homepage-admin/, homepage-public/, portainer/, watchtower/
media/            arr-stack/, invidious/, jellyfin/                (unchanged)
monitoring/       monitoring-home/, monitoring-oci/, uptime-kuma/
networking/       ddclient/, netbird-client/, netbird-server/, traefik/, wireguard/
storage/          immich/, nextcloud/, syncthing/                  (unchanged)
utilities/        convertx/, it-tools/, matrix/, neko/, searxng/, wiki-js/, yopass/
```

Rules behind the layout:

- **Top level by tool for provisioning.** `terraform/` and `ansible/` hold everything run from a control node. Category folders hold only compose stacks (what runs on hosts). Ansible refers to stacks by repo-relative path, the way `ansible/gaming` already deploys `gaming/*`.
- **Categories by job.** Every stack is exactly one level under its category.
- **Variants are flat siblings with suffixes** (`netbird-server`/`netbird-client`, `homepage-admin`/`homepage-public`, `monitoring-home`/`monitoring-oci`). No parent folder with variant subfolders.
- **`ai-agents/`** holds agent skills and MCP config used by agents on the user's machines (for the Obsidian vault). It is separate from `.agents/`, which is this repo's own agent config and is loaded by sessions in this repo.

### Path Map

| Old | New |
| --- | --- |
| `infrastructure/terraform/<provider>/<name>/` | `terraform/<provider>/<name>/` |
| `automation/ansible/README.md` | `ansible/README.md` |
| `automation/ansible/gaming/` | `ansible/gaming/` |
| `automation/ansible/server-admin/` | `ansible/server-admin/` |
| `automation/ollama-aws-hybrid/ansible/` | `ansible/ollama-aws-hybrid/` |
| `automation/ai-stack/context/tasknotes-obsidian/` | `ai-agents/tasknotes-obsidian/` |
| `automation/ai-stack/context/inbox-processing/` | `ai-agents/inbox-processing/` |
| `infrastructure/traefik/` | `networking/traefik/` |
| `infrastructure/ddclient/` | `networking/ddclient/` |
| `infrastructure/wireguard/` | `networking/wireguard/` |
| `infrastructure/netbird-server/` | `networking/netbird-server/` |
| `infrastructure/netbird-client/` | `networking/netbird-client/` |
| `infrastructure/monitoring/` | `monitoring/monitoring-home/` |
| `infrastructure/monitoring-oci/` | `monitoring/monitoring-oci/` |
| `infrastructure/uptime-kuma/` | `monitoring/uptime-kuma/` |
| `infrastructure/homepage/admin-instance/` | `infrastructure/homepage-admin/` |
| `infrastructure/homepage/public-instance/` | `infrastructure/homepage-public/` |
| `infrastructure/homepage/README.md` | split into `homepage-admin/README.md` and `homepage-public/README.md` |
| `infrastructure/matrix/` | `utilities/matrix/` |
| `infrastructure/wiki-js/` | `utilities/wiki-js/` |

`automation/ollama-aws-hybrid/` keeps its compose file, `config/`, `letsencrypt/`, `.env.example`, and README; only its `ansible/` subfolder moves.

## Conventions

### Compose project name

Every compose file sets a top-level `name:` equal to the folder name it has **before** the move. The value is not changed after the move, so volume and network names stay the same.

| Compose file (current path) | `name:` |
| --- | --- |
| `infrastructure/homepage/admin-instance/` | `admin-instance` |
| `infrastructure/homepage/public-instance/` | `public-instance` |
| `infrastructure/monitoring/docker-compose.example.yml` | `monitoring` |
| `infrastructure/monitoring/node-exporter/` | `node-exporter` |
| `automation/ai-stack/ollama/` | `ollama` |
| `automation/ai-stack/open-webui/` | `open-webui` |
| every other stack | its folder name |

Already pinned and left as-is: `matrix`, `monitoring-oci`, `netbird`, `immich`.

`COMPOSE_PROJECT_NAME` is not used anywhere in the repo. If a host's live `.env` sets it, it still overrides `name:`.

### Example files

- General rule: `<file>.example.<ext>`.
- Env-style files keep the env convention: `.env.example`, `<name>.env.example`. This keeps `.gitignore` patterns like `*.env` from matching examples.
- `terraform.tfvars.example` keeps the Terraform convention.
- Files with no extension: `<file>.example` (e.g. `Modelfile.example`).

Renames:

| Old | New |
| --- | --- |
| `ansible/server-admin/inventory/example.hosts.yml` | `hosts.example.yml` |
| `ansible/ollama-aws-hybrid/open-webui-ec2-instance.example.yaml` | `open-webui-ec2-instance.example.yml` |
| `networking/ddclient/ddclient.conf.example` | `ddclient.example.conf` |
| `networking/netbird-server/config.yaml.example` | `config.example.yaml` |
| `utilities/matrix/element/config.json.example` | `config.example.json` |
| `utilities/matrix/homeserver.yaml.template` | `homeserver.example.yaml` |
| `networking/wireguard/templates/minecraft-server-example.conf` | `minecraft-server.conf` (the `templates/` folder already marks it as a template) |

### Ansible file extensions

Ansible playbooks and inventories use `.yml`. Renames:

- `ansible/gaming/playbooks/{deploy,setup,teardown,verify-host}.yaml` → `.yml`
- `ansible/ollama-aws-hybrid/{deploy,setup,teardown,verify-host}.yaml` → `.yml`
- live inventory `open-webui-ec2-instance.yaml` → `open-webui-ec2-instance.yml` (update `ansible.cfg` and `.gitignore`)

Mounted app configs (`loki/config.yaml`, `livekit.yaml`, Grafana provisioning, `traefik-dynamic.yaml`, `cloud-init.yaml`) keep their names.

### Portable provisioning

- Tracked Ansible files use paths relative to `playbook_dir` or the playbook file, never absolute workstation paths. Target-host paths like `/home/ubuntu/...` are fine.
- Anything specific to one machine stays in gitignored files with a tracked `.example` next to them: inventories, vault env files, `runtime.env`, `terraform.tfvars`.
- The Terraform → Ansible handoff stays manual: Terraform outputs the IP, and the user puts it in the gitignored inventory on the machine running Ansible.

Ansible path fixes after the move:

- `ansible/gaming/playbooks/setup.yml`: `{{ playbook_dir }}/../../../../gaming/...` → `{{ playbook_dir }}/../../../gaming/...`
- `ansible/ollama-aws-hybrid/setup.yml`: `src: ../docker-compose.yml` → `src: "{{ playbook_dir }}/../../automation/ollama-aws-hybrid/docker-compose.yml"`; `src: ../config/traefik.yml` → `src: "{{ playbook_dir }}/../../automation/ollama-aws-hybrid/config/traefik.yml"`. Using `playbook_dir` matches the gaming playbooks and avoids Ansible's `files/` search-path lookup.

### `.gitignore` scoping

Replace bare filenames, which match anywhere in the repo, with anchored paths:

| Old | New |
| --- | --- |
| `traefik.yml` | `/networking/traefik/config/traefik.yml` |
| `pi5.yml`, `truenas.yml`, `ubuntu-server*.yml` (6 lines) | `/networking/traefik/config/dynamic/*.yml` and `!/networking/traefik/config/dynamic/*.example.yml` |
| `app.ini` | `**/gitea/**/app.ini` |
| `**/monitoring/docker-compose.yml` | `/monitoring/monitoring-home/docker-compose.yml` |
| `automation/ollama-aws-hybrid/ansible/open-webui-ec2-instance.yaml` | `/ansible/ollama-aws-hybrid/open-webui-ec2-instance.yml` |
| `automation/ollama-aws-hybrid/ansible/check.output` | `/ansible/ollama-aws-hybrid/check.output` |
| `automation/ansible/server-admin/inventory/hosts.yml` | `/ansible/server-admin/inventory/hosts.yml` |
| (new) | `.agents/settings.local.json` |

Why: the bare `traefik.yml` pattern also matches `automation/ollama-aws-hybrid/config/traefik.yml`. That file is tracked only because it was force-added.

Before and after the change, compare `git status --ignored --porcelain` to confirm the same live files are ignored.

### Stack README template

Every stack README uses these sections in this order. A section with nothing to say gets one line saying so; it is not dropped.

```
# <Service>

<One-paragraph overview: what it is and why it's in the lab.>

**Runs on:** <placement requirement>   (optional, see below)

## Prerequisites
## Setup            (cp .env.example .env, other .example copies, first start)
## Configuration    (every .env variable, one line each)
## Routing & Ports  (Traefik hostnames, external networks, published ports)
## Data & Backups   (bind mounts and volumes, what to back up)
## Troubleshooting
```

Category READMEs (`networking/`, `monitoring/`, `infrastructure/`, `utilities/`, `automation/`, `ansible/`, `terraform/`, `ai-agents/`) list their stacks with one line each.

Which machine runs each stack changes often, so it is tracked in private homelab documentation, not in the repo. A stack README has a `**Runs on:**` line only when placement is a requirement or a stable role, worded as that role (e.g. "the OCI host (must share the `services` network with netbird-server)", "a host with an NVIDIA GPU", "every Docker host"), never as the machine it happens to run on today. The root README has no host map; its Infrastructure Overview describes what each device is for.

## Out of Scope

- Remote Terraform state backend. This becomes necessary once `apply` runs from more than one machine. Listed as a follow-up.
- Shared Ansible roles and a single shared inventory.
- Renaming `docker-compose.yml` to `compose.yaml`.
- Renaming mounted app config files.
- Untracked work in progress: `infrastructure/terraform/aws/ollama-aws-hybrid/dev-box/` and `infrastructure/monitoring/dashboard.example.json`. These stay untracked and travel with their folders (see Step 3 and Step 4).
- `DOCS-AUDIT.md`: never tracked.

## Implementation Steps

All work happens on branch `restructure`. Each step is one or more single-line Conventional Commits.

### Step 1: Commit finished docs-audit edits

Commit the current tracked edits and the `ollama/models/.env.example` → `ollama/.env.example` move. Do not stage `DOCS-AUDIT.md`, `dev-box/`, `dashboard.example.json`, `.agents/settings.local.json`, or the `.claude` symlink.

### Step 2: Pin compose `name:`

Add `name:` to every compose file per the table above. Nothing changes for running stacks.

Host check (user, optional): run `docker compose ls` on each host and confirm the running project names match the pinned values.

### Step 3: Move provisioning (`terraform/`, `ansible/`)

- Move folders with `git mv <dir> <new dir>`. A directory `git mv` renames the whole folder on disk, so ignored and untracked files (`.terraform/`, `terraform.tfstate*`, `terraform.tfvars`, live inventories, `dev-box/`) travel with it, while only tracked files are staged. Never use `git add -A` here: it would stage untracked work in progress.
- Rename the Ansible files to `.yml`, fix the Ansible relative paths, update the `ansible.cfg` inventory path for `ollama-aws-hybrid`, and update `.gitignore`.
- Other machines with a clone that runs Terraform or Ansible: after `git pull`, move the ignored files left in the old folders into the new ones.

### Step 4: Move stacks and `ai-agents/`

- Same `git mv` approach in this working copy (carries `dashboard.example.json` and any local live files).
- Split the Homepage README into two.
- Apply the `.gitignore` scoping.
- Update every reference to old paths: READMEs, the category READMEs, the root README, the comments in `gaming/*/docker-compose.yml` that mention `infrastructure/netbird-*`, and `networking/netbird-client/.env.example`.

Host migration, per moved stack, on the host that runs it:

```
cd <old path> && docker compose down
cd <repo root> && git pull
rsync -a <old path>/ <new path>/      # brings over .env, data dirs, acme.json, etc.
cd <new path> && docker compose up -d
# verify the stack works, then:
rm -rf <old path>
```

Also check each host for absolute paths pointing at old folders: cron jobs, systemd units, scripts, shell aliases.

### Step 5: Rename example files

Apply the example-file renames and update every reference to them in READMEs and compose files.

### Step 6: READMEs to template

1. Ask the user which host runs each stack. Use the answers for **Runs on** lines and the root host table.
2. Rewrite each stack README to the template. Resolve the remaining `DOCS-AUDIT.md` items in the same pass, checking each README against its compose file and `.env.example`.
3. Update the category READMEs and the root README "Project Organization" section.

## Verification (after each step)

- **Compose:** for every compose file, `docker compose -f <file> config -q`. Record a baseline before Step 2. A failure is acceptable only if it also appears in the baseline (e.g. a missing gitignored `.env`).
- **Ansible:** `ansible-playbook --syntax-check` on every playbook. Ansible is not installed on this machine, so the user runs this on the control node.
- **Terraform:** `terraform init -backend=false && terraform validate` in each Terraform folder. Terraform is not installed on this machine, so the user runs this.
- **Links:** a script that checks every relative Markdown link resolves to an existing file.
- **Old paths:** `git grep` for `infrastructure/terraform`, `automation/ansible`, `automation/ollama-aws-hybrid/ansible`, `ai-stack/context`, and every old stack path in the path map. Expect no hits outside this spec.
- **Ignores:** compare `git status --ignored --porcelain` before and after each `.gitignore` change.
