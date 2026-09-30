# NetBird Server

My self-hosted NetBird control plane: the combined server, the dashboard, the NetBird Proxy with CrowdSec, and Traefik. It started as the output of NetBird's [one-line installer](https://docs.netbird.io/selfhosted/selfhosted-quickstart), version 0.79.0 (answers: built-in Traefik, proxy on, CrowdSec on). That script is kept here as [`getting-started-v0.79.0.sh`](./getting-started-v0.79.0.sh) for diffing and is never run.

## Changes from the installer output

- This stack creates the `services` network (`SERVICES_SUBNET`), and Traefik joins it at `TRAEFIK_SERVICES_IP` (`10.110.2.20`). [netbird-client](../netbird-client/README.md) routes the network to peers. [Matrix](../matrix/README.md) and the game servers sit on it.
- A second resolver, `letsencrypt-dns`, handles DNS-01 through Cloudflare. It covers NetBird-only hostnames, which resolve to private IPs. The token goes in `cloudflare-dns-token` (`Zone:DNS:Edit`, `chmod 600`).
- The NetBird images are pinned and excluded from Watchtower.
- Domain and ACME email come from `.env`. `name: netbird` keeps the installer's volume and network names (`netbird_netbird_data`, `netbird_netbird`).
- The installer hard-codes Traefik's internal IP as `172.30.0.10`. It's also in `config.yaml`, `proxy.env` and Matrix's lk-jwt-service `extra_hosts`.

## Host

- **ufw:** deny all incoming, allow `22/tcp` from anywhere. Docker's published ports bypass ufw, so the NetBird ports don't need ufw rules.
- **OCI security list** (see [free-tier-host](../terraform/oci/free-tier-host/README.md#firewall)):
  - `22/tcp` from the control node or jump server only.
  - `80/tcp`, `443/tcp`, `3478/udp` and `51820/udp` from anywhere.
- **DNS** (Cloudflare, DNS only):
  - `NETBIRD_DOMAIN` → the public IP.
  - The Matrix hostnames → `10.110.2.20`.

## Setup

The order is: this stack → [netbird-client](../netbird-client/README.md) (`SERVICES_EXTERNAL=true`) → Matrix and game stacks.

1. Copy `.env.example`, `config.yaml.example` (`chmod 600`), `dashboard.env.example` and `proxy.env.example` without the `.example` suffix. Replace `netbird.domain.tld` in all of them.
2. Fill in the `config.yaml` secrets:
   - `authSecret`: `openssl rand -base64 32 | sed 's/=//g'`
   - `sessionCookieEncryptionKey`: `openssl rand -base64 32`
   - `encryptionKey`: `openssl rand -base64 32`. It encrypts the store, so back it up.
3. Create `cloudflare-dns-token` and `mkdir crowdsec`.
4. `docker compose up -d traefik dashboard netbird-server crowdsec`
5. Fill in `proxy.env`:
   - `NB_PROXY_TOKEN`: the `Token:` line from `docker compose exec netbird-server /go/bin/netbird-server admin token create --name default-proxy --config /etc/netbird/config.yaml`
   - `NB_PROXY_CROWDSEC_API_KEY`: the output of `docker compose exec crowdsec cscli bouncers add netbird-proxy -o raw`
6. `docker compose up -d proxy`, then open `https://NETBIRD_DOMAIN` and create the owner account.

In the dashboard:

- **Setup key** for netbird-client ([docs](https://docs.netbird.io/manage/peers/register-machines-using-setup-keys)).
- **Network** with a resource for `SERVICES_SUBNET`, netbird-client as routing peer and masquerade on ([docs](https://docs.netbird.io/manage/networks)).
- **Access policy** from my user group to that resource ([docs](https://docs.netbird.io/manage/access-control)):

  | Protocol | Ports | For |
  |----------|-------|-----|
  | TCP | 443, 7881 | Matrix through Traefik, LiveKit TCP fallback |
  | UDP | 7882 | LiveKit media |
  | TCP | 25565 | Minecraft |
  | UDP | 8211, 27015 | Palworld |
  | UDP | 2456-2458 | Valheim |

## Upgrading

Follow the [official upgrade steps](https://docs.netbird.io/selfhosted/maintenance/upgrade): back up, read the release notes, and keep the proxy and management versions in sync. Because the tags here are pinned, also do the following:

1. Diff the installer against the new release:
   ```sh
   curl -fsSLo new.sh https://github.com/netbirdio/netbird/releases/download/vX.Y.Z/getting-started.sh
   diff getting-started-v0.79.0.sh new.sh
   ```
2. Carry over any changes to the compose, `config.yaml` or env templates.
3. Bump `netbird-server`, `reverse-proxy` and netbird-client's `netbird` together, plus the matching dashboard release.
4. Replace the kept script with the new one.

## Migrating from `~/services/netbird`

The live server still runs from where the installer put it in May. It differs from this copy in three ways:

- Its `config.yaml` has no `trustedPeers` (same value as `trustedHTTPProxies`) or `sessionCookieEncryptionKey`.
- Its compose is missing the `/management.ProxyService/` gRPC route.
- Its `services` network belongs to the netbird-client project, so it has to be recreated under this one. That means stopping everything attached to it.

To migrate:

1. Stop Matrix, the game stacks, netbird-client and the old stack.
2. `docker network rm services`
3. `sudo cp -a` `config.yaml`, `dashboard.env`, `proxy.env`, `cloudflare-dns-token` and `crowdsec/` into this directory, then add the two missing keys.
4. Bring everything back up in setup order.

The volumes are reused as they are.
