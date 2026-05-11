# NetBird Client

NetBird Client provides a lightweight VPN client that connects your host to the NetBird mesh network, enabling secure remote access and service discovery across my homelab and/or game servers.

## Configuration

| Variable | Description |
|----------|-------------|
| `HOSTNAME` | Host name to register in NetBird. Defaults to container hostname if unset. |
| `SETUP_KEY` | NetBird setup key for onboarding the client. |
| `NB_MANAGEMENT_URL` | URL of the NetBird management server. |

All variables are supplied via `.env` or Docker Compose.

## Deployment

```sh
docker compose up -d
```

The container mounts a named volume (`netbird-client`) to persist configuration and state across restarts.

## Usage

Once running, your host becomes part of the NetBird mesh. You can verify connectivity with:

```sh
docker exec netbird-client nb status
```

or by checking the NetBird dashboard for the new node.

---

*For advanced options (e.g., custom certificates or policy configuration), refer to the official [NetBird documentation](https://docs.netbird.io).*
