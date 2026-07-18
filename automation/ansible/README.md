# Ansible

This setup provides shared Ansible automation for managing homelab and cloud servers. It currently focuses on Debian-based hosts and includes a playbook for updating system packages across the homelab inventory.

## Inventory

- **`inventory/hosts.yml`**: Local inventory used by Ansible by default.
- **`inventory/example.hosts.yml`**: Example inventory template with placeholder host addresses and connection settings.

Hosts are grouped by purpose:

- **`debian_servers`**: Debian-based hosts that can run Debian-specific tasks.
- **`homelab_servers`**: Local homelab machines.
- **`cloud_servers`**: Cloud-hosted machines.

## Configuration

1. **Ansible Config**
   The local `ansible.cfg` points Ansible at `./inventory/hosts.yml`, so commands can be run from this directory without passing `-i` each time.

2. **Inventory Setup**
   Copy the example inventory and replace the placeholder hostnames, ports, users, and SSH key path:

   ```bash
   cp inventory/example.hosts.yml inventory/hosts.yml
   ```

3. **SSH Access**
   Ensure the configured SSH user and private key can connect to each host before running playbooks.

4. **Privilege Escalation**
   The package update playbook uses `become: true`, so the remote user must be allowed to run privileged package-management tasks. These hosts are configured to require a sudo password, so include `--ask-become-pass` when running playbooks that use `become`.

## Playbooks

- **`playbooks/update-packages.yml`**: Updates the package cache, performs a dist upgrade on Debian-based homelab hosts, and reboots hosts when `/var/run/reboot-required` exists.

## Usage

Run commands from the `automation/ansible` directory:

```bash
cd automation/ansible
```

Check that the inventory is reachable:

```bash
ansible all -m ping
```

Run the package update playbook:

```bash
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
