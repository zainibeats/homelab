# Proxmox AI Box

Terraform for a Debian 13 VM on Proxmox VE with an NVIDIA GPU passed through, used to run local LLMs with Ollama for Hermes Agent. Instead of cloning a template, it builds the VM from the Debian cloud image with q35 + OVMF, which PCIe passthrough needs. Models live on a separate disk, so the OS can be rebuilt without downloading them again.

**Runs on:** a Proxmox node with an NVIDIA GPU ready for passthrough

## Prerequisites

- **GPU passthrough ready on the node:** IOMMU enabled, GPU bound to `vfio-pci`, host drivers blocklisted.
- **PCI resource mapping** for the GPU with all functions (GPU + HDMI audio) included (Datacenter → Resource Mappings). Its name goes in `gpu_mapping`.
- **Proxmox VE 8.4+** and the `import` content type on the image datastore. Add `import` to the datastore's existing content list. Check the current list with `pvesm status --content import` or `/etc/pve/storage.cfg` first, because `--content` replaces the whole list:

  ```bash
  pvesm set local --content <existing>,import
  ```

- **API token** with these privileges (whatever role it has):
  - `Mapping.Use` on the GPU mapping (included in `PVEAdmin`).
  - `Datastore.AllocateTemplate` on the image datastore (included in `PVEAdmin`).
  - `Sys.AccessNetwork` on the node, so Proxmox can download the cloud image. **Not in `PVEAdmin`**; the only alternative Proxmox accepts is `Sys.Audit` + `Sys.Modify` on `/`, which is much broader. Grant it with a small custom role:

    ```bash
    pveum role add TerraformDownload -privs "Sys.AccessNetwork"
    pveum acl modify /nodes/<node> --tokens '<user>@<realm>!<tokenid>' --roles TerraformDownload
    # privilege-separated token (privsep 1): the user needs it too
    pveum acl modify /nodes/<node> --users <user>@<realm> --roles TerraformDownload
    ```

  See the "Required permissions" of [`download-url`](https://pve.proxmox.com/pve-docs/api-viewer/#/nodes/{node}/storage/{storage}/download-url) and the [bpg download file docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/download_file).

## Setup

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The VM comes up with SSH only. The software is installed by hand inside the VM after `terraform apply`:

1. **Enable non-free sources:** add `contrib non-free non-free-firmware` to the components in `/etc/apt/sources.list.d/debian.sources`, then run `sudo apt update`.
2. **Models disk:** format the `scsi1` disk and mount it where Ollama keeps models. Use the by-id path: the kernel's `sda`/`sdb` letters don't follow the Proxmox `scsi0`/`scsi1` order, and the models disk may well be `sda`. Check it first with `ls -l /dev/disk/by-id/ | grep drive-scsi1`.

   ```bash
   sudo mkfs.ext4 -L models /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
   sudo mkdir -p /var/lib/ollama
   echo 'LABEL=models /var/lib/ollama ext4 defaults,discard,nofail 0 2' | sudo tee -a /etc/fstab
   sudo systemctl daemon-reload && sudo mount -a
   ```

3. **NVIDIA driver:** `sudo apt install linux-headers-cloud-amd64 nvidia-driver firmware-misc-nonfree`, then reboot. `nvidia-smi` should list the GPU.
4. **Docker + NVIDIA Container Toolkit:** install [Docker Engine](https://docs.docker.com/engine/install/debian/) and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), then `sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker`. Check with `sudo docker run --rm --gpus all debian:trixie-slim nvidia-smi`.
5. **Ollama:** clone this repo and run the [Ollama stack](../../../automation/ai-stack/README.md). In `ollama/.env`, set `OLLAMA_DATA=/var/lib/ollama/models` so downloaded models land on the models disk (otherwise they fill the OS disk), and `MODELS_DIR=/var/lib/ollama/custom` for Modelfiles. Check with `docker exec ollama ollama run hermes3:8b "hi"`, then `du -sh /var/lib/ollama/models`.
6. **Firewall:** Ollama has no authentication, so anything that can reach port 11434 can use the GPU or pull and delete models. UFW denies all incoming traffic except SSH and Ollama from the LAN. Allow SSH first, or `enable` locks you out:

   ```bash
   sudo apt install -y ufw
   sudo ufw allow 22/tcp
   sudo ufw allow from <lan-subnet> to any port 11434 proto tcp   # e.g. 172.20.50.0/24
   sudo ufw enable
   sudo ufw status verbose
   ```

   UFW covers Ollama because the stack uses host networking. Ports published by containers with `ports:` bypass UFW, so don't rely on it for those. If Hermes runs in a bridged container, also allow `sudo ufw allow in on docker0 to any port 11434 proto tcp`.
7. **Hermes Agent:** install it and point it at `http://localhost:11434/v1`.

## Configuration

| Variable | Description |
| --- | --- |
| `proxmox_endpoint` | Proxmox VE API URL. |
| `proxmox_api_token` | API token, `user@realm!tokenid=secret`. |
| `proxmox_insecure` | Skip TLS verification (default `true`). |
| `node_name` | Node that holds the GPU. |
| `vm_name` | VM name (default `ai-box`). |
| `vm_id` | VM ID. |
| `cloud_image_url` | Debian cloud image to import (default: trixie genericcloud). |
| `cloud_image_file_name` | File name for the image on the image datastore. |
| `image_datastore_id` | Directory datastore with `import` content (default `local`). |
| `cpu_cores` | vCPU cores. The CPU type is `host`. |
| `memory_mb` | Dedicated RAM in MiB. Ballooning is off. |
| `datastore_id` | Datastore for the boot, EFI and cloud-init disks (default `local-lvm`). |
| `disk_size_gb` | Boot disk size in GiB. |
| `models_datastore_id` | Datastore for the models disk. |
| `models_disk_size_gb` | Models disk size in GiB. |
| `models_disk_backup` | Include the models disk in vzdump backups (default `false`). |
| `gpu_mapping` | Name of the GPU's PCI resource mapping. |
| `network_bridge` | Bridge for the NIC (default `vmbr0`). |
| `ipv4_cidr` / `ipv4_gateway` / `dns_servers` | Static network settings set through cloud-init. |
| `admin_username` | User created by cloud-init (default `debian`). |
| `public_key_path` / `private_key_path` | SSH key pair. The public key goes into the VM, and the private key path is only used in the `ssh_command` output. |
| `qemu_agent_enabled` | Enable the guest agent. Only set this after installing `qemu-guest-agent` (default `false`). |

## Routing & Ports

- `22/tcp`: SSH.
- `11434/tcp`: Ollama API (host networking). UFW allows it from the LAN subnet only (Setup step 6).
- Everything else incoming is denied by UFW.

## Data & Backups

- **Boot disk** (`scsi0`): OS and Hermes Agent config. Covered by vzdump.
- **Models disk** (`scsi1`, mounted at `/var/lib/ollama`): left out of vzdump by default, since models can be downloaded again.
- **Terraform state** is local in this folder and gitignored.

## Troubleshooting

- **VM won't start, mapping error:** the token needs `Mapping.Use`, and the mapping must exist on `node_name`.
- **Image download fails with a content type error:** the image datastore is missing the `import` content type.
- **Image download fails with `HTTP 403 ... Permission check failed` (GetQueryURLMetadata):** the token lacks `Sys.AccessNetwork` on the node (see Prerequisites). `Sys.Modify` granted on the node does not count; Proxmox only accepts it on `/`.
- **`nvidia-smi` reports no devices:** check `lspci -nnk | grep -A3 NVIDIA` in the guest and confirm vfio still owns the card on the host.
- **Apply hangs at "waiting for agent":** `qemu_agent_enabled` is `true`, but the agent isn't installed in the guest.
