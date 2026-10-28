# Gaming Ansible

Ansible automation for deploying one game stack at a time onto the reusable OCI Debian-based host from `terraform/oci/free-tier-host`.

The playbooks copy the Compose stack from `gaming/minecraft` or `gaming/palworld`, install Docker host prerequisites, decrypt a Vault-managed `.env`, and start the stack. Valheim isn't supported (`gaming_allowed_stacks` lists only `minecraft` and `palworld`); deploy it manually with `docker compose`.

## Setup

Run commands from this directory (`cd ansible/gaming`).

1. Create the inventory and edit it with the OCI public IP, SSH user, and key path:

   ```bash
   cp inventory/oci-game-hosts.example.yml inventory/oci-game-hosts.yml
   ```

2. Install the required collection:

   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. Create an encrypted runtime env file (`files/<game>.env.vault`) for each game you plan to deploy. The `*.env.vault` files are gitignored.

   ```bash
   cp ../../gaming/minecraft/.env.example /tmp/minecraft.env
   ansible-vault encrypt /tmp/minecraft.env --output files/minecraft.env.vault
   ```

   Repeat with `palworld` for Palworld.

## Usage

Set `game_stack` to `minecraft` or `palworld`:

| Playbook | Does |
| --- | --- |
| `setup.yml` | Prepares the host and copies the selected stack. Needs `--ask-vault-pass`. |
| `deploy.yml` | Starts the selected stack and stops the other one. |
| `verify-host.yml` | Checks Docker and the selected stack's setup. |
| `teardown.yml` | Stops the selected stack. |

```bash
ansible-playbook playbooks/setup.yml -e game_stack=minecraft --ask-vault-pass
ansible-playbook playbooks/deploy.yml -e game_stack=minecraft
```

To switch the host to the other game, run the same two commands with its name. `deploy.yml` stops the other stack unless you pass `-e gaming_stop_other_stack=false`.

## Runtime Paths

Each stack lives in `/opt/gaming/<game>` on the host, with the copied `docker-compose.yml`, the decrypted `.env`, persistent `data/`, and optional `config/`.
