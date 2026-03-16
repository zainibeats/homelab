# Tools & Utilities

This directory contains various utility services that enhance the homelab functionality, from secret sharing to file synchronization and local AI.

## Services Overview

### File operations

- **[ConvertX](./convertx/README.md)** - Simple file conversion service with a web interface for converting between various file formats
- **[Syncthing](./syncthing/README.md)** - Continuous file synchronization program that synchronizes files between two or more computers in real time

### Version Control

- **[Gitea](./gitea/README.md)** - Lightweight, self‑hosted Git service offering a web UI, SSH, REST API, package registry, and CI/CD, all packaged in a single Docker container

### Dashboard

- **[Homepage](./homepage/README.md)** - Highly‑customizable dashboard that aggregates over 100 service APIs, runs in Docker, and serves a static web UI on port 3000 inside the container

### Virtual Browser 

- **[Neko](./neko/README.md)** - Virtual browser with VPN integration for watch parties, remote access, collaborative browsing, etc.


### AI & Machine Learning

- **[Ollama + Open WebUI AWS Deployment](./ollama-aws-hybrid/README.md)** - Hybrid deployment of a local Ollama instance exposed to Open WebUI on an AWS EC2 instance via a Gluetun WireGuard tunnel.
- **[Ollama + Open WebUI](./ollama-openwebui/README.md)** - Run large language models locally with Ollama and interact with them through a user-friendly web interface

### Secret Sharing

- **[Yopass](./yopass/README.md)** - Secure, self‑hosted secret‑sharing platform that encrypts data client‑side, stores it temporarily in Memcached, and returns a one‑time URL that expires automatically
