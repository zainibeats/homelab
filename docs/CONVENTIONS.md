# Conventions

Rules for adding or changing anything in this repo. Compose stacks are deployed by `git pull` + `docker compose up` on each host, and Ansible and Terraform run from a workstation or control node. Most of these rules exist so that layout changes never break a running host.

## Layout

- **Compose stacks** live one level under a category folder named for their job: `<category>/<stack>/`. Categories: `automation`, `gaming`, `infrastructure`, `media`, `monitoring`, `networking`, `storage`, `utilities`.
- **Provisioning** lives in top-level folders by tool: `terraform/<provider>/<name>/` and `ansible/<project>/`. Category folders hold only compose stacks.
- **Variants of one service** are flat siblings with a suffix (`netbird-server`/`netbird-client`, `homepage-admin`/`homepage-public`, `monitoring-home`/`monitoring-oci`), not a parent folder with variant subfolders.
- **`agent-context/`** holds context for AI agents working on things outside this repo (e.g. the Obsidian vault). **`.agents/`** is this repo's own agent config.
- Every category folder has a `README.md` listing its stacks, one line each.

## Compose

- Every compose file sets a top-level `name:`. For a new stack, use its folder name.
- Never change an existing `name:`, even after moving or renaming the folder. The project name prefixes volume and network names, so changing it makes named volumes look empty. Some names therefore differ from their folder (e.g. `infrastructure/homepage-admin` is `name: admin-instance`).
- A gitignored live copy of a compose file (e.g. `monitoring/monitoring-home/docker-compose.yml`) must keep the same `name:` line as its example.
- Moving a stack folder means migrating every host that runs it: `docker compose down`, `git pull`, move the gitignored live files to the new folder, `docker compose up -d`, and confirm the project name with `docker compose ls`.

## Deploying

Hosts run each stack straight from their clone, and the stacks bind-mount gitignored live files from it. In a deployed clone:

- Never `git stash`, `checkout`, `reset`, `switch` or `clean`. Git treats ignored files as expendable and overwrites any that share a path with a file tracked in the target commit. A running container keeps the old file until it restarts, so the breakage shows up days later.
- Before `git pull`, check that no untracked or ignored path you rely on is tracked upstream: `git cat-file -e origin/main:<path>` must fail.
- Untracking a live file (`git rm --cached`) deletes it on every host at its next pull, so back it up on each host first.
- Shell variables override `.env`. Some shells export `HOSTNAME` and `TZ`, which netbird-client, the game servers and wiki-js read, so run compose as `env -u HOSTNAME -u TZ docker compose ...` there.
- Dry-run before `up` (`docker compose --dry-run up -d`) to see which containers and networks it will recreate.

## Live files and examples

- Live config, secrets, and state are never tracked: `.env`, `*.env`, live inventories, vault files, `terraform.tfvars`, `*.tfstate`, `acme.json`, data folders. Each has a tracked example next to it.
- Example naming:
  - General: `<file>.example.<ext>` (e.g. `hosts.example.yml`, `config.example.yaml`).
  - Env files: `.env.example` and `<name>.env.example`, so ignore patterns like `*.env` never match an example.
  - Terraform: `terraform.tfvars.example`.
  - No extension: `<file>.example` (e.g. `Modelfile.example`).
- To use one, copy it without `.example` and fill it in.

## `.gitignore`

- Ignore live files by anchored path (`/networking/traefik/config/traefik.yml`), not by bare filename (`traefik.yml`). A bare name matches anywhere in the repo and can hide an unrelated file.
- After changing `.gitignore`, check with `git check-ignore -v <path>` that live files are still ignored and examples are not.

## Ansible

- Playbooks and inventories use `.yml`. Mounted app configs keep whatever name the app expects.
- Paths to repo files are relative to `{{ playbook_dir }}`, never absolute workstation paths, so any clone on any machine can run them.
- Each project folder keeps its own `ansible.cfg` and a gitignored inventory with a tracked `*.example.yml`.

## Terraform

- One folder per configuration: `terraform/<provider>/<name>/`.
- State is local and gitignored, so run each configuration from one machine only, until it moves to a remote backend.
- The Terraform → Ansible handoff is manual: copy the output IP into the gitignored Ansible inventory.

## READMEs

Every stack README follows this template. A section with nothing to say gets one line (e.g. `None.`); it is not dropped.

```
# <Service>

<One-paragraph overview: what it is and why it's in the lab.>

**Runs on:** <placement requirement>   (optional, see below)

## Prerequisites
## Setup            (cp .env.example .env, other .example copies, first start)
## Configuration    (every .env.example variable, one line each)
## Routing & Ports  (Traefik hostnames, external networks, published ports)
## Data & Backups   (bind mounts and volumes, what to back up)
## Troubleshooting
```

- **Placement:** which machine runs each stack changes often, so it is tracked in private homelab documentation, not in this repo. Add a `**Runs on:**` line only when placement is a requirement or a stable role, worded as that role ("the OCI host (must share the `services` network with netbird-server)", "a host with an NVIDIA GPU", "every Docker host"), never as the machine it happens to run on today.
- **Links:** use relative links between READMEs. Commands that `cd` assume the README's own folder as the starting point.
- The root README has no host map; its Infrastructure Overview describes what each device is for.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/), subject line only (e.g. `docs(networking): standardize stack readmes`). No body and no trailers (`Co-Authored-By`, session links). The tracked [conventional-commits skill](../.agents/skills/conventional-commits/SKILL.md) applies this rule.
