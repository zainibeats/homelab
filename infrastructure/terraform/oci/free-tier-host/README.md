# OCI Free Tier Host

Reusable Terraform for a single OCI Free Tier host.

Use this when the infrastructure shape stays the same and only the workload
running on the host changes.

## Layout

- This directory creates the OCI compute and network resources.
- Workload-specific Compose stacks live in their own service directories.

Set `service_name` in `terraform.tfvars` to control the generated OCI display
names, for example `minecraft`, `palworld`, or another reusable host name.

Keep workload-specific container settings in the owning service directory
instead of duplicating this Terraform directory.
