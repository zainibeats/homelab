# Gaming Ansible

Ansible automation for deploying one game stack at a time onto the reusable OCI Debian-based host from `infrastructure/terraform/oci/free-tier-host`.

The playbooks copy the existing Compose stacks from `gaming/minecraft` or `gaming/palworld`, install Docker host prerequisites, decrypt a Vault-managed `.env`, and start the selected stack.

## Layout

- `inventory/oci-game-hosts.example.yml` - Inventory template for the OCI host.
- `files/*.env.vault` - Vault-managed runtime env files, created from the game stack `.env.example` files.
- `playbooks/setup.yaml` - Prepare the host and copy the selected game stack.
- `playbooks/deploy.yaml` - Start the selected stack and stop the other stack by default.
- `playbooks/teardown.yaml` - Stop the selected stack.
- `playbooks/verify-host.yaml` - Check Docker and selected stack setup.

## Setup

Run commands from this directory:

```bash
cd automation/ansible/gaming
```

Create the inventory:

```bash
cp inventory/oci-game-hosts.example.yml inventory/oci-game-hosts.yml
```

Edit `inventory/oci-game-hosts.yml` with the OCI public IP, SSH user, and key path.

Install the required Ansible collection:

```bash
ansible-galaxy collection install -r requirements.yml
```

Create an encrypted runtime env file for each game you plan to deploy:

```bash
cp ../../../gaming/minecraft/.env.example /tmp/minecraft.env
ansible-vault encrypt /tmp/minecraft.env --output files/minecraft.env.vault

cp ../../../gaming/palworld/.env.example /tmp/palworld.env
ansible-vault encrypt /tmp/palworld.env --output files/palworld.env.vault
```

The real `*.env.vault` files are ignored locally by default. Remove the ignore rule if you want to commit encrypted Vault files.

## Usage

Prepare the OCI host for Minecraft:

```bash
ansible-playbook playbooks/setup.yaml -e game_stack=minecraft --ask-vault-pass
```

Deploy Minecraft:

```bash
ansible-playbook playbooks/deploy.yaml -e game_stack=minecraft
```

Switch the same OCI host to Palworld:

```bash
ansible-playbook playbooks/setup.yaml -e game_stack=palworld --ask-vault-pass
ansible-playbook playbooks/deploy.yaml -e game_stack=palworld
```

`deploy.yaml` stops the other known game stack first when `gaming_stop_other_stack` is true. Override it only when you intentionally want to leave another stack running:

```bash
ansible-playbook playbooks/deploy.yaml -e game_stack=palworld -e gaming_stop_other_stack=false
```

Verify the host:

```bash
ansible-playbook playbooks/verify-host.yaml -e game_stack=minecraft
```

Stop a stack:

```bash
ansible-playbook playbooks/teardown.yaml -e game_stack=minecraft
```

## Runtime Paths

By default the remote host uses:

- `/opt/gaming/minecraft`
- `/opt/gaming/palworld`

Each selected directory contains the copied `docker-compose.yml`, decrypted `.env`, persistent `data/`, optional `config/`, and NetBird state.
