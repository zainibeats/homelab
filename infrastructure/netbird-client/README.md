# NetBird Client

NetBird Client provides a lightweight VPN client that connects your host to the NetBird mesh network, enabling secure remote access and service discovery across my homelab and/or game servers.

It's also the routing peer for the `services` Docker network. Containers with a static IP on it are reachable by NetBird peers once the subnet is a [network resource](https://docs.netbird.io/manage/networks) routed by this client.

## Configuration

| Variable | Description |
|----------|-------------|
| `HOSTNAME` | Host name to register in NetBird. |
| `NB_SETUP_KEY` | NetBird setup key for onboarding the client. |
| `NB_MANAGEMENT_URL` | URL of the NetBird management server (e.g. `https://netbird.domain.tld`). |
| `SERVICES_SUBNET`, `SERVICES_GATEWAY`, `NETBIRD_CLIENT_IP` | The `services` network and this client's IP on it. All three are required. The subnet must be private and must not overlap any NetBird client's networks, so use a different one per host. |
| `SERVICES_EXTERNAL` | Set to `true` on the host running [netbird-server](../netbird-server/README.md), which creates `services` itself. |

All variables are supplied via `.env` (copy `.env.example`).

## Deployment

```sh
docker compose up -d
```

The image is pinned to the NetBird server's version and excluded from Watchtower, so [upgrade them together](../netbird-server/README.md#upgrading).

## Usage

Once running, your host becomes part of the NetBird mesh. You can verify connectivity with:

```sh
docker exec netbird-client netbird status
```

or by checking the NetBird dashboard for the new node.

---

*For advanced options (e.g., custom certificates or policy configuration), refer to the official [NetBird documentation](https://docs.netbird.io).*
