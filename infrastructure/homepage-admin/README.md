# Homepage (Admin)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the administrator instance; the public instance is [Homepage (Public)](../homepage-public/README.md).

## Ports

- `3330` - Admin dashboard URL.

## Volumes

- `./config:/app/config` - Holds all YAML config files (`services.yaml`, `settings.yaml`, etc.).

## Troubleshooting

If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
