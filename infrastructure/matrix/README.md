# Matrix

Private Matrix homeserver (Synapse) with Element Web and Element Call / MatrixRTC calls through LiveKit. It sits behind NetBird's Traefik and is reachable only by NetBird peers. Federation is disabled and accounts are created by the admin.

## Architecture

| Service | Purpose | Reached at |
|---------|---------|------------|
| `synapse` + `synapse-postgres` | Homeserver and database | `https://MATRIX_HOST` |
| `element-web` | Web client | `https://CHAT_HOST` |
| `livekit` | SFU for calls | `https://RTC_HOST/livekit/sfu` (signalling), `LIVEKIT_IP` 7881/tcp and 7882/udp (media) |
| `lk-jwt-service` | Issues LiveKit tokens to Matrix users | `https://RTC_HOST/livekit/jwt` |

- NetBird routes the `services` Docker network (created by [netbird-client](../netbird-client/README.md), which is the routing peer) to your peers.
- Traefik joins `services` with a static IP. The three hostnames point there, and every router uses an IP allowlist (`ALLOWED_RANGES`).
- LiveKit has a static IP on `services` and publishes no ports. Nothing is exposed on the public interface.

## Prerequisites

- **Routed network:** the netbird-client stack with `SERVICES_SUBNET` set to a **private** subnet that doesn't overlap any client's local or Docker networks (e.g. `10.110.2.0/24`).
- **Traefik:** NetBird's Traefik joined to `services` with a static IP (e.g. `10.110.2.20`) and a DNS-01 resolver (Cloudflare) named as in `TRAEFIK_CERTRESOLVER`.
- **NetBird:** a network resource for the subnet with netbird-client as routing peer and masquerade on, plus a policy allowing your group TCP 443, TCP 7881 and UDP 7882.
- **DNS:** Cloudflare A records for the three hostnames pointing to Traefik's IP on `services`, DNS only.

## Setup

1. Copy `.env.example` to `.env` and fill it in. Set `rtc.node_ip` in `livekit/livekit.yaml` to `LIVEKIT_IP`, and put `MATRIX_HOST` in `element/config.json`.
2. Generate the Synapse signing key and log config once. Type the server name literally; an unset shell variable produces broken, nameless files.
   ```sh
   docker run --rm -v "$PWD/synapse:/data" -e SYNAPSE_SERVER_NAME=matrix.domain.tld -e SYNAPSE_REPORT_STATS=no matrixdotorg/synapse:latest generate
   ```
3. Replace `synapse/homeserver.yaml` with `homeserver.yaml.template` and fill in every `CHANGE_ME_*`. The database password is `POSTGRES_PASSWORD`; generate the other secrets with `openssl rand -hex 32`.
4. `sudo chown -R 991:991 synapse`
5. `docker compose up -d`
6. Create accounts (registration is disabled). Add `-a` for an admin:
   ```sh
   docker exec -it synapse register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
   ```

## Verify

From a container on `services`:

```sh
docker run --rm --network services curlimages/curl -s --resolve matrix.domain.tld:443:10.110.2.20 https://matrix.domain.tld/.well-known/matrix/client
docker run --rm --network services curlimages/curl -s -o /dev/null -w '%{http_code}\n' --resolve rtc.domain.tld:443:10.110.2.20 https://rtc.domain.tld/livekit/jwt/healthz
```

The well-known response must contain `org.matrix.msc4143.rtc_foci`.

## Notes

- `server_name` (`MATRIX_HOST`) is permanent once users exist.
- Keep `log_config` pointing at the console log config from step 2. A log file path outside `/data` makes Synapse crash-loop on permissions.
- Clients need NetBird running on the device itself. A NetBird container on a workstation doesn't route that host's browser.
- Some routers block DNS answers that point to private IPs (DNS rebinding protection). Whitelist the domain if the names don't resolve.
- The `netbird-only` allowlist middleware is defined on the `synapse` container. While Synapse is down, the other routers fail closed.
