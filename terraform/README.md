# Terraform

Terraform configurations, grouped by provider. Run them from a workstation or a control node. State is local to each folder (`terraform.tfstate`, gitignored), so run each configuration from one machine only.

- **[Azure Jump Server](./azure/jump-server/README.md)** - Terraform-managed Azure Linux jump server for SSH access to other cloud resources
- **[OCI Free Tier Host](./oci/free-tier-host/README.md)** - Reusable Terraform configuration for a single OCI Free Tier host
- **[Ollama AWS Hybrid](./aws/ollama-aws-hybrid/README.md)** - Terraform-managed AWS EC2 host for the hybrid Ollama deployment
- **[Proxmox Debian VM](./proxmox/debian-vm/README.md)** - Terraform configurations for Proxmox VM management
