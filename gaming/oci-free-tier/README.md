# OCI Free Tier Game Server

Reusable Terraform for a single OCI Free Tier game server host.

Use this when the infrastructure shape stays the same and only the game-specific
Docker Compose stack changes.

## Layout

- `terraform/` creates the OCI compute and network resources.
- `../minecraft/` contains the Minecraft Compose stack.
- `../palworld/` contains the Palworld Compose stack.

Set `service_name` in `terraform/terraform.tfvars` to control the generated OCI
display names, for example `minecraft` or `palworld`.

Keep game-specific container settings in each game's Compose directory instead
of duplicating this Terraform directory.
