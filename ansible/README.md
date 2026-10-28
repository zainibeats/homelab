# Ansible

Shared Ansible automation for homelab and cloud servers, one subdirectory per job:

- **`server-admin/`**: General server administration (e.g., package updates).
- **`gaming/`**: Deploys one game stack from `gaming/` onto the OCI game host.
- **`ollama-aws-hybrid/`**: Prepares and deploys the [Ollama AWS Hybrid](../automation/ollama-aws-hybrid/README.md) stack on its EC2 host.

## Setup

Each subdirectory has its own `ansible.cfg`, so run commands from inside it. For server-admin, create the inventory from the example and replace the placeholder hostnames, ports, users, and SSH key path:

```bash
cp server-admin/inventory/hosts.example.yml server-admin/inventory/hosts.yml
```

Hosts are grouped as `debian_servers`, `homelab_servers`, and `cloud_servers`. The SSH user and key must be able to connect to each host. These hosts require a sudo password, so pass `--ask-become-pass` to any playbook that uses `become`.

## Playbooks

- **`server-admin/playbooks/update-packages.yml`**: Updates the package cache, dist-upgrades Debian-based hosts (it asserts this first), and reboots only when `/var/run/reboot-required` exists.

```bash
cd ansible/server-admin
ansible all -m ping
ansible-playbook playbooks/update-packages.yml --ask-become-pass
ansible-playbook playbooks/update-packages.yml --limit <host-or-group> --ask-become-pass
```
