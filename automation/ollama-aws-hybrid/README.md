# Ollama AWS Hybrid Deployment

> **Experimental** — This is an exploratory setup and not the primary Ollama deployment. For the standard local-only configuration, see [ollama-openwebui](../ollama-openwebui/README.md).

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

**Local**:
- Ollama is exposed on the LAN (e.g., `http://192.168.1.100:11434`) and is reachable from the EC2 instance through the WireGuard tunnel.

## Configuration

**EC2 Instance**:
- `OLLAMA_BASE_URL` must point to the **local** Ollama instance.  
- The EC2 security group should allow TCP port `443` only from your trusted
  public CIDR. Port `3000` is not published by the Compose stack.

_See full configuration [here](./docker-compose.yml)_

**Local**:

- The local compose stack should include Open WebUI to adjust permissions, troubleshoot, etc. 
- Only variation from [standard configuration](../ollama-openwebui/docker-compose.yml) is setting `network_mode: host` in the compose file to make ollama reachable via IP from the EC2 instance.

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
and start the stack:

```shell
docker compose up -d
```

Traefik discovers the route from labels on the Gluetun service. This is
intentional: Open WebUI uses `network_mode: "service:gluetun"`, so it shares
Gluetun's network namespace and is reachable through Gluetun on port `8080`.
