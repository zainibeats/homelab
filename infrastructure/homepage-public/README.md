# Homepage (Public)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the public instance; the admin instance is [Homepage (Admin)](../homepage-admin/README.md).

<img src="https://assets.czaini.net/images/homepage-clip.jpg" height="75%" width="75%" />

## Ports

- `7575` - Public dashboard URL (e.g. `http://localhost:7575`).

## Volumes

- `./config:/app/config` - Holds all YAML config files (`services.yaml`, `settings.yaml`, etc.).

## Troubleshooting

If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
