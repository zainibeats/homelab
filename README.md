# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose stacks, infrastructure automation, service documentation, and hardware that powers the environment. Further details about the hardware inventory are available in the [hardware readme](./hardware/README.md).

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

Services are organized into logical categories for easier management and navigation:
- **[Automation](./automation/README.md)** - Home automation and AI platforms
- **[Gaming](./gaming/README.md)** - Game server stacks and runtime documentation
- **[Infrastructure](./infrastructure/README.md)** - Dashboards, version control, and container management
- **[Terraform](./terraform/README.md)** - Terraform configurations for cloud and Proxmox hosts
- **[Ansible](./ansible/README.md)** - Playbooks for server administration, game hosts, and the Ollama AWS hybrid host
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Monitoring](./monitoring/README.md)** - Metrics, logs, and uptime monitoring for home and OCI hosts
- **[Networking](./networking/README.md)** - Reverse proxy, dynamic DNS, and remote access (WireGuard, NetBird)
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Utilities](./utilities/README.md)** - General-purpose tools including file conversion, IT utilities, secret sharing, search, virtual browser, wiki, and Matrix chat

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
