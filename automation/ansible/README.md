# Ansible

This setup provides shared Ansible automation for managing homelab and cloud servers. It is organized into subdirectories by service:

- **`server-admin/`**: General server administration tasks (e.g., package updates).
- **`gaming/`**: Gaming-related infrastructure automation.

## Inventory

### Server Admin
- **`server-admin/inventory/hosts.yml`**: Local inventory used by Ansible by default for admin tasks.
- **`server-admin/inventory/example.hosts.yml`**: Example inventory template with placeholder host addresses and connection settings.

### Gaming
- **`gaming/inventory/`**: Contains inventory files specific to gaming hosts.

Hosts are grouped by purpose:

- **`debian_servers`**: Debian-based hosts that can run Debian-specific tasks.
- **`homelab_servers`**: Local homelab machines.
- **`cloud_servers`**: Cloud-hosted machines.

## Configuration

1. **Ansible Config**
   Each subdirectory (e.g., `server-admin/` and `gaming/`) contains its own `ansible.cfg`. This ensures that the correct inventory and variables are loaded when running tasks from those specific directories.

2. **Inventory Setup**
   Copy the example inventory and replace the placeholder hostnames, ports, users, and SSH key path for the server admin setup:

   ```bash
   cp server-admin/inventory/example.hosts.yml server-admin/inventory/hosts.yml
   ```

3. **SSH Access**
   Ensure the configured SSH user and private key can connect to each host before running playbooks.

4. **Privilege Escalation**
   The package update playbook uses `become: true`, so the remote user must be allowed to run privileged package-management tasks. These hosts are configured to require a sudo password, so include `--ask-become-pass` when running playbooks that use `become`.

## Playbooks

- **`server-admin/playbooks/update-packages.yml`**: Updates the package cache, performs a dist upgrade on Debian-based homelab hosts, and reboots hosts when `/var/run/reboot-required` exists.

## Usage

Run commands from the appropriate subdirectory:

```bash
# For server administration
cd automation/ansible/server-admin
ansible all -m ping
ansible-playbook playbooks/update-packages.yml --ask-become-pass
```

Limit the run to a single host or group when needed:

```bash
ansible-playbook playbooks/update-packages.yml --limit ubuntu_server --ask-become-pass
ansible-playbook playbooks/update-packages.yml --limit homelab_servers --ask-become-pass
```

## Notes

- The update playbook asserts that each target is Debian-based before running `apt` tasks.
- Reboots are automatic only when the target host reports that one is required.
- Use `--ask-become-pass` for playbooks that need sudo because these hosts do not use passwordless sudo.
