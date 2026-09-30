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

## Firewall

This Terraform doesn't manage the security list. The subnet uses the VCN's
default list, and its rules are set in the OCI console.

- **ufw on the host:** deny all incoming, allow `22/tcp` from anywhere.
- **Security list:** `22/tcp` from the control node or jump server only, plus
  any public ports the workload needs. For [NetBird Server](../../../netbird-server/README.md)
  that's `80/tcp`, `443/tcp`, `3478/udp` and `51820/udp` from anywhere.

SSH is restricted in the security list rather than in ufw, so the allowed IPs
can be changed from the console without being locked out of the host. Docker's
published ports bypass ufw, so only the security list filters them.
