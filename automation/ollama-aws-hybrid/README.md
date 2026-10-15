# Ollama AWS Hybrid Deployment

> **Experimental** — This is an exploratory setup and not the primary Ollama deployment. For the standard local-only configuration, see [ai-stack](../ai-stack/README.md).

This project provides a hybrid LLM deployment that runs your large language models locally on a home machine while exposing a user‑friendly web interface via an AWS EC2 instance. Public clients connect to Open WebUI over HTTPS, and Open WebUI reaches the local Ollama service through a WireGuard tunnel managed by **Gluetun**.

The preferred workflow uses Terraform to provision the EC2 host, cloud-init to
install Docker and Docker Compose, and Ansible to configure and run the Compose
stack. The Compose files can still be used manually if you prefer to provision
or configure the host yourself.

Public traffic enters the EC2 instance over HTTPS through **Traefik**. Traefik
obtains certificates using Cloudflare's DNS-01 challenge, so the instance does
not need to expose an HTTP listener on port 80.

**Runs on:** an AWS EC2 instance (Open WebUI), with Ollama on a local machine

### Architecture

<img src="https://assets.czaini.net/images/aws-ollama-diagram.jpg" width="50%" height="auto"/>

**EC2 Instance**:
- Gluetun runs inside the instance and creates a WireGuard tunnel to the local network.
- Open‑WebUI runs inside the same compose stack and shares a container network with Gluetun (`network_mode: "service:gluetun"`), so it can communicate with the tunnel.
- Traefik terminates HTTPS with a certificate obtained through Cloudflare's DNS challenge and proxies requests to Open WebUI through Gluetun's shared network namespace.

```text
Client -> EC2:443 -> Traefik -> Gluetun:8080/Open WebUI -> WireGuard -> Ollama
```

#### Public IP and DNS

The default infrastructure uses an Elastic IP so the Cloudflare DNS record
remains valid across EC2 stop/start cycles and service downtime is minimized.

As an alternative, [`ddclient`](../../networking/ddclient/README.md) can
update the Cloudflare DNS record when the instance's dynamically assigned
public IP changes. This avoids reserving an Elastic IP, but introduces a period
of downtime while the instance starts, `ddclient` detects the new address, and
DNS caches expire.

**Local**:
- Ollama is exposed on the LAN (e.g., `http://192.168.1.100:11434`) and is reachable from the EC2 instance through the WireGuard tunnel.

## Prerequisites

- An AWS CLI profile and the SSH key referenced by `public_key_path` (Terraform).
- A Cloudflare zone for `DOMAIN` and an API token that can edit its DNS records.
- A WireGuard server on the local network, with a peer for the EC2 instance.
- Local Ollama listening on an address reachable from the WireGuard client, with only the WireGuard client IP allowed to reach TCP `11434`. The local compose stack can still include Open WebUI for local troubleshooting and permission changes:

  ```yaml
  # Running on local node
  services:
    ollama:
      network_mode: host
  ```

## Setup

### Terraform

The configuration in
[`terraform/aws/ollama-aws-hybrid`](../../terraform/aws/ollama-aws-hybrid/)
creates the AWS resources
for the EC2 host: a VPC, public subnet, internet gateway, route table, security
group, SSH key pair, EC2 instance, encrypted EBS root volume, and Elastic IP.
The EC2 instance uses
[`cloud-init.yaml`](../../terraform/aws/ollama-aws-hybrid/cloud-init.yaml)
to
install Docker and Docker Compose during first boot.

Before starting, configure an AWS CLI profile and create the SSH key referenced
by `public_key_path`. Then create your local variables file:

```shell
cd ../../terraform/aws/ollama-aws-hybrid
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` with `aws_profile`, one or more trusted public IPv4
addresses in `/32` CIDR notation under `trusted_ipv4_cidrs`, and an
`availability_zone_id`. Use an availability-zone ID such as `usw2-az2`, not a
zone name such as `us-west-2b`. Do not commit `terraform.tfvars` or Terraform
state files.

`trusted_ipv4_cidrs` currently allows both SSH and HTTPS access to the EC2
instance. Only include public client IPs that should have that access. For a
broader deployment, split SSH and HTTPS into separate security group inputs.

Review and deploy the infrastructure:

