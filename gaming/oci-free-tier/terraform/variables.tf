variable "compartment_id" {
  type        = string
  description = "Full OCI compartment OCID where the game server resources will be created."
}

variable "service_name" {
  type        = string
  description = "Short name for the game server, used to derive OCI display names."
  default     = "minecraft"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.service_name))
    error_message = "service_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vnic_name" {
  type        = string
  description = "Optional display name of virtual NIC. Defaults to <service_name>-vnic."
  default     = null
}

variable "instance_name" {
  type        = string
  description = "Optional display name of the instance. Defaults to <service_name>-01."
  default     = null
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
  description = "Optional display name for VCN. Defaults to <service_name>-vcn."
  default     = null
}

variable "vcn_dns_label" {
  type        = string
  description = "Optional DNS label for the VCN. Defaults to service_name with hyphens removed plus vcn."
  default     = null
}

variable "subnet_dns_label" {
  type        = string
  description = "Optional DNS label for the public subnet. Defaults to service_name with hyphens removed plus subnet."
  default     = null
}

variable "public_subnet_name" {
  type        = string
  description = "Optional display name for public subnet. Defaults to <service_name>-public-subnet."
  default     = null
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
  default     = "10.0.0.0/24"
}

variable "internet_gateway_name" {
  type        = string
  description = "Optional display name for Internet Gateway. Defaults to Internet Gateway <service_name>-vcn."
  default     = null
}

variable "shape" {
  type        = string
  description = "Default shape for the instance"
  default     = "VM.Standard.A1.Flex"
}
