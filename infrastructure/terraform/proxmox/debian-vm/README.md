# Proxmox Debian VM

Terraform for a single Debian VM cloned from a cloud-init ready template on
Proxmox VE, using the `bpg/proxmox` provider.

## Layout

- `compute.tf` clones the template and configures CPU, memory, disk, network,
  and cloud-init (static IP, DNS, user, SSH key).
- `terraform.tfvars.example` shows the required inputs and common overrides.

## Proxmox API Token

Create a dedicated user and token on the Proxmox host:

```bash
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role TerraformProv
pveum user token add terraform@pve tf --privsep 0
```

Set `proxmox_api_token` in `terraform.tfvars` to `terraform@pve!tf=<secret>`.

## Template Requirements

- cloud-init installed, with a cloud-init drive attached.
- `disk_interface` must match the template's boot disk (`scsi0`, `virtio0`, ...).
- `disk_size_gb` must be greater than or equal to the template's disk size.
- Set `qemu_agent_enabled = true` only if `qemu-guest-agent` is installed in the
  template; otherwise `terraform apply` hangs waiting for the agent.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
