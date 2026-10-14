# Watchtower

Watchtower automates Docker image updates. It watches running containers, pulls new images, and restarts containers when updates are available. This stack runs the maintained `nickfedor/watchtower` fork.

**Runs on:** Every Docker host

## Prerequisites

None beyond Docker.

## Setup

```bash
docker compose up -d
```

To run a one-time update check without waiting for the schedule:

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock nickfedor/watchtower --run-once
```

## Configuration

There is no `.env` file. Settings are in `docker-compose.yml`:

- `WATCHTOWER_SCHEDULE` - `0 0 5 * * *`: daily at 5:00 AM (six-field cron, seconds first), during low-usage hours.
- `TZ` - `America/Los_Angeles`; the schedule runs in this timezone.
- `WATCHTOWER_CLEANUP` - `true`: removes old images after updating.

To exclude a container from updates, add the label `com.centurylinklabs.watchtower.enable=false` to it. The NetBird stacks ([netbird-server](../../networking/netbird-server/README.md), [netbird-client](../../networking/netbird-client/README.md)) use it because their images are pinned and upgraded together.

See the [Watchtower documentation](https://watchtower.nickfedor.com/) for every option.

## Routing & Ports

None. Watchtower runs on its own `watchtower_net` bridge (`172.28.0.0/24`) and publishes no ports.

## Data & Backups

- `/var/run/docker.sock` - Docker API access (required). No persistent data.

## Troubleshooting

- Check what happened on the last run: `docker logs watchtower`.
- A container keeps getting updated when it shouldn't: add the opt-out label above and recreate it.
