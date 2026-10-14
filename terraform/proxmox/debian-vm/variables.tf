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
  description = "Proxmox node that hosts the template and the new VM."
}

variable "template_vm_id" {
  type        = number
  description = "VM ID of the cloud-init ready Debian template to clone."
}

variable "vm_name" {
  type        = string
  description = "Name of the new VM."
  default     = "debian-vm"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.vm_name))
    error_message = "vm_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vm_id" {
  type        = number
  description = "Optional VM ID for the new VM. Defaults to the next free ID."
}

variable "cpu_cores" {
  type        = number
  description = "Number of vCPU cores."
}

variable "memory_mb" {
  type        = number
  description = "Dedicated memory in MiB."
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GiB. Must be >= the template disk size."
}

variable "datastore_id" {
  type        = string
  description = "Datastore for the VM disk and cloud-init drive."
  default     = "local-lvm"
}

variable "network_bridge" {
  type        = string
  description = "Network bridge for the VM NIC."
  default     = "vmbr0"
}

variable "ipv4_cidr" {
  type        = string
  description = "Static IPv4 address in CIDR notation."

  validation {
    condition     = can(cidrnetmask(var.ipv4_cidr))
    error_message = "ipv4_cidr must be in CIDR notation, e.g. 172.23.51.107/24."
  }
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
  description = "User created by cloud-init."
  default     = "debian"
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key injected via cloud-init."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_key_path" {
  type        = string
  description = "Path to the SSH private key used for the example SSH command output."
  default     = "~/.ssh/id_ed25519"
}

variable "disk_interface" {
  type        = string
  description = "Boot disk interface. Must match the template's disk (e.g. scsi0 or virtio0)."
  default     = "scsi0"
}

variable "qemu_agent_enabled" {
  type        = bool
  description = "Enable the QEMU guest agent. Only set true if qemu-guest-agent is installed in the template."
  default     = false
}
