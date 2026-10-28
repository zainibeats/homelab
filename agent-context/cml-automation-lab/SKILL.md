---
name: cml-automation-lab
description: "Build a small Cisco Modeling Labs (CML-Free) lab for practicing network automation: one to four Cisco IOS devices reachable over SSH, plus an Ubuntu automation box with Python (Netmiko, Paramiko) and Ansible pre-installed. Use when the user asks to build, create or set up a CML automation or practice lab. Requires the CML MCP server with pyATS support."
---

# CML Automation Lab

Build a lab the user can practice network automation against. The lab is the deliverable: Cisco devices reachable over SSH and an automation box ready to use. Do not write automation scripts or playbooks for the user unless they ask; writing those is the exercise.

## Rules

- **Node limit:** CML-Free runs at most 5 nodes at once. The Unmanaged Switch and External Connector don't count, but the Ubuntu `host` does, so the lab has at most 4 Cisco devices.
- **Keep it simple:** build only what this skill describes. No extra nodes, protocols or tooling.
- **Stop and ask** if a tool call fails or something is ambiguous. Report the exact error. Don't work around failures on your own.
- **Existing labs:** never delete, wipe or overwrite a lab without asking.
- **Password:** never repeat the admin password in chat, plans or summaries. Call it "the password from `.env`".

## 1. Preflight

1. Check that the CML MCP server's tools are available. If they aren't, stop and point the user to the README's Setup section.
2. Check CML health and licensing. Note the node limit the license reports.
3. List the node definitions. Confirm `ubuntu`, `unmanaged_switch` and `external_connector` exist, and note which of these Cisco types have an image: `iosvl2`, `iosv`, `ioll2-xe`, `iol-xe`.
4. List the existing labs so you can catch a title clash in step 2.

## 2. Gather inputs

Ask in one message, showing the defaults:

- **Lab title:** default `automation-practice`. If a lab with that title exists, ask whether to pick another title or replace it.
- **Number of Cisco devices:** 1 to 4, default 1.
- **Type of each device:** default `iosvl2`. Offer only the types from step 1 that have an image.
- **External Connector mode:**
  - **Bridge** (default): nodes join the user's LAN and are reachable from their machine.
  - **NAT**: nodes are reachable only from inside CML, so the user works from `host`. Suggest it when the CML VM can't bridge, for example over Wi-Fi.

For the admin password, read `LAB_ADMIN_PASSWORD` from `.env` in the current working directory, then from `.env` next to this file. Ask only if neither has it.

Then show the planned topology, with node names, types and connector mode, and wait for a go-ahead.

## 3. Build the lab

Every node connects to one Unmanaged Switch, so they all share one network segment:

```
ext-conn-0 ── unmanaged-switch-0 ─┬─ sw1 / r1 (first physical interface)
                                  ├─ ... (one link per Cisco device)
                                  └─ host (ens2)
```

- **Names:** switches (`iosvl2`, `ioll2-xe`) are `sw1`, `sw2` and so on; routers (`iosv`, `iol-xe`) are `r1`, `r2` and so on. The Ubuntu node is `host`.
- **External Connector:** set its configuration to `System Bridge` for bridge mode or `NAT` for NAT mode.
- **Cisco devices:** no startup configuration. You configure them over the console in step 5.
- **`host`:** use this cloud-init `user-data`, plus a `network-config` that enables DHCP on `ens2`:

  ```yaml
  #cloud-config
  hostname: host
  manage_etc_hosts: true
  system_info:
    default_user:
      name: cisco
  password: cisco
  chpasswd: { expire: false }
  ssh_pwauth: true
  package_update: true
  packages:
    - python3-venv
  runcmd:
    - sudo -u cisco python3 -m venv /home/cisco/venv
    - sudo -u cisco /home/cisco/venv/bin/pip install --quiet netmiko "paramiko>=4,<5" ansible
    - echo 'source ~/venv/bin/activate' >> /home/cisco/.bashrc
  ```

  `cisco`/`cisco` matches the MCP server's default console login, so the server can log into `host` without extra configuration. Paramiko is pinned below 5 because 5.x dropped the SHA-1 key exchange that IOS 15.x devices (IOSv, IOSvL2) need. The `ansible` package includes the `cisco.ios` collection.

Create the whole topology in one call if the server supports it, then list the nodes and links to confirm the wiring.

## 4. Start the lab

Start the lab and wait until every node has booted.

## 5. Configure the Cisco devices

Send these over each device's console in configuration mode. The MCP tool enters and leaves config mode itself, so leave out `configure terminal` and `end`.

```
hostname <name>
ip domain-name lab.local
username admin privilege 15 secret <password from .env>
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
```

Then configure the management interface:

- **Switches:**

  ```
  interface Vlan1
   ip address dhcp
   no shutdown
  ```

- **Routers:** use the interface that's linked to the Unmanaged Switch (`GigabitEthernet0/0` on IOSv, `Ethernet0/0` on IOL-XE):

  ```
  interface <that interface>
   ip address dhcp
   no shutdown
  ```

Finally, run `write memory` in exec mode, so the config survives a lab stop and start.

If a device already has RSA keys (for example on a re-run), skip `crypto key generate`, because it asks for confirmation.

## 6. Verify

On each Cisco device:

- `show ip interface brief`: the management interface has a DHCP address. DHCP can take up to a minute, so retry before calling it a failure.
- `show ip ssh`: shows `SSH Enabled - version 2.0`.

On `host`:

- `cloud-init status --wait`: must end in `status: done`. Installing the packages takes several minutes. On an error, show the last lines of `/var/log/cloud-init-output.log` and stop.
- `ip -4 -br addr show ens2`: has an address.
- `ping -c 3 <device IP>` for each device.
- `source ~/venv/bin/activate && python -c "import netmiko, paramiko; print(paramiko.__version__)" && ansible --version | head -1`
- For each device, check that SSH negotiates. This stops before the password prompt, so `Permission denied (publickey,keyboard-interactive,password).` means success:

  ```
  ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 \
      -o KexAlgorithms=+diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-rsa admin@<device IP> exit
  ```

**Bridge-mode failure pattern:** a device gets a DHCP address but can't ping its gateway, or `host` never gets an address. That usually means the hypervisor drops unicast frames addressed to the lab nodes' MAC addresses. Stop and point the user to the README's Troubleshooting section. Don't switch modes without asking.

## 7. Report

End with:

- the lab title and ID
- each node's name, type and IP address
- credentials: devices `admin` with the password from `.env`; `host` `cisco`/`cisco`
- how to reach the devices:
  - **Bridge mode:** SSH from the user's machine. IOSv and IOSvL2 need the legacy `-o` options shown in step 6 with modern OpenSSH.
  - **NAT mode:** open `host`'s console in the CML web UI and work from there.
- how to start and stop the lab: the CML web UI, or ask the agent. Stopping keeps the saved config; wiping erases it.
- a note that the IP addresses come from DHCP and can change after a restart
