# Matrix

Private Matrix homeserver (Synapse) with Element Web and Element Call / MatrixRTC calls through LiveKit. It sits behind NetBird's Traefik and is reachable only by NetBird peers. Federation is disabled and accounts are created by the admin.

| Service | Purpose | Reached at |
|---------|---------|------------|
| `synapse` + `synapse-postgres` | Homeserver and database | `https://MATRIX_HOST` |
| `element-web` | Web client | `https://CHAT_HOST` |
| `livekit` | SFU for calls | `https://RTC_HOST/livekit/sfu` (signalling), `LIVEKIT_IP` 7881/tcp and 7882/udp (media) |
| `lk-jwt-service` | Issues LiveKit tokens to Matrix users | `https://RTC_HOST/livekit/jwt` |

**Runs on:** Oracle (OCI)

## Prerequisites

Deploy in this order: [netbird-server](../../networking/netbird-server/README.md#setup) → [netbird-client](../../networking/netbird-client/README.md) → this stack. That gives you:

- **Routed network:** `services` (`10.110.2.0/24`) with netbird-client as routing peer, masquerade on, and a policy allowing your group TCP 443, TCP 7881 and UDP 7882.
- **Traefik:** on `services` at `10.110.2.20`, with the `letsencrypt-dns` resolver named in `TRAEFIK_CERTRESOLVER`.
- **DNS:** Cloudflare A records for the three hostnames pointing to Traefik's IP on `services`, DNS only.

## Setup

1. Copy `.env.example` to `.env` and `element/config.example.json` to `element/config.json`, and fill them in (`MATRIX_HOST` goes in `config.json`). Set `rtc.node_ip` and `rtc.ips.includes` in `livekit/livekit.yaml` to `LIVEKIT_IP`.
2. Generate the Synapse signing key and log config once. Type the server name literally; an unset shell variable produces broken, nameless files.
   ```sh
   docker run --rm -v "$PWD/synapse:/data" -e SYNAPSE_SERVER_NAME=matrix.domain.tld -e SYNAPSE_REPORT_STATS=no matrixdotorg/synapse:latest generate
   ```
3. Replace `synapse/homeserver.yaml` with `homeserver.example.yaml` and fill in every `CHANGE_ME_*`. The database password is `POSTGRES_PASSWORD`; generate the other secrets with `openssl rand -hex 32`.
4. `sudo chown -R 991:991 synapse`
5. `docker compose up -d`
6. Create accounts (registration is disabled). Add `-a` for an admin:
   ```sh
   docker exec -it synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
   ```
7. Verify from a container on `services`:
   ```sh
   docker run --rm --network services curlimages/curl -s --resolve matrix.domain.tld:443:10.110.2.20 https://matrix.domain.tld/.well-known/matrix/client
   docker run --rm --network services curlimages/curl -s -o /dev/null -w '%{http_code}\n' --resolve rtc.domain.tld:443:10.110.2.20 https://rtc.domain.tld/livekit/jwt/healthz
   ```
   The well-known response must contain `org.matrix.msc4143.rtc_foci`.

## Configuration

- `MATRIX_HOST`, `CHAT_HOST`, `RTC_HOST` - Hostnames for Synapse, Element Web, and LiveKit. Cloudflare A records → Traefik's IP on `services` (DNS only). `MATRIX_HOST` is also the permanent `server_name`.
- `LIVEKIT_IP` - LiveKit's static IP on `services`. Must match `rtc.node_ip` in `livekit/livekit.yaml`.
- `ALLOWED_RANGES` - Who may connect through Traefik: NetBird peers, the routed network (masqueraded NetBird traffic), and Docker containers (lk-jwt-service calls back through Traefik).
- `TRAEFIK_NETWORK` - Docker network of NetBird's Traefik (`netbird_netbird`).
- `TRAEFIK_ENTRYPOINT` - Traefik entrypoint (`websecure`).
- `TRAEFIK_CERTRESOLVER` - Must use DNS-01 (`letsencrypt-dns`): the hostnames resolve to a private IP, so TLS/HTTP challenges can't validate.
- `POSTGRES_PASSWORD` - Postgres password (`openssl rand -hex 24`).
- `LIVEKIT_KEY`, `LIVEKIT_SECRET` - LiveKit API key pair (`docker run --rm livekit/livekit-server:latest generate-keys`).

Other config files: `synapse/homeserver.yaml` (from `homeserver.example.yaml`), `element/config.json`, `livekit/livekit.yaml`.

## Routing & Ports

- `https://MATRIX_HOST`, `https://CHAT_HOST`, `https://RTC_HOST/livekit/{sfu,jwt}` - Through NetBird's Traefik. Every router uses the `netbird-only` IP allowlist (`ALLOWED_RANGES`).
- LiveKit media: `LIVEKIT_IP` `7881/tcp` and `7882/udp`, reached directly over `services`.
- No published ports; nothing is exposed on the public interface.
- The `services` Docker network is created by [netbird-server](../../networking/netbird-server/README.md) and routed to peers by [netbird-client](../../networking/netbird-client/README.md).

## Data & Backups

- `./synapse` → `/data` - Synapse config, signing key, and media. Back this up; the signing key can't be regenerated without breaking the server identity.
- `./postgres-data` - Postgres data (messages, accounts). Back up with `pg_dump` or while stopped.
- `.env`, `element/config.json` - Live config (gitignored).

## Troubleshooting

- `server_name` (`MATRIX_HOST`) is permanent once users exist.
- Keep `log_config` pointing at the console log config from step 2. A log file path outside `/data` makes Synapse crash-loop on permissions.
- Clients need NetBird running on the device itself. A NetBird container on a workstation doesn't route that host's browser.
- Some routers block DNS answers that point to private IPs (DNS rebinding protection). Whitelist the domain if the names don't resolve.
- The `netbird-only` allowlist middleware is defined on the `synapse` container. While Synapse is down, the other routers fail closed.
