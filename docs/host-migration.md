# Host Migration (repo restructure)

One-time steps for hosts and control nodes after the repo restructure that moved stacks into `networking/`, `monitoring/`, `utilities/`, `terraform/` and `ansible/`. Delete this file once every host has been migrated.

## Moved stacks

| Old path | New path |
| --- | --- |
| `infrastructure/{traefik,ddclient,wireguard,netbird-server,netbird-client}` | `networking/…` |
| `infrastructure/monitoring` | `monitoring/monitoring-home` |
| `infrastructure/{monitoring-oci,uptime-kuma}` | `monitoring/…` |
| `infrastructure/homepage/admin-instance` | `infrastructure/homepage-admin` |
| `infrastructure/homepage/public-instance` | `infrastructure/homepage-public` |
| `infrastructure/{matrix,wiki-js}` | `utilities/…` |

Compose project names did not change (every compose file pins `name:`), so volumes and networks keep their names.

## Every host with a clone

For each stack the host runs that moved:

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

- **monitoring-home:** it runs from a gitignored live `docker-compose.yml` copied before `name:` was pinned. Before `docker compose up -d`, add `name: monitoring` as its first line (or re-copy `docker-compose.example.yml`); otherwise the project becomes `monitoring-home`.
- **ollama-aws-hybrid:** it also lost its tracked `acme.json`. On a manual deployment, back it up and restore it the same way.
- **Root-owned data** (e.g. `netbird-client/netbird/`) needs `sudo rsync` and `sudo rm`.
- Until the old folders are removed, their live files show up as untracked in `git status`. Don't run `git add -A` mid-migration.
- Check each host for absolute paths to old folders: `crontab -l`, `systemctl list-unit-files`, shell aliases, scripts.

## Machines that run Terraform or Ansible

After `git pull`, move the ignored leftovers (state, tfvars, live inventories, vault files):

```bash
rsync -a --remove-source-files infrastructure/terraform/ terraform/ && find infrastructure/terraform -type d -empty -delete
rsync -a --remove-source-files automation/ansible/ ansible/ && find automation/ansible -type d -empty -delete
rsync -a --remove-source-files automation/ollama-aws-hybrid/ansible/ ansible/ollama-aws-hybrid/ && find automation/ollama-aws-hybrid/ansible -type d -empty -delete
mv ansible/ollama-aws-hybrid/open-webui-ec2-instance.yaml ansible/ollama-aws-hybrid/open-webui-ec2-instance.yml 2>/dev/null
```

Then run `terraform init -backend=false && terraform validate` in each Terraform folder and `ansible-playbook --syntax-check` on each playbook.
