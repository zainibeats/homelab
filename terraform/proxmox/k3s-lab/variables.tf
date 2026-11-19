variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox VE API endpoint, e.g. https://pve.example.lan:8006/."
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token in the form user@realm!tokenid=secret."
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification for self-signed Proxmox certificates."
  default     = true
}

variable "node_name" {
  type        = string
  description = "Proxmox node that hosts the lab VMs."
}

variable "template_vm_id" {
  type        = number
  description = "VM ID of the cloud-init ready Debian 13 (generic image) template to clone."
}

variable "disk_interface" {
  type        = string
  description = "Boot disk interface. Must match the template's disk (e.g. scsi0 or virtio0)."
  default     = "scsi0"
}

variable "vm_datastore_id" {
  type        = string
  description = "Datastore for VM disks and cloud-init drives."
  default     = "local-lvm"
}

variable "network_bridge" {
  type        = string
  description = "Network bridge for the VM NICs."
  default     = "vmbr0"
}

variable "vlan_id" {
  type        = number
  description = "VLAN tag for the VM NICs. Leave null if the bridge is already on the homelab VLAN."
  default     = null
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 default gateway."
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers configured via cloud-init."
}

variable "admin_username" {
  type        = string
  description = "User created by cloud-init; Ansible connects as this user."
  default     = "debian"
}

variable "public_key_path" {
  type        = string
  description = "SSH public key injected via cloud-init."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "qemu_agent_enabled" {
  type        = bool
  description = "Enable the QEMU guest agent. Set true only if the template has qemu-guest-agent installed or after the Ansible base playbook has installed it, otherwise apply waits for the agent until it times out."
  default     = false
}

variable "start_on_boot" {
  type        = bool
  description = "Start the lab VMs when the Proxmox host boots."
  default     = false
}

variable "nodes" {
  description = "Lab cluster nodes, keyed by VM name (also the hostname)."
  type = map(object({
    vm_id     = number
    role      = string
    ipv4_cidr = string
    cores     = number
    memory_mb = number
    disk_gb   = number
  }))

  validation {
    condition     = alltrue([for n in values(var.nodes) : contains(["server", "agent"], n.role)])
    error_message = "Each node's role must be \"server\" or \"agent\"."
  }

  validation {
    condition     = length([for n in values(var.nodes) : n if n.role == "server"]) % 2 == 1
    error_message = "Use an odd number of server nodes (1, 3, 5) for embedded etcd."
  }

  validation {
    condition     = alltrue([for name in keys(var.nodes) : can(regex("^[a-z][a-z0-9-]*$", name))])
    error_message = "Node names must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = alltrue([for n in values(var.nodes) : can(cidrnetmask(n.ipv4_cidr))])
    error_message = "ipv4_cidr must be in CIDR notation, e.g. 172.20.50.211/24."
  }
}
