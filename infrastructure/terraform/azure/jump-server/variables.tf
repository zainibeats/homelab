variable "subscription_id" {
  type        = string
  description = "Azure subscription ID used by the provider."
}

variable "azure_environment" {
  type        = string
  description = "Azure cloud environment used by the provider."
  default     = "public"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "service_name" {
  type        = string
  description = "Short name used to derive Azure resource names."
  default     = "ubuntu-test-vm"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.service_name))
    error_message = "service_name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the deployment."
  default     = "canadacentral"
}

variable "resource_group_name" {
  type        = string
  description = "Optional resource group name. Defaults to <service_name>-<environment>-rg."
  default     = null
}

variable "vm_resource_group_name" {
  type        = string
  description = "Optional VM resource group name override for imported resources with casing differences. Defaults to resource_group_name."
  default     = null
}

variable "virtual_network_name" {
  type        = string
  description = "Optional virtual network name. Defaults to <service_name>-<environment>-vnet."
  default     = null
}

variable "network_security_group_name" {
  type        = string
  description = "Optional network security group name. Defaults to <service_name>-<environment>-nsg."
  default     = null
}

variable "network_interface_name" {
  type        = string
  description = "Optional network interface name. Defaults to <service_name>-<environment>-nic."
  default     = null
}

variable "public_ip_name" {
  type        = string
  description = "Optional public IP name. Defaults to <service_name>-<environment>-pip."
  default     = null
}

variable "ssh_key_name" {
  type        = string
  description = "Optional Azure SSH public key resource name. Defaults to <service_name>-<environment>-ssh-key."
  default     = null
}

variable "admin_username" {
  type        = string
  description = "Admin username configured on the Linux VM."
  default     = "azureuser"
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key used for the Azure SSH key resource and new VM admin logins."
  default     = "~/.ssh/azure.pub"
}

variable "private_key_path" {
  type        = string
  description = "Path to the SSH private key used for the example SSH command output."
  default     = "~/.ssh/azure"
}

variable "vm_name" {
  type        = string
  description = "Optional Linux VM name. Defaults to <service_name>-<environment>-vm."
  default     = null
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
  default     = "Standard_B2ats_v2"
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "Storage account type for the OS disk."
  default     = "Premium_LRS"
}

variable "os_disk_caching" {
  type        = string
  description = "Caching mode for the OS disk."
  default     = "ReadWrite"
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Azure Marketplace image used for the Linux VM."
  default = {
    publisher = "canonical"
    offer     = "ubuntu-22_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

variable "secure_boot_enabled" {
  type        = bool
  description = "Whether secure boot is enabled on the VM."
  default     = true
}

variable "vtpm_enabled" {
  type        = bool
  description = "Whether vTPM is enabled on the VM."
  default     = true
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address spaces for the virtual network."
  default     = ["10.1.0.0/16"]
}

variable "default_subnet_cidr" {
  type        = string
  description = "CIDR block for the default subnet."
  default     = "10.1.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet."
  default     = "10.1.2.0/24"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet."
  default     = "Private"
}

variable "ssh_security_rule_name" {
  type        = string
  description = "Name of the inbound SSH security rule."
  default     = "azureuser"
}

variable "ssh_security_rule_description" {
  type        = string
  description = "Description of the inbound SSH security rule."
  default     = "Allow SSH from VPN iP"
}

variable "trusted_ipv4_cidrs" {
  type        = list(string)
  description = "Single trusted IPv4 address allowed to SSH to the VM, expressed as a /32 CIDR."

  validation {
    condition = length(var.trusted_ipv4_cidrs) == 1 && alltrue([
      for cidr_block in var.trusted_ipv4_cidrs :
      can(cidrnetmask(cidr_block)) &&
      endswith(cidr_block, "/32")
    ])
    error_message = "Address must be a single-item list in CIDR notation and must end in /32 (e.g. ['8.8.8.8/32'])."
  }
}

variable "enable_aad_ssh_login" {
  type        = bool
  description = "Whether to install the Azure AD SSH Login extension."
  default     = true
}

variable "enable_vm_access" {
  type        = bool
  description = "Whether to install the VMAccessForLinux recovery extension. Enable only with an explicit recovery configuration."
  default     = false
}

variable "enable_azure_monitor_agent" {
  type        = bool
  description = "Whether to install the Azure Monitor Agent extension."
  default     = false
}

variable "enable_vm_insights_rule" {
  type        = bool
  description = "Whether to create a VM Insights data collection rule."
  default     = false
}

variable "data_collection_rule_name" {
  type        = string
  description = "Optional VM Insights data collection rule name. Defaults to MSVMI-<location>-<service_name>."
  default     = null
}

variable "data_collection_rule_resource_group_name" {
  type        = string
  description = "Optional resource group name for the VM Insights data collection rule. Defaults to resource_group_name."
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  type        = string
  description = "Existing Log Analytics workspace resource ID for VM Insights. Required when enable_vm_insights_rule is true."
  default     = null
}
