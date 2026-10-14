# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose stacks, infrastructure automation, service documentation, and hardware that powers the environment. Further details about the hardware inventory are available in the [hardware readme](./hardware/README.md).

> For my build processes, insights, stories, photos, and more, visit my [blog](https://czaini.net/blog).

## Infrastructure Overview

### On-Prem

| Device                     | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| **NAS**                    | Centralized storage and backups               | TrueNAS Scale |
| **Application Server**     | Primary application hosting                   | Ubuntu Server LTS |
| **Raspberry Pi**           | Network services, monitoring and automation   | Raspberry Pi OS Lite |
| **GPU Compute Node**       | Virtual machines, remote desktop and testing  | Proxmox VE |

### Cloud Instances
| Provider                   | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| Oracle                     | Game servers, Matrix, and NetBird server      | Ubuntu Server LTS |
| Azure                      | Jump server                                   | Debian |

### Host Map

| Host | Stacks |
| --- | --- |
| Application Server | [arr-stack](./media/arr-stack/README.md), [convertx](./utilities/convertx/README.md), [gitea](./infrastructure/gitea/README.md), [home-assistant](./automation/home-assistant/README.md), [immich](./storage/immich/README.md), [invidious](./media/invidious/README.md), [it-tools](./utilities/it-tools/README.md), [jellyfin](./media/jellyfin/README.md), [neko](./utilities/neko/README.md), [nextcloud](./storage/nextcloud/README.md), [portainer](./infrastructure/portainer/README.md), [searxng](./utilities/searxng/README.md), [traefik](./networking/traefik/README.md), [wiki-js](./utilities/wiki-js/README.md), [yopass](./utilities/yopass/README.md) |
| Raspberry Pi | [homepage-admin](./infrastructure/homepage-admin/README.md), [homepage-public](./infrastructure/homepage-public/README.md), [monitoring-home](./monitoring/monitoring-home/README.md), [traefik](./networking/traefik/README.md), [uptime-kuma](./monitoring/uptime-kuma/README.md) |
| NAS | [syncthing](./storage/syncthing/README.md) |
| GPU Compute Node | [ai-stack](./automation/ai-stack/README.md) |
| Desktop | [ai-stack](./automation/ai-stack/README.md), [syncthing](./storage/syncthing/README.md) |
| Oracle (OCI) | [matrix](./utilities/matrix/README.md), [minecraft](./gaming/minecraft/README.md), [monitoring-oci](./monitoring/monitoring-oci/README.md), [netbird-client](./networking/netbird-client/README.md), [netbird-server](./networking/netbird-server/README.md), [palworld](./gaming/palworld/README.md), [valheim](./gaming/valheim/README.md) |
| AWS EC2 | [ollama-aws-hybrid](./automation/ollama-aws-hybrid/README.md) |
| Every Docker host | [watchtower](./infrastructure/watchtower/README.md) |
| Cloud instances without a static IP | [ddclient](./networking/ddclient/README.md) |
| Any other host on the NetBird network (project dependent) | [netbird-client](./networking/netbird-client/README.md) |

OCI and AWS run the Traefik bundled in [netbird-server](./networking/netbird-server/README.md) and [ollama-aws-hybrid](./automation/ollama-aws-hybrid/README.md) instead of the standalone [traefik](./networking/traefik/README.md) stack.

## Project Organization

Compose stacks are grouped by job, one folder per stack. Provisioning code (run from a workstation or control node) lives in its own top-level folders.

**Compose stacks**
- **[Automation](./automation/README.md)** - Home automation and AI platforms
- **[Gaming](./gaming/README.md)** - Game server stacks and runtime documentation
- **[Infrastructure](./infrastructure/README.md)** - Dashboards, version control, and container management
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Monitoring](./monitoring/README.md)** - Metrics, logs, and uptime monitoring for home and OCI hosts
- **[Networking](./networking/README.md)** - Reverse proxy, dynamic DNS, and remote access (WireGuard, NetBird)
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Utilities](./utilities/README.md)** - General-purpose tools including file conversion, IT utilities, secret sharing, search, virtual browser, wiki, and Matrix chat

**Provisioning**
- **[Terraform](./terraform/README.md)** - Terraform configurations for cloud and Proxmox hosts
- **[Ansible](./ansible/README.md)** - Playbooks for server administration, game hosts, and the Ollama AWS hybrid host

**Conventions**
- Every compose file pins `name:`, so renaming a folder never renames its volumes. Gitignored live compose copies must keep the same `name:` line (e.g. `monitoring/monitoring-home/docker-compose.yml`).
- Example files are `<file>.example.<ext>` (env files: `.env.example`, `<name>.env.example`; Terraform: `terraform.tfvars.example`). Copy them without `.example` and fill them in; the live copies are gitignored.

## AI Agents
This repository includes an AI agent framework located in the `.agents` directory. 
- **[AGENTS.md](./AGENTS.md)** - Core rules, behaviors, and instructions for the AI agents.
- **[.agents](./.agents)** - Contains specialized skills and configurations used by the agents to perform tasks like documentation audits and conventional commit generation.
- **[ai-agents](./ai-agents/README.md)** - Agent context and skills for tools outside this repo (e.g. the Obsidian vault).

## Storage Overview

Storage is provided by a dedicated NAS (TrueNAS Server) and separated by category. Media, application data, backups, virtual machine storage, etc. are organized into separate datasets and shares.

## Automatic Updates

Utilizing **Watchtower** for automatic Docker container updates.

I've configured it to run daily at 5:00 AM to minimize disruption during peak usage hours. See the [Watchtower documentation](./infrastructure/watchtower/README.md) for configuration details and usage instructions.
