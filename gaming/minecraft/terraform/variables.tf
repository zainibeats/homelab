variable "compartment_id" {
  type        = string
  description = "Full OCI compartment OCID where the Minecraft resources will be created."
}

variable "vnic_name" {
  type        = string
  description = "Display name of virtual NIC"
  default     = "minecraft-vnic"
}

variable "instance_name" {
  type        = string
  description = "Display name of the instance"
  default     = "minecraft-01"
}

variable "availability_domain" {
  type        = string
  description = "Availability domain for the instance"
  default     = "ahrg:US-SANJOSE-1-AD-1"
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to assign a public IPv4 address to the instance VNIC."
  default     = false
}

variable "ssh_authorized_keys" {
  type        = string
  description = "Public SSH key contents to add to the instance metadata."
}

variable "memory_in_gbs" {
  type        = number
  description = "Instance memory in gb"
  default     = 24
}

variable "ocpus" {
  type        = number
  description = "Number of ocpus"
  default     = 4
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Boot volume size in Gigabytes"
  default     = 50
}

variable "boot_volume_vpus_per_gb" {
  type        = number
  description = "Boot volume vpus per Gigabyte"
  default     = 10
}

variable "image_id" {
  type        = string
  description = "Full OCI image OCID to use for the instance boot volume."
  default     = "ocid1.image.oc1.us-sanjose-1.aaaaaaaann6xbmbuudmjvhnuuwuellabpu5cdzgaoz3wsendrluoqw6sbkqq"
}

variable "vcn_cidr" {
  type        = string
  description = "Virtual Cloud Network CIDR block"
  default     = "10.0.0.0/16"
}

variable "vcn_display_name" {
  type        = string
  description = "Display name for VCN"
  default     = "minecraft-vcn"
}

variable "vcn_dns_label" {
  type        = string
  description = "DNS label for the VCN"
  default     = "minecraftvcn"
}

variable "subnet_dns_label" {
  type        = string
  description = "DNS label for the public subnet"
  default     = "mcsubnet"
}

variable "public_subnet_name" {
  type        = string
  description = "Display name for public subnet"
  default     = "minecraft-public-subnet"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
  default     = "10.0.0.0/24"
}

variable "internet_gateway_name" {
  type        = string
  description = "Display name for Internet Gateway"
  default     = "Internet Gateway minecraft-vcn"
}

variable "shape" {
  type        = string
  description = "Default shape for the instance"
  default     = "VM.Standard.A1.Flex"
}
