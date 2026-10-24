# NetBird Client

NetBird Client connects the host to the NetBird mesh network, giving secure remote access to the homelab and game servers.

It is also the routing peer for the `services` Docker network. Containers with a static IP on it are reachable by NetBird peers once the subnet is a [network resource](https://docs.netbird.io/manage/networks) routed by this client.

**Runs on:** any host on the NetBird network (always on the OCI host)

## Prerequisites

- A running [NetBird Server](../netbird-server/README.md) and a setup key from its dashboard.
- A private `/24` for the `services` network that is unique per host and doesn't overlap any NetBird client's local or Docker networks.

## Setup

```shell
cp .env.example .env
# fill in .env, then:
docker compose up -d
```

On the host running [netbird-server](../netbird-server/README.md), start that stack first and set `SERVICES_EXTERNAL=true` here.

## Configuration

| Variable | Description |
|----------|-------------|
| `HOSTNAME` | Host name to register in NetBird (passed as `NB_HOSTNAME`). |
| `NB_SETUP_KEY` | NetBird setup key for onboarding the client. |
| `NB_MANAGEMENT_URL` | URL of the NetBird management server (e.g. `https://netbird.domain.tld`). |
| `SERVICES_SUBNET` | Subnet of the `services` network (required). |
| `SERVICES_GATEWAY` | Gateway of the `services` network (required). |
| `NETBIRD_CLIENT_IP` | This client's static IP on `services` (required). |
| `SERVICES_EXTERNAL` | `true` on the host running netbird-server, which creates `services` itself (`SERVICES_SUBNET` must then match that stack's `.env`). Defaults to `false`. |

## Routing & Ports

- No published ports.
- Creates the `services` bridge network (or joins it when `SERVICES_EXTERNAL=true`). Matrix, the game servers, and other stacks attach to it at static IPs.

## Data & Backups

- `./netbird` → `/var/lib/netbird` - Client identity and state (root-owned). Back it up to keep the same peer identity after a rebuild.

## Troubleshooting

- Check connectivity: `docker exec netbird-client netbird status`, or look for the node in the NetBird dashboard.
- The image is pinned to the NetBird server's version and excluded from Watchtower, so [upgrade them together](../netbird-server/README.md#upgrading).
- The peer registers under the wrong name: a `HOSTNAME` exported by your shell overrides `.env`. Start it with `env -u HOSTNAME docker compose up -d`.
- On the netbird-server host, peers reach this client over the relay (`rels://` in `netbird status -d`), not directly: the container publishes no UDP port, and its STUN probe to the host's own public IP times out. That's expected.
- For advanced options (custom certificates, policies), see the [NetBird documentation](https://docs.netbird.io).
