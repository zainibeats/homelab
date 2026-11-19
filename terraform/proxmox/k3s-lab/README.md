# Proxmox k3s Lab

OpenTofu for the k3s lab cluster on Proxmox: one server and two agent VMs
on Debian 13, the same shape as the production cluster's start. Uses the
`bpg/proxmox` provider. The OS and k3s are configured afterwards by
[`ansible/k3s`](../../../ansible/k3s/README.md), which also runs against the
bare-metal production nodes.

## Layout

- `compute.tf` full-clones one VM per entry in `nodes` from a Debian 13 template
  (`template_vm_id`), with native cloud-init (static IP, DNS, user, SSH key).
- `outputs.tf` prints the node IPs and a ready-made Ansible inventory.
- `terraform.tfvars.example` shows the required inputs and common overrides.

## Prerequisites

- OpenTofu 1.10 or newer (`tofu`), or the [homelab toolbox](../../../homelab-toolbox/README.md) (run `homelab-box` in this folder instead of installing it). The code is also valid Terraform.
- A Proxmox API token. The `terraform@pve` token and `TerraformProv` role from
  [`debian-vm`](../debian-vm/README.md#proxmox-api-token) work here too.
- A cloud-init-ready Debian 13 template made from the `generic` cloud image (not
  `genericcloud`), set as `template_vm_id`. Its boot disk must match
  `disk_interface` (default `scsi0`).
- No SSH access to the Proxmox host is needed: everything goes through the API.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in IPs, node name, token
tofu init
tofu plan
tofu apply
tofu output -raw ansible_inventory > ../../../ansible/k3s/inventory/lab/hosts.yml
```

Then run the playbooks in `ansible/k3s`. After the base playbook has installed
`qemu-guest-agent`, set `qemu_agent_enabled = true` and run `tofu apply` again;
the VMs restart to pick up the agent device.

## Rebuild

```bash
tofu destroy
tofu apply
```

The VMs get new SSH host keys, so remove the old ones first:
`ssh-keygen -R <ip>` for each node.

## Notes

- State is local and gitignored (see [CONVENTIONS](../../../docs/CONVENTIONS.md#terraform)),
  so run this configuration from one machine. Ansible can run from any machine.
- To move to a newer Debian image, update the template, then [rebuild](#rebuild)
  the VMs.
- The `generic` image (not `genericcloud`) uses Debian's standard kernel, matching
  the bare-metal production nodes.
