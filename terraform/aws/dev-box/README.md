# Dev Box

Terraform for a personal AWS EC2 dev box: SSH in, run Claude Code, and try out
services (web servers, containers, and so on).

## Layout

- Creates a VPC, public subnet, internet gateway, route table, security group,
  SSH key pair, one EC2 instance (`m7i-flex.large`, 50 GB encrypted gp3), and an
  Elastic IP so the address survives stop/start.
- `cloud-init.yaml` installs Docker, Compose, git, build tools, tmux, Python,
  ripgrep, jq, Node LTS, and Claude Code on first boot.
- Only SSH (22) is open, restricted to `trusted_ipv4_cidrs`. Add `ingress`
  blocks in `security.tf` when a service needs a port.

## Usage

1. Create a dedicated key: `ssh-keygen -t ed25519 -f ~/.ssh/dev-box-key`
2. `cp terraform.tfvars.example terraform.tfvars` and set `trusted_ipv4_cidrs`
   (`/32` only), `aws_profile`, and `availability_zone_id` (an AZ ID such as
   `usw2-az2`, not a name such as `us-west-2b`).
3. `terraform init && terraform plan && terraform apply`
4. Connect with the `ssh_command` output, then run `claude` once to log in.
   Cloud-init may still be running for a few minutes after first boot; check
   with `cloud-init status --wait`.

State is local. Keep `terraform.tfvars` and state files out of git.
