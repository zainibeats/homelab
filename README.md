# Homelab

Configuration and documentation for my homelab: Docker Compose stacks, infrastructure automation, and [hardware](./hardware/README.md).

> For my build processes, insights, stories, photos, and more, visit my [blog](https://czaini.net/blog).

## Infrastructure Overview

### On-Prem

| Device                     | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| **NAS**                    | Centralized storage and backups               | TrueNAS Scale |
| **Application Server**     | Primary application hosting                   | Ubuntu Server |
| **Raspberry Pi**           | Network services, monitoring and automation   | Raspberry Pi OS Lite |
| **GPU Compute Node**       | Virtual machines, remote desktop and testing  | Proxmox VE |

### Cloud Instances
| Provider                   | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| Oracle                     | Game servers, Matrix, and NetBird server      | Ubuntu Server |
| Azure                      | Jump server                                   | Debian |
| AWS                        | Testing                                       | Ubuntu Server |

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
- **[Utilities](./utilities/README.md)** - General-purpose tools and Matrix chat

**Provisioning**
- **[Terraform](./terraform/README.md)** - Terraform configurations for cloud and Proxmox hosts
- **[Ansible](./ansible/README.md)** - Playbooks for server administration, game hosts, and the Ollama AWS hybrid host

**Conventions:** layout, compose `name:`, example files, and the README template are in [docs/CONVENTIONS.md](./docs/CONVENTIONS.md).

## AI Agents

| Path | Applies to | Contents |
| ---- | ---------- | -------- |
| **[AGENTS.md](./AGENTS.md)** | This repo only | Rules and workflow for agents working here |
| **[.agents](./.agents)** | This repo, reusable anywhere | Skills used here (documentation audits, conventional commits). They're generic, so they can be copied to other repos |
| **[ai-agents](./ai-agents/README.md)** | Other projects, not this repo | Context bundles and skills for tools outside this repo, such as the Obsidian vault |

## Automatic Updates

- **Containers:** [Watchtower](./infrastructure/watchtower/README.md) updates Docker containers daily at 5:00 AM.
- **Host OS:** All Debian-based hosts except Proxmox use `unattended-upgrades` for automatic security updates. TrueNAS and Proxmox are updated manually.
