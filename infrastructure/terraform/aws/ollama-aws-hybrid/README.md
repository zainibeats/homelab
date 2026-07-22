# Ollama AWS Hybrid

Terraform for the AWS EC2 host used by the experimental Ollama hybrid
deployment.

Use this when the public Open WebUI entry point should run in AWS while the
Ollama service remains on a local homelab machine. The application deployment
and Ansible workflow live in
[`automation/ollama-aws-hybrid`](../../../../automation/ollama-aws-hybrid/README.md).

## Layout

- This directory creates the AWS VPC, public subnet, internet gateway, route
  table, security group, SSH key pair, EC2 instance, encrypted root volume, and
  Elastic IP.
- `cloud-init.yaml` installs Docker and Docker Compose during first boot.
- `terraform.tfvars.example` shows the required local inputs.

Set `trusted_ipv4_cidrs` in `terraform.tfvars` to the public IPv4 `/32` ranges
that should reach the instance. This currently controls both SSH and HTTPS
access.

Set `availability_zone_id` to an AWS availability-zone ID, such as `usw2-az2`,
not a zone name such as `us-west-2b`.

## Handoff

After `terraform apply`, use the `public_ip` output for the Cloudflare DNS
record and the `ssh_command` output for host access. Continue with the
deployment workflow in
[`automation/ollama-aws-hybrid`](../../../../automation/ollama-aws-hybrid/README.md).

This project currently uses local Terraform state. Keep `terraform.tfvars` and
state files out of git.
