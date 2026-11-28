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
  description = "Proxmox node that holds the GPU."
}

variable "vm_name" {
  type        = string
  description = "Name of the new VM."
  default     = "ai-box"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.vm_name))
    error_message = "vm_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vm_id" {
  type        = number
  description = "VM ID for the new VM."
}

variable "cloud_image_url" {
  type        = string
  description = "Debian cloud image (qcow2) the boot disk is imported from."
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "cloud_image_file_name" {
  type        = string
  description = "File name for the downloaded cloud image on the image datastore."
  default     = "debian-13-genericcloud-amd64.qcow2"
}

variable "image_datastore_id" {
  type        = string
  description = "Directory datastore with the 'import' content type, used for the cloud image."
  default     = "local"
}

variable "cpu_cores" {
  type        = number
  description = "Number of vCPU cores."
}

variable "memory_mb" {
  type        = number
  description = "Dedicated memory in MiB."
}

variable "datastore_id" {
  type        = string
  description = "Datastore for the boot disk, EFI disk, and cloud-init drive."
  default     = "local-lvm"
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GiB."
}

variable "models_datastore_id" {
  type        = string
  description = "Datastore for the models disk."
}

variable "models_disk_size_gb" {
  type        = number
  description = "Models disk size in GiB."
}

variable "models_disk_backup" {
  type        = bool
  description = "Include the models disk in vzdump backups."
  default     = false
}

variable "gpu_mapping" {
  type        = string
  description = "Name of the Proxmox PCI resource mapping for the GPU."
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
    error_message = "ipv4_cidr must be in CIDR notation, e.g. 172.20.50.140/24."
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

variable "qemu_agent_enabled" {
  type        = bool
  description = "Enable the QEMU guest agent. The Debian cloud image does not ship it; only enable after installing qemu-guest-agent."
  default     = false
}