```shell
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

After the apply completes, wait for cloud-init to finish installing Docker,
then use the `public_ip` output to create an `A` record for
`open-webui.${DOMAIN}` in the Cloudflare dashboard. The Elastic IP keeps this
address stable across EC2 stop/start cycles. The `ssh_command` output provides
the command for
connecting to the instance.

To remove the AWS resources when they are no longer needed, review the destroy
plan before confirming it:

```shell
terraform plan -destroy
terraform destroy
```

This project currently uses local Terraform state. That is suitable for an
experimental single-user deployment; shared or production use should move the
state to an encrypted remote backend with locking.

### Ansible

The playbooks in [`ansible/ollama-aws-hybrid/`](../../ansible/ollama-aws-hybrid/) verify the EC2 prerequisites and
deploy the Compose and Traefik configuration. Create a local inventory from the
example and replace the EC2 address and SSH key path:

```shell
cd ../../ansible/ollama-aws-hybrid
cp open-webui-ec2-instance.example.yml open-webui-ec2-instance.yml
```

Create the runtime environment file from the project example, fill in every
placeholder, and encrypt the complete file before running the deployment:

```shell
cp ../../automation/ollama-aws-hybrid/.env.example files/runtime.env
ansible-vault encrypt files/runtime.env
```

The deployment decrypts the file while copying it to the EC2 host
as `/home/ubuntu/ollama-aws-hybrid/.env` with mode `0600`; the remote file is
plaintext and must retain its restrictive permissions.

Verify the host, then prepare the application directory:

```shell
ansible-playbook verify-host.yml
ansible-playbook --ask-vault-pass setup.yml
```

Run `setup.yml` a second time to confirm idempotency. The second run should
report no changes when the deployed configuration is already current.

Deploy the stack:

```shell
ansible-playbook deploy.yml
```

To stop the stack while preserving volumes:

```shell
ansible-playbook teardown.yml
```

### Manual deployment

For a manual deployment, copy `.env.example` to `.env`, replace every
placeholder, ensure Traefik's certificate store is private, and start the
stack:

```shell
mkdir -p letsencrypt && touch letsencrypt/acme.json && chmod 600 letsencrypt/acme.json
docker compose up -d
```

Traefik discovers the route from labels on the Gluetun service. This is
intentional: Open WebUI uses `network_mode: "service:gluetun"`, so it shares
Gluetun's network namespace and is reachable through Gluetun on port `8080`.

## Configuration

`.env` (see [`.env.example`](./.env.example)):

- `VPN_SERVICE_PROVIDER`, `VPN_TYPE` - `custom` and `wireguard` for a self-hosted WireGuard server.
- `WIREGUARD_ENDPOINT_IP` - Public IP of the home WireGuard server. Domain names may not work; use the IP if unsure.
- `WIREGUARD_ENDPOINT_PORT` - WireGuard server port (`51820`).
- `WIREGUARD_PUBLIC_KEY` - The server's public key.
- `WIREGUARD_PRIVATE_KEY` - This client's private key.
- `WIREGUARD_PRESHARED_KEY` - Preshared key (optional).
- `WIREGUARD_ADDRESSES` - This client's tunnel address in CIDR, e.g. `10.0.1.5/32`.
- `WIREGUARD_ALLOWED_IPS` - Networks routed through the tunnel: the home network (e.g. `192.168.1.0/24`) and the health target's IP (`1.1.1.1/32`).
- `WIREGUARD_MTU` - Tunnel MTU (`1380`).
- `HEALTH_TARGET_ADDRESS` - Address Gluetun checks to confirm the tunnel works (`1.1.1.1:443`). Its IP must be in `WIREGUARD_ALLOWED_IPS`.
- `DNS_ADDRESS` - DNS server used by the VPN client (`1.1.1.1`, or a local DNS server).
- `CF_DNS_API_TOKEN` - Cloudflare API token with DNS edit access to the zone (Traefik DNS-01).
- `ACME_EMAIL` - Email for ACME certificate registration.
- `DOMAIN` - Base DNS zone; Open WebUI is served at `open-webui.${DOMAIN}`.
- `OLLAMA_BASE_URL` - URL of the **local** Ollama instance, reached through the tunnel (e.g. `http://192.168.1.100:11434`).
- `WEBUI_SECRET_KEY` - Long, random secret used by Open WebUI to secure sessions.
- `TZ` - Timezone, e.g. `America/Los_Angeles`.

Traefik's static configuration is in [`config/traefik.yml`](./config/traefik.yml). See the full stack in [`docker-compose.yml`](./docker-compose.yml).

## Routing & Ports

```text
Client -> EC2:443 -> Traefik -> Gluetun:8080/Open WebUI -> WireGuard -> Ollama
```

- `443` - The only published port (Traefik, HTTPS). Restrict it to trusted public CIDRs in the Terraform security group. There is no HTTP listener on port 80; certificates use the DNS-01 challenge.
- `open-webui.${DOMAIN}` - Open WebUI. Traefik discovers the route from labels on the Gluetun service: Open WebUI uses `network_mode: "service:gluetun"`, so it shares Gluetun's network namespace and is reachable through Gluetun on port `8080`. Port `3000` is not published.
- Create a DNS `A` record for `open-webui.${DOMAIN}` pointing to the instance's public IP (the Terraform `public_ip` output).

## Data & Backups

- `open-webui` volume - Open WebUI data (users, chats, settings). Back this up if the instance is long-lived.
- `./letsencrypt/acme.json` - Traefik certificates (mode `600`, gitignored).
- `./gluetun` - Gluetun data.
- Terraform state is local to `terraform/aws/ollama-aws-hybrid` (gitignored). Move it to an encrypted remote backend with locking for shared or production use.

## Troubleshooting

- Gluetun keeps restarting or the tunnel is unstable: the health check target's IP must be in `WIREGUARD_ALLOWED_IPS`. The example uses `1.1.1.1/32` for both (which also allows Cloudflare DNS).
- Open WebUI can't reach Ollama: confirm `OLLAMA_BASE_URL` uses the local LAN address, that the address is inside `WIREGUARD_ALLOWED_IPS`, and that the local firewall allows the WireGuard client IP on `11434`.
- The first certificate can take a few minutes after the DNS record is created.
