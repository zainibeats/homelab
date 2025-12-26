# Watchtower

Watchtower is a process for automating Docker container base image updates. It monitors running containers and automatically pulls new images and restarts containers when updates are available.

## Configuration

### Automatic Updates Schedule

This Watchtower instance is configured to run automatically at **5:00 AM daily** using the cron schedule `0 0 5 * * *`. This ensures updates happen during low-usage hours to minimize service disruption.

## Usage

### Starting Watchtower

```bash
# Start Watchtower with the configured schedule
docker-compose up -d
```

### Manual Updates

To trigger an immediate update check without waiting for the scheduled time:

```bash
# Run a one-time update check
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once
```

## Documentation

For more advanced configuration options and features, visit the [official Watchtower documentation](https://containrrr.dev/watchtower/).
