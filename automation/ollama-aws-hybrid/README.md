# Ollama AWS Hybrid Deployment

> **Experimental** — This is an exploratory setup and not the primary Ollama deployment. For the standard local-only configuration, see [ai-stack](../ai-stack/README.md).

This project provides a hybrid LLM deployment that runs your large language models locally on a home machine while exposing a user‑friendly web interface via an AWS EC2 instance. The setup uses **Gluetun** to establish a WireGuard tunnel from the EC2 host to the local Ollama service, allowing Open WebUI to connect to the models securely over the internet.

Public traffic enters the EC2 instance over HTTPS through **Traefik**. Traefik
obtains certificates using Cloudflare's DNS-01 challenge, so the instance does
not need to expose an HTTP listener on port 80.

## Architecture Overview

<img src="https://assets.czaini.net/images/aws-ollama-diagram.jpg" width="50%" height="auto"/>

**EC2 Instance**:
- Gluetun runs inside the instance and creates a secure tunnel to the local network.
- Open‑WebUI runs inside the same compose stack and shares a container network with Gluetun (`network_mode: "service:gluetun"`), so it can communicate with the tunnel.
- Traefik terminates HTTPS with a certificate obtained through Cloudflare's DNS challenge and proxies requests to Open WebUI through Gluetun's shared network namespace.

```text
Client -> EC2:443 -> Traefik -> Gluetun:8080/Open WebUI -> WireGuard -> Ollama
```

### Public IP and DNS

The default infrastructure uses an Elastic IP so the Cloudflare DNS record
remains valid across EC2 stop/start cycles and service downtime is minimized.

As an alternative, [`ddclient`](../../infrastructure/ddclient/README.md) can
update the Cloudflare DNS record when the instance's dynamically assigned
public IP changes. This avoids reserving an Elastic IP, but introduces a period
of downtime while the instance starts, `ddclient` detects the new address, and
DNS caches expire. AWS charges for public IPv4 addresses whether they are
dynamically assigned to EC2 or allocated as Elastic IP addresses, so this
alternative should not be assumed to reduce the public IPv4 cost.

**Local**:
- Ollama is exposed on the LAN (e.g., `http://192.168.1.100:11434`) and is reachable from the EC2 instance through the WireGuard tunnel.

## Terraform

The configuration in [`terraform/`](./terraform/) creates the AWS resources
for the EC2 host: a VPC, public subnet, internet gateway, route table, security
group, SSH key pair, EC2 instance, encrypted EBS root volume, and Elastic IP.

Before starting, configure an AWS CLI profile and create the SSH key referenced
by `public_key_path`. Then create your local variables file:

```shell
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` with `aws_profile`, one or more trusted public IPv4
addresses in `/32` CIDR notation under `trusted_ipv4_cidrs`, and an
`availability_zone_id`. Use an availability-zone ID such as `usw2-az2`, not a
zone name such as `us-west-2b`. Do not commit `terraform.tfvars` or Terraform
state files.

Review and deploy the infrastructure:

```shell
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

After the apply completes, use the
`public_ip` output to create an `A` record for
`OPENWEBUI_HOST` in the Cloudflare dashboard. The Elastic IP keeps this address
stable across EC2 stop/start cycles. The `ssh_command` output provides the
command for connecting to the instance.

To remove the AWS resources when they are no longer needed, review the destroy
plan before confirming it:

```shell
terraform plan -destroy
terraform destroy
```

This project currently uses local Terraform state. That is suitable for an
experimental single-user deployment; shared or production use should move the
state to an encrypted remote backend with locking.

## Configuration

**EC2 Instance**:
- `OLLAMA_BASE_URL` must point to the **local** Ollama instance.  
- The EC2 security group should allow TCP port `443` only from your trusted
  public CIDR. Port `3000` is not published by the Compose stack.

_See full configuration [here](./docker-compose.yml)_

**Local**:

- The local compose stack should include Open WebUI to adjust permissions, troubleshoot, etc. 

```yaml
# Running on local node
services:
  ollama:
    network_mode: host
```

### Environment Variables

**IMPORTANT**: Any IP that is being used for the health check during the gluetun startup must be included in `WIREGUARD_ALLOWED_IPS`. For simplicity (and to whitelist Cloudflare DNS), I've opted for 1.1.1.1/32 in the example [env file](./.env.example). Without a passing the healthcheck, the VPN connection will be unstable.

Set `OPENWEBUI_HOST` to the DNS hostname that resolves to the EC2 instance. The
Cloudflare token must be able to edit DNS records for that hostname's zone so
Traefik can complete the DNS-01 certificate challenge. Only TCP port 443 needs
to be exposed by the instance; restrict it to your trusted public CIDR in the
Terraform security group.

Traefik requires these values in `.env`:

- `OPENWEBUI_HOST`: hostname used to reach Open WebUI, such as
  `ollama.example.com`.
- `CF_DNS_API_TOKEN`: Cloudflare API token with DNS edit access to the relevant
  zone.
- `ACME_EMAIL`: email address used for ACME certificate registration.
- `WEBUI_SECRET_KEY`: long, random secret used by Open WebUI.

Create a DNS record for `OPENWEBUI_HOST` that points to the EC2 instance's
public address. Then copy `.env.example` to `.env`, replace every placeholder,
ensure Traefik's certificate store is private, and start the stack:

```shell
chmod 600 ./letsencrypt/acme.json
docker compose up -d
```

Traefik discovers the route from labels on the Gluetun service. This is
intentional: Open WebUI uses `network_mode: "service:gluetun"`, so it shares
Gluetun's network namespace and is reachable through Gluetun on port `8080`.

## Ansible

The playbooks in [`ansible/`](./ansible/) verify the EC2 prerequisites and
deploy the Compose and Traefik configuration. Create a local inventory from the
example and replace the EC2 address and SSH key path:

```shell
cd ansible
cp open-webui-ec2-instance.example.yaml open-webui-ec2-instance.yaml
```

Create the runtime environment file from the project example, fill in every
placeholder, and encrypt the complete file before running the deployment:

```shell
cp ../.env.example files/runtime.env
ansible-vault encrypt files/runtime.env
```

`files/runtime.env` is ignored by Git. Keep the Vault password outside this
repository. The deployment decrypts the file while copying it to the EC2 host
as `/home/ubuntu/ollama-aws-hybrid/.env` with mode `0600`; the remote file is
plaintext and must retain its restrictive permissions.

Verify the host, then deploy the configuration:

```shell
ansible-playbook verify-host.yaml
ansible-playbook --ask-vault-pass setup.yaml
```

Run `setup.yaml` a second time to confirm idempotency. The second run should
report no changes when the deployed configuration is already current.
