# Proxmox k3s Lab

OpenTofu for the k3s lab cluster on pve-compute: one server and two agent VMs
on Debian 13, the same shape as the production cluster's start. Uses the
`bpg/proxmox` provider. The OS and k3s are configured afterwards by
[`ansible/k3s`](../../../ansible/k3s/README.md), which also runs against the
bare-metal production nodes.

## Layout

- `compute.tf` downloads the Debian 13 cloud image into Proxmox and creates one
  VM per entry in `nodes`, with native cloud-init (static IP, DNS, user, SSH key).
- `outputs.tf` prints the node IPs and a ready-made Ansible inventory.
- `terraform.tfvars.example` shows the required inputs and common overrides.

## Prerequisites

- OpenTofu 1.10 or newer (`tofu`), or the [homelab toolbox](../../../homelab-toolbox/README.md) (run `homelab-box` in this folder instead of installing it). The code is also valid Terraform.
- A Proxmox API token. The `terraform@pve` token and `TerraformProv` role from
  [`debian-vm`](../debian-vm/README.md#proxmox-api-token) work here too.
- The **Import** content type enabled on `image_datastore_id` (default `local`):
  Datacenter → Storage → local → Content.
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
- The image comes from Debian's `latest` path and is downloaded once. To pick up
  a newer image: `tofu apply -replace=proxmox_virtual_environment_download_file.debian_13`.
- The `generic` image (not `genericcloud`) uses Debian's standard kernel, matching
  the bare-metal production nodes.
