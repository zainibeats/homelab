# CML Automation Lab

An agent skill that builds a small [Cisco Modeling Labs](https://developer.cisco.com/modeling-labs/) lab for practicing network automation on CML-Free. You end up with real Cisco IOS devices you can SSH into, plus an Ubuntu automation box with Python (Netmiko, Paramiko) and Ansible ready to use. How you automate them is up to you: Python scripts, Ansible playbooks, Bash, or SSH and the CLI by hand.

The skill is a portable [`SKILL.md`](SKILL.md), so any agent that supports skills and MCP servers can run it.

## What You Get

```
your LAN ── ext-conn-0 ── unmanaged-switch-0 ─┬─ sw1 (IOSvL2, the default)
                                              ├─ sw2 / r1 ... (optional, up to 4 Cisco devices)
                                              └─ host (Ubuntu automation box)
```

- **Cisco devices:** one IOSvL2 switch by default. The skill can build up to four devices of any Cisco IOS type your CML has an image for. Each one gets:
  - a hostname
  - an `admin` user
  - SSH v2 as the only way in on the vty lines
  - a management IP from DHCP
  - its config saved
- **`host`:** Ubuntu 24.04 with a Python virtualenv (`~/venv`, activated at login) containing Netmiko, Paramiko 4.x and Ansible, which includes the `cisco.ios` collection. It's useful when:
  - your own machine can't reach the lab, or runs Windows
  - you want a throwaway place to install things
  - you want to schedule jobs inside the lab
- **External Connector:**
  - **Bridge mode:** nodes join your LAN and are reachable from your machine.
  - **NAT mode:** nodes are reachable only from inside CML, so you work from `host`.

CML-Free runs at most 5 nodes at once. `host` counts towards that and the Unmanaged Switch and External Connector don't, so the lab can hold up to 4 Cisco devices.

## Prerequisites

- CML-Free installed and running, with its web UI reachable from your machine.
- For bridge mode on VMware Workstation with a Linux host: your user needs read/write access to `/dev/vmnet*` (see [Troubleshooting](#troubleshooting)).
- An agent that supports MCP servers and skills, such as Claude Code.
- [uv](https://docs.astral.sh/uv/), because the MCP server runs with `uvx`.
- Internet access from the lab, because `host` downloads its Python packages on first boot.

Built with CML 2.10.1 in VMware Workstation on a Linux host, using cml-mcp 0.32.2, the `iosvl2-2020` image and the `ubuntu-24-04-20260307` image.

## Setup

### 1. Connect the CML MCP server

The skill controls CML through [cml-mcp](https://github.com/xorrkaz/cml-mcp). It needs the `pyats` extra. Without it, the server can't send console commands, and every configuration step fails.

Copy the `mcpServers` block from [`mcp.example.json`](mcp.example.json) into your agent's MCP config, then fill in your CML URL and login:
- **Claude Code:** put it in `.mcp.json` in the folder you start Claude from, or add the server at user scope (see `claude mcp --help`).
- **Other agents:** use the same block in their own config file.

This config contains your CML password, so keep it out of git. Use a config file outside any repo, or if you use a project-level `.mcp.json`, don't commit it.

Restart the agent and ask it to check CML's status to confirm it's connected.

### 2. Install the skill

- **Claude Code:** from this folder, link it into your skills directory with `ln -s "$PWD" ~/.claude/skills/cml-automation-lab`.
- **Other agents:** copy or link this folder to wherever your agent loads skills from.

### 3. Set the lab password

```bash
cp .env.example .env
```

Set `LAB_ADMIN_PASSWORD` in `.env`. The skill reads `.env` from the folder you run the agent in first, then from this folder. If it finds neither, it asks you. `.env` is gitignored, and your own scripts can read the same file.

`.env` keeps the password out of the chat and out of git, but not away from the agent: it still has to type the password into the device config.

## Configuration

`.env`:

- `LAB_ADMIN_PASSWORD`: password for the `admin` user on the Cisco devices.

MCP server config:

- `CML_URL`: your CML address, for example `https://192.168.1.50`.
- `CML_USERNAME` / `CML_PASSWORD`: your CML web UI login.
- `CML_VERIFY_SSL`: `false` for CML's default self-signed certificate.
- `PYATS_USERNAME` / `PYATS_PASSWORD` (optional): the console login the server uses for every node. The default `cisco`/`cisco` matches `host`.

Lab logins:

| Node | Username | Password |
|---|---|---|
| Cisco devices | `admin` | `LAB_ADMIN_PASSWORD` |
| `host` | `cisco` | `cisco` |

`host` uses CML's default Ubuntu login because the MCP server logs into every node's console with that one login. In bridge mode, that means a weak SSH login on your LAN. To change it, edit `password:` in the skill's cloud-init and set `PYATS_PASSWORD` to match.

## Usage

Ask your agent to "build me a CML automation lab", or in Claude Code, run `/cml-automation-lab`. The skill:
1. checks CML
2. asks for the lab title, how many Cisco devices and of which type, and the connector mode
3. shows the plan and waits for your go-ahead
4. builds and starts the lab, then configures the devices over their consoles
5. verifies everything and reports the IP addresses and logins

The first build takes a while: IOSvL2 needs a few minutes to boot, and `host` installs its packages on first boot.

**Reaching the lab:**

- **Devices, from your machine (bridge mode):** `ssh admin@<device-ip>`. IOSv and IOSvL2 need extra options with modern OpenSSH (see [Troubleshooting](#troubleshooting)).
- **`host`:** `ssh cisco@<host-ip>` in bridge mode, or its console in the CML web UI in either mode.

**Start, stop and wipe:**

- Use the lab's controls in the CML web UI, or ask the agent.
- **Stop** powers the nodes off. The devices keep their saved config, and `host` keeps its disk.
- **Wipe** resets every node to a blank state. Afterwards, ask the agent to configure the devices again.

All IP addresses come from DHCP and can change after a restart. A DHCP reservation on your router keeps them stable.

## Troubleshooting

**"PyATS and Genie are required to send commands to running devices."**

The MCP server was installed without the `pyats` extra. Use the `--from cml-mcp[pyats]` args from [`mcp.example.json`](mcp.example.json), then restart the agent.

**Bridge mode: devices get an IP but can't reach anything, and `host` never gets an IP**

VMware Workstation on a Linux host drops frames addressed to the lab nodes unless the CML VM can use promiscuous mode, and that needs read/write access to `/dev/vmnet*`. DHCP half works: IOS asks for a broadcast reply, which gets through, but Ubuntu asks for a unicast reply, which doesn't. To fix it:

```bash
sudo chgrp <your-group> /dev/vmnet*
sudo chmod g+rw /dev/vmnet*
```

Then shut the CML VM down completely and power it on again. Restarting it isn't enough, whether from inside CML or from VMware. VMware recreates these device files when its services start, so the fix resets when your machine reboots. Reapply it then, or make it persistent.

If `host` booted before the fix, its cloud-init failed too (see below).

Bridging a VM over Wi-Fi usually doesn't work at all. Use NAT mode and work from `host` instead.

**`host`: `cloud-init status` ends in `status: error`**

Usually `host` had no network on its first boot, so it couldn't install its packages. `/var/log/cloud-init-output.log` shows the failing step. Fix the network first, then re-run cloud-init from `host`'s console:

```bash
sed -i '/source ~\/venv\/bin\/activate/d' ~/.bashrc
sudo cloud-init clean --logs --reboot
```

The `sed` removes the venv line the failed run added to `~/.bashrc`, because cloud-init adds it again. `host` reboots and installs its packages, which takes several minutes.

**Device config is gone after stopping the lab**

The config wasn't saved. The skill runs `write memory`. If you change the config by hand, save it the same way.

**SSH: "no matching key exchange method found" (OpenSSH) or "Incompatible ssh peer (no acceptable kex algorithm)" (Paramiko, Netmiko)**

IOSv and IOSvL2 run IOS 15.x, which only offers SHA-1 key exchange and `ssh-rsa` host keys. Modern clients disable these algorithms or have removed them entirely.

- **OpenSSH:** enable them per connection:

  ```bash
  ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa admin@<device-ip>
  ```

  You can also put these options in `~/.ssh/config` for the lab's IPs.
- **Paramiko:** version 5.x removed these algorithms, so no setting brings them back. Use Paramiko 4.x, which `host`'s virtualenv already has. Netmiko uses Paramiko for its connections, so the same applies.
