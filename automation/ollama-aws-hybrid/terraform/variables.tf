variable "region" {
  type        = string
  description = "AWS region for the deployment"
  default     = "us-west-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile used by the provider"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "availability_zone_id" {
  description = "Availability zone ID for the EC2 instance"
  type        = string
}

variable "trusted_ipv4_cidrs" {
  type        = list(string)
  description = "Trusted IPv4 addresses allowed through the security group, expressed as /32 CIDRs"

  validation {
    condition = alltrue([
      for cidr_block in var.trusted_ipv4_cidrs :
      can(cidrnetmask(cidr_block)) &&
      endswith(cidr_block, "/32")
    ])
    error_message = "Address must be a list of strings in CIDR notation and must end in /32 (e.g. ['8.8.8.8/32'])"
  }
}

variable "ssh_key_name" {
  description = "Name assigned to the EC2 SSH key pair"
  type        = string
  default     = "open-webui-key"
}

variable "public_key_path" {
  description = "Public key path"
  type        = string
  default     = "~/.ssh/open-webui-key.pub"
}

variable "private_key_path" {
  description = "Private key path"
  type        = string
  default     = "~/.ssh/open-webui-key"
}

variable "ssh_username" {
  description = "Username used to connect to the EC2 instance over SSH"
  type        = string
  default     = "ubuntu"
}
