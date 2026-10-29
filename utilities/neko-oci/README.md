# Neko (OCI)

Neko is a self-hosted virtual browser (Brave) streamed to your web browser over WebRTC. This variant runs on the ARM OCI host for watch parties: CPU encoding, browsing routed through a VPN with Gluetun, and reachable only by NetBird peers through NetBird's Traefik. The NVIDIA version is in [neko](../neko/README.md).

**Runs on:** the OCI host (must share the `services` network with netbird-server)

## Prerequisites

- [netbird-server](../../networking/netbird-server/README.md) and [netbird-client](../../networking/netbird-client/README.md) running, with `services` routed to peers and Traefik on it.
- `UDP 52000` in the NetBird access policy for the `services` resource (see the policy table in netbird-server).
- A Cloudflare A record for `NEKO_HOST` → Traefik's IP on `services` (DNS only).
- A WireGuard private key from a VPN provider supported by Gluetun (e.g. ProtonVPN).

## Setup

```bash
cp .env.example .env
# fill in .env, then:
env -u HOSTNAME -u TZ docker compose up -d
```

Check the route and certificate from a container on `services`:

```bash
docker run --rm --network services curlimages/curl -s -o /dev/null -w '%{http_code}\n' --resolve neko.domain.tld:443:10.110.2.20 https://neko.domain.tld/
```

## Configuration

- `TZ` - Timezone, e.g. `America/Los_Angeles`.
- `NEKO_HOST` - Hostname for the web UI.
- `NEKO_IP` - Neko's static IP on `services`, also advertised to WebRTC clients (NAT1TO1).
- `ALLOWED_RANGES` - Who may connect through Traefik: NetBird peers and the routed network (masqueraded NetBird traffic).
- `TRAEFIK_ENTRYPOINT` - Traefik's HTTPS entrypoint (`websecure`).
- `TRAEFIK_CERTRESOLVER` - A DNS-01 resolver (`letsencrypt-dns`); the hostname resolves to a private IP.
- `VPN_SERVICE_PROVIDER` - Gluetun provider, e.g. `protonvpn` ([providers](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers)).
- `WIREGUARD_PRIVATE_KEY` - WireGuard private key from the provider.
- `SERVER_COUNTRIES` - Exit countries, e.g. `United States`.
- `NEKO_MEMBER_MULTIUSER_USER_PASSWORD` - Password for guests.
- `NEKO_MEMBER_MULTIUSER_ADMIN_PASSWORD` - Password for the admin.

Fixed in the compose file: Brave `3.2.0` and Gluetun `v3.41.3`, both pinned (Watchtower only pulls the same tag; upgrade them together by hand), WireGuard, H.264 (x264) at `1280x720@30`, multiuser auth, WebRTC on one UDP mux port `52000` with ICE-lite, file transfer off, and limits of 3 CPUs and 6 GB for Neko.

## Routing & Ports

- Neko shares Gluetun's network namespace. Gluetun holds `NEKO_IP` on `services` and carries the Traefik labels; everything else leaves through the VPN, and nothing does while the VPN is down.
- `https://NEKO_HOST` - Through NetBird's Traefik, with the `neko-netbird-only` IP allowlist (`ALLOWED_RANGES`).
- WebRTC media: `NEKO_IP` `52000/udp`, reached directly over `services`.
- Gluetun's firewall allows inbound `8080` (Traefik) and `52000` (WebRTC) via `FIREWALL_INPUT_PORTS`.
- No published ports; nothing is exposed on the public interface.

## Data & Backups

- `home` volume (`neko-oci_home`) → `/home/neko`: the Brave profile (settings, logins, extensions). Back it up if you keep logins in it.
- `gluetun` volume (`neko-oci_gluetun`) → `/gluetun`: Gluetun's server list cache. Nothing to back up.

## Troubleshooting

- Neko never starts: it waits for Gluetun's health check. Check `docker logs neko-oci-gluetun` for VPN errors.
- Neko has no network after Gluetun was recreated: the old namespace is gone. Run `env -u HOSTNAME -u TZ docker compose up -d --force-recreate neko`.
- Gluetun fails with "address already in use" on `up`: the old Neko container still holds `NEKO_IP`. Stop Neko first, then `up -d`.
- Page loads but video stays black: `UDP 52000` is missing from the NetBird policy, `NEKO_IP` doesn't match Gluetun's address, or `52000` isn't in `FIREWALL_INPUT_PORTS`.
- High CPU while playing: the site is sending more than 720p, which Brave decodes in software. Set the player to 720p or lower.
- Brave relaunched from its own settings runs detached from supervisord (`supervisorctl -c /etc/neko/supervisord.conf status` shows `brave FATAL`). It keeps working until it closes; restart the container to put it back under supervisord.
- Brave won't start and `/var/log/neko/brave.log` says the profile is in use "on another computer": a stale profile lock from an older container. Delete `SingletonLock`, `SingletonCookie` and `SingletonSocket` in `/home/neko/.config/brave`, then restart the container. The fixed `hostname:` (set on Gluetun, which Neko inherits) normally lets Brave clear the lock itself.
- See the [Neko documentation](https://neko.m1k1o.net/docs/v3/quick-start).
